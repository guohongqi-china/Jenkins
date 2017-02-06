//
//  Utils.m
//  OnlineNovel
//
//  Created by Ann Yao on 12-8-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"

@implementation Utils

//获取Document路径
+ (NSString *)documentsDirectory 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

//获取cache路径
+ (NSString *)cacheDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    return [paths objectAtIndex:0];
}

//获取tmp路径
+ (NSString *)tmpDirectory
{
    return  NSTemporaryDirectory();
}

//获取文档管理路径:Documents/Sloth2Document/FileDirectory
+ (NSString *)getSloth2DocumentPath
{
    NSString *strTempPathDir = [[Utils documentsDirectory] stringByAppendingPathComponent:SLOTH2_DOC_PATH];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:strTempPathDir];
    if (!fileExists)
    {
        //not exist,then create
        [fileManager createDirectoryAtPath:strTempPathDir withIntermediateDirectories:YES  attributes:nil error:nil];
    }
    return strTempPathDir;
}

//获取音频管理路径:Documents/Sloth2Document/Audio
+ (NSString *)getSloth2AudioPath
{
    NSString *strTempPathDir = [[Utils documentsDirectory] stringByAppendingPathComponent:SLOTH2_AUDIO_PATH];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:strTempPathDir];
    if (!fileExists)
    {
        //not exist,then create
        [fileManager createDirectoryAtPath:strTempPathDir withIntermediateDirectories:YES  attributes:nil error:nil];
    }
    return strTempPathDir;
}

//"temp/TempFile"
+ (NSString *)getTempPath
{
    NSString *strTempPathDir = [[Utils cacheDirectory] stringByAppendingPathComponent:POST_TEMP_DIRECTORY];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:strTempPathDir];
    if (!fileExists)
    {
        //not exist,then create
        [fileManager createDirectoryAtPath:strTempPathDir withIntermediateDirectories:YES  attributes:nil error:nil];
    }
    return strTempPathDir;
}
//clear "temp/TempFile"
+ (void)clearTempPath
{
    NSString *strTempPathDir = [[Utils tmpDirectory] stringByAppendingPathComponent:POST_TEMP_DIRECTORY];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:strTempPathDir];
    if (fileExists)
    {
        //delete director
        [fileManager removeItemAtPath:strTempPathDir error:nil];
    }
}

//获取文件大小
+ (NSString *)getFileSize:(NSString *)filePath
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
	
	NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:&error];
	if(fileAttributes != nil)
    {
		NSString *fileSize = [fileAttributes objectForKey:NSFileSize];
		
        return fileSize;
	}
    
    return nil;
}

//复制文件操作
+ (BOOL)copyFile:(NSString*)strSource toPath:(NSString*)strDest
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    return [fileManager copyItemAtPath:strSource toPath:strDest error:nil];
}

+ (void)setNavigationBarBackgroundImage:(UINavigationBar*)navigationBar
{
    [navigationBar setBackgroundImage:[UIImage imageNamed:NAV_BG_IMAGE] forBarMetrics:UIBarMetricsDefault];
}

//获取当前的时间字符串 格式yyyy-MM-dd HH:mm:ss
+ (NSString *)getCurrentDateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *currentDateString = [dateFormatter stringFromDate:[NSDate date]];
    
    return currentDateString;
}

//创建UIBarButtonItem按钮
+ (UIButton *)buttonWithImageName:(UIImage *)imgBtn frame:(CGRect)rect target:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = rect;
    [button setImage:imgBtn forState:UIControlStateNormal];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//右导航按钮
+ (UIButton *)buttonWithTitle:(NSString*)strTitle frame:(CGRect)rect target:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = rect;
    [button setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
    [button setBackgroundImage:[[UIImage imageNamed:@"nav_right_btn"] stretchableImageWithLeftCapWidth:22 topCapHeight:16] forState:UIControlStateNormal];
    [button setTitle:strTitle forState:UIControlStateNormal];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//左导航按钮
+ (UIButton *)leftButtonWithTitle:(NSString*)strTitle frame:(CGRect)rect target:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = rect;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
    [button setBackgroundImage:[[UIImage imageNamed:@"nav_left_btn"] stretchableImageWithLeftCapWidth:40 topCapHeight:0] forState:UIControlStateNormal];

    [button setTitle:strTitle forState:UIControlStateNormal];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIButton *)getButton:(NSString*)strTitle frame:(CGRect)rect target:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = rect;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0]];
    [button setBackgroundImage:[Common getImageWithColor:COLOR(174, 27, 29, 1.0)] forState:UIControlStateNormal];
    [button setTitle:strTitle forState:UIControlStateNormal];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button.layer setBorderWidth:1.0];
    [button.layer setCornerRadius:3];
    button.layer.borderColor = [[UIColor clearColor] CGColor];
    [button.layer setMasksToBounds:YES];
    return button;
}

//获取透明的button
+ (UIButton *)getTransparentButton:(CGRect)rect target:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = rect;
    [button setBackgroundImage:[Common getImageWithColor:COLOR(150, 150, 150, 0.4)] forState:UIControlStateHighlighted];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button.layer setBorderWidth:1.0];
    [button.layer setCornerRadius:3];
    button.layer.borderColor = [[UIColor clearColor] CGColor];
    [button.layer setMasksToBounds:YES];
    return button;
}

//获取google地图地址
+ (NSString *)googleMapsURLWithLocation:(NSString *)location
{
    return [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?language=zh-cn&location=%@&radius=150&sensor=false&key=AIzaSyCG1Dgw1X1aTP2ntizQvOsUuJccJsLq-OA", location];
}

+(CGRect)getNavRightBtnFrame:(CGSize)sizeOfFrame
{
    float fLeft = kScreenWidth - NAV_BTN_X_OFFSET - sizeOfFrame.width/2;
    float fTop = kStatusBarHeight + (NAV_BAR_HEIGHT-kStatusBarHeight - sizeOfFrame.height/2)/2;
    CGRect rect = CGRectMake(fLeft,fTop, sizeOfFrame.width/2, sizeOfFrame.height/2);
    return rect;
}

+(CGRect)getNavLeftBtnFrame:(CGSize)sizeOfFrame
{
    float fLeft = NAV_BTN_X_OFFSET;
    float fTop = kStatusBarHeight + (NAV_BAR_HEIGHT - kStatusBarHeight - sizeOfFrame.height/2)/2;
    CGRect rect = CGRectMake(fLeft,fTop, sizeOfFrame.width/2, sizeOfFrame.height/2);
    return rect;
}

+ (UIView*)findFirstResponderBeneathView:(UIView*)view 
{
    // Search recursively for first responder
    for ( UIView *childView in view.subviews ) {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder] ) return childView;
        UIView *result = [self findFirstResponderBeneathView:childView];
        if ( result ) return result;
    }
    return nil;
}

+ (NSString *)getRandom
{
    long time = (long)[[NSDate date] timeIntervalSince1970];
    
    return [NSString stringWithFormat:@"%ld", time];
}

@end
