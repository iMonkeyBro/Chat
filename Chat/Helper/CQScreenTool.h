//
//  CQScreenTool.h
//  Chat
//
//  Created by 刘超群 on 2020/4/15.
//  Copyright © 2020 chaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CQScreenTool : NSObject

#pragma mark - 全面屏适配，仅适用竖屏App
/// 是否是全面屏的iPad Pro
+ (BOOL)isFullScreenIPadPro;

/// 是否是iPhone X系列
+ (BOOL)isIPhoneXSeries;

/// 是否是iPad 系列
+ (BOOL)isIpadSeries;

/// 是否是全面屏设备
+ (BOOL)isFullScreenDevice;

/// 适配全面屏设备的底边间隙
+ (CGFloat)fullScreenMarginBottom;

/// 适配全面屏设备的顶部间隙
+ (CGFloat)fullScreenMarginTop;

/// 适配全面屏的导航条的高度
+ (CGFloat)fitNav;

/// 适配全面屏的状态栏高度
+ (CGFloat)fitStatusBar;

/// 适配全面屏的tabbar高度
+ (CGFloat)fitTabBar;


@end

NS_ASSUME_NONNULL_END
