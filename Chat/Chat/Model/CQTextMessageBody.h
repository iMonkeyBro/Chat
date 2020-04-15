//
//  CQTextMessageBody.h
//  Chat
//
//  Created by 刘超群 on 2020/2/15.
//  Copyright © 2020 chaoqun. All rights reserved.
//

#import "CQMessageBody.h"

NS_ASSUME_NONNULL_BEGIN

@interface CQTextMessageBody : CQMessageBody

/**
 *  文本内容
 */
@property (nonatomic, copy) NSString *text;

@end

NS_ASSUME_NONNULL_END
