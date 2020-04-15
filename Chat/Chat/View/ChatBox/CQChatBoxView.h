//
//  CQChatBoxView.h
//  Chat
//
//  Created by 刘超群 on 2020/4/15.
//  Copyright © 2020 chaoqun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CQChatBoxView;

@protocol CQChatBoxViewDelegate <NSObject>

@optional
/**
 改变高度时
 */
- (void)chatBoxView:(CQChatBoxView *)chatBoxView didChangeChatBoxHeight:(CGFloat)height;

/**
 发送消息
 @param messageText 消息模型
 */
- (void)chatBoxView:(CQChatBoxView *)chatBoxView sendTextMessage:(NSString *)messageText;

@end

@interface CQChatBoxView : UIView

@property (nonatomic, weak) id<CQChatBoxViewDelegate> delegate;  ///< 代理

@property (nonatomic, strong) UITextView *textView;  ///< 输入框

@end

NS_ASSUME_NONNULL_END
