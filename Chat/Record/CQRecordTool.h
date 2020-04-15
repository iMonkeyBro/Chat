//
//  CQRecordTool.h
//  Chat
//
//  Created by 刘超群 on 2020/2/15.
//  Copyright © 2020 chaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CQRecorderDelegate <NSObject>
@optional
/**
 *  准备中
 */
- (void)recorderPrepare;

/**
 *  录音中
 */
- (void)recorderRecording;

/**
 *  录音失败
 */
- (void)recorderFailed:(NSString *)failedMessage;

/**
 *  播放失败
 */
- (void)playerFailer:(NSString *)failedMessage;

/**
 *  播放文件不存在
 */
- (void)playerFileInexistence;

/**
 *  在声音播放完毕时调用。如果播放器因中断而停止，则不调用此方法。
 */
- (void)playerDidFinish;

@end

@interface CQRecordTool : NSObject

+ (instancetype)shareInstance;

@property (nonatomic,weak) id<CQRecorderDelegate> delegate;  ///< 代理

@property (nonatomic,assign, readonly) BOOL isRecording;  ///< 是否在录音

/**
 *  开始录音
 *  @param Record 存放的路径，如果传nil ，则默认在沙盒document/Record 下，文件名为时间命名.wav
 */
- (void)beginRecordWithRecordPath:(nullable NSString *)Record;

/**
 *  结束录音
 *  @return 录音时长和录音路径,firstObject为录音时长精确到0.1,如果开始录音设置路径则不反回路径,未设置lastObject为默认路径字符串
 */
- (NSArray *)endRecord;

/**
 *  暂停录音
 */
- (void)pauseRecord;

/**
 *  继续录音
 */
- (void)continueRecord;

/**
 *  删除录音
 */
- (void)deleteRecord;

/**
 *  返回分贝值
 */
- (float)levels;

/**
 *  wav转MP3
 *  @param wavFilePath wav文件路径 不能为空，否则方法不做任何执行
 *  @param savePath 需要保存的MP3路径 传nil则直接在wavFilePath内生成MP3文件
 *  @param isDelete 是否删除原wav文件
 */
- (void)convertWavToMp3:(nonnull NSString *)wavFilePath withSavePath:(nullable NSString *)savePath isDeleteSourchFile:(BOOL)isDelete;

/**
 播放录音文件
 *  @param path 录音文件
 */
- (void)playRecordWithPath:(NSString *)path;

/**
 *  暂停播放
 */
- (void)pausePlay;

/**
 *  继续播放
 */
- (void)continuePlay;


@end

