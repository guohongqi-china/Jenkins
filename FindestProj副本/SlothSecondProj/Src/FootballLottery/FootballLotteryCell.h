//
//  FootballLotteryCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/9.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeagueVo.h"

@class FootballLotteryViewController,FootballLotteryCell;


//change by fjz
@protocol footballLotteryCellDelegate <NSObject>

@optional
- (void) footballLotteryCell:(FootballLotteryCell *)cell copyLinkSharingWithLeagueVo:(LeagueVo *)leagueVo;

@end


@interface FootballLotteryCell : UITableViewCell

@property (nonatomic,weak) FootballLotteryViewController *parentController;

- (void)setEntity:(LeagueVo *)entity last:(BOOL)bLastRow;
@property (weak, nonatomic) id<footballLotteryCellDelegate>delegate;

@end
