//
//  CQChatBoxView.m
//  Chat
//
//  Created by 刘超群 on 2020/4/15.
//  Copyright © 2020 chaoqun. All rights reserved.
//

#import "CQChatBoxView.h"
#import "CQChatBoxMoreView.h"// 更多视图
#import "CQChatBoxFaceView.h"// 表情视图

#define faceHeight 200 //表情视图高度
#define moreHeight 220 //更多视图高度
#define normalHeight 50 //下方标准高度
#define textNormalHeight 34 //输入框标准高度
#define textMargin 16 //输入框上下间隙
@interface CQChatBoxView ()<UITextFieldDelegate,UITextViewDelegate>
@property (nonatomic, strong) UIView *topLine;  ///< 顶部分割线
@property (nonatomic, strong) UIButton *voiceButton;  ///< 声音按钮
@property (nonatomic, strong) UIButton *talkButton;  ///< 按住说话按钮
@property (nonatomic, strong) UIButton *faceButton;  ///< 表情按钮
@property (nonatomic, strong) UIButton *moreButton;  ///< 更多按钮
@property (nonatomic, strong) UIView *centerLine;  ///< 中间的线
@property (nonatomic, strong) CQChatBoxMoreView *moreView;  ///< 更多视图
@property (nonatomic, strong) CQChatBoxFaceView *faceView;  ///< 表情视图

@end

@implementation CQChatBoxView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.topLine];
        [self addSubview:self.voiceButton];
        [self addSubview:self.textView];
        [self addSubview:self.faceButton];
        [self addSubview:self.talkButton];
        [self addSubview:self.moreButton];
        [self addSubview:self.centerLine];
        [self addSubview:self.moreView];
        [self addSubview:self.faceView];
        [self addLayout];
    }
    return self;
}

#pragma mark - event handle
//更多按钮事件
- (void)moreButtonAction:(UIButton *)button{
    // 其他两个按键复位 并隐藏语音按钮
    [self.voiceButton setImage:[UIImage imageNamed:@"chatVoice"] forState:UIControlStateNormal];
    [self.voiceButton setImage:[UIImage imageNamed:@"chatVoiceHighlighted"] forState:UIControlStateHighlighted];
    [self.faceButton setImage:[UIImage imageNamed:@"chatFace"] forState:UIControlStateNormal];
    [self.faceButton setImage:[UIImage imageNamed:@"chatFaceHighlighted"] forState:UIControlStateHighlighted];
    self.talkButton.hidden = YES;
    // 输入框是第一响应的时候，点更多按钮，必须是呼出更多列表
    if ([self.textView isFirstResponder]) {
        button.selected = NO;
    }
    if (!button.selected) {
        // 呼出更多列表
        self.centerLine.hidden = NO;
        self.talkButton.hidden = YES;
         CGFloat textViewHeight = [self heightForTextViewWithText:self.textView.text  isHighLimit:YES];
        [self updateViewHeightWithView1:_moreView height1:moreHeight view2:_faceView height2:0 selfHeight:textMargin+textViewHeight+moreHeight];
        [self.textView resignFirstResponder];
    }else{
        // 变为键盘，此时语音和表情按钮如果是键盘标识，需要修改
        [self.textView becomeFirstResponder];
        [self.faceButton setImage:[UIImage imageNamed:@"chatFace"] forState:UIControlStateNormal];
        [self.faceButton setImage:[UIImage imageNamed:@"chatFaceHighlighted"] forState:UIControlStateHighlighted];
        [self.voiceButton setImage:[UIImage imageNamed:@"chatVoice"] forState:UIControlStateNormal];
        [self.voiceButton setImage:[UIImage imageNamed:@"chatVoiceHighlighted"] forState:UIControlStateHighlighted];
        self.centerLine.hidden = YES;
        CGFloat textViewHeight = [self heightForTextViewWithText:self.textView.text  isHighLimit:YES];
        [self updateViewHeightWithView1:_moreView height1:0 view2:_faceView height2:0 selfHeight:textViewHeight+textMargin];
    }
    button.selected = !button.selected;
}

/// 刷新textView 以及底部的高度，最多不大于90，
- (void)updateTextViewHeight:(CGFloat)height{
    [_textView updateConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(height);
    }];
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxView:didChangeChatBoxHeight:)]) {
        // 总高度加16，例：单行 textView 34 总高度50
        [_delegate chatBoxView:self didChangeChatBoxHeight:height+textMargin];
    }
}

/// 根据文textView的文字 刷新textView 以及底部的高度
- (void)updateTextViewHeightWithText:(NSString *)text{
    CGFloat height = [self heightForTextViewWithText:text  isHighLimit:YES];
    [self updateTextViewHeight:height];
}

/// 刷新textView 以及底部的高度，最多不大于90，并且加上一个其他视图的高度，例如表情视图等
- (void)updateTextViewHeight:(CGFloat)height otherViewHeight:(CGFloat)otherViewHeight{
    [_textView updateConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(height);
    }];
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxView:didChangeChatBoxHeight:)]) {
        [_delegate chatBoxView:self didChangeChatBoxHeight:height+textMargin+otherViewHeight];
    }
}

/// 根据文textView的文字 刷新textView 以及底部的高度 ，并且加上一个其他视图的高度，例如表情视图等
- (void)updateTextViewHeightWithText:(NSString *)text otherViewHeight:(CGFloat)otherViewHeight{
    CGFloat height = [self heightForTextViewWithText:text  isHighLimit:YES];
    [self updateTextViewHeight:height otherViewHeight:otherViewHeight];
}

/// 修改更多视图 或 表情视图的约束，并代理回调修改整体高度
- (void)updateViewHeightWithView1:(UIView *)view1 height1:(CGFloat)height1 view2:(UIView *)view2 height2:(CGFloat)height2 selfHeight:(CGFloat)selfHeight{
    if (view1) {
        [view1 updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(height1);
        }];
        if (height1 == 0) {
            view1.hidden = YES;
        }else{
            view1.hidden = NO;
        }
    }
    if (view2) {
        [view2 updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(height2);
        }];
        if (height2 == 0) {
            view2.hidden = YES;
        }else{
            view2.hidden = NO;
        }
    }
    if (view1 || view2) {
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutIfNeeded];
        }];
    }
    if (selfHeight) {
        if (_delegate && [_delegate respondsToSelector:@selector(chatBoxView:didChangeChatBoxHeight:)]) {
            [_delegate chatBoxView:self didChangeChatBoxHeight:selfHeight];
        }
    }
}


#pragma mark - private methods
/**
 根据textView的文字，计算textView的高度
 @param text 文本
 @param isHeightLimit 是否限制高度
 */
- (CGFloat)heightForTextViewWithText:(NSString *)text isHighLimit:(BOOL)isHeightLimit{
    CGSize constraint = CGSizeMake(self.textView.contentSize.width-10 , CGFLOAT_MAX);
    CGRect size = [text boundingRectWithSize:constraint
                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]}
                                     context:nil];
    CGFloat textViewHeight = size.size.height + (17-0.900391);
    // 保持最多4行的高度
    if (isHeightLimit) {
        if (textViewHeight > 90) {
            return 87.701172;
        }else{
            return textViewHeight;
        }
    }else{
        return textViewHeight;
    }
}

#pragma mark - lazy load
- (CQChatBoxFaceView *)faceView{
    if (!_faceView) {
        _faceView = [[CQChatBoxFaceView alloc] init];
    }
    return _faceView;
}

- (CQChatBoxMoreView *)moreView{
    if (!_moreView) {
        _moreView = [[CQChatBoxMoreView alloc] init];
    }
    return _moreView;
}

- (UIView *)centerLine{
    if (!_centerLine) {
        _centerLine = [[UIView alloc] init];
        _centerLine.backgroundColor = RGB(221, 221, 221);
        _centerLine.hidden = YES;
    }
    return _centerLine;
}

- (UIButton *)moreButton{
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreButton setImage:[UIImage imageNamed:@"chatMore"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"chatMoreHighlighted"] forState:UIControlStateHighlighted];
        [_moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (UIButton *)faceButton{
    if (!_faceButton) {
        _faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_faceButton setImage:[UIImage imageNamed:@"chatFace"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"chatFaceHighlighted"] forState:UIControlStateHighlighted];
        [_faceButton addTarget:self action:@selector(faceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceButton;
}

- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-130, 34)];
        _textView.backgroundColor = RGB(245, 245, 245);
        CQLayerConfiguration(_textView, 3, 0.7, RGB(221, 221, 221));
        _textView.delegate = self;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.font = [UIFont systemFontOfSize:15];
    }
    return _textView;
}

- (UIButton *)talkButton{
    if (!_talkButton) {
        _talkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _talkButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_talkButton setBackgroundImage:[UIImage cq_ImageWithColor:RGB(245, 245, 245) andSize:CGSizeMake(1, 1)] forState:UIControlStateNormal];
        [_talkButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_talkButton setTitleColor:RGB(51, 51, 51) forState:UIControlStateNormal];
        [_talkButton setBackgroundImage:[UIImage cq_ImageWithColor:RGB(221, 221, 221) andSize:CGSizeMake(1, 1)] forState:UIControlStateHighlighted];
        [_talkButton setTitle:@"松开 结束" forState:UIControlStateHighlighted];
        [_talkButton addTarget:self action:@selector(startRecordingVoice) forControlEvents:UIControlEventTouchDown];
        [_talkButton addTarget:self action:@selector(sendVoice) forControlEvents:UIControlEventTouchUpInside];
        [_talkButton addTarget:self action:@selector(sendVoice) forControlEvents:UIControlEventTouchCancel];
        [_talkButton addTarget:self action:@selector(prepareCancelSendVoice) forControlEvents:UIControlEventTouchDragExit];
        [_talkButton addTarget:self action:@selector(cancelSendVoice) forControlEvents:UIControlEventTouchUpOutside];
        [_talkButton addObserver:self forKeyPath:@"titleLabel.text" options:NSKeyValueObservingOptionNew context:nil];
        CQLayerConfiguration(_talkButton, 3, 0.7, RGB(221, 221, 221));
        _talkButton.hidden = YES;
    }
    return _talkButton;
}

- (UIButton *)voiceButton{
    if (!_voiceButton) {
        _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_voiceButton setImage:[UIImage imageNamed:@"chatVoice"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"chatVoiceHighlighted"] forState:UIControlStateHighlighted];
        [_voiceButton addTarget:self action:@selector(voiceButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}

- (UIView *)topLine{
    if (!_topLine) {
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = RGB(221, 221, 221);
    }
    return _topLine;
}

#pragma mark - layout
- (void)addLayout{
    [_topLine makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.equalTo(1);
    }];
    
    [_voiceButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(15);
        make.size.equalTo(CGSizeMake(25, 25));
        make.bottom.equalTo(self.textView.mas_bottom).offset(-6);
    }];
    
    [_moreButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-10);
        make.size.equalTo(CGSizeMake(25, 25));
        make.bottom.equalTo(self.textView.mas_bottom).offset(-6);
    }];
    
    [_faceButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.moreButton.mas_left).offset(-10);
        make.size.equalTo(CGSizeMake(25, 25));
        make.bottom.equalTo(self.textView.mas_bottom).offset(-6);
    }];

    [_textView makeConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(34);
        make.left.equalTo(self.voiceButton.mas_right).offset(10);
        make.right.equalTo(self.faceButton.mas_left).offset(-10);
        make.top.equalTo(self.mas_top).offset(8);
    }];
    
    [_talkButton makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(34);
        make.left.right.equalTo(self.textView);
        make.top.equalTo(self.mas_top).offset(8);
    }];

    [_centerLine makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.equalTo(1);
        make.top.equalTo(self.textView.mas_bottom).offset(8);
    }];
    
    [_moreView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.centerLine.mas_bottom);
        make.height.equalTo(0);
    }];
    
    [_faceView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.centerLine.mas_bottom);
        make.height.equalTo(0);
    }];
}


@end
