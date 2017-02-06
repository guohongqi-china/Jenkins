//
//  LotteryVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-5-5.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LotteryOptionVo.h"

@interface LotteryVo : NSObject

@property(nonatomic,strong)NSString *strLotteryID;          //奖ID
@property(nonatomic)NSInteger nLotterySumNum;               //总人数
@property(nonatomic,strong)NSString *strEndTime;            //结束日期
@property(nonatomic)BOOL bDrawLottery;                      //本人是否抽过奖
@property(nonatomic,strong)NSString *strWinOptionID;       //本人中奖的奖项
@property(nonatomic,strong)NSMutableArray *aryLotteryOption;    //投票项数组
@property(nonatomic,strong)NSMutableArray *aryHistory;    //抽奖历史
@property(nonatomic,strong)NSString *strImageBK;   //背景图片

@property(nonatomic)BOOL bExpired;                      //本奖是否已经过期

@property(nonatomic,strong)UIImage *imgWinOption;       //抽中的图片

@property(nonatomic)NSInteger nConsumeIntegral;

@end
