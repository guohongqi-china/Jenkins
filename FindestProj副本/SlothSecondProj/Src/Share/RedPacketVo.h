//
//  RedPacketVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 4/20/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RedPacketVo : NSObject

@property(nonatomic,strong)NSString *strID;
@property(nonatomic,strong)NSString *strRemark;

@property(nonatomic)NSInteger nIntegralTotal;       //总分
@property(nonatomic)NSInteger nIntegralRemain;      //剩余积分
@property(nonatomic)NSInteger nNum; //已经抽的次数

@property(nonatomic)NSInteger nGetIntegral;     //当前用户抽的分数
@property(nonatomic,strong)NSString *strGetDateTime;//当前用户抽的时间

@end
