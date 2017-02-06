//
//  NotifyVo.h
//  Sloth
//
//  Created by Ann Yao on 12-10-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerProvider.h"   

@interface NotifyVo : NSObject

@property (nonatomic, retain) NSString *strID;              //提醒ID
@property (nonatomic, retain) NSString *strFromUserID;      //发送者ID
@property (nonatomic, retain) NSString *strFromUserName;
@property (nonatomic, retain) NSString *strDescription;     //详情
@property (nonatomic, retain) NSString *strAssistContent;   //提醒辅助内容
@property (nonatomic, retain) NSString *strLinkHtml;        //消息源
@property (nonatomic, retain) NSString *strUserImgUrl;      //发送人头像url
@property (nonatomic, assign) int nReadState;               //0:已读;1:未读
@property (nonatomic, retain) NSString *strRefID;           //资源ID
@property (nonatomic, retain) NSString *strCreateDate;      //创建日期
@property (nonatomic, retain) NSString *strTitleID;         //title id(如果是消息)

@property (nonatomic, assign) NotifyMainType notifyMainType;      //通知主类型
@property (nonatomic, assign) NotifySubType notifySubType;        //通知子类型

@property (nonatomic, retain) NSString *title;      //名称
@property (nonatomic, assign) int count;

@end
