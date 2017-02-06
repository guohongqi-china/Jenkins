//
//  ActivityService.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/17.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerProvider.h"
#import "ServerReturnInfo.h"
#import "ServerURL.h"
#import "UserVo.h"

@interface ActivityService : NSObject

//活动首页列表
+ (void)getHomeActivityList:(ResultBlock)resultBlock;

+ (void)getActivityDetail:(NSString*)strBlogID result:(ResultBlock)resultBlock;
//回答详情
+ (void)getAnswerDetail:(BlogVo *)blogVo result:(ResultBlock)resultBlock;

+ (void)signupActivityProject:(NSString *)strProjectID andUserVO:(UserVo*)userVo result:(ResultBlock)resultBlock;

//获取活动列表
+ (void)getActivityList:(NSString*)strSearch myActivity:(NSInteger)nSelfFlag page:(NSInteger)nPage size:(NSInteger)nSize result:(ResultBlock)resultBlock;

//获取已报名人员列表
+ (void)getActivityUserList:(NSString *)strActivityID page:(NSInteger)nPage result:(ResultBlock)resultBlock;

@end
