//
//  SessionManageViewController.h
//  WeiShangKeProj
//
//  Created by 焱 孙 on 4/30/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "HMSegmentedControl.h"
#import "SessionListViewController.h"
#import "BaseData.h"

@interface SessionManageViewController : QNavigationViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,strong)HMSegmentedControl *hmSegmentedControl;
@property(nonatomic,strong)UIScrollView *m_scrollView;
@property(nonatomic)SessionState sessionState;

//来源不同的SessionList
@property(nonatomic,strong)SessionListViewController *sessionListAll;       //所有
@property(nonatomic,strong)SessionListViewController *sessionListSina;      //新浪
@property(nonatomic,strong)SessionListViewController *sessionListBrowser;   //浏览器(web chat)
@property(nonatomic,strong)SessionListViewController *sessionListWeixin;    //微信

@end
