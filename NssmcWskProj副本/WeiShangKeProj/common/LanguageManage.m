//
//  LanguageManage.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 7/4/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "LanguageManage.h"

static NSString *g_language = @"";            //当前支持两种语言zh-Hans,en（跟随系统auto字段保存到NSUserDefaults中）

@implementation LanguageManage

//初始化语言设置
+ (void)initLanguageSetting
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strLanguage = [userDefaults stringForKey:@"Sloth2Language"];
    [LanguageManage setCurrLanguage:strLanguage];
}

//获取存储在NSUserDefault里面的语言
+ (NSString *)getUserDefaultLanguage
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults stringForKey:@"Sloth2Language"];
}

//当前内存运行的语言
+ (NSString *)getCurrLanguage
{
	return g_language;
}

+ (void)setCurrLanguage:(NSString *)strLanguage
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //没有设置语言或者跟随系统
    if (strLanguage == nil || [strLanguage isEqualToString:@"auto"])
    {
        NSArray* languages = [userDefaults objectForKey:@"AppleLanguages"];
        NSString* strSystemLanguage = [languages objectAtIndex:0];
        if ([strSystemLanguage isEqualToString:@"zh-Hans"])
        {
            strLanguage = @"zh-Hans";
        }
        else
        {
            //其他语言统一设置为英文
            strLanguage = @"en";
        }
        
        [userDefaults setObject:@"auto" forKey:@"Sloth2Language"];
    }
    else if([strLanguage isEqualToString:@"zh-Hans"])
    {
        strLanguage = @"zh-Hans";
        [userDefaults setObject:@"zh-Hans" forKey:@"Sloth2Language"];
    }
    else
    {
        //其他语言统一设置为英文
        strLanguage = @"en";
        [userDefaults setObject:@"en" forKey:@"Sloth2Language"];
    }
    g_language = [strLanguage copy];
}

+ (void)updateLanguageToServer
{
    //将语言设置更新到后台
    dispatch_async(dispatch_get_global_queue(0,0),^{
        //do thread work
        NSString *strTemp = nil;
        if ([g_language isEqualToString:@"zh-Hans"])
        {
            strTemp = @"zh";
        }
        else
        {
            strTemp = @"en";
        }
        //不管成功失败
        [ServerProvider setLanguage:strTemp];
    });
}

@end
