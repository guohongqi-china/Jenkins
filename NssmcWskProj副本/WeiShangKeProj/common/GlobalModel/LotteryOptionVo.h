//
//  LotteryOptionVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-5-5.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LotteryOptionVo : NSObject

@property(nonatomic,strong)NSString *strLotteryOptionID;          //奖项ID
@property(nonatomic,strong)NSString *strLotteryName;        //奖项名称,一等奖
@property(nonatomic)NSInteger nLotteryNum;                  //该奖项的数量
@property(nonatomic)NSInteger nLotteryLeftNum;              //剩下未抽完的数量
@property(nonatomic,strong)NSString *strLotteryImgUrl;      //奖项图片
@property(nonatomic,strong)NSString *strWinLotteryName;  //已经抽奖的名字(逗号分割)

@property(nonatomic)BOOL bExpansion;                    //是否展开

@end
