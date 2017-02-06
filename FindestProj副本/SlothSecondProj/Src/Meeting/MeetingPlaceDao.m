//
//  MeetingPlaceDao.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/19.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MeetingPlaceDao.h"

@implementation MeetingPlaceDao

+ (MeetingPlaceVo *)getMeetingPlaceVo
{
    MeetingPlaceVo *placeVo = nil;
    
    NSDictionary * dicPlaceVo = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"MeetingDefaultPlace"];
    if (dicPlaceVo != nil)
    {
        placeVo = [[MeetingPlaceVo alloc]init];
        placeVo.strID = [Common checkStrValue:dicPlaceVo[@"strID"]];
        placeVo.strName = [Common checkStrValue:dicPlaceVo[@"strName"]];
        placeVo.strDesc = [Common checkStrValue:dicPlaceVo[@"strDesc"]];
    }
    return placeVo;
}

+ (void)setMeetingPlaceVo:(MeetingPlaceVo *)placeVo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(placeVo == nil)
    {
        [userDefaults setObject:nil forKey:@"MeetingDefaultPlace"];
    }
    else
    {
        NSDictionary *dicPlaceVo = @{@"strID":placeVo.strID,@"strName":placeVo.strName,@"strDesc":placeVo.strDesc};
        [userDefaults setObject:dicPlaceVo forKey:@"MeetingDefaultPlace"];
    }
}

@end
