//
//  LocationService.m
//  NssmcWskProj
//
//  Created by 焱 孙 on 15/12/11.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "LocationService.h"
#import "VNetworkFramework.h"

@implementation LocationService

+ (void)uploadLocation:(CLLocation *)location result:(ResultBlock)resultBlock
{
    NSMutableDictionary *dicBody = [NSMutableDictionary dictionary];
    [dicBody setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
    [dicBody setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getUploadLocationURL]];
    [networkFramework startRequestToServer:@"POST" parameter:dicBody result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.bSuccess = YES;
        }
        resultBlock(retInfo);
    }];
}

@end
