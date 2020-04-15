//
//  CQRecordTool.m
//  Chat
//
//  Created by 刘超群 on 2020/2/15.
//  Copyright © 2020 chaoqun. All rights reserved.
//

#import "CQRecordTool.h"
#include "lame/lame.h"
#import "CQVoiceConverter.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#ifdef DEBUG
#define CQLog(s,...) NSLog(@"<%p %@ %s [%d]> %@",self,[[NSString stringWithFormat:@"%s",__FILE__] lastPathComponent],__FUNCTION__,__LINE__,[NSString stringWithFormat:(s), ##__VA_ARGS__]);
#else
#define CQLog(s,...)
#endif
#define documentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define ALPHA 0.02f                 // 音频振幅调解相对值 (越小振幅就越高)

@interface CQRecordTool ()<AVAudioPlayerDelegate>
@property (nonatomic,copy, readonly) NSString *recordPath;  ///< 录音保存路径
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;  ///< 录音对象
@property (nonatomic, strong) dispatch_source_t timer;  ///< 定时器
@property (nonatomic, assign) CGFloat recordTime;  ///< 录音时间
@property (nonatomic, strong) AVAudioPlayer *player;  ///< 播放器
@property (nonatomic,copy, readonly) NSString *playPath;  ///< 录音保存路径

@property (nonatomic, assign) BOOL isStartSensorNot;  ///< 是否打开了传感器通知

/*** 这两个bool在录音和传感器更改时相互控制 ，解决传感器没关掉或提前关的bug ***/
@property (nonatomic, assign) BOOL isStopPlay;  ///< 是否停止
@property (nonatomic, assign) BOOL isSensorClose;  ///< 传感器是否接近用户

@end

@implementation CQRecordTool

#pragma mark - 单例
static CQRecordTool *_shareInstance;
+ (instancetype)shareInstance{
    if(_shareInstance == nil){
        _shareInstance = [[CQRecordTool alloc] init];
        _shareInstance.recordTime = 0.0;
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [super allocWithZone:zone];
    });
    return _shareInstance;
}

#pragma mark - 初始化录音
- (BOOL)initAudioRecorder{
    // 0. 设置录音会话
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    // 1. 确定存储位置
    NSURL *pathUrl = [self getRecorderPath];
    // 2. 配置录音参数
    NSDictionary *recordSetting = [self getRecorderConfig];
    // 3.创建录音对象
    NSError *error = nil;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:pathUrl settings:recordSetting error:&error];
    _audioRecorder.meteringEnabled = YES;
    if (error) {
        NSLog(@"%@",error);
        return NO;
    }
    return YES;
}

#pragma mark - 配置录音
// 获取录音存放位置
- (NSURL *)getRecorderPath{
    if (self.recordPath) {
        return [NSURL URLWithString:self.recordPath];
    }else{
        NSString *path = [NSString stringWithFormat:@"%@/%@.wav",[self getPath],[self getCurrentTime:@"YYYYMMddHHmmss"]];
        return [NSURL URLWithString:path];
    }
}

// 获取录音参数配置
- (NSDictionary *)getRecorderConfig{
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
    // 设置编码格式  AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    
    // 设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:11025.0] forKey:AVSampleRateKey];
    
    // 线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    
    // 录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    
    // 录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
    NSDictionary *result = [NSDictionary dictionaryWithDictionary:recordSetting];
    return result;
}

#pragma mark - public methods
- (void)beginRecordWithRecordPath:(NSString *)recordPath{
    CQLog(@"录音地址是-%@",recordPath);
    _isRecording = YES;
    _recordPath = recordPath;
    //    NSLog(@"创建中...");
    if (self.delegate && [self.delegate respondsToSelector:@selector(recorderPrepare)]) {
        [self.delegate recorderPrepare];
    }
    if (![self initAudioRecorder]) { // 初始化录音机
        CQLog(@"录音机创建失败...");
        if (self.delegate && [self.delegate respondsToSelector:@selector(recorderFailed:)]) {
            [self.delegate recorderFailed:@"录音器创建失败"];
        }
        return;
    };
    //    NSLog(@"创建完成...");
    [self micPhonePermissions:^(BOOL ishave) {
        if (ishave) {
            [self startRecording];
        }else {
            [self showPermissionsAlert];
            //            NSLog(@"麦克风未开启权限");
        }
    }];
}

// 开始录音
- (void)startRecording{
    //    NSLog(@"startRecording...");
    if (!_isRecording){
        return;
    }
    //    NSLog(@"初始化...");
    if (![self.audioRecorder prepareToRecord]) {
        NSLog(@"初始化录音机失败");
        if (self.delegate && [self.delegate respondsToSelector:@selector(recorderFailed:)]) {
            [self.delegate recorderFailed:@"录音器初始化失败"];
        }
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(recorderRecording)]) {
        [self.delegate recorderRecording];
    }
    [self.audioRecorder record];
    
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
        self.recordTime += 0.1;
    });
    dispatch_resume(self.timer);
    
}

// 结束录音
- (NSArray *)endRecord{
    if (!_isRecording){
        return nil;
    }
    if (!self.audioRecorder) {
        return nil;
    }
    _isRecording = NO;
    [self.audioRecorder stop];

    if (self.timer) {
        dispatch_source_cancel(self.timer);
    }
    NSString *recordTime = [NSString stringWithFormat:@"%.1lf",self.recordTime];
    self.recordTime = 0.0;
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:recordTime];
    if (!self.recordPath) {
        [arr addObject:[self getRecorderPath]];
    }
    return arr;
}

// 暂停录音
- (void)pauseRecord{
    if (!_isRecording){
        return ;
    }
    _isRecording = NO;
    [self.audioRecorder pause];
    if (self.timer) {
        dispatch_source_cancel(self.timer);
    }
    
}

// 继续录音
- (void)continueRecord{
    if (_isRecording){
        return ;
    }
    _isRecording = YES;
    [self startRecording];
}

// 删除录音
- (void)deleteRecord{
    _isRecording = NO;
    [self.audioRecorder stop];
    [self.audioRecorder deleteRecording];
}

// 分贝值
- (float)levels{
    [self.audioRecorder updateMeters];
    double aveChannel = pow(10, (ALPHA * [self.audioRecorder averagePowerForChannel:0]));
    if (aveChannel <= 0.05f) aveChannel = 0.05f;
    if (aveChannel >= 1.0f) aveChannel = 1.0f;
    return aveChannel;
}

#pragma mark - wav 转 MP3
// wav转MP3
- (void)convertWavToMp3:(NSString*)wavFilePath withSavePath:(NSString*)savePath isDeleteSourchFile:(BOOL)isDelete{
    if (!wavFilePath) {
        return;
    }
    if (!savePath) {
        NSArray<NSString *> *wavArr = [wavFilePath componentsSeparatedByString:@"/"];
        NSString *wavFileStr = [wavArr lastObject];
        NSString *wavFileName = [wavFileStr substringToIndex:wavFileStr.length-3];
        NSString *mp3Name = [wavFileName stringByAppendingString:@"mp3"];
        NSString *path = [wavFilePath stringByDeletingLastPathComponent];
        savePath = [NSString stringWithFormat:@"%@/%@",path,mp3Name];
    }
    @try {
        int read, write;
        
        FILE *pcm = fopen([wavFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024,SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([savePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 44100);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            fwrite(mp3_buffer, write, 1, mp3);
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        NSLog(@"MP3生成成功:");
        if (isDelete) {
            [self deleteFile:wavFilePath];
        }
    }
}

#pragma mark - 播放录音
- (BOOL)initPlayer{
    if (![self isFileExit:self.playPath]) {
        CQLog(@"文件不存在");
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerFileInexistence)]) {
            [self.delegate playerFileInexistence];
        }
        return NO;
    }
    if ([CQVoiceConverter isAMRFile:self.playPath]) {
        CQLog(@"AMR文件，，转WAV再播放");
        // 这里没必要拼接wav后缀，因为如果你是wav，没后缀一样能播放，不是，加个后缀也播放不了
        // 所以直接相同地址替换即可，简单粗暴，完美解决
        [CQVoiceConverter amrToWav:self.playPath wavSavePath:self.playPath];
    }
    NSError *error = nil;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:self.playPath] error:&error];
    _player.delegate = self;
    if (error) {
        return NO;
    }else{
        return YES;
    }
}

// 播放录音文件
- (void)playRecordWithPath:(NSString *)path{
    _playPath = path;
    
    if (![self initPlayer]) {
        CQLog(@"播放器创建失败...%@",self.playPath);
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerFailer:)]) {
            [self.delegate playerFailer:@"播放器创建失败"];
        }
        return;
    }
    
    if (![self.player prepareToPlay]) {
        CQLog(@"初始化播放器失败-%@",self.playPath);
        if (self.delegate && [self.delegate respondsToSelector:@selector(recorderFailed:)]) {
            [self.delegate recorderFailed:@"初始化播放器失败"];
        }
        return;
    }
    [self startSensor];
    self.isStopPlay = NO;
    [self.player play];
}

// 暂停播放
- (void)pausePlay{
    self.isStopPlay = YES;
    if (!self.isSensorClose) {
        [self stopSensor];
    }
    [self.player pause];
}

// 继续播放
- (void)continuePlay{
    [self startSensor];
    self.isStopPlay = NO;
    [self.player play];
}

#pragma mark - AVAudioPlayerDelegate
// 在声音播放完毕时调用。如果播放器因中断而停止，则不调用此方法。
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    self.isStopPlay = YES;
    if (!self.isSensorClose) {
        [self stopSensor];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidFinish)]) {
        [self.delegate playerDidFinish];
    }
}

#pragma mark - 开关听筒红外感应
// 打开红外感应
- (void)startSensor{
    if (self.isStartSensorNot) {
        return;
    }
    self.isStartSensorNot = YES;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];//红外状态改变时发通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

// 停止红外感应
- (void)stopSensor{
    self.isStartSensorNot = NO;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

/*
 如果是贴近耳朵的状态，播完或暂停不关闭传感器通知，等传感器离开耳朵，再去关闭传感器通知
 如果不是贴近耳朵的状态，播完或暂停关闭传感器通知
 */
// 红外感应操作
-(void)sensorStateChange:(NSNotificationCenter *)notification{
    self.isSensorClose = YES;
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES){
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }else{
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        self.isSensorClose = NO;
        if (self.isStopPlay) {
            [self stopSensor];
        }
    }
}

#pragma mark - 权限判断
// 判断麦克风权限
- (void)micPhonePermissions:(void (^)(BOOL ishave))block{
    __block BOOL ret = NO;
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [avSession requestRecordPermission:^(BOOL available) {
            if (available) ret = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) block(ret);
            });
        }];
    }
}

- (void)showPermissionsAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法录音" message:@"请在“设置-隐私-麦克风”中允许访问麦克风" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 工具方法
// 系统时间
- (NSString *)getCurrentTime:(NSString*)formatter{
    NSDate *senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:formatter];
    NSString *locationString=[dateformatter stringFromDate:senddate];
    return locationString;
}

// 获取Record文件路径
- (NSString *)getPath{
    NSString * path=[NSString stringWithFormat:@"%@/Record",documentPath];
    if (![self isFileExit:path]) {
        [self createPath:path];
    }
    return path;
}

// 判断是否存在
- (BOOL)isFileExit:(NSString*)path{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

// 删除
- (void)deleteFile:(NSString*)path{
    if ([self isFileExit:path]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if (error) {
            CQLog(@"删除%@出错:%@",path,error.domain);
        }
    }
}

// 新建
- (void)createPath:(NSString*)path{
    if (![self isFileExit:path]) {
        NSFileManager * fileManager=[NSFileManager defaultManager];
        NSString * parentPath=[path stringByDeletingLastPathComponent];
        // 先判断path 的父目录是否存在
        if ([self isFileExit:parentPath]) {
            // 存在直接创建path
            NSError * error;
            [fileManager createDirectoryAtPath:path withIntermediateDirectories:path attributes:nil error:&error];
        }else{
            // 不存在 先创建父目录
            [self createPath:parentPath];
            // 再创建目录
            [self createPath:path];
        }
    }
}


@end
