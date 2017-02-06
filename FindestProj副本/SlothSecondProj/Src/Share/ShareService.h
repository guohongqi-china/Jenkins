//
//  ShareService.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerProvider.h"
#import "ServerReturnInfo.h"
#import "ServerURL.h"
#import "LeagueVo.h"
#import "ReportUserVo.h"

@interface ShareService : NSObject

+ (void)shieldUserByID:(NSString*)strUserID result:(ResultBlock)resultBlock;
+ (void)restoreShieldUserByID:(NSString*)strUserID result:(ResultBlock)resultBlock;
+ (void)getShieldUserList:(NSInteger)nPage result:(ResultBlock)resultBlock;
+ (void)reportUser:(ReportUserVo *)userVo result:(ResultBlock)resultBlock;
+ (void)getHomeSearchData:(ResultBlock)resultBlock;

@end
