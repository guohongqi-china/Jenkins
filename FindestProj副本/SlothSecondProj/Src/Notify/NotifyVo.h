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
@property (nonatomic) NSInteger nReadState;               //0:已读;1:未读
@property (nonatomic, retain) NSString *strRefID;           //资源ID
@property (nonatomic, retain) NSString *strCreateDate;      //创建日期
@property (nonatomic, retain) NSString *strTitleID;         //类型为消息时,该字段为消息的titleId ；类型为评论时，该字段为评论id （refId为分享id）

@property (nonatomic, retain) NSString *title;      //名称
@property (nonatomic) NSInteger nPush;  //是否推送,1:打开推送；0:关闭推送
@property (nonatomic, assign) int count;

/////////////////////////////////////////////////////////////////////////////
@property (nonatomic, retain) NSString *strBlogTitle;      //分享标题
@property (nonatomic, retain) NSString *strBlogPicture;      //分享第一张图片

@property (nonatomic, assign) NSInteger notifyMainType;      //通知主类型 11:待办事项 12:回复/评论 13:被@ 14:打赏 15:消息/群组
@property (nonatomic, assign) NotifySubType notifySubType;        //通知子类型

@end
