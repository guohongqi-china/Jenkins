//
//  LocationService.h
//  NssmcWskProj
//
//  Created by 焱 孙 on 15/12/11.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerProvider.h"
#import "ServerReturnInfo.h"
#import "ServerURL.h"

@interface LocationService : NSObject

+ (void)uploadLocation:(CLLocation *)location result:(ResultBlock)resultBlock;

@end
