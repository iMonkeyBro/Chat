//
//  CQChatViewController.m
//  Chat
//
//  Created by 刘超群 on 2020/2/15.
//  Copyright © 2020 chaoqun. All rights reserved.
//

#import "CQChatViewController.h"
#import "CQChatMessageTableView.h"// 消息列表
#import "CQChatBoxView.h"// 聊天输入盒子
#import "CQChatVoiceView.h"// 音频输入视图

@interface CQChatViewController ()<CQChatBoxViewDelegate>
@property (nonatomic, strong) UIBarButtonItem *delItem;  ///< 导航条右侧删除键
@property (nonatomic, strong) CQChatMessageTableView *messageView;  ///< 聊天视图
@property (nonatomic, strong) CQChatBoxView *chatBoxView;  ///< 底部输入视图
@property (nonatomic, strong) CQChatVoiceView *voiceView;  ///< 录音指示弹窗
@property (nonatomic, assign) CGFloat lastChatBoxViewHeight;  ///< 上一次boxView的高
@property (nonatomic, assign) CGPoint lastMessageViewContentOffSet;  ///< 上一次的offset
@end

@implementation CQChatViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    

}

#pragma mark - UI
- (void)initUI{
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"纸短情长";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
    [self.view addSubview:self.messageView];
    [self.view addSubview:self.chatBoxView];
    [self addLayout];
}

#pragma mark - event handle
- (void)cancelAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - VIPChatBoxViewDelegate
// 下方输入模块改变高度时
- (void)chatBoxView:(CQChatBoxView *)chatBoxView didChangeChatBoxHeight:(CGFloat)height{
    [self changeChatBoxHeight:height];
}

// 下方输入模块发送消息时
- (void)chatBoxView:(CQChatBoxView *)chatBoxView sendTextMessage:(NSString *)messageText{
    //[self sendTextMessage:messageText];
}

#pragma mark - private methods
// 改变下方输入框高度 备注：不要直接输入height调用此方法
- (void)changeChatBoxHeight:(CGFloat)height{
    self.lastMessageViewContentOffSet = self.messageView.contentOffset;
    [_chatBoxView updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(height);
    }];
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
    // 类似微信，直接调整到底部7
    [self.messageView scrollToBottom];
    self.lastChatBoxViewHeight = height;
}

#pragma mark - lazy load
- (CQChatVoiceView *)voiceView{
    if (!_voiceView) {
        _voiceView = [[CQChatVoiceView alloc] init];
    }
    return _voiceView;
}

- (CQChatBoxView *)chatBoxView{
    if (!_chatBoxView) {
        _chatBoxView = [[CQChatBoxView alloc] init];
        //_chatBoxView.delegate = self;
    }
    return _chatBoxView;
}

- (CQChatMessageTableView *)messageView{
    if (!_messageView) {
        _messageView = [[CQChatMessageTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        //_messageView.chatMessageDelegate = self;
    }
    return _messageView;
}

- (UIBarButtonItem *)delItem{
    if (!_delItem) {
        UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [delBtn setImage:[UIImage imageNamed:@"deleteIcon"] forState:UIControlStateNormal];
        [delBtn addTarget:self action:@selector(delAction) forControlEvents:UIControlEventTouchUpInside];
        [delBtn sizeToFit];
        _delItem = [[UIBarButtonItem alloc] initWithCustomView:delBtn];
    }
    return _delItem;
}

#pragma mark - layout
- (void)addLayout{

    [_messageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.chatBoxView.mas_top);
    }];
    
    [_chatBoxView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-[CQScreenTool fullScreenMarginBottom]);
        make.left.right.equalTo(self.view);
        make.height.equalTo(50);
    }];
    self.lastChatBoxViewHeight = 50;
}

@end
