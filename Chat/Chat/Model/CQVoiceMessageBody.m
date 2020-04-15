//
//  CQVoiceMessageBody.m
//  Chat
//
//  Created by 刘超群 on 2020/2/15.
//  Copyright © 2020 chaoqun. All rights reserved.
//

#import "CQVoiceMessageBody.h"

@implementation CQVoiceMessageBody

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = CQMessageBodyTypeVoice;
    }
    return self;
}

@end
