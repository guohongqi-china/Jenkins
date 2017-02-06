//
//  TicketTraceVo.h
//  WeiShangKeProj
//
//  Created by 焱 孙 on 15/5/29.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TicketTraceVo : NSObject

@property(strong,nonatomic)NSString *strID;
@property(strong,nonatomic)NSString *strTicketID;       //工单ID
@property(strong,nonatomic)NSString *strTicketNum;      //工单号
@property(strong,nonatomic)NSString *strSessionID;      //会话ID
@property(nonatomic)NSInteger nStatus;           //状态
@property(strong,nonatomic)NSString *strContent;        //变更内容描述
@property(strong,nonatomic)NSString *strDateTime;


@end
