//
//  CQVoiceMessageBody.h
//  Chat
//
//  Created by 刘超群 on 2020/2/15.
//  Copyright © 2020 chaoqun. All rights reserved.
//

#import "CQMessageBody.h"

@interface CQVoiceMessageBody : CQMessageBody

/**
 语音时长, 秒为单位
 */
@property (nonatomic, assign) CGFloat duration;

@property (nonatomic, strong) NSString *localPath;  ///< 语音文件本地路径

@end

