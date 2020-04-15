//
//  CQChatVoiceView.h
//  Chat
//
//  Created by 刘超群 on 2020/2/15.
//  Copyright © 2020 chaoqun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,VoiceState) {
    VoiceStateInRecording,
    VoiceStatePrepareCancelSend
    
};

@interface CQChatVoiceView : UIView

@property (nonatomic, assign) VoiceState voiceState;  ///< 当前的录音状态，录音中或者准备取消
@property (nonatomic, assign) NSUInteger volum;  ///< 音量，该参数要<=7

/**
 展示
 */
- (void)show;

/**
 退出
 */
- (void)exit;

@end


