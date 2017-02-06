//
//  MessageDetailViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-19.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "MessageVo.h"
#import "MBProgressHUD.h"

@class MainMessageListViewController;

@interface MessageDetailViewController : QNavigationViewController<UIActionSheetDelegate,UIScrollViewDelegate,MBProgressHUDDelegate>

@property(nonatomic,strong)MBProgressHUD *hud;

@property(nonatomic,strong)UIView *viewBottom;
@property(nonatomic,strong)UIImageView *imgViewTabLine;
@property(nonatomic,strong)UIButton *btnStar;
@property(nonatomic,strong)UIButton *btnForward;
@property(nonatomic,strong)UIButton *btnDelete;
@property(nonatomic,strong)UIButton *btnMore;

@property(nonatomic,strong)UIScrollView * m_scrollView;

//middle view
@property(nonatomic,strong)UIView *viewMsgContainer;

@property(nonatomic,strong)NSMutableArray *arySessionMsgList;
@property(nonatomic,strong)MessageVo *m_currMessageVo;

@property(nonatomic, assign) int nWebViewHeight;
@property(nonatomic,strong)NSMutableArray *aryMsgListView;

@property(nonatomic,assign)MainMessageListViewController *parentView;

@property(nonatomic)BOOL bScrolling;   //UIWebView是否正在滚动，优化分享详情图片点击

-(void)initData;
-(void)initMiddleView;
-(void)tapOneMessage:(MessageVo*)messageVo;
-(void)updateMsgListFrame;

@end
