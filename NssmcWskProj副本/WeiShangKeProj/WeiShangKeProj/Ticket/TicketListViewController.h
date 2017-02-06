//
//  TicketListViewController.h
//  WeiShangKeProj
//
//  Created by 焱 孙 on 15/5/28.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "ChatObjectVo.h"
#import "NoSearchView.h"
#import "CommonViewController.h"

typedef enum _TicketListType{
    TicketListTryType,          //可抢工单
    TicketListMyType,           //我的工单
    TicketListUnresolveType,    //未结束
    TicketListResolveType     //已结束
}TicketListType;

@interface TicketListViewController : CommonViewController  //QNavigationViewController

@property (nonatomic)TicketListType ticketListType;

@property (nonatomic) NSInteger nCurrPage;
@property (nonatomic) BOOL refreshing;

@end
