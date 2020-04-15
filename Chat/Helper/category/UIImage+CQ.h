//
//  UIImage+CQ.h
//  CNote
//
//  Created by 超群 on 2018/6/10.
//  Copyright © 2018年 超群. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CQ)


/**
 传入颜色和尺寸生成图片
 @param color 颜色
 @param size 尺寸
*/
+(UIImage *)cq_ImageWithColor:(UIColor *)color andSize:(CGSize)size;

/**
 更改图片的颜色
 @param color 需要更改的颜色
 */
-(UIImage*)imageChangeColor:(UIColor*)color;

#pragma mark - 裁切图片
/**
 传入图片和裁切位置，直接裁切图片
 @param originalImage 原图片
 @param rect 需要剪切的位置
 */
+ (UIImage *)cq_imagecutWithOriginalImage:(UIImage *)originalImage withCutRect:(CGRect)rect;

/**
 传入图片和裁切位置，直接裁切图片
 @param originalImage 原图片
 @param size 需要剪切的尺寸
 */
+ (UIImage *)cq_imageWithOriginalImage:(UIImage *)originalImage withScaleSize:(CGSize)size;

/**
 渲染一个指定大小的image
 */
- (UIImage *)cq_renderAtSize:(const CGSize)size;

#pragma mark - 压缩图片
/**
 压缩图片 先压尺寸，再压质量
 @param image 需要压缩的图片
 @param maxLength 目标大小
 */
+ (UIImage *)cq_compressImage:(UIImage *)image toByte:(NSUInteger)maxLength;

/**
 压缩图片质量
 @param image 需要压缩的图片
 @param maxLength 目标大小
 */
+ (UIImage *)cq_compressImageQuality:(UIImage *)image toByte:(NSInteger)maxLength;


/**
 压缩图片尺寸
 @param image 需要压缩的图片
 @param maxLength 目标大小
 */
+ (UIImage *)cq_compressImageSize:(UIImage *)image toByte:(NSUInteger)maxLength;



@end
