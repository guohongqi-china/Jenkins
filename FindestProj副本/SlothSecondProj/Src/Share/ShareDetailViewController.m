//
//  ShareDetailViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/6.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ShareDetailViewController.h"
#import "ServerURL.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+clickLike.h"
#import "UIImage+Extras.h"
#import "GroupAndUserDao.h"
#import "UserVo.h"
#import "CustomWebViewController.h"
#import "Utils.h"
#import "UIBarButtonItem+Extension.h"
#import "PublishMessageViewController.h"
#import "MessageVo.h"
#import "PraiseVo.h"
#import "UserProfileViewController.h"
#import "MJRefresh.h"
#import "SurveyViewController.h"
#import "TagVo.h"
#import "UIView+Extension.h"
#import "SkinManage.h"
#import "BusinessCommon.h"
#import "KeyValueVo.h"
#import "LotteryVo.h"
#import "LotteryOptionVo.h"
#import "SDWebImageManager.h"
#import "BufferVideoFirstImage.h"
#import "DocViewController.h"
#import "EXTScope.h"
#import "ShareDetailHeaderView.h"
#import "CommentListCell.h"
#import "AnswerListCell.h"
#import "PraiseListCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "UINavigationBar+Awesome.h"
#import "ChooseUserViewController.h"
#import "EditShareBodyViewController.h"
#import "RewardView.h"
#import "ActivityService.h"
#import "TableNoDataView.h"
#import "popView.h"

@import WebKit;

@interface ShareDetailViewController ()<AnswerCellDelegate,EditShareBodyDelegate,ChooseUserViewControllerDelegate,UIActionSheetDelegate,SimpleToolBarDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate,UIWebViewDelegate,CommentCellDelegate,ISSShareViewDelegate,UIAlertViewDelegate>
{
    //导航条
    UIView *viewNavBar;
    UILabel *lblTitle;
    UIButton *btnRight;
    popView *POView;
    //整个分享架构采用TableView布局,正文部分采用tableHeaderView，
    //中间切换praise和comment采用Sectionheader,底部list采用共享同一个tableView方式(切换数据源)
    UITableView *tableViewShare;
    
    //Table Header View
    ShareDetailHeaderView *shareHeaderView;
    
    //评论和赞模块    
    NSInteger nBottomListType;          //底部列表类型，0：评论，1：赞 ，2：答案列表
    NSMutableArray *aryComment;
    NSMutableArray *aryPraise;
    NSInteger nPraisePage;
    NSMutableArray *aryAnswer;
    NSInteger nAnswerPage;
    
    NSInteger nCommentScrollH;          //当前处于comment情况下，tableView滚动的高度
    NSInteger nPraiseScrollH;           //当前处于praise情况下，tableView滚动的高度
    NSInteger nTableHeaderH;
    
    //保存评论和赞的底部的上拉加载的状态
    BOOL bCommentCompleted;
    BOOL bPraiseCompleted;
    
    CGFloat fScrollOffsetY;
    
    NSString *strTypeName;  //
    
    ///////////////////////////////////////////
    RewardView *rewardView; //打赏View
    BOOL bCompletedAnimate;
}
@property (weak, nonatomic) UIWebView *myWebView;
@property (assign, nonatomic) NSInteger commentNumber;
@end

@implementation ShareDetailViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RefreshShareDetailNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeleteAnswerNotification" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [self initData];
    if (_isHe) {
        UIBarButtonItem *item1 = [UIBarButtonItem itemWithTarget:self action:@selector(buttonAction:) withTitle:@"通过"];
        UIBarButtonItem *item2 = [UIBarButtonItem itemWithTarget:self action:@selector(buttonAction:) withTitle:@"退回"];
        self.navigationItem.rightBarButtonItems = @[item2,item1];
        
    }
    POView = [[NSBundle mainBundle]loadNibNamed:@"popView" owner:nil options:nil].lastObject;
    POView.frame = CGRectMake(kScreenWidth - kScreenWidth / 4, 64, kScreenWidth / 4, 80);
    POView.hidden = YES;
    POView.strID = _m_originalBlogVo.streamId;
    [self.view addSubview:POView];
    _shareType = ShareDetailViewControllerNO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moveActoion) name:@"removePoP" object:nil];

    self.fd_prefersNavigationBarHidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self refreshShareList];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear: animated];
    
    if ([self.m_blogVo.strBlogType  isEqualToString:@"activity"])
    {
        [MobAnalytics endLogPageView:@"activityDetailPage"];
    }
}

- (void)initData
{
    bCompletedAnimate = YES;
    self.bFirstRefresh = YES;
    self.nDoShareAction = 0;
    self.commentNumber = 1;
    aryComment = [NSMutableArray array];
    aryPraise = [NSMutableArray array];
    nPraisePage = 1;
    aryAnswer = [NSMutableArray array];
    nAnswerPage = 1;
    
    nCommentScrollH = -1;
    nPraiseScrollH = -1;
    nTableHeaderH = -1;
    
    self.bDoCollectionAction = NO;
    bCommentCompleted = NO;
    bPraiseCompleted = NO;
    strTypeName = @"文章";
    
    [self refreshData];
}

- (void)initView
{
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    //navigation bar
    [self initNavBar];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshShareData) name:@"RefreshShareDetailNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteAnswerNotification:) name:@"DeleteAnswerNotification" object:nil];
    
    //tableView
    tableViewShare = [[UITableView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT) style:UITableViewStylePlain];
    tableViewShare.delegate = self;
    tableViewShare.dataSource = self;
    tableViewShare.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableViewShare.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    [self.view addSubview:tableViewShare];
    
    [tableViewShare registerNib:[UINib nibWithNibName:@"CommentListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CommentListCell"];
    [tableViewShare registerNib:[UINib nibWithNibName:@"PraiseListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"PraiseListCell"];
    [tableViewShare registerNib:[UINib nibWithNibName:@"AnswerListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AnswerListCell"];
    
    //headerView
    shareHeaderView = [[ShareDetailHeaderView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) parent:self];
    shareHeaderView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    tableViewShare.tableHeaderView = shareHeaderView;
    //上拉加载更多
    @weakify(self)
    tableViewShare.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self footerRereshing];
    }];
    
    [self initBottomTabBar];
    
    rewardView = [[RewardView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-50)];
    //打赏View
//    if (_shareType == ShareDetailViewControllerIS) {
//        rewardView.statusType = RewardViewIS;
//    }else{
        rewardView.statusType = RewardViewNO;
        
//    }

    rewardView.stringID = _m_originalBlogVo.streamId;
    rewardView.homeViewController = self;
}

- (void)refreshData
{
    if (self.m_originalBlogVo.streamId.length == 0)
    {
        [Common tipAlert:@"数据异常，请求失败"];
        return;
    }
    
    ResultBlock resultBlock = ^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            self.m_blogVo = (BlogVo*)retInfo.data;
            [self refreshView];
            
            //加载底部数据
            if (self.bFirstRefresh)
            {
                [self footerRereshing];
            }
            
            self.bFirstRefresh = NO;
            
            bPraiseCompleted = YES; //评论上拉加载完成
            
            //            //获取视频第一帧图片
            //            if (self.m_blogVo.aryVideoUrl.count>0)
            //            {
            //                NSString *strURL = self.m_blogVo.aryVideoUrl[0];
            //                [BufferVideoFirstImage getFirstFrameImageFromURL:strURL finished:^(UIImage *image) {
            //                    [self.btnVideoView setImage:image forState:UIControlStateNormal];
            //                }];
            //            }
            
            [self refreshHeaderView];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    };
    
    if([self.m_originalBlogVo.strBlogType isEqualToString:@"answer"])
    {
//        //回答(不需要再加载一次内容)
//        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
//        retInfo.bSuccess = YES;
//        retInfo.data = self.m_originalBlogVo;
//        resultBlock(retInfo);
        //change by fjz
        [Common showProgressView:nil view:self.view modal:NO];
        [ActivityService getAnswerDetail:self.m_originalBlogVo result:resultBlock];
    }
    else if([self.m_originalBlogVo.strBlogType isEqualToString:@"activity"])
    {
        //活动
        [Common showProgressView:nil view:self.view modal:NO];
        [ActivityService getActivityDetail:self.m_originalBlogVo.streamId result:resultBlock];
    }
    else
    {
        //其他
        [Common showProgressView:nil view:self.view modal:NO];
        [ServerProvider getShareDetailBlog:self.m_originalBlogVo.streamId type:self.m_originalBlogVo.strBlogType result:resultBlock];
    }
}

//初始化导航栏
- (void)initNavBar
{
    self.fd_prefersNavigationBarHidden = YES;
    viewNavBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, NAV_BAR_HEIGHT)];
    viewNavBar.backgroundColor = [SkinManage colorNamed:@"Theme_Color"];
    viewNavBar.clipsToBounds = YES;
    [self.view addSubview:viewNavBar];
    
    UIView *viewNavContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, NAV_BAR_HEIGHT)];
    viewNavContainer.tag = 2001;
    viewNavContainer.backgroundColor = [UIColor clearColor];
    [viewNavBar addSubview:viewNavContainer];
    
    UIButton *btnBack = [Utils buttonWithImage:[SkinManage imageNamed:@"nav_back_white"] frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:@selector(backButtonClicked)];
    btnBack.tintColor = [SkinManage colorNamed:@"Nav_Btn_Tint_Color"];
    btnBack.center = CGPointMake(btnBack.center.x-11.5, btnBack.center.y);
    [viewNavContainer addSubview:btnBack];
    
    lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(0,kStatusBarHeight, kScreenWidth, NAV_BAR_HEIGHT-kStatusBarHeight)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.text = @"正文";
    [viewNavContainer addSubview:lblTitle];

    if (_detailType) {
        btnRight = [Utils buttonWithTitle:@"审核" frame:[Utils getNavRightBtnFrame:CGSizeMake(118,76)] target:self action:@selector(doShare:)];
        btnRight.tintColor = [SkinManage colorNamed:@"Nav_Btn_Tint_Color"];
        [viewNavContainer addSubview:btnRight];

        return;
    }
    btnRight = [Utils buttonWithImage:[SkinManage imageNamed:@"nav_btn_more"] frame:[Utils getNavRightBtnFrame:CGSizeMake(106,76)] target:self action:@selector(doShare:)];
    btnRight.tintColor = [SkinManage colorNamed:@"Nav_Btn_Tint_Color"];
    [viewNavContainer addSubview:btnRight];

}

//初始化评论和赞
- (void)initCommentAndPraise
{
    
}

- (void)initBottomTabBar
{
    //5.底部按钮
    self.viewBottom = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
    self.viewBottom.backgroundColor = [SkinManage colorNamed:@"ShareView_Bottom_bg"];
    [self.view addSubview:_viewBottom];
    self.viewBottom.hidden = YES;
    
    self.viewTabLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
    self.viewTabLine.backgroundColor = [SkinManage colorNamed:@"ShareView_Sep_bg"];
    [self.viewBottom addSubview:self.viewTabLine];
    
    CGFloat fTabW = kScreenWidth/3;
    
    //本人发表带上删除按钮
    //删除 - 打赏(自己的文章没有打赏)
    self.btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnDelete setTitleColor:[SkinManage colorNamed:@"Tab_Item_Color"] forState:UIControlStateNormal];
    [self.btnDelete setImage:[SkinManage imageNamed:@"btn_share_delete"] forState:UIControlStateNormal];
    if ([SkinManage getCurrentSkin] == SkinDefaultType) {
        [self.btnDelete setTitleColor:COLOR(88, 76, 72, 1.0) forState:UIControlStateHighlighted];
    }else{
        
    }
    
    [self.btnDelete.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [self.btnDelete addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.btnDelete.hidden = YES;
    [self.viewBottom addSubview:self.btnDelete];
    
    self.viewSeparate1 = [[UIView alloc]init];
    self.viewSeparate1.backgroundColor = COLOR(221, 208, 204, 1.0);
    [self.viewBottom addSubview:self.viewSeparate1];
    
    //评论
    self.btnReply = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnReply setTitleColor:[SkinManage colorNamed:@"Tab_Item_Color"] forState:UIControlStateNormal];
    if ([SkinManage getCurrentSkin] == SkinDefaultType) {
        [self.btnReply setTitleColor:COLOR(88, 76, 72, 1.0) forState:UIControlStateHighlighted];
    }
    [self.btnReply.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
   
    [self.btnReply setTitle:@"评论" forState:UIControlStateNormal];
   
    [self.btnReply setImage:[SkinManage imageNamed:@"btn_share_comment"] forState:UIControlStateNormal];
    [self.btnReply addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.btnReply.hidden = YES;
    [self.viewBottom addSubview:self.btnReply];
    
    self.viewSeparate2 = [[UIView alloc]init];
    self.viewSeparate2.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.viewBottom addSubview:self.viewSeparate2];
    
    //赞
    self.btnPraise = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnPraise.frame = CGRectMake(self.btnReply.right, 0, fTabW, 50);
    [self.btnPraise setTitleColor:[SkinManage colorNamed:@"Tab_Item_Color"] forState:UIControlStateNormal];
    if ([SkinManage getCurrentSkin] == SkinDefaultType) {
        [self.btnPraise setTitleColor:COLOR(88, 76, 72, 1.0) forState:UIControlStateHighlighted];
    }
    
    [self.btnPraise.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [self.btnPraise setTitle:@"赞" forState:UIControlStateNormal];
    [self.btnPraise setImage:[SkinManage imageNamed:@"btn_share_praise"] forState:UIControlStateNormal];
    [self.btnPraise addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.btnPraise.hidden = YES;
    [self.viewBottom addSubview:self.btnPraise];
    
//    //add by fjz（点赞动画）
//    UIWebView *myWebView = [[UIWebView alloc] init];
//    [self.btnPraise addSubview:myWebView];
//    myWebView.scalesPageToFit = YES;
//    myWebView.scrollView.scrollEnabled = NO;
//    myWebView.backgroundColor = [UIColor clearColor];
//    myWebView.opaque = 0;
//    self.myWebView = myWebView;
//    //end
    
    //邀请回答
    self.btnInviteAnswer = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnInviteAnswer setTitleColor:[SkinManage colorNamed:@"Tab_Item_Color"] forState:UIControlStateNormal];
    if ([SkinManage getCurrentSkin] == SkinDefaultType) {
        [self.btnInviteAnswer setTitleColor:COLOR(88, 76, 72, 1.0) forState:UIControlStateHighlighted];
    }
    [self.btnInviteAnswer.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [self.btnInviteAnswer setTitle:@"邀请回答" forState:UIControlStateNormal];
    [self.btnInviteAnswer setImage:[SkinManage imageNamed:@"btn_invite_answer"] forState:UIControlStateNormal];
    [self.btnInviteAnswer addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.btnInviteAnswer.hidden = YES;
    [self.viewBottom addSubview:self.btnInviteAnswer];
    
    //添加回答
    self.btnAddAnswer = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnAddAnswer setTitleColor:[SkinManage colorNamed:@"Tab_Item_Color"] forState:UIControlStateNormal];
    if ([SkinManage getCurrentSkin] == SkinDefaultType) {
        [self.btnAddAnswer setTitleColor:COLOR(88, 76, 72, 1.0) forState:UIControlStateHighlighted];
    }
    [self.btnAddAnswer.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [self.btnAddAnswer setTitle:@"添加回答" forState:UIControlStateNormal];
    [self.btnAddAnswer setImage:[SkinManage imageNamed:@"btn_add_answer"] forState:UIControlStateNormal];
    [self.btnAddAnswer addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.btnAddAnswer.hidden = YES;
    [self.viewBottom addSubview:self.btnAddAnswer];
}

//广播通知刷新文章详情
- (void)refreshShareData
{
    [self refreshData];
}

//刷新视图
- (void)refreshView
{
    //导航条
    if([self.m_blogVo.strBlogType  isEqualToString:@"blog"])
    {
        strTypeName = @"分享";
        lblTitle.text = @"分享正文";
    }
    else if ([self.m_blogVo.strBlogType  isEqualToString:@"vote"])
    {
        strTypeName = @"投票";
        lblTitle.text = @"投票正文";
    }
    else if ([self.m_blogVo.strBlogType  isEqualToString:@"qa"])
    {
        strTypeName = @"问答";
        nBottomListType = 2;
        lblTitle.text = @"问答正文";
    }
    else if ([self.m_blogVo.strBlogType  isEqualToString:@"answer"])
    {
        strTypeName = @"回答";
        lblTitle.text = @"回答详情";
    }
    else if ([self.m_blogVo.strBlogType  isEqualToString:@"activity"])
    {
        strTypeName = @"活动";
        lblTitle.text = @"活动详情";
        
        [MobAnalytics beginLogPageView:@"activityDetailPage"];
    }
    lblTitle.textColor = [SkinManage colorNamed:@"Nav_Bar_Title_Color"];
    //底部按钮布局
    CGFloat fTabW = kScreenWidth/3;
    if([self.m_blogVo.strBlogType  isEqualToString:@"qa"])
    {
        //问答
        if ([self.m_blogVo.strCreateBy isEqualToString:[Common getCurrentUserVo].strUserID])
        {
            self.btnDelete.hidden = NO;
            self.btnDelete.frame = CGRectMake(0, 0, fTabW, 50);
            [self.btnDelete setImage:[SkinManage imageNamed:@"btn_share_delete"] forState:UIControlStateNormal];
            [self.btnDelete setTitle:@"删除" forState:UIControlStateNormal];
            [Common setButtonImageLeftTitleRight:self.btnDelete spacing:10];
            self.viewSeparate1.frame = CGRectMake(self.btnDelete.right, 8.5, 0.5, 32);
            
            self.btnInviteAnswer.hidden = NO;
            self.btnInviteAnswer.frame = CGRectMake(self.btnDelete.right, 0, fTabW, 50);
            [Common setButtonImageLeftTitleRight:self.btnInviteAnswer spacing:10];
            
            self.viewSeparate2.hidden = NO;
            self.viewSeparate2.frame = CGRectMake(self.btnInviteAnswer.right, 8.5, 0.5, 32);
            
            self.btnAddAnswer.hidden = NO;
            self.btnAddAnswer.frame = CGRectMake(self.btnInviteAnswer.right, 0, fTabW, 50);
            [Common setButtonImageLeftTitleRight:self.btnAddAnswer spacing:10];
        }
        else
        {
            fTabW = kScreenWidth/2;
            
            self.btnInviteAnswer.hidden = NO;
            self.btnInviteAnswer.frame = CGRectMake(0, 0, fTabW, 50);
            [Common setButtonImageLeftTitleRight:self.btnInviteAnswer spacing:10];
            self.viewSeparate1.frame = CGRectMake(self.btnInviteAnswer.right, 8.5, 0.5, 32);
            
            self.btnAddAnswer.hidden = NO;
            self.btnAddAnswer.frame = CGRectMake(self.btnInviteAnswer.right, 0, fTabW, 50);
            [Common setButtonImageLeftTitleRight:self.btnAddAnswer spacing:10];
        }
        
        btnRight.hidden = YES;
    }
    else if([self.m_blogVo.strBlogType isEqualToString:@"activity"])
    {
        //活动
        fTabW = kScreenWidth/2;
        
        self.btnReply.hidden = NO;
        self.btnReply.frame = CGRectMake(0, 0, fTabW, 50);
        [Common setButtonImageLeftTitleRight:self.btnReply spacing:10];
        self.viewSeparate1.frame = CGRectMake(self.btnReply.right, 8.5, 0.5, 32);
        
        self.btnPraise.hidden = NO;
        self.btnPraise.frame = CGRectMake(self.btnReply.right, 0, fTabW, 50);
        
        if(self.m_blogVo.strMentionID.length >0)
        {
            [self.btnPraise setImage:[UIImage imageNamed:@"btn_share_praise_h"] forState:UIControlStateNormal];
        }
        else
        {
            [self.btnPraise setImage:[SkinManage imageNamed:@"btn_share_praise"] forState:UIControlStateNormal];
        }
        
        [Common setButtonImageLeftTitleRight:self.btnPraise spacing:10];
    }
    else
    {
        //分享和投票
        if ([self.m_blogVo.strCreateBy isEqualToString:[Common getCurrentUserVo].strUserID])
        {
            [self.btnDelete setImage:[SkinManage imageNamed:@"btn_share_delete"] forState:UIControlStateNormal];
            [self.btnDelete setTitle:@"删除" forState:UIControlStateNormal];
        }
        else
        {
            [self.btnDelete setImage:[SkinManage imageNamed:@"btn_share_reward"] forState:UIControlStateNormal];
            if (_shareType == ShareDetailViewControllerIS) {
                [self.btnDelete setTitle:@"审核退回" forState:UIControlStateNormal];
            }else{
                [self.btnDelete setTitle:@"打赏" forState:UIControlStateNormal];

            }
        }
        self.btnDelete.hidden = NO;
        self.btnDelete.frame = CGRectMake(0, 0, fTabW, 50);
        [Common setButtonImageLeftTitleRight:self.btnDelete spacing:10];
        self.viewSeparate1.frame = CGRectMake(self.btnDelete.right, 8.5, 0.5, 32);
        
        self.btnReply.hidden = NO;
        self.btnReply.frame = CGRectMake(self.btnDelete.right, 0, fTabW, 50);
        [Common setButtonImageLeftTitleRight:self.btnReply spacing:10];
        
        self.viewSeparate2.hidden = NO;
        self.viewSeparate2.frame = CGRectMake(self.btnReply.right, 8.5, 0.5, 32);
        
        if(self.m_blogVo.strMentionID.length >0)
        {
            [self.btnPraise setImage:[UIImage imageNamed:@"btn_share_praise_h"] forState:UIControlStateNormal];
        }
        else
        {
            [self.btnPraise setImage:[SkinManage imageNamed:@"btn_share_praise"] forState:UIControlStateNormal];
        }
        self.btnPraise.hidden = NO;
        self.btnPraise.frame = CGRectMake(self.btnReply.right, 0, fTabW, 50);
        [Common setButtonImageLeftTitleRight:self.btnPraise spacing:10];
    }
    self.viewBottom.hidden = NO;
    self.viewSeparate1.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.viewSeparate2.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [tableViewShare reloadData];
}

- (void)refreshHeaderView
{
    [shareHeaderView refreshView:self.m_blogVo];
    [tableViewShare layoutIfNeeded];
}
- (void)moveActoion{
    btnRight.selected = NO;
    POView.hidden = YES;
    
}
- (void)doShare:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
    if ([sender.titleLabel.text isEqualToString:@"审核"]) {
        if (sender.selected) {
            
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:10 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
                POView.hidden = NO;
            } completion:^(BOOL finished) {
                
            }];
        }else{
            
            POView.hidden = YES;

            }
        
        return;
    }
    if (self.m_shareInfoVo == nil)
    {
        ShareResType shareResType;
        NSString *strStreamID;
        if ([self.m_blogVo.strBlogType isEqualToString:@"answer"])
        {
            shareResType = ShareResAnswerType;
            strStreamID = self.m_blogVo.strQuestionID;
        }
        else if ([self.m_blogVo.strBlogType isEqualToString:@"activity"])
        {
            shareResType = ShareResActivityType;
            strStreamID = self.m_blogVo.streamId;
            
            [MobAnalytics event:@"shareButton"];
        }
        else
        {
            shareResType = ShareResShareType;
            strStreamID = self.m_blogVo.streamId;
        }
        
        [Common showProgressView:nil view:self.view modal:NO];
        [ServerProvider getShareInformation:strStreamID andResType:shareResType andAnswerID:self.m_blogVo.streamId result:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            if (retInfo.bSuccess)
            {
                self.m_shareInfoVo = retInfo.data;
                [BusinessCommon shareContentToThirdPlatform:self shareVo:self.m_shareInfoVo shareList:nil];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
    else
    {
        [BusinessCommon shareContentToThirdPlatform:self shareVo:self.m_shareInfoVo shareList:nil];
    }
}

- (void)backButtonClicked
{
    if (self.nDoShareAction == 1 && [self.parentController isKindOfClass:[ShareDetailViewController class]]) {
        ShareDetailViewController *detailController = self.parentController;
        [detailController loadAnswerData:YES];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

//刷新分享列表
- (void)refreshShareList
{
    //暂时忽略收藏的刷新，让用户主动下拉刷新
    //    if (self.bDoCollectionAction)
    //    {
    //        [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshShareListAfterCollection" object:nil];
    //    }
    if (self.nDoShareAction>0)
    {
        BlogVo *blogVo = nil;
        if (self.nDoShareAction == 2)
        {
            //删除了分享
            blogVo = self.m_originalBlogVo;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshShareListFromDetail" object:blogVo];
        self.nDoShareAction = 0;
    }
}

//切换底部列表
- (void)switchBottomList:(UIButton *)sender
{
    CGPoint ptOffset = tableViewShare.contentOffset;
    BOOL bHeaderFloat = ptOffset.y > nTableHeaderH+1?YES:NO;
    
    if (nBottomListType == 0)
    {
        nCommentScrollH = ptOffset.y;
    }
    else
    {
        nPraiseScrollH = ptOffset.y;
    }
    
    if(sender.tag == 1002)
    {
        if (nBottomListType != 0)
        {
            
            nBottomListType = 0;
            [tableViewShare reloadData];
            
            if (bHeaderFloat)
            {
                //如果当前已经悬停了，接下来判断被切换的视图之前高度是否大于悬停，
                //是则保留之前的，否则使用固定高度（该固定高度为悬停时的最小高度）
                if (nCommentScrollH >= nTableHeaderH)
                {
                    [tableViewShare setContentOffset:CGPointMake(ptOffset.x, nCommentScrollH) animated:NO];
                }
                else
                {
                    [tableViewShare setContentOffset:CGPointMake(ptOffset.x, nTableHeaderH) animated:NO];
                }
            }
            else
            {
                //非悬停状态，则不改变table的offset
            }
        }
    }
    else
    {
        if (nBottomListType != 1)
        {
            //赞列表
            nBottomListType = 1;
            [tableViewShare reloadData];
            
            if (bHeaderFloat)
            {
                //如果当前已经悬停了，接下来判断被切换的视图之前高度是否大于悬停，
                //是则保留之前的，否则使用固定高度（该固定高度为悬停时的最小高度）
                if (nPraiseScrollH >= nTableHeaderH)
                {
                    [tableViewShare setContentOffset:CGPointMake(ptOffset.x, nPraiseScrollH) animated:NO];
                }
                else
                {
                    [tableViewShare setContentOffset:CGPointMake(ptOffset.x, nTableHeaderH) animated:NO];
                }
            }
            
            if (aryPraise.count == 0 && self.m_blogVo.nPraiseCount > 0)
            {
                [self footerRereshing];
            }
        }
    }
    
    //上拉加载状态
    if (nBottomListType == 0)
    {
        if (bCommentCompleted)
        {
            [tableViewShare.mj_footer endRefreshingWithNoMoreData];
        }
        else
        {
            [tableViewShare.mj_footer endRefreshing];
        }
    }
    else
    {
        if (bPraiseCompleted)
        {
            [tableViewShare.mj_footer endRefreshingWithNoMoreData];
        }
        else
        {
            [tableViewShare.mj_footer endRefreshing];
        }
    }
    
    //    //增加滑动杆的动画
    //    UIView *viewSelection = (UIView*)[tableViewShare.tableHeaderView viewWithTag:1000];
    //    if (nBottomListType == 0)
    //    {
    //        //评论
    //        [UIView animateWithDuration:0.5 animations:^{
    //            [viewSelection mas_updateConstraints:^(MASConstraintMaker *make) {
    //                make.left.equalTo(0);
    //            }];
    //            [self.view layoutIfNeeded];
    //        }];
    //    }
    //    else
    //    {
    //        //赞
    //        [UIView animateWithDuration:0.3 animations:^{
    //            [viewSelection mas_updateConstraints:^(MASConstraintMaker *make) {
    //                make.left.equalTo(kScreenWidth/2);
    //            }];
    //            [self.view layoutIfNeeded];
    //        }];
    //    }
}

#pragma mark - 底部按钮action
- (void)bottomButtonAction:(UIButton *)sender
{
    if(self.btnDelete == sender)
    {
        if([[self.btnDelete titleForState:UIControlStateNormal] isEqualToString:@"删除"])
        {
            if ([Common ask:[NSString stringWithFormat:@"你确认要删除该%@？",strTypeName]])
            {
                ResultBlock resultBlock = ^(ServerReturnInfo *retInfo){
                    [Common hideProgressView:self.view];
                    if (retInfo.bSuccess)
                    {
                        //刷新列表
                        self.nDoShareAction = 2;
                        if ([self.m_blogVo.strBlogType isEqualToString:@"answer"]) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteAnswerNotification" object:self.m_blogVo.streamId];
                        }
                        [self backButtonClicked];
                    }
                    else
                    {
                        [Common tipAlert:retInfo.strErrorMsg];
                    }
                };
                
                [Common showProgressView:nil view:self.view modal:NO];
                if ([self.m_blogVo.strBlogType isEqualToString:@"qa"])
                {
                    [ServerProvider deleteQusetion:self.m_blogVo.streamId result:resultBlock];
                }
                else if ([self.m_blogVo.strBlogType isEqualToString:@"answer"])
                {
                    [ServerProvider deleteAnswer:self.m_blogVo.streamId result:resultBlock];
                }
                else
                {
                    [ServerProvider deleteShareArticle:self.m_blogVo.streamId result:resultBlock];
                }
            }
        }
        else
        {
            //打赏
            if(!rewardView.bShow)
            {
                rewardView.bShow = YES;
                [AppDelegate getSlothAppDelegate].currentPageName = PublishPage;
                if (_shareType == ShareDetailViewControllerIS) {
                    rewardView.statusType = RewardViewIS;
                }else{
                    rewardView.statusType = RewardViewNO;
                }
                
                [self.view addSubview:rewardView];
                rewardView.alpha = 0.0;
                [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    rewardView.alpha = 1.0;
                } completion:^(BOOL finished){
                    [rewardView beginningAnimation];
                }];
            }
            else
            {
                [rewardView closeView:YES];
            }
        }
    }
    else if (_btnPraise == sender)
    {
        //赞
        [Common showProgressView:nil view:self.view modal:NO];
        [ServerProvider praiseBlog:self.m_blogVo.streamId type:self.m_blogVo.strBlogType result:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            if (retInfo.bSuccess)
            {
                NSString  *paiserStr = retInfo.data;
                self.m_blogVo.strMentionID = paiserStr;
                if (paiserStr.length > 0)
                {
                    _isFavorite = 0;
                    self.m_blogVo.nPraiseCount +=1;
                }
                else
                {
                    _isFavorite = 1;
                    self.m_blogVo.nPraiseCount -=1;
                    if (self.m_blogVo.nPraiseCount <= 0)
                    {
                        self.m_blogVo.nPraiseCount = 0;
                    }
                }
                //change by fjz （点赞动画）
                if (_isFavorite == 0)
                {
//                    CGFloat temp = 8;
//                    
//                    CGFloat webViewX = self.btnPraise.imageView.frame.origin.x;
//                    CGFloat webViewY = self.btnPraise.imageView.frame.origin.y;
//                    CGFloat webViewW = self.btnPraise.imageView.frame.size.width;
//                    self.myWebView.frame = CGRectMake(webViewX - temp, webViewY - temp - 2, webViewW + temp * 2, webViewW + temp * 2);
//                    [self.btnPraise addSubview: self.myWebView];
//                    
//                    NSString *path = [[NSBundle mainBundle] pathForResource:@"tzhLike" ofType:@"gif"];
//                    NSData *gifData = [NSData dataWithContentsOfFile:path];
//                    [self.myWebView loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [Common bubbleTip:@"点赞成功" andView:self.view];
                        [self refreshView];
                        self.m_originalBlogVo.nPraiseCount = self.m_blogVo.nPraiseCount;
                        self.nDoShareAction = 1;
//                        [self.myWebView loadHTMLString:@"" baseURL:nil];
                        [self loadPraiseData:YES];
//                        [self.myWebView removeFromSuperview];
//                    });
                    
                }
                else
                {
                    [Common bubbleTip:@"取消赞成功" andView:self.view];
                    self.m_originalBlogVo.nPraiseCount = self.m_blogVo.nPraiseCount;
                    self.nDoShareAction = 1;
                    [self loadPraiseData:YES];
                    [self refreshView];
                }
                //end
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
    else if (_btnReply == sender)
    {
        //评论
        if (self.viewComment == nil || self.simpleToolBar == nil)
        {
            self.viewComment = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            [self.view addSubview:self.viewComment];
            
            self.simpleToolBar = [[SimpleToolBar alloc]init:CGRectMake(0,0,kScreenWidth,kScreenHeight) superView:self.viewComment type:SimpleToolBarFaceType];
            self.simpleToolBar.delegateFaceToolBar=self;
            self.simpleToolBar.textView.placeholder = @"评论";
            self.simpleToolBar.bEnableAT = YES;
            [self.simpleToolBar dismissKeyBoard];
            
            //添加手势，点击屏幕其他区域关闭键盘的操作
            UITapGestureRecognizer *gesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyBoard)];
            gesture.delegate = self;
            gesture.numberOfTapsRequired=1;
            [self.viewComment addGestureRecognizer:gesture];
        }
        
        self.viewComment.hidden = NO;
        [self.simpleToolBar resetFrame];
        [self.simpleToolBar.textView becomeFirstResponder];
    }
    else if (_btnInviteAnswer == sender)
    {
        //邀请回答
        ChooseUserViewController *chooseUserViewController = [[UIStoryboard storyboardWithName:@"UserModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ChooseUserViewController"];
        chooseUserViewController.delegate = self;
        [self.navigationController pushViewController:chooseUserViewController animated:YES];
    }
    else if (_btnAddAnswer == sender)
    {
        //添加回答
        EditShareBodyViewController *editShareBodyViewController = [[UIStoryboard storyboardWithName:@"ShareModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"EditShareBodyViewController"];
        editShareBodyViewController.editShareBodyType = EditShareBodyAnswerType;
        editShareBodyViewController.strRefID = self.m_blogVo.streamId;
        editShareBodyViewController.delegate = self;
        [self.navigationController pushViewController:editShareBodyViewController animated:YES];
    }
    
    if(rewardView.bShow && sender != _btnDelete)
    {
        //        self.publishView.mainTabType = self.mainTabType;
        [rewardView closeView:YES];
    }
}

- (void)paiserSuccess
{
}

- (void)closeKeyBoard
{
    //SimpleToolBar由控件去关闭键盘
    [self.simpleToolBar dismissKeyBoard];
}

//comment tableView 上拉加载
- (void)footerRereshing
{
    if (nBottomListType == 0)
    {
        //评论
        [self loadCommentData:NO];
    }
    else if (nBottomListType == 1)
    {
        //赞
        [self loadPraiseData:NO];
    }
    else
    {
        //答案
        [self loadAnswerData:NO];
    }
}

-(void)deleteCommentAction:(CommentVo*)commentVo
{
    [Common showProgressView:nil view:self.view modal:NO];
    [ServerProvider deleteComment:commentVo.strID type:self.m_blogVo.strBlogType result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            [aryComment removeObject:commentVo];
            self.m_blogVo.nCommentCount = aryComment.count;
            [tableViewShare reloadData];
            [self refreshView];
            self.m_originalBlogVo.nCommentCount = aryComment.count;
            self.nDoShareAction = 1;
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//分页加载评论数据
- (void)loadCommentData:(BOOL)bRefresh
{
    if (self.m_blogVo.streamId.length == 0)
    {
        return;
    }
    
    if (bRefresh)
    {
        //下拉刷新
        self.commentNumber = 1;
    }
    
    NSString *strEndCommentID = nil;
    BOOL bMidData = NO;
    if (self.bFirstRefresh && self.strNotifyCommentID.length>0)
    {
        bMidData = YES;
        strEndCommentID = self.strNotifyCommentID;
    }
    else
    {
        //上拖加载并且已经有数据
        if (aryComment.count>0 && !bRefresh)
        {
            CommentVo *commentVo = aryComment[aryComment.count-1];
            strEndCommentID = commentVo.strID;
        }
    }
    
    [ServerProvider getCommentList:self.m_blogVo.streamId type:self.m_blogVo.strBlogType endCommentId:strEndCommentID midData:bMidData pageNumber:self.commentNumber result:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryData = retInfo.data;
            if (bRefresh)
            {
                //下拉刷新
                if (aryData != nil && aryData.count>0)
                {
                    [aryComment removeAllObjects];
                    [aryComment addObjectsFromArray:aryData];
                }

            }
            else
            {
                //上拖加载
                [aryComment addObjectsFromArray:aryData];
            }
            
            if (aryData != nil && aryData.count>0)
            {
                self.commentNumber ++;
            }
            [tableViewShare reloadData];
            
            bCommentCompleted = [retInfo.data2 boolValue];//是否所有加载完成
            
            if ([retInfo.data2 boolValue] && !bMidData)
            {
                [tableViewShare.mj_footer endRefreshingWithNoMoreData];
            }
            else
            {
                [tableViewShare.mj_footer endRefreshing];
            }
        }
        else
        {
            [tableViewShare.mj_footer endRefreshing];
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//分页加载问答数据
- (void)loadAnswerData:(BOOL)bRefresh
{
    if (self.m_blogVo.streamId.length == 0)
    {
        return;
    }
    
    if (bRefresh)
    {
        //下拉刷新
        nAnswerPage = 1;
    }
    
    [ServerProvider getAnswerList:self.m_blogVo.streamId nPage:nAnswerPage result:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryData = retInfo.data;
            if (bRefresh)
            {
                //下拉刷新
                if (aryData != nil && aryData.count>0)
                {
                    [aryAnswer removeAllObjects];
                    [aryAnswer addObjectsFromArray:aryData];
                }
            }
            else
            {
                //上拖加载
                [aryAnswer addObjectsFromArray:aryData];
            }
            
            if (aryData != nil && aryData.count>0)
            {
                nAnswerPage ++;
            }
            [tableViewShare reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
        
        //停止刷新
        if (bRefresh)
        {
            if([retInfo.data2 boolValue])
            {
                [tableViewShare.mj_footer endRefreshingWithNoMoreData];   //最后一页
            }
            [tableViewShare.mj_header endRefreshing];
        }
        else
        {
            if([retInfo.data2 boolValue])
            {
                [tableViewShare.mj_footer endRefreshingWithNoMoreData];   //最后一页
            }
            else
            {
                [tableViewShare.mj_footer endRefreshing];
            }
        }
    }];
}

- (void)deleteAnswerNotification:(NSNotification *)notification {
    NSString *strAnswerID = notification.object;
    for (BlogVo *blogVo in aryAnswer) {
        if ([blogVo.streamId isEqualToString:strAnswerID]) {
            [aryAnswer removeObject:blogVo];
            if (self.m_blogVo.nCommentCount > 0) {
                self.m_blogVo.nCommentCount -= 1;
            }
            [tableViewShare reloadData];
            break;
        }
    }
}

//分页加载赞列表数据
- (void)loadPraiseData:(BOOL)bRefresh
{
    if (self.m_blogVo.streamId.length == 0)
    {
        return;
    }
    
    if (bRefresh)
    {
        //下拉刷新
        nPraisePage = 1;
    }
    
    [ServerProvider getPraiseList:self.m_blogVo.streamId type:self.m_blogVo.strBlogType page:nPraisePage result:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryData = retInfo.data;
            if (bRefresh)
            {
                //下拉刷新
                [aryPraise removeAllObjects];
                [aryPraise addObjectsFromArray:aryData];
            }
            else
            {
                //上拖加载
                [aryPraise addObjectsFromArray:aryData];
            }
            
            if (aryData != nil && aryData.count>0)
            {
                nPraisePage ++;
            }
            [tableViewShare reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
        
        //停止刷新
        if (bRefresh)
        {
            [tableViewShare.mj_header endRefreshing];
        }
        
        if([retInfo.data2 boolValue])
        {
            [tableViewShare.mj_footer endRefreshingWithNoMoreData];   //最后一页
        }
        else
        {
            [tableViewShare.mj_footer endRefreshing];
        }
    }];
}

//刷新table header view
- (void)refreshTableHeaderView
{
    tableViewShare.tableHeaderView = shareHeaderView;
    [shareHeaderView setNeedsLayout];
    [shareHeaderView layoutIfNeeded];
    CGSize size = [shareHeaderView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    CGFloat height = size.height;
    nTableHeaderH = height;
    
    //update the header's frame and set it again
    CGRect headerFrame = shareHeaderView.frame;
    headerFrame.size.height = height;
    shareHeaderView.frame = headerFrame;
    tableViewShare.tableHeaderView = shareHeaderView;
}

- (void)configureCommentCell:(CommentListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = NO;
    cell.entity = aryComment[indexPath.row];
}

- (void)configureAnswerCell:(AnswerListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = NO;
    cell.entity = aryAnswer[indexPath.row];
}

#pragma mark - ISSShareViewDelegate
- (void)viewOnWillDisplay:(UIViewController *)viewController shareType:(ShareType)shareType
{
    viewController.view.backgroundColor = COLOR(224, 224, 224, 1.0);
    [viewController.navigationController.navigationBar setBarTintColor:[SkinManage skinColor]];
    if (shareType == ShareTypeSinaWeibo)
    {
        viewController.title = @"新浪微博";
    }
}

#pragma mark - EditShareBodyDelegate
- (void)completedEditShareBodyWithAnswer:(BlogVo*)answerVo
{
    //刷新问答列表
    if(answerVo != nil)
    {
        [aryAnswer insertObject:answerVo atIndex:0];
        self.m_blogVo.nCommentCount += 1;
        [tableViewShare reloadData];
    }
}

#pragma mark - ChooseUserViewControllerDelegate(完成成员选择)
-(void)completeChooseUserAction:(NSMutableArray*)aryChoosedUser group:(GroupVo*)groupVo
{
    NSMutableArray *aryUser = [NSMutableArray array];
    [aryUser addObjectsFromArray:aryChoosedUser];
    
    [Common showProgressView:nil view:self.view modal:NO];
    [ServerProvider askUser:self.m_blogVo.streamId andUser:aryUser result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            [Common tipAlert:@"邀请成功"];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

#pragma mark - CommentCellDelegate
- (void)deleteComment:(CommentVo*)commentVo
{
    self.commentVoTap = commentVo;
    
    UIAlertView *alertViewTemp =[[UIAlertView alloc] initWithTitle:@"" message:@"您确认要删除该评论？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    alertViewTemp.tag = 2002;
    [alertViewTemp show];
}

- (void)replyComment:(CommentVo*)commentVo
{
    self.strParentCommentID = commentVo.strID;
    [self bottomButtonAction:self.btnReply];
}

- (void)praiseComment:(CommentVo*)commentVo
{
    [Common showProgressView:nil view:self.view modal:NO];
    [ServerProvider praiseComment:commentVo.strID type:self.m_blogVo.strBlogType result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            NSString *strTipInfo = @"";
            if(retInfo.data == nil)
            {
                //取消赞成功
                commentVo.nPraiseCount--;
                commentVo.strMentionID = nil;
                if(commentVo.nPraiseCount<0)
                {
                    commentVo.nPraiseCount = 0;
                }
                strTipInfo = @"取消赞成功";
                commentVo.praiseState = PraiseStateNomal;
            }
            else
            {
                //赞成功
                commentVo.strMentionID = commentVo.strID;
                commentVo.nPraiseCount++;
                strTipInfo = @"点赞成功";
                commentVo.praiseState = PraiseStatePraise;
            }
            
            [Common bubbleTip:strTipInfo andView:self.view];
            [tableViewShare reloadData];
            
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)copyComment:(CommentVo*)commentVo
{
    //复制文字到剪切板
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = [Common htmlTextToPlainText:commentVo.strContent];
}

- (void)tapCommentView:(CommentVo*)commentVo
{
    self.commentVoTap = commentVo;
    
    //本人是否赞过
    NSString *strPraiseTitle;
    if (commentVo.strMentionID == nil)
    {
        strPraiseTitle = @"赞";
    }
    else
    {
        strPraiseTitle = @"取消赞";
    }
    
    UIActionSheet *actionSheet;
    if([[Common getCurrentUserVo].strUserID isEqualToString:commentVo.strUserID])
    {
        //自己的评论
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"回复",strPraiseTitle,@"删除",nil];
        actionSheet.tag = 1001;
    }
    else
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"回复",strPraiseTitle,nil];
        actionSheet.tag = 1002;
    }
    
    [actionSheet showInView:self.view];
}

#pragma mark - CommentCellDelegate
- (void)praiseAnswer:(BlogVo*)answerVo
{
    [Common showProgressView:nil view:self.view modal:NO];
    [ServerProvider paiserAnswer:answerVo.streamId result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            NSString *strTipInfo = @"";
            if(retInfo.data == nil)
            {
                //取消赞成功
                answerVo.nPraiseCount--;
                answerVo.strMentionID = nil;
                if(answerVo.nPraiseCount<0)
                {
                    answerVo.nPraiseCount = 0;
                }
                strTipInfo = @"取消赞成功";
                answerVo.praiseState = PraiseStateNomal;
            }
            else
            {
                //赞成功
                answerVo.strMentionID = answerVo.streamId;
                answerVo.nPraiseCount++;
                strTipInfo = @"点赞成功";
                answerVo.praiseState = PraiseStatePraise;
            }
            
            [Common bubbleTip:strTipInfo andView:self.view];
            [tableViewShare reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2002)
    {
        //删除评论
        if (buttonIndex==1)
        {
            [self deleteCommentAction:self.commentVoTap];
        }
    }
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1001)
    {
        //自己的评论
        if(buttonIndex == 0)
        {
            //回复
            [self replyComment:self.commentVoTap];
        }
        else if (buttonIndex == 1)
        {
            //赞
            [self praiseComment:self.commentVoTap];
        }
        else if (buttonIndex == 2)
        {
            //删除
            [self deleteComment:self.commentVoTap];
        }
    }
    else if (actionSheet.tag == 1002)
    {
        //他人的评论
        if(buttonIndex == 0)
        {
            //回复
            [self replyComment:self.commentVoTap];
        }
        else if (buttonIndex == 1)
        {
            //赞
            [self praiseComment:self.commentVoTap];
        }
        else if (buttonIndex == 2)
        {
            //复制
            [self copyComment:self.commentVoTap];
        }
    }
}

#pragma mark - SimpleToolBarDelegate
- (void)sendTextAction:(NSString*)strText
{
    if (strText.length == 0)
    {
        return;
    }
    
    //隐藏评论框
    [self closeKeyBoard];
    
    [Common showProgressView:nil view:self.view modal:NO];
    [ServerProvider addComment:self.strParentCommentID blogId:self.m_blogVo.streamId content:strText type:self.m_blogVo.strBlogType result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            //刷新视图
            NSMutableArray *aryResult = retInfo.data;
            if (aryResult.count>0)
            {
                /**
                 *只要请求成功，就把我们输入的内容展示出来，不需要再从后台返回数据
                 */
//                CommentVo *commentVo = [[CommentVo alloc]init];
//                commentVo = [aryResult objectAtIndex:0];
//                commentVo.strContent = strText;
//                
//                /**
//                 *发送文本的时间设置
//                 */
//                NSDate *nowDate = [NSDate date];
//                NSDateFormatter *timeFormatter  = [[NSDateFormatter alloc]init];
//                timeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
//                commentVo.strCreateDate = [timeFormatter stringFromDate:nowDate];
//                
//                /**
//                 * 设置评论人的ID
//                 */
//                commentVo.strUserID = [Common getCurrentUserVo].strUserID;
                
//                [aryComment insertObject:commentVo atIndex:0];
//                self.m_blogVo.nCommentCount = aryComment.count;
            }
            
            self.strParentCommentID = nil;
            //清理数据
            [self.simpleToolBar clearToolBarData];
            
            [self closeKeyBoard];
            self.nDoShareAction = 1;
            
            self.m_originalBlogVo.nCommentCount = aryComment.count;
//            [tableViewShare reloadData];
            [self loadCommentData:YES];
            [self refreshView];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

-(void)hideKeyboard
{
    self.viewComment.hidden = YES;
}

-(void)showKeyboard
{
    self.viewComment.hidden = NO;
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (nBottomListType == 0)
    {
        //评论
        return aryComment.count;
    }
    else if (nBottomListType == 1)
    {
        //赞
        return aryPraise.count;
    }
    else
    {
        //答案
        return aryAnswer.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (nBottomListType == 0)
    {
        //评论
        CommentListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentListCell" forIndexPath:indexPath];
        cell.delegate = self;
        [self configureCommentCell:cell atIndexPath:indexPath];
        return cell;
    }
    else if (nBottomListType == 1)
    {
        //赞
        PraiseListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PraiseListCell" forIndexPath:indexPath];
        cell.entity = aryPraise[indexPath.row];
        return cell;
    }
    else
    {
        //答案
        AnswerListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnswerListCell" forIndexPath:indexPath];
        cell.delegate = self;
        [self configureAnswerCell:cell atIndexPath:indexPath];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(nBottomListType == 0)
    {
        return [tableView fd_heightForCellWithIdentifier:@"CommentListCell" cacheByIndexPath:indexPath configuration:^(id cell) {
            [self configureCommentCell:cell atIndexPath:indexPath];
        }];
    }
    else if (nBottomListType == 1)
    {
        return 63;
    }
    else
    {
        return [tableView fd_heightForCellWithIdentifier:@"AnswerListCell" cacheByIndexPath:indexPath configuration:^(id cell) {
            [self configureAnswerCell:cell atIndexPath:indexPath];
        }];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *header = @"ShareSectionHeader";
    UITableViewHeaderFooterView *viewHeader;
    viewHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:header];
    if (viewHeader == nil)
    {
        viewHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:header];
        viewHeader.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        
        UIView *viewBK = [[UIView alloc]initWithFrame:CGRectMake(-0.5, 0, kScreenWidth+1, 43.5)];
        viewBK.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        viewBK.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
        viewBK.layer.borderWidth = 0.5;
        viewBK.layer.masksToBounds = YES;
        [viewHeader addSubview:viewBK];
        
        UIView *viewContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 43.5)];
        viewContainer.tag = 1000;
        viewContainer.backgroundColor = [UIColor clearColor];
        [viewHeader addSubview:viewContainer];
        
        UIView *viewSelection = [[UIView alloc]initWithFrame:CGRectMake(0, 41, kScreenWidth/2, 2)];
        viewSelection.tag = 1001;
        viewSelection.backgroundColor = COLOR(239, 111, 88, 1.0);
        [viewContainer addSubview:viewSelection];
        
        UIView *viewLineV = [[UIView alloc]initWithFrame:CGRectMake(kScreenWidth/2, 6, 0.5, 32)];
        viewLineV.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];;
        [viewContainer addSubview:viewLineV];
        
        UIButton *btnCommentTab = [UIButton buttonWithType:UIButtonTypeSystem];
        btnCommentTab.tag = 1002;
        btnCommentTab.frame = CGRectMake(0, 0, kScreenWidth/2, 43.5);
        btnCommentTab.titleLabel.font = [UIFont systemFontOfSize:14];
        [btnCommentTab setTitle:@"0 条评论" forState:UIControlStateNormal];
        [btnCommentTab addTarget:self action:@selector(switchBottomList:) forControlEvents:UIControlEventTouchUpInside];
        [viewContainer addSubview:btnCommentTab];
        
        UIButton *btnPraiseTab = [UIButton buttonWithType:UIButtonTypeSystem];
        btnPraiseTab.tag = 1003;
        btnPraiseTab.frame = CGRectMake(btnCommentTab.right, 0, kScreenWidth/2, 43.5);
        btnPraiseTab.titleLabel.font = [UIFont systemFontOfSize:14];
        [btnPraiseTab setTitle:@"0 个赞" forState:UIControlStateNormal];
        [btnPraiseTab addTarget:self action:@selector(switchBottomList:) forControlEvents:UIControlEventTouchUpInside];
        [viewContainer addSubview:btnPraiseTab];
        
        //问答的回答数量
        UILabel *lblAnswerNum = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, kScreenWidth-24, 43.5)];
        lblAnswerNum.tag = 1004;
        lblAnswerNum.font = [UIFont systemFontOfSize:14];
        lblAnswerNum.textAlignment = NSTextAlignmentLeft;
        [viewHeader addSubview:lblAnswerNum];
        
        //空白数据提示View
        TableNoDataView *tableNoDataView = [[TableNoDataView alloc]initWithFrame:CGRectMake(0, viewBK.bottom, kScreenWidth, 300) tip:nil];
        tableNoDataView.tag = 1005;
        [viewHeader addSubview:tableNoDataView];
    }
    
    UIView *viewContainer = (UIView*)[viewHeader viewWithTag:1000];
    UIView *viewSelection = (UIView*)[viewContainer viewWithTag:1001];
    UIButton *btnCommentTab = (UIButton*)[viewContainer viewWithTag:1002];
    UIButton *btnPraiseTab = (UIButton*)[viewContainer viewWithTag:1003];
    UILabel *lblAnswerNum = (UILabel*)[viewHeader viewWithTag:1004];
    TableNoDataView *tableNoDataView = (TableNoDataView*)[viewHeader viewWithTag:1005];
    
    if ([self.m_blogVo.strBlogType isEqualToString:@"qa"])
    {
        viewContainer.hidden = YES;
        lblAnswerNum.hidden = NO;
        
        NSMutableAttributedString *attrAnswerNum = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%li 条回答",(long)self.m_blogVo.nCommentCount]];
        [attrAnswerNum addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Menu_Title_Color"] range:NSMakeRange(0, attrAnswerNum.length-3)];
        [attrAnswerNum addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Tab_Item_Color"] range:NSMakeRange(attrAnswerNum.length-3, 3)];
        lblAnswerNum.attributedText = attrAnswerNum;
        
        if(aryAnswer.count == 0)
        {
            [tableNoDataView setTipText:@"快来添加你的答案吧"];
            tableNoDataView.hidden = NO;
        }
        else
        {
            tableNoDataView.hidden = YES;
        }
    }
    else
    {
        //增加滑动杆的动画
        if (nBottomListType == 0)
        {
            //评论
            [UIView animateWithDuration:0.5 animations:^{
                viewSelection.frame = CGRectMake(0, 41, kScreenWidth/2, 2);
            }];
            
            if (aryComment.count == 0)
            {
                [tableNoDataView setTipText:@"快来发表你的评论吧"];
                tableNoDataView.hidden = NO;
            }
            else
            {
                tableNoDataView.hidden = YES;
            }
        }
        else if (nBottomListType == 1)
        {
            //赞
            [UIView animateWithDuration:0.5 animations:^{
                viewSelection.frame = CGRectMake(kScreenWidth/2, 41, kScreenWidth/2, 2);
            }];
            
            if (aryPraise.count == 0)
            {
                [tableNoDataView setTipText:@"快来点赞吧"];
                tableNoDataView.hidden = NO;
            }
            else
            {
                tableNoDataView.hidden = YES;
            }
        }
        
        viewContainer.hidden = NO;
        lblAnswerNum.hidden = YES;
        
        NSMutableAttributedString *attrComment = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%li 条评论",(long)self.m_blogVo.nCommentCount]];
        [attrComment addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Menu_Title_Color"] range:NSMakeRange(0, attrComment.length-3)];
        [attrComment addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Tab_Item_Color"] range:NSMakeRange(attrComment.length-3, 3)];
        [btnCommentTab setAttributedTitle:attrComment forState:UIControlStateNormal];
        
        NSMutableAttributedString *attrPraise = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%li 个赞",(long)self.m_blogVo.nPraiseCount]];
        [attrPraise addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Menu_Title_Color"] range:NSMakeRange(0, attrPraise.length-2)];
        [attrPraise addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Tab_Item_Color"] range:NSMakeRange(attrPraise.length-2, 2)];
        [btnPraiseTab setAttributedTitle:attrPraise forState:UIControlStateNormal];
    }
    
    return viewHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat fHeight = 43.5;
    if ([self.m_blogVo.strBlogType isEqualToString:@"qa"])
    {
        if(aryAnswer.count == 0)
        {
            fHeight += 300;
        }
    }
    else
    {
        //增加滑动杆的动画
        if (nBottomListType == 0)
        {
            //评论
            if (aryComment.count == 0)
            {
                fHeight += 300;
            }
        }
        else if (nBottomListType == 1)
        {
            //赞
            if (aryPraise.count == 0)
            {
                fHeight += 300;
            }
        }
    }
    return fHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (nBottomListType == 0)
    {
        //评论
        [self tapCommentView:aryComment[indexPath.row]];
    }
    else if (nBottomListType == 1)
    {
        //赞
        PraiseVo *userVo = aryPraise[indexPath.row];
        
        UserProfileViewController *userProfileViewController = [[UserProfileViewController alloc]init];
        userProfileViewController.strUserID = userVo.strID;
        [self.navigationController pushViewController:userProfileViewController animated:YES];
    }
    else
    {
        //答案
        ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc] init];
        shareDetailViewController.parentController = self;
        BlogVo *blog = aryAnswer[indexPath.row];
        blog.strTitle = self.m_blogVo.strTitle;
        shareDetailViewController.m_originalBlogVo = blog;
        if (blog.streamId.length == 0)
        {
            [Common tipAlert:@"数据异常，请求失败"];
            return;
        }
        
        [self.navigationController pushViewController:shareDetailViewController animated:YES];
    }
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    fScrollOffsetY = scrollView.contentOffset.y;
     POView.hidden = YES;

    btnRight.selected = NO;

    if (scrollView == tableViewShare)
    {
        self.bScrolling = YES;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == tableViewShare)
    {
        __block ShareDetailViewController* bself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            bself.bScrolling = NO;
        });
    }
    
    //向下滚动弹出顶部导航和底部筛选按钮
    UIView *viewNavBK = [viewNavBar viewWithTag:2001];
    if (scrollView.contentOffset.y<fScrollOffsetY && bCompletedAnimate)
    {
        //显示
        if(viewNavBar.top < 0 || _viewBottom.top > kScreenHeight-50)//当已经显示就不用再执行动画显示了
        {
            bCompletedAnimate = NO;
            viewNavBK.alpha = 0;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                viewNavBar.frame = CGRectMake(0, 0, kScreenWidth, NAV_BAR_HEIGHT);
                _viewBottom.frame = CGRectMake(0, kScreenHeight-50, kScreenWidth, 50);
                tableViewShare.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-50);
                viewNavBK.alpha = 1.0;
            } completion:^(BOOL finished) {
                bCompletedAnimate = YES;
            }];
        }
        else
        {
            viewNavBK.alpha = 1.0;
        }
    }
    else if (scrollView.contentOffset.y>fScrollOffsetY && bCompletedAnimate)
    {
        //隐藏
        if(viewNavBar.top >= 0 || _viewBottom.height <= kScreenHeight-50)
        {
            bCompletedAnimate = NO;
            viewNavBK.alpha = 1.0;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                viewNavBar.frame = CGRectMake(0, -NAV_BAR_HEIGHT, kScreenWidth, NAV_BAR_HEIGHT);
                _viewBottom.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 50);
                tableViewShare.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
                viewNavBK.alpha = 0;
            } completion:^(BOOL finished) {
                bCompletedAnimate = YES;
            }];
        }
        else
        {
            viewNavBK.alpha = 0;
        }
    }
}

#pragma mark - 头像点击事件
- (void)commentCell:(CommentListCell *)commentListCell iconClick:(CommentVo *)commentVo
{
    UserProfileViewController *userProfileViewController = [[UserProfileViewController alloc]init];
    userProfileViewController.strUserID = commentVo.strUserID;
    
    [self.navigationController pushViewController:userProfileViewController animated:YES];
}

@end
