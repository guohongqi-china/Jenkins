//
//  SkinManage.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 12/5/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SkinDefaultType = 0,                          //默认
    SkinNightType                           //夜间模式
}SkinType;

@interface SkinManage : NSObject

+ (void)initSkinSetting;
+ (SkinType)getCurrentSkin;
+ (void)setCurrentSkin:(SkinType)skinType;

+ (UIImage *)imageNamed:(NSString *)name;   //根据皮肤获取图片
+ (UIColor *)skinColor;                     //获取皮肤颜色

+ (UIColor *)colorNamed:(NSString *)name;   //获取属性列表文件里面配置的皮肤颜色

@end
