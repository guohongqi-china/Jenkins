//
//  SessionListViewController.h
//  WeiShangKeProj
//
//  Created by 焱 孙 on 5/17/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseData.h"
#import "NoSearchView.h"

@class SessionManageViewController;
@interface SessionListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UIRefreshControl* refreshControl;

@property(nonatomic,strong)NoSearchView *noSearchView;
@property (nonatomic, retain) UITableView *tableViewSession;
@property (nonatomic, retain) NSMutableArray *arySession;            //tableView data

//进入类别（0:首页tab进入,1:推送进入）
@property(nonatomic,assign)int nEnterType;

@property(weak,nonatomic)SessionManageViewController *homeViewController;

@property(nonatomic)SessionState sessionState;   //会话状态 -1: 未分配 1: 未处理 2: 处理中 3: 已暂停 4: 已结束
//1: 微信
//2: 新浪微博
//3: 腾讯微博
//4: 易信
//5: 邮件
//6: 短信
//7: 新浪微博@我的
//8: 新浪微博评论
//9: WebChat聊天
//10:微软接口
//11:WebChat留言板
//12:国泰接口
//14:睿路接口
@property(nonatomic)NSInteger nSessionFrom;    //来源

@property (nonatomic, strong) UIActivityIndicatorView * activity;
@property (nonatomic, strong) UIImageView *imgViewWaiting;

//分页数据
@property(nonatomic)BOOL refreshing;
@property(nonatomic)int m_curPageNum;

-(void)refreshView;

@end
