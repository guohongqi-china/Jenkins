//
//  FootballService.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/10.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerProvider.h"
#import "ServerReturnInfo.h"
#import "ServerURL.h"
#import "LeagueVo.h"

@interface FootballService : NSObject

+ (void)getLeagueList:(NSInteger)nType result:(ResultBlock)resultBlock;
+ (void)getMyLeagueList:(NSInteger)nLeagueType page:(NSInteger)nPage result:(ResultBlock)resultBlock;
+ (void)commitLeague:(NSMutableArray*)aryLeague singleBet:(NSInteger)nSingleBet result:(ResultBlock)resultBlock;
+ (void)getBetList:(ResultBlock)resultBlock;

@end
