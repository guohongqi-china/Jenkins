//
//  LocationManage.m
//  NssmcWskProj
//
//  Created by 焱 孙 on 15/12/10.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "LocationManage.h"

//外部变量
BMKUserLocation *g_userLocation = nil;
NSDate *g_dateLocation = nil;

@interface LocationManage ()<BMKLocationServiceDelegate>
{
    BMKLocationService *locService;
    LocationBlock locationBlock;
}

@end

@implementation LocationManage

+ (instancetype)sharedLocationManage
{
    static LocationManage *locationManage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationManage = [[LocationManage alloc]init];
    });
    return locationManage;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        locService = [[BMKLocationService alloc]init];
        locService.delegate = self;
    }
    return self;
}

- (void)startLocation:(LocationBlock)block
{
    locationBlock = block;
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:g_dateLocation];
    if (g_dateLocation == nil || timeInterval>600)
    {
        //当间隔时间超过10分钟，则获取新的位置信息
        [locService startUserLocationService];
    }
    else
    {
        //使用旧的位置
        locationBlock(g_userLocation);
    }
}

- (void)stopLocation
{
    [locService stopUserLocationService];
}

#pragma BMKLocationServiceDelegate

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    DLog(@"BaiduLocation:%@",userLocation.location);
    //停止定位
    [self stopLocation];
    
    //更新外部变量
    g_userLocation = userLocation;
    g_dateLocation = [NSDate date];
    
    locationBlock(userLocation);
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    locationBlock(nil);
}

/**
 *在停止定位后，会调用此函数
 */
- (void)didStopLocatingUser
{
    DLog(@"didStopLocatingUser");
}

@end
