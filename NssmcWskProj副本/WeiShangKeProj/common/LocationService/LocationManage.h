//
//  LocationManage.h
//  NssmcWskProj
//
//  Created by 焱 孙 on 15/12/10.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>

typedef void(^LocationBlock)(BMKUserLocation *userLocation);

@interface LocationManage : NSObject

+ (instancetype)sharedLocationManage;

- (void)startLocation:(LocationBlock)block;
- (void)stopLocation;

@end
