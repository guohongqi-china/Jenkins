//
//  SkinManage.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 12/5/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "SkinManage.h"
#import "Constants+OC.h"

static SkinType g_skin = 0;  //当前支持2种皮肤，0:白天（默认橙色）、1:夜间模式
static NSDictionary *dicSkinDefault = nil;
static NSDictionary *dicSkinNight = nil;

static NSBundle *bundleSkinDefault = nil;
static NSBundle *bundleSkinNight = nil;

@implementation SkinManage

+ (void)initSkinSetting
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *skinType = [userDefaults objectForKey:@"CurrentDayNightSkin"];
    if (skinType == nil)
    {
        [SkinManage setCurrentSkin:SkinDefaultType];
    }
    else
    {
        [SkinManage setCurrentSkin:(SkinType)skinType.integerValue];
    }
}

+ (SkinType)getCurrentSkin
{
    return g_skin;
}

+ (void)setCurrentSkin:(SkinType)skinType
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (skinType <= 1)
    {
        g_skin = skinType;
    }
    else
    {
        g_skin = SkinDefaultType;
    }
    [userDefaults setObject:[NSNumber numberWithInteger:skinType] forKey:@"CurrentDayNightSkin"];
}

+ (UIImage *)imageNamed:(NSString *)name
{
    NSString *strPath = [[NSBundle mainBundle]resourcePath];
    SkinType skinType = [SkinManage getCurrentSkin];
    if (skinType == SkinDefaultType)
    {
        
    }
    else if (skinType == SkinNightType)
    {
        strPath = [strPath stringByAppendingPathComponent:@"skin_night"];
    }
    
    if (iOSPlatform>7)
    {
        strPath = [strPath stringByAppendingPathComponent:name];
    }
    else
    {
        //iOS7以及iOS6不能自动追加后缀
        strPath = [strPath stringByAppendingPathComponent:name];
        strPath = [NSString stringWithFormat:@"%@@2x.png",strPath];
    }
    return [UIImage imageWithContentsOfFile:strPath];
}

+ (UIColor *)skinColor
{
    UIColor *colorSkin;
    SkinType skinType = [SkinManage getCurrentSkin];
    if (skinType == SkinDefaultType)
    {
        colorSkin = THEME_COLOR;
    }
    else if (skinType == SkinNightType)
    {
        colorSkin = NIGHT_COLOR;
    }
    return colorSkin;
}

//获取属性列表文件里面配置的皮肤颜色
+ (UIColor *)colorNamed:(NSString *)name
{
    UIColor *color = nil;
    NSBundle *bundleSkinConfig = nil;
    NSString *strPath = [[NSBundle mainBundle]resourcePath];
    SkinType skinType = [SkinManage getCurrentSkin];
    if (skinType == SkinDefaultType)
    {
        if (bundleSkinDefault == nil)
        {
            bundleSkinDefault = [NSBundle bundleWithPath:strPath];
        }
        bundleSkinConfig = bundleSkinDefault;
    }
    else if (skinType == SkinNightType)
    {
        if (bundleSkinNight == nil)
        {
            strPath = [strPath stringByAppendingPathComponent:@"skin_night/"];
            bundleSkinNight = [NSBundle bundleWithPath:strPath];
        }
        bundleSkinConfig = bundleSkinNight;
    }

    if (bundleSkinConfig != nil)
    {
        NSArray *aryColorElem = [[bundleSkinConfig localizedStringForKey:name value:name table:@"SkinConfig"] componentsSeparatedByString:@","];
        if (aryColorElem != nil || aryColorElem.count == 4)
        {
            color = COLOR(((NSString*)aryColorElem[0]).integerValue, ((NSString*)aryColorElem[1]).integerValue, ((NSString*)aryColorElem[2]).integerValue, ((NSString*)aryColorElem[3]).doubleValue);;
        }
    }
    
    return color;
}

@end
