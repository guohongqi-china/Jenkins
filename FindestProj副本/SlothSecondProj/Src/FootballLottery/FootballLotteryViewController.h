//
//  FootballLotteryViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/9.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"
#import "LeagueSelectVo.h"

@interface FootballLotteryViewController : CommonViewController

@property (nonatomic,strong) LeagueSelectVo *leagueSelectVo;

- (void)updateSelectNum;

@end
