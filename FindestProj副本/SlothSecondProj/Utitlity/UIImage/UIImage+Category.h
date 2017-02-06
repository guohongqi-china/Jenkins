//
//  UIImage+Category.h
//  ErShouHui
//
//  Created by 刘硕 on 15/12/16.
//  Copyright (c) 2015年 www.woyuance.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>
@interface UIImage (Category)


/**
 *  根据本地选择的图片assert URl生成一张图片
 *
 *  @param asset <#asset description#>
 *
 *  @return <#return value description#>
 */
- (UIImage *)fullResolutionImageFromALAsset:(ALAsset *)asset;

/**
 *  图片模糊
 */

// 0.0 to 1.0
- (UIImage*)blurredImage:(CGFloat)blurAmount;


/**
 *  传入一种颜色生成一张图片
 *
 *  @param color <#color description#>
 *
 *  @return <#return value description#>
 */
+(UIImage *)imageWithColor:(UIColor *)color;

/**
 *  截整个屏幕的一张图
 *
 *  @return <#return value description#>
 */
+ (UIImage *)screenshot;
@end
