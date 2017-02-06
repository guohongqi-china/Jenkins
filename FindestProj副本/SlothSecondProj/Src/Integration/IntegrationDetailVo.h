//
//  IntegrationDetailVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 4/10/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IntegrationDetailVo : NSObject

@property(nonatomic,strong)NSString *strID;
@property(nonatomic,strong)NSString *strFromID;     //发分人ID
@property(nonatomic,strong)NSString *strFromName;   //发分人名
@property(nonatomic,strong)NSString *strTitle;      //分享标题、系统奖励、系统扣分
@property(nonatomic,strong)NSString *strDateTime;

@property(nonatomic,strong)NSString *strFromType;    //积分来源(U:用户积分 M:版主额度积分 A:管理员手工积分)
@property(nonatomic)double fNum;     //积分数量

@property(nonatomic,strong)NSString *strIntegralType;//积分类型
@property(nonatomic,strong)NSString *strIntegralTypeName;//积分类型中文描述

@end
