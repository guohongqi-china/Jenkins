//
//  LeagueSelectVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/10.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeagueSelectVo : NSObject

@property (nonatomic) NSInteger nLeagueNum;     //赛事数量
@property (nonatomic) double fIntegralSum;     //积分总数
@property (nonatomic,strong) NSMutableArray *aryLeague;

@end
