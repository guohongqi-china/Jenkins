//
//  LeftMenuViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-13.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftMenuVo.h"
#import "NoticeNumView.h"
#import "MainSearchViewController.h"
#import "CustomerListViewController.h"
#import "SessionManageViewController.h"
#import "AboutViewController.h"
#import "TicketListViewController.h"
#import "UserDetailViewController.h"
#import "EditPasswordViewController.h"

@interface LeftMenuViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property(nonatomic,strong) UIScrollView *scrollViewBody;
@property(nonatomic,strong) UILabel *lblAppName;
@property(nonatomic,strong) UILabel *lblUserName;
@property(nonatomic,strong) UIImageView *imgViewNotify;//提示

@property(nonatomic,strong) UITableView *tableViewMenu;


@property(nonatomic,strong) NSIndexPath *indexPathLast;
@property(nonatomic,strong) NSMutableArray *arySection;     //分组的数组
@property(nonatomic,strong) NSMutableArray *aryMenu;        //菜单数组
@property(nonatomic,strong) NSMutableArray *arySessionTypeMenu;

//用于刷新提醒数量
@property(nonatomic,strong) NoticeNumView *noticeNumView;

//中心视图控制器
@property(nonatomic,strong) MainSearchViewController *mainSearchViewController;

//客户列表
@property(nonatomic,strong) CustomerListViewController *customerListViewController;

//可抢工单
@property(nonatomic,strong) TicketListViewController *grabTicketListViewController;

//我的工单
@property(nonatomic,strong) TicketListViewController *myTicketListViewController;

//工单分类查看
@property(nonatomic,strong) TicketListViewController *processingTicketListViewController;   //处理中会话
@property(nonatomic,strong) TicketListViewController *processedTicketListViewController;  //已处理会话

//我的信息
@property(nonatomic,strong) UserDetailViewController *userDetailViewController;

//修改密码
@property(nonatomic,strong) EditPasswordViewController *editPasswordViewController;

//关于
@property(nonatomic,strong) AboutViewController *aboutViewController;

-(BOOL)switchView:(NSString *)strKey;
+(BOOL)getLeftMenuState;

@end
