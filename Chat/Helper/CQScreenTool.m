//
//  CQScreenTool.m
//  Chat
//
//  Created by 刘超群 on 2020/4/15.
//  Copyright © 2020 chaoqun. All rights reserved.
//

#import "CQScreenTool.h"

@implementation CQScreenTool

+ (BOOL)isFullScreenIPadPro{
    if (@available(iOS 12.0, *)) {
        if ([UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom == 20) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

+ (BOOL)isIpadSeries{
    if ([UIScreen mainScreen].bounds.size.height/[UIScreen mainScreen].bounds.size.width < 1.5) {
        return YES;
    }else {
        return NO;
    }
}

+ (BOOL)isIPhoneXSeries{
    if (@available(iOS 11.0, *)) {
        if ([UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom == 34) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

+ (BOOL)isFullScreenDevice{
    if ([CQScreenTool isIPhoneXSeries]) {
        return YES;
    }else if ([CQScreenTool isFullScreenIPadPro]) {
        return YES;
    }else{
        return NO;
    }
    return NO;
}

+ (CGFloat)fullScreenMarginBottom{
    if ([CQScreenTool isIPhoneXSeries]) {
        return 34.0;
    }else if ([CQScreenTool isFullScreenIPadPro]) {
        return 20.0;
    }else{
        return 0;
    }
}

+ (CGFloat)fullScreenMarginTop{
    if ([CQScreenTool isIPhoneXSeries]) {
        return 24.0;
    }else if ([CQScreenTool isFullScreenIPadPro]) {
        return 0.0;
    }else{
        return 0.0;
    }
}

+ (CGFloat)fitNav{
    if ([CQScreenTool isIPhoneXSeries]) {
        return 88.0;
    }else if ([CQScreenTool isFullScreenIPadPro]) {
        return 64.0;
    }else{
        return 64.0;
    }
}

+ (CGFloat)fitStatusBar{
    if ([CQScreenTool isIPhoneXSeries]) {
        return 44.0;
    }else if ([CQScreenTool isFullScreenIPadPro]) {
        return 20.0;
    }else{
        return 20.0;
    }
}

+ (CGFloat)fitTabBar{
    if ([CQScreenTool isIPhoneXSeries]) {
        return 83.0;
    }else if ([CQScreenTool isFullScreenIPadPro]) {
        return 69.0;
    }else{
        return 49.0;
    }
}

@end
