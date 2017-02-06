//
//  ActivityProjectVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-5-29.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityProjectVo : NSObject

@property(nonatomic,strong)NSString *strID;             //项目id
@property(nonatomic,strong)NSString *strBlogID;         //活动ID
@property(nonatomic,strong)NSString *strCreateID;       //创建者ID
@property(nonatomic,strong)NSString *strProjectName;    //项目名称
@property(nonatomic,strong)NSString *strProjectDesc;    //项目描述
@property(nonatomic)BOOL bShow;                         //是否对普通用户显示报名人员列表

@property(nonatomic,strong)NSString *strCreateDate;     //创建时间
@property(nonatomic,strong)NSString *strMaxImageURL;    //海报的最大图
@property(nonatomic,strong)NSString *strMinImageURL;    //海报的最小图
@property(nonatomic,strong)NSString *strStartDateTime;  //报名开始时间
@property(nonatomic,strong)NSString *strEndDateTime;    //报名结束时间

@property(nonatomic)NSInteger nStatus;                  //项目报名状态,1：已经结束，2：未开始，3：正在进行
@property(nonatomic)NSInteger nSignupCount;             //报名人数

@property(nonatomic,strong)NSMutableArray *aryMemberList;   //报名成员

@end
