//
//  CQMessageBody.h
//  Chat
//
//  Created by 刘超群 on 2020/2/15.
//  Copyright © 2020 chaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,CQMessageBodyType){
    CQMessageBodyTypeText   = 1,    /*! \~chinese 文本类型 \~english Text */
    CQMessageBodyTypeImage,         /*! \~chinese 图片类型 \~english Image */
    CQMessageBodyTypeVoice,         /*! \~chinese 语音类型 \~english Voice */
};

@interface CQMessageBody : NSObject

/**
 * 消息体类型 初始化时会自动赋值
 */
@property (nonatomic, assign) CQMessageBodyType type;

@end


