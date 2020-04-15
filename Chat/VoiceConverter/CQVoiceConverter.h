//
//  CQVoiceConverter.h
//  Chat
//
//  Created by 刘超群 on 2020/2/15.
//  Copyright © 2020 chaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 音频转换工具
 */

NS_ASSUME_NONNULL_BEGIN

@interface CQVoiceConverter : NSObject

/**
 是否是MP3文件
 @param filePath 文件位置
 @return YES/NO
 */
+ (BOOL)isMP3File:(NSString *)filePath;

/**
是否是AMR文件
@param filePath 文件位置
@return YES/NO
*/
+ (BOOL)isAMRFile:(NSString *)filePath;

/**
 AMR转WAV
 @param amrPath amr文件位置
 @param savePath 转换后wav文件存储位置
 @return YES/NO转换是否成功
 */
+ (BOOL)amrToWav:(NSString*)amrPath wavSavePath:(NSString*)savePath;

/**
WAV转AMR
@param wavPath wav文件位置
@param savePath 转换后amr文件存储位置
@return YES/NO转换是否成功
*/
+ (BOOL)wavToAmr:(NSString*)wavPath amrSavePath:(NSString*)savePath;

@end

NS_ASSUME_NONNULL_END
