//
//  TopRangkingManageViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/6/15.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "CommonViewController.h"
#import "HMSegmentedControl.h"
#import "TopRankingViewController.h"

@interface TopRangkingManageViewController : CommonViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,strong)HMSegmentedControl *hmSegmentedControl;
@property(nonatomic,strong)UIScrollView *m_scrollView;
@property(nonatomic)NSInteger nTabIndex;    //0:当日热贴榜,1:积分排行榜,2:风云人物榜,3:我的排名

//来源不同的SessionList
@property(nonatomic,strong)TopRankingViewController *topShareViewController;       //当日热贴榜
@property(nonatomic,strong)TopRankingViewController *allIntegralViewController;          //积分排行榜
@property(nonatomic,strong)TopRankingViewController *dailyUserViewController;       //风云人物榜
@property(nonatomic,strong)TopRankingViewController *myRankingViewController;        //我的排名
@property(nonatomic,strong)TopRankingViewController *companyRankingViewController;        //公司排名

@end
