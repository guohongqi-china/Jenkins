//
//  UserProfileViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/26.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "UserProfileViewController.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import "UIImage+UIImageScale.h"
#import "MJRefresh.h"
#import "ShareListCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "UserProfileCollectionCell.h"
#import "HMWaterflowLayout.h"
#import "UIViewExt.h"
#import "ShareDetailViewController.h"
#import "UserDetailView.h"
#import "ChatContentViewController.h"
#import "ChatObjectVo.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "Utils.h"
#import "CommonUserListViewController.h"
#import "TableNoDataView.h"
#import "IntegralInfoVo.h"

@interface UserProfileViewController ()<UITableViewDelegate, UITableViewDataSource,ShareListCellDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    CGFloat _headerHeight;
    CGFloat _subHeaderHeight;
    CGFloat _headerSwitchOffset;
    CGFloat _avatarImageSize;
    CGFloat _avatarImageCompressedSize;
    BOOL _barIsCollapsed;
    BOOL _barAnimationComplete;
    
    UserVo *_userVo;
    
    //Navigation Bar
    UILabel* lblNavTitle;
    NSLayoutConstraint *constraintAvatarTop;
    
    //UserDetailView
    UserDetailView *userDetailView;
    
    //TableView Header view
    UIImageView* avatarImageView;             //头像ImageView
    UIImageView* imgViewAddCoverImage;        //添加封面图片 - 图标
    UILabel* nameLabel;
    UIImageView *imgViewLevel;
    UILabel* lblSignature;
    UIButton* btnFans;
    UIButton* btnAttentionTo;
    UIButton *btnAttention;
    
    //Table Section Header
    UISegmentedControl* _segmentedControl;
    
    //底部tableView
    NSInteger nBottomListType;          //底部列表类型，0：分享，1：赞，2：收藏
    NSMutableArray *aryShare;
    
    NSMutableArray *aryPraise;
    NSInteger nPraisePage;
    
    NSMutableArray *aryCollection;
    NSInteger nCollectionPage;
    
    //保存评论和赞的底部的上拉加载的状态
    BOOL bShareCompleted;
    BOOL bPraiseCompleted;
    BOOL bCollectCompleted;
    
    NSInteger nShareScrollH;          //当前处于comment情况下，tableView滚动的高度
    NSInteger nPraiseScrollH;         //当前处于praise情况下，tableView滚动的高度
    NSInteger nCollectionScrollH;     //当前处于praise情况下，tableView滚动的高度
    NSInteger nTableHeaderH;
    
    BOOL bFirstEnter;                 //是否第一次进入
    CGFloat fLastTitlePos;
    
    MJRefreshFooter *refreshFooter;
}

@property (nonatomic,strong) UIView *viewNavBar;
@property (nonatomic,strong) UIImageView *imageHeaderView;              //封面图
@property (nonatomic,strong) UIVisualEffectView *visualEffectView;
@property (nonatomic,strong) UIView *customTitleView;
@property (nonatomic,strong) UIImage *originalBackgroundImage;
@property (nonatomic,strong) NSMutableDictionary* blurredImageCache;
@property(nonatomic , strong)UIView *tableHeaderView;
@property(nonatomic , strong)UIView *subHeaderPart;
@end

@implementation UserProfileViewController

- (void)dealloc
{
    _originalBackgroundImage = nil;
    [_blurredImageCache removeAllObjects];
    _blurredImageCache = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RefreshUserProfilePage" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    self.fd_prefersNavigationBarHidden = YES;
    
    [self initData];
    [self initView];
    
    //他人的个人中心
    if (![self.strUserID isEqualToString:[Common getCurrentUserVo].strUserID])
    {
        self.navigationItem.rightBarButtonItem = [self rightBtnItemWithImage:@"nav_chat"];
    }
    self.navigationItem.leftBarButtonItem = [self rightBtnItemWithImage:@"nav_userprofile_back"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"RefreshUserProfilePage" object:nil];
    
    [self getUserDetail:^{
        nBottomListType = 1;
        [self refreshView];
        [self segmentedAction:_segmentedControl];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //    if(bFirstEnter)
    {
        [self configureNavBar];
        [self.tableViewList.tableHeaderView exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
        bFirstEnter = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Theme_Color"]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
}

- (void)initData
{
    aryShare = [NSMutableArray array];
    aryPraise = [NSMutableArray array];
    aryCollection = [NSMutableArray array];
    
    bShareCompleted = NO;
    bPraiseCompleted = NO;
    bCollectCompleted = YES;
    bFirstEnter = YES;
    
    nPraisePage = 1;
    nCollectionPage = 1;
    
    nTableHeaderH = 275-64;
    self.nCellHeight = 0;
    fLastTitlePos = 0;
}

- (void)initView
{
//    [self configureNavBar];
    
    _headerHeight = 160.0;          //封面图
    _subHeaderHeight = 120.0+0.5;   //头像模块 115.0
    
#pragma mark - change by fjz  默认两行
    //判断是否签名换行，
//    CGSize sizeSignature = [Common getStringSize:_userVo.strSignature font:[UIFont systemFontOfSize:13] bound:CGSizeMake(kScreenWidth-92, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
//    if(sizeSignature.height > 25)
//    {
        _subHeaderHeight += 15.5;
//    }
    
    _avatarImageSize = 60;
    _avatarImageCompressedSize = 45;//45
    _barIsCollapsed = false;
    _barAnimationComplete = false;
    
    //    UIApplication* sharedApplication = [UIApplication sharedApplication];
    CGFloat kStatusBarHeight = 20;//sharedApplication.statusBarFrame.size.height;
    CGFloat kNavBarHeight =  44;//self.navigationController.navigationBar.frame.size.height;
    
    /* To compensate  the adjust scroll insets */
    _headerSwitchOffset = _headerHeight - (kStatusBarHeight + kNavBarHeight)  - kStatusBarHeight - kNavBarHeight;
    
    NSMutableDictionary* views = [NSMutableDictionary new];
    views[@"super"] = self.view;
    
    UITableView* tableView = [[UITableView alloc] init];
    tableView.translatesAutoresizingMaskIntoConstraints = NO; //autolayout
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableViewList = tableView;
    [self.view addSubview:tableView];
    views[@"tableView"] = tableView;
    
    [self.tableViewList registerNib:[UINib nibWithNibName:@"ShareListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ShareListCell"];
    [self.tableViewList registerNib:[UINib nibWithNibName:@"UserCollectionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"UserCollectionCell"];
    [self.tableViewList registerNib:[UINib nibWithNibName:@"UserProfileCollectionCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"UserProfileCollectionCell"];
    self.tableViewList.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //上拉加载更多
    @weakify(self)
    refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        if (self->nBottomListType == 0)
        {
            [self loadShareData:NO];
        }
        else if (self->nBottomListType == 1)
        {
            [self loadPraiseData:NO];
        }
        else
        {
            [self loadCollectionData:NO];
        }
    }];
    self.tableViewList.mj_footer = refreshFooter;
    
    UIImage* bgImage = [UIImage imageNamed:@"default_image"];//封面图
    _originalBackgroundImage = bgImage;
    
    UIImageView* headerImageView = [[UIImageView alloc] initWithImage:bgImage]; //封面图
    headerImageView.userInteractionEnabled = YES;
    headerImageView.translatesAutoresizingMaskIntoConstraints = NO; //autolayout
    headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    headerImageView.clipsToBounds = true;
    self.imageHeaderView = headerImageView;
    views[@"headerImageView"] = headerImageView;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCoverImage)];
    [headerImageView addGestureRecognizer:tapGesture];
    
    //Table全局HeaderView
    /* Not using autolayout for this one, because i don't really have control on how the table view is setting up the items.*/
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,_headerHeight - /* To compensate  the adjust scroll insets */(kStatusBarHeight + kNavBarHeight) + _subHeaderHeight)];
    
#pragma mark to do
    tableHeaderView.backgroundColor = [SkinManage colorNamed:@"myTableheaderBK"];
    [tableHeaderView addSubview:headerImageView];
    
    UIView* subHeaderPart = [self createSubHeaderView];// [[UIView alloc] init];
    self.subHeaderPart = subHeaderPart;
    subHeaderPart.translatesAutoresizingMaskIntoConstraints = NO; //autolayout
    // subHeaderPart.backgroundColor  = [UIColor greenColor];
    [tableHeaderView insertSubview:subHeaderPart belowSubview:headerImageView];
    views[@"subHeaderPart"] = subHeaderPart;
    
    self.tableHeaderView = tableHeaderView;
    
    tableView.tableHeaderView = tableHeaderView;
    
    //头像
    avatarImageView = [self createAvatarImage];
    avatarImageView.translatesAutoresizingMaskIntoConstraints = NO; //autolayout
    views[@"avatarImageView"] = avatarImageView;
    [tableHeaderView addSubview:avatarImageView];
    
    /*
     * At this point tableHeader views are ordered like this:
     * 0 : subHeaderPart
     * 1 : headerImageView
     * 2 : avatarImageView
     */
    
    /* This is important, or section header will 'overlaps' the navbar */
    self.automaticallyAdjustsScrollViewInsets = YES;
    
    
    //Now Let's do the layout
    NSArray* constraints;
    NSLayoutConstraint* constraint;
    NSString* format;
    NSDictionary* metrics = @{
                              @"headerHeight" : [NSNumber numberWithFloat:_headerHeight- /* To compensate  the adjust scroll insets */(kStatusBarHeight + kNavBarHeight) ],
                              @"minHeaderHeight" : [NSNumber numberWithFloat:(kStatusBarHeight + kNavBarHeight)],
                              @"avatarSize" :[NSNumber numberWithFloat:_avatarImageSize],
                              @"avatarCompressedSize" :[NSNumber numberWithFloat:_avatarImageCompressedSize],
                              @"subHeaderHeight" :[NSNumber numberWithFloat:_subHeaderHeight],
                              };
    
    // 定义TableView的布局 ===== Table view should take all available space ========
    format = @"|-0-[tableView]-0-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self.view addConstraints:constraints];
    
    format = @"V:|-0-[tableView]-0-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self.view addConstraints:constraints];
    
    // 封面图和头像的水平布局 ===== Header image view should take all available width ========
    format = @"|-0-[headerImageView]-0-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [tableHeaderView addConstraints:constraints];
    
    format = @"|-0-[subHeaderPart]-0-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [tableHeaderView addConstraints:constraints];
    
    // 封面图和头像的垂直布局===== Header image view should not be smaller than nav bar and stay below navbar ========
    //minHeaderHeight = 64,subHeaderHeight = 100
    format = @"V:[headerImageView(>=minHeaderHeight)]-(subHeaderHeight@750)-|"; //封面图大于最小高度 64
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self.view addConstraints:constraints];
    
    //headerHeight = 100
    format = @"V:|-(headerHeight)-[subHeaderPart(subHeaderHeight)]";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self.view addConstraints:constraints];
    
    // 封面图黏住屏幕最上端 ===== Header image view should stick to top of the 'screen'  ========
    NSLayoutConstraint* magicConstraint = [NSLayoutConstraint constraintWithItem:headerImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0];
    [self.view addConstraint: magicConstraint];
    
    // 头像的X中心黏住左侧的固定距离 ===== avatar should stick to left with default margin spacing  ========
    NSLayoutConstraint *avatarConstraint = [NSLayoutConstraint constraintWithItem:avatarImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:tableHeaderView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:42];
    [self.view addConstraint:avatarConstraint];
    
    // === avatar is square
    constraint = [NSLayoutConstraint constraintWithItem:avatarImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:avatarImageView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0];
    [self.view addConstraint: constraint];
    
    // ===== avatar size can be between avatarSize and avatarCompressedSize
    // avatarSize = 70(优先级：760),avatarCompressedSize = 44(优先级：800)
    format = @"V:[avatarImageView(<=avatarSize@760,>=avatarCompressedSize@800)]";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views];
    [self.view addConstraints:constraints];
    
    //头像视图滚动时距离【屏幕顶部】大于等于131.5(优先级：790)
    constraintAvatarTop = [NSLayoutConstraint constraintWithItem:avatarImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:131.5];//(kStatusBarHeight + kNavBarHeight)
    constraintAvatarTop.priority = 790;
    [self.view addConstraint: constraintAvatarTop];
    
    //距离底部固定83.5(优先级：801)
    CGFloat fHeaderBottom = -83.5;
//    if(sizeSignature.height > 25)
//    {
        fHeaderBottom -= 15.5;
//    }
    constraint = [NSLayoutConstraint constraintWithItem:avatarImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:subHeaderPart attribute:NSLayoutAttributeBottom multiplier:1.0f constant:fHeaderBottom];
    constraint.priority = 801;
    [self.view addConstraint: constraint];
    
    //导航按钮
    imgViewAddCoverImage = [[UIImageView alloc]initWithImage:[SkinManage imageNamed:@"add_cover_image_icon"]];
    imgViewAddCoverImage.hidden = YES;
    [_imageHeaderView addSubview:imgViewAddCoverImage];
    
    [imgViewAddCoverImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(120, 44));
        make.bottom.equalTo(-42);
        make.centerX.equalTo(0);
    }];
}

- (void)refreshView
{
    //Navigation Bar
    lblNavTitle.text = _userVo.strUserName;
    
    //封面图
    [_imageHeaderView sd_setImageWithURL:[NSURL URLWithString:_userVo.strCoverImageURL] placeholderImage:[UIImage imageNamed:@"default_image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image)
        {
            imgViewAddCoverImage.hidden = YES;
        }
        else
        {
            image = [Common getImageWithColor:[SkinManage colorNamed:@"Theme_Color"]];
            _imageHeaderView.image = image;
            
            if ([_userVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID]) {
                imgViewAddCoverImage.hidden = NO;
            } else {
                imgViewAddCoverImage.hidden = YES;
            }
        }
        
        //生成不同模糊程度的图片
        _originalBackgroundImage = _imageHeaderView.image;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self fillBlurredImageCache];
        });
    }];
    
    //table header view
    [avatarImageView sd_setImageWithURL:[NSURL URLWithString:_userVo.strHeadImageURL] placeholderImage:[UIImage imageNamed:@"default_m"]];
    nameLabel.text = _userVo.strUserName;
    imgViewLevel.image = [UIImage imageNamed:[BusinessCommon getIntegralInfo:_userVo.fIntegrationCount].strLevelImage];
    lblSignature.text = _userVo.strSignature;
    
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%li 关注者",(long)_userVo.nFansCount]];
    [attriString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"lblBeAttention_color"] range:NSMakeRange(0, attriString.string.length-3)];
    [attriString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"lblBeAttention_back_color"] range:NSMakeRange(attriString.string.length-3, 3)];
    [btnFans setAttributedTitle:attriString forState:UIControlStateNormal];
    
    attriString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%li 正在关注",(long)_userVo.nAttentionCount]];
    [attriString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"lblBeAttention_color"] range:NSMakeRange(0, attriString.string.length-4)];
    [attriString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"lblBeAttention_back_color"] range:NSMakeRange(attriString.string.length-4, 4)];
    [btnAttentionTo setAttributedTitle:attriString forState:UIControlStateNormal];
    
    if(_userVo.bAttentioned)
    {
        [btnAttention setImage:[UIImage imageNamed:@"user_attentioned"] forState:UIControlStateNormal];
    }
    else
    {
        [btnAttention setImage:[UIImage imageNamed:@"user_not_attention"] forState:UIControlStateNormal];
    }
}

- (void)refreshData {
    [self getUserDetail:^{
        [self refreshView];
    }];
}

-(void)getUserDetail:(void(^)(void))finished
{
    [Common showProgressView:nil view:self.view modal:NO];
    [ServerProvider getUserDetail:self.strUserID result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            _userVo = (UserVo*)retInfo.data;
            if ([_userVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID])
            {
                //更新当前登录用户信息
                [Common setCurrentUserVo:_userVo];
            }
            finished();
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)righBarClick
{
    //即时聊天
    ChatObjectVo *chatObjectVo = [[ChatObjectVo alloc] init];
    chatObjectVo.nType = 1;
    chatObjectVo.strIMGURL = _userVo.strHeadImageURL;
    chatObjectVo.strNAME = _userVo.strUserName;
    chatObjectVo.strVestID = _userVo.strUserID;
    ChatContentViewController *chatContentViewController = [[ChatContentViewController alloc] init];
    chatContentViewController.m_chatObjectVo = chatObjectVo;
    [self.navigationController pushViewController:chatContentViewController animated:YES];
}

#pragma mark - NavBar configuration
- (void)configureNavBar
{
    //配置导航条
    //    self.view.backgroundColor = [UIColor blueColor];
    
    //    self.viewNavBar = [[UIView alloc]init];
    //    [self.view addSubview:self.viewNavBar];
    //    [self.viewNavBar mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.leading.top.trailing.equalTo(0);
    //        make.height.equalTo(60);
    //    }];
    
    //    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];           //文字颜色
    //
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backAction)];
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:nil];
    
    [self switchToExpandedHeader];
}

- (void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//展开Header(往下拉到顶部)
- (void)switchToExpandedHeader
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];   //清空背景图片
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.titleView = nil;
    
    _barAnimationComplete = false;
    self.imageHeaderView.image = self.originalBackgroundImage;
    
    //Inverse Z-Order of avatar Image view
    [self.tableViewList.tableHeaderView exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
}

//最小化Header(往上推，隐藏封面图)
- (void)switchToMinifiedHeader
{
    _barAnimationComplete = false;
    
    self.navigationItem.titleView = self.customTitleView;
    //    self.navigationController.navigationBar.clipsToBounds = YES;
    
    //Setting the view transform or changing frame origin has no effect, only this call does
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:60 forBarMetrics:UIBarMetricsDefault];
    
    //[self.navigationItem.titleView updateConstraintsIfNeeded];
    
    //Inverse Z-Order of avatar Image view
    [self.tableViewList.tableHeaderView exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yPos = scrollView.contentOffset.y;
    //    NSLog(@"--%f",yPos);
    //    //让头像均匀变小
    //    [avatarImageView mas_updateConstraints:^(MASConstraintMaker *make) {
    //        if (yPos > 96)
    //        {
    //            make.height.equalTo(_avatarImageCompressedSize).priority(790);
    //        }
    //        else if (yPos < 0)
    //        {
    //            make.height.equalTo(_avatarImageSize).priority(790);
    //        }
    //        else
    //        {
    //            make.height.equalTo(_avatarImageCompressedSize+(_avatarImageSize-_avatarImageCompressedSize)*((96.0-yPos)/96.0)).priority(790);
    //        }
    //    }];
    //    [self.view layoutIfNeeded];
    
//    DLog(@">>>>>>yPos(%f)----_headerHeight(%f)--_headerSwitchOffset(%f)",yPos,_headerHeight,_headerSwitchOffset);
    if (yPos > _headerSwitchOffset && !_barIsCollapsed)
    {
        [self switchToMinifiedHeader];
        _barIsCollapsed = true;
    }
    else if (yPos < _headerSwitchOffset && _barIsCollapsed)
    {
        [self switchToExpandedHeader];
        _barIsCollapsed = false;
    }
//    DLog(@"<<<<<<yPos(%f)--_headerHeight(%f)--_headerSwitchOffset(%f)",yPos,_headerHeight,_headerSwitchOffset);
    //appologies for the magic numbers
    if(yPos > _headerSwitchOffset +20 && yPos <= _headerSwitchOffset +20 +40)
    {
        CGFloat delta = (40 +20 - (yPos-_headerSwitchOffset));
        [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:delta forBarMetrics:UIBarMetricsDefault];
        
        self.imageHeaderView.image = [self blurWithImageAt:((60-delta)/60.0)];
    }
    
    if(!_barAnimationComplete && yPos > _headerSwitchOffset +20 +40)
    {
        [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
        self.imageHeaderView.image = [self blurWithImageAt:1.0];
        _barAnimationComplete = true;
    }
}

#pragma mark - privates
//创建头像视图
- (UIImageView*)createAvatarImage
{
    UIImageView* avatarView = [[UIImageView alloc] init];
    avatarView.clipsToBounds = YES;
    avatarView.contentMode = UIViewContentModeScaleAspectFill;
    avatarView.layer.cornerRadius = 5.0;
    avatarView.layer.borderColor = [SkinManage colorNamed:@"myIconBorder_Color"].CGColor;
    avatarView.layer.borderWidth = 1.0f;
    avatarView.layer.masksToBounds = YES;
    avatarView.userInteractionEnabled = YES;
    //add by fjz
    UITapGestureRecognizer *iconTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarViewClick)];
    [avatarView addGestureRecognizer:iconTap];
    return avatarView;
}

//自定义导航title
- (UIView*)customTitleView
{
    if(!_customTitleView)
    {
        UILabel* myLabel = [UILabel new];
        myLabel.text = _userVo.strUserName;
        myLabel.translatesAutoresizingMaskIntoConstraints = NO;
        myLabel.numberOfLines =1;
        [myLabel setTextColor:[SkinManage colorNamed:@"Nav_Bar_Title_Color"]];
        [myLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:17.0f]];
        
        UIView* wrapper = [UIView new];
        //        wrapper.translatesAutoresizingMaskIntoConstraints = NO;
        [wrapper addSubview:myLabel];
        lblNavTitle = myLabel;
        
        [wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[myLabel]-0-|" options:0 metrics:nil views:@{@"myLabel": myLabel}]];
        [wrapper addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[myLabel]-0-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"myLabel": myLabel}]];
        
        //mmm.. it seems that i have to set it like this, if not the view size is set to 0 by the navabar layout..
        wrapper.frame = CGRectMake(0, 0, myLabel.intrinsicContentSize.width, myLabel.intrinsicContentSize.height);
        
        wrapper.clipsToBounds = true;
        
        _customTitleView  = wrapper;
    }
    return _customTitleView;
}

//创建TableView的Header视图
- (UIView*)createSubHeaderView
{
    UIView* view = [UIView new];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(kScreenWidth).priority(800);
    }];
    
    UIButton* followButton = [UIButton buttonWithType:UIButtonTypeSystem];
    followButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [followButton setTitle:@"详细资料" forState:UIControlStateNormal];
    followButton.tintColor = [SkinManage colorNamed:@"myButton_Color"];
    followButton.layer.cornerRadius = 5;
    followButton.layer.borderWidth = 1;
    followButton.layer.borderColor = [SkinManage colorNamed:@"myButton_Color"].CGColor;
    
    
    [followButton addTarget:self action:@selector(viewUserDetailInfo) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:followButton];
    [followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(70, 30));
        make.top.equalTo(30);
        make.trailing.equalTo(-12);
    }];
    
    btnAttention = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAttention addTarget:self action:@selector(attentionAction) forControlEvents:UIControlEventTouchUpInside];
    btnAttention.hidden = YES;
    [view addSubview:btnAttention];
    [btnAttention mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(48, 30));
        make.centerY.equalTo(followButton.mas_centerY);
        make.trailing.equalTo(followButton.mas_leading).offset(-10);
    }];
    
    nameLabel = [UILabel new];
    //    nameLabel.backgroundColor = [UIColor redColor];
    nameLabel.text = @"My Display Name";
    nameLabel.textColor = [SkinManage colorNamed:@"nameLabel_Color"];
    [nameLabel setFont:[Common fontWithName:@"PingFangSC-Medium" size:16]];
    [view addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(24);
        make.top.equalTo(39);
        make.leading.equalTo(12);
    }];
 
//#warning .......................... 等级
    imgViewLevel = [UIImageView new];
    imgViewLevel.contentMode = UIViewContentModeScaleAspectFit;
//    imgViewLevel.image = [UIImage imageNamed:[BusinessCommon getIntegralInfo:[Common getCurrentUserVo].fIntegrationCount].strLevelImage];
    [view addSubview:imgViewLevel];
    [imgViewLevel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(nameLabel.mas_centerY);
        make.size.equalTo(CGSizeMake(25, 25));
        make.leading.equalTo(nameLabel.mas_trailing).offset(5);
    }];
    
    lblSignature = [UILabel new];
    lblSignature.numberOfLines = 2;
    lblSignature.textColor = COLOR(100, 100, 100, 1.0);
    [lblSignature setFont:[UIFont systemFontOfSize:13]];
    [view addSubview:lblSignature];
    [lblSignature mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(7);
        make.height.greaterThanOrEqualTo(19).priority(751);
        make.leading.equalTo(12);
        make.trailing.equalTo(-80);
    }];
    
    btnFans = [UIButton buttonWithType:UIButtonTypeSystem];
    btnFans.titleLabel.font = [UIFont systemFontOfSize:13];
    [btnFans addTarget:self action:@selector(enterAttentionList:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnFans];
    [btnFans mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lblSignature.mas_bottom).offset(5);
        make.height.equalTo(30);
        make.leading.equalTo(12);
    }];
    
    btnAttentionTo = [UIButton buttonWithType:UIButtonTypeSystem];
    btnAttentionTo.titleLabel.font = [UIFont systemFontOfSize:13];
    [btnAttentionTo addTarget:self action:@selector(enterAttentionList:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnAttentionTo];
    [btnAttentionTo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lblSignature.mas_bottom).offset(5);
        make.height.equalTo(30);
        make.leading.equalTo(btnFans.mas_trailing).offset(30);
    }];
    
    if ([self.strUserID isEqualToString:[Common getCurrentUserVo].strUserID])
    {
        //自己的个人中心
        btnAttention.hidden = YES;
    }
    else
    {
        //他人的个人中心
//        self.navigationItem.rightBarButtonItem = [self rightBtnItemWithImage:@"nav_chat"];
        btnAttention.hidden = NO;
    }
    
    return view;
}

//按比例模糊图片
- (UIImage *)blurWithImageAt:(CGFloat)percent
{
    NSNumber* keyNumber = @0;
    if(percent <= 0.1){
        keyNumber = @1;
    } else if(percent <= 0.2) {
        keyNumber = @2;
    } else if(percent <= 0.3) {
        keyNumber = @3;
    } else if(percent <= 0.4) {
        keyNumber = @4;
    } else if(percent <= 0.5) {
        keyNumber = @5;
    } else if(percent <= 0.6) {
        keyNumber = @6;
    } else if(percent <= 0.7) {
        keyNumber = @7;
    } else if(percent <= 0.8) {
        keyNumber = @8;
    } else if(percent <= 0.9) {
        keyNumber = @9;
    } else if(percent <= 1) {
        keyNumber = @10;
    }
    UIImage* image = [_blurredImageCache objectForKey:keyNumber];
    if(image == nil)
    {
        //if cache not yet built, just compute and put in cache
        return _originalBackgroundImage;
    }
    return image;
}

- (UIImage *)blurWithImageEffects:(UIImage *)image andRadius: (CGFloat) radius
{
    return [image applyBlurWithRadius:radius tintColor:[UIColor colorWithWhite:1 alpha:0.2] saturationDeltaFactor:1.5 maskImage:nil];
}

- (void)fillBlurredImageCache
{
    CGFloat maxBlur = 30;
    self.blurredImageCache = [NSMutableDictionary new];
    for (int i = 0; i <= 10; i++)
    {
        self.blurredImageCache[[NSNumber numberWithInt:i]] = [self blurWithImageEffects:_originalBackgroundImage andRadius:(maxBlur * i/10)];
    }
}

- (void)viewUserDetailInfo
{
    if(userDetailView == nil)
    {
        userDetailView = [[UserDetailView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) user:_userVo];
    }
    [self.view.window addSubview:userDetailView.view];
    [userDetailView showWithAnimation];
}

//关注操作
- (void)attentionAction
{
    //关注action 取消关注用户 or 关注用户
    [Common showProgressView:nil view:self.view modal:NO];
    [ServerProvider attentionUserAction:!_userVo.bAttentioned andOtherUserID:_userVo.strUserID result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            if(_userVo.bAttentioned)
            {
                _userVo.bAttentioned = NO;
                [btnAttention setImage:[UIImage imageNamed:@"user_not_attention"] forState:UIControlStateNormal];
                
                //取消关注成功，更新数据库，发送推送通知
                GroupAndUserDao *groupAndUserDao = [[GroupAndUserDao alloc]init];
                [groupAndUserDao updateUserAfterAttentionAction:_userVo andAttention:NO];
            }
            else
            {
                _userVo.bAttentioned = YES;
                [btnAttention setImage:[UIImage imageNamed:@"user_attentioned"] forState:UIControlStateNormal];
                
                //关注用户成功，更新数据库，发送推送通知
                GroupAndUserDao *groupAndUserDao = [[GroupAndUserDao alloc]init];
                [groupAndUserDao updateUserAfterAttentionAction:_userVo andAttention:YES];
            }
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)enterAttentionList:(UIButton *)sender
{
    CommonUserListType userListType;
    if (sender == btnFans)
    {
        //粉丝
        userListType = UserListFansType;
    }
    else
    {
        //关注
        userListType = UserListAttentionType;
    }
    CommonUserListViewController *commonUserListViewController = [[UIStoryboard storyboardWithName:@"UserModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CommonUserListViewController"];
    commonUserListViewController.strUserID = _userVo.strUserID;
    commonUserListViewController.userListType = userListType;
    [self.navigationController pushViewController:commonUserListViewController animated:YES];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//更换封面图
- (void)tapCoverImage
{
    //add by fjz ..... 不能修改别人的封面
    if (![_userVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID])
        return;
    UIActionSheet *photoSheet = [[UIActionSheet alloc] initWithTitle:@"更换封面照片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"用户相册", nil];
    [photoSheet showInView:self.view];
}

-(void)updateCoverImage:(NSString*)strPath image:(UIImage*)imageData
{
    [Common showProgressView:nil view:self.view modal:NO];
    [ServerProvider updateUserCoverImage:strPath result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            [Common bubbleTip:@"您已成功更换了封面照片" andView:self.view];
            
            _userVo.strCoverImageURL = retInfo.data;
            _imageHeaderView.image = imageData;
            imgViewAddCoverImage.hidden = YES;
            
            //生成不同模糊程度的图片
            _originalBackgroundImage = _imageHeaderView.image;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self fillBlurredImageCache];
            });
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//分享
-(void)loadShareData:(BOOL)bRefreshing
{
    NSString *blogID = nil;
    if (aryShare != nil && aryShare.count > 0)
    {
        if (bRefreshing)
        {
            //下拉刷新
            blogID = @"";
        }
        else
        {
            //上拖加载
            BlogVo *blog = aryShare.lastObject;
            blogID = blog.streamId;
        }
    }
    
    [ServerProvider getShareBlog:blogID andType:0 content:nil create:self.strUserID result:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryTemp = retInfo.data;
            if (bRefreshing)
            {
                //下拉刷新
                [aryShare removeAllObjects];
                [aryShare addObjectsFromArray:aryTemp];
            }
            else
            {
                //上拖加载
                [aryShare addObjectsFromArray:aryTemp];
            }
            
            bShareCompleted = [retInfo.data2 boolValue];//是否所有加载完成
            
            if (bShareCompleted)
            {
                [self.tableViewList.mj_footer endRefreshingWithNoMoreData];
            }
            else
            {
                [self.tableViewList.mj_footer endRefreshing];
            }
            
            [self.tableViewList reloadData];
        }
        else
        {
            [self.tableViewList.mj_footer endRefreshing];
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//赞
-(void)loadPraiseData:(BOOL)bRefreshing
{
    if (bRefreshing)
    {
        //下拉刷新
        nPraisePage = 1;
    }
    
    [ServerProvider getPraiseShareBlog:nPraisePage create:self.strUserID result:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryTemp = retInfo.data;
            if (bRefreshing)
            {
                //下拉刷新
                [aryPraise removeAllObjects];
                [aryPraise addObjectsFromArray:aryTemp];
                nPraisePage = 2;
            }
            else
            {
                //上拖加载
                [aryPraise addObjectsFromArray:aryTemp];
                nPraisePage ++;
            }
            
            bPraiseCompleted = [retInfo.data2 boolValue];//是否所有加载完成
            if (bPraiseCompleted)
            {
                [self.tableViewList.mj_footer endRefreshingWithNoMoreData];
            }
            else
            {
                [self.tableViewList.mj_footer endRefreshing];
            }
            
            [self.tableViewList reloadData];
        }
        else
        {
            [self.tableViewList.mj_footer endRefreshing];
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//收藏
-(void)loadCollectionData:(BOOL)bRefreshing
{
    if([_userVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID] || _userVo.bViewFavorite)
    {
        if (bRefreshing)
        {
            //下拉刷新
            nCollectionPage = 1;
        }
        
        [ServerProvider getCollectionBlog:nCollectionPage create:self.strUserID result:^(ServerReturnInfo *retInfo){
            if (retInfo.bSuccess)
            {
                NSMutableArray *aryTemp = retInfo.data;
                if (bRefreshing)
                {
                    //下拉刷新
                    [aryCollection removeAllObjects];
                    [aryCollection addObjectsFromArray:aryTemp];
                    nCollectionPage = 2;
                }
                else
                {
                    //上拖加载
                    [aryCollection addObjectsFromArray:aryTemp];
                    nCollectionPage ++;
                }
                
                bCollectCompleted = [retInfo.data2 boolValue];//是否所有加载完成
                if (bCollectCompleted)
                {
                    [self.tableViewList.mj_footer endRefreshingWithNoMoreData];
                }
                else
                {
                    [self.tableViewList.mj_footer endRefreshing];
                }
                
                [self.tableViewList reloadData];
                
                if(aryCollection.count == 0)
                {
                    _tableViewList.mj_footer = nil;
                }
            }
            else
            {
                [self.tableViewList.mj_footer endRefreshing];
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
    else
    {
        bCollectCompleted = YES;
        [self.tableViewList reloadData];
        _tableViewList.mj_footer = nil;
    }
}

- (void)segmentedAction:(UISegmentedControl*)segmentedControl
{
    NSInteger nIndex = segmentedControl.selectedSegmentIndex;
    
    self.tableViewList.mj_footer = refreshFooter;
    CGPoint ptOffset = _tableViewList.contentOffset;
    BOOL bHeaderFloat = ptOffset.y > nTableHeaderH+1?YES:NO;
    
    if (nBottomListType == 0)
    {
        nShareScrollH = ptOffset.y;
    }
    else if (nBottomListType == 1)
    {
        nPraiseScrollH = ptOffset.y;
    }
    else
    {
        nCollectionScrollH = ptOffset.y;
    }
    
    if(nIndex == 0)
    {
        if (nBottomListType != 0)
        {
            
            nBottomListType = 0;
            if (aryShare.count == 0)
            {
                [self loadShareData:NO];
            }
            else
            {
                [_tableViewList reloadData];
            }
            
            if (bHeaderFloat)
            {
                //如果当前已经悬停了，接下来判断被切换的视图之前高度是否大于悬停，
                //是则保留之前的，否则使用固定高度（该固定高度为悬停时的最小高度）
                if (nShareScrollH >= nTableHeaderH)
                {
                    [_tableViewList setContentOffset:CGPointMake(ptOffset.x, nShareScrollH) animated:NO];
                }
                else
                {
                    [_tableViewList setContentOffset:CGPointMake(ptOffset.x, nTableHeaderH) animated:NO];
                }
            }
            else
            {
                //非悬停状态，则不改变table的offset
            }
        }
    }
    else if(nIndex == 1)
    {
        if (nBottomListType != 1)
        {
            nBottomListType = 1;
            if (aryPraise.count == 0)
            {
                [self loadPraiseData:NO];
            }
            else
            {
                [_tableViewList reloadData];
            }
            
            if (bHeaderFloat)
            {
                //如果当前已经悬停了，接下来判断被切换的视图之前高度是否大于悬停，
                //是则保留之前的，否则使用固定高度（该固定高度为悬停时的最小高度）
                if (nPraiseScrollH >= nTableHeaderH)
                {
                    [_tableViewList setContentOffset:CGPointMake(ptOffset.x, nPraiseScrollH) animated:NO];
                }
                else
                {
                    [_tableViewList setContentOffset:CGPointMake(ptOffset.x, nTableHeaderH) animated:NO];
                }
            }
        }
    }
    else
    {
        if (nBottomListType != 2)
        {
            nBottomListType = 2;
            if (aryCollection.count == 0)
            {
                [self loadCollectionData:NO];
            }
            else
            {
                [_tableViewList reloadData];
            }
            
            if (bHeaderFloat)
            {
                //如果当前已经悬停了，接下来判断被切换的视图之前高度是否大于悬停，
                //是则保留之前的，否则使用固定高度（该固定高度为悬停时的最小高度）
                if (nCollectionScrollH >= nTableHeaderH)
                {
                    [_tableViewList setContentOffset:CGPointMake(ptOffset.x, nCollectionScrollH) animated:NO];
                }
                else
                {
                    [_tableViewList setContentOffset:CGPointMake(ptOffset.x, nTableHeaderH) animated:NO];
                }
            }
        }
    }
    
    //上拉加载状态
    if (nBottomListType == 0)
    {
        if (bShareCompleted)
        {
            [_tableViewList.mj_footer endRefreshingWithNoMoreData];
        }
        else
        {
            [_tableViewList.mj_footer endRefreshing];
        }
    }
    else if (nBottomListType == 1)
    {
        if (bPraiseCompleted)
        {
            [_tableViewList.mj_footer endRefreshingWithNoMoreData];
        }
        else
        {
            [_tableViewList.mj_footer endRefreshing];
        }
    }
    else
    {
        if (bCollectCompleted)
        {
            
            [_tableViewList.mj_footer endRefreshingWithNoMoreData];
        }
        else
        {
            [_tableViewList.mj_footer endRefreshing];
        }
    }
}

- (void)configureCell:(ShareListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = YES; // Enable to use "-sizeThatFits:"
    
    BlogVo *blogObjectVo = nil;
    if (nBottomListType == 0)
    {
        //分享
        if (aryShare.count > indexPath.row)
        {
            blogObjectVo = [aryShare objectAtIndex:[indexPath row]];
        }
    }
    else if (nBottomListType == 1)
    {
        //赞
        if (aryPraise.count > indexPath.row)
        {
            blogObjectVo = [aryPraise objectAtIndex:[indexPath row]];
        }
    }
    else
    {
        //收藏
        if (aryCollection.count > indexPath.row)
        {
            blogObjectVo = [aryCollection objectAtIndex:[indexPath row]];
        }
    }
    [cell setEntity:blogObjectVo controller:self];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //拍照
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        {
            return;
        }
        UIImagePickerController *photoController = [[UIImagePickerController alloc] init];
        photoController.delegate = self;
        photoController.mediaTypes = @[(NSString*)kUTTypeImage];
        photoController.sourceType = UIImagePickerControllerSourceTypeCamera;
        photoController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        photoController.allowsEditing = YES;
        [photoController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        
        [self presentViewController:photoController animated:YES completion: nil];
    }
    else if (buttonIndex == 1)
    {
        //用户相册
        UIImagePickerController *photoAlbumController = [[UIImagePickerController alloc]init];
        photoAlbumController.delegate = self;
        photoAlbumController.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
        photoAlbumController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        photoAlbumController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        photoAlbumController.allowsEditing = YES;
        [photoAlbumController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        
        [self presentViewController:photoAlbumController animated:YES completion: nil];
    }
}

#pragma mark - ShareListCellDelegate
- (void)shareListCellAction:(NSInteger)nType data:(BlogVo *)blogVo
{
    if (nType == 0)
    {
        //屏蔽 & 举报
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (editedImage)
        {
            imageToSave = editedImage;
        }
        else
        {
            imageToSave = originalImage;
            
        }
        imageToSave = [Common rotateImage:imageToSave];
        
        // Save the new image (original or edited) to the Camera Roll
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        }
        
        float fWidth = imageToSave.size.width;
        float fHeight = imageToSave.size.height;
        
        //1.get middle image(square)
        CGRect rect;
        if(fWidth >= fHeight)
        {
            rect  = CGRectMake((fWidth-fHeight)/2, 0, fHeight, fHeight);
        }
        else
        {
            rect  = CGRectMake(0,(fHeight-fWidth)/2, fWidth, fWidth);
        }
        
        UIImage *imgTemp1 = [imageToSave getSubImage:rect];
        UIImage *imgTemp2 = [imgTemp1 scaleToSize:CGSizeMake(1000,1000)];
        
        //self.imgViewHead.image = imgTemp2;
        
        //2.保存图片
        NSData *imageData = UIImageJPEGRepresentation(imgTemp2,1.0);
        NSString *imagePathDir = [[Utils tmpDirectory] stringByAppendingPathComponent:POST_TEMP_DIRECTORY];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:imagePathDir];
        if (fileExists)
        {
            //delete director
            [fileManager removeItemAtPath:imagePathDir error:nil];
        }
        
        //create director
        [fileManager createDirectoryAtPath:imagePathDir  withIntermediateDirectories:YES  attributes:nil error:nil];
        
        //save file
        NSString *imagePath = [imagePathDir stringByAppendingPathComponent:[Common createImageNameByDateTime]];
        [fileManager createFileAtPath:imagePath contents:imageData attributes:nil];
        
        //更新封面图
        [self updateCoverImage:imagePath image:imgTemp2];
    }
    [picker dismissViewControllerAnimated:YES completion: nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (nBottomListType == 0)
    {
        //分享
        return aryShare.count;
    }
    else if (nBottomListType == 1)
    {
        //赞
        return aryPraise.count;
    }
    else
    {
        //收藏
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (nBottomListType == 2)
    {
        //收藏
        static NSString *identifier = @"UserProfileCollectionCell";
        UserProfileCollectionCell *cell = (UserProfileCollectionCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        cell.parentController = self;
        [cell setData:aryCollection userVo:_userVo];
        return cell;
    }
    else
    {
        static NSString *identifier = @"ShareListCell";
        ShareListCell *cell = (ShareListCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        cell.delegate = self;
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (nBottomListType == 2)
    {
        if([_userVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID] || _userVo.bViewFavorite)
        {
            return self.nCellHeight;
        }
        else
        {
            return 0;
        }
    }
    else
    {
        //采用自动计算高度，并且带有缓存机制
        return [tableView fd_heightForCellWithIdentifier:@"ShareListCell" cacheByIndexPath:indexPath configuration:^(ShareListCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *strIdentifier = @"UserProfileSectionHeader";
    UITableViewHeaderFooterView *viewHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:strIdentifier];
    if (viewHeader == nil)
    {
        viewHeader = [[UITableViewHeaderFooterView alloc]initWithReuseIdentifier:strIdentifier];
        viewHeader.backgroundColor = [SkinManage colorNamed:@"myTableheaderBK"];
        
        UIView *viewBK = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 51.5)];
        viewBK.backgroundColor =  [SkinManage colorNamed:@"myTableheaderBK"];
        [viewHeader addSubview:viewBK];
        
        UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"分享", @"赞", @"收藏"]];
        segmentedControl.frame = CGRectMake(12, 10, kScreenWidth-24, 31);
        segmentedControl.tintColor = [SkinManage colorNamed:@"myTbaleViewSegement_BK_color"];
        [segmentedControl addTarget:self action:@selector(segmentedAction:) forControlEvents:UIControlEventValueChanged];
        [viewHeader addSubview:segmentedControl];
        segmentedControl.selectedSegmentIndex = 0;
        _segmentedControl = segmentedControl;
        
        UIView* separator = [[UIView alloc]initWithFrame:CGRectMake(0, 51, kScreenWidth, 0.5)];
        separator.backgroundColor = [SkinManage colorNamed:@"myTbaleViewLine_BK_color"];
        [viewHeader addSubview:separator];
        
        //空白数据提示View
        TableNoDataView *tableNoDataView = [[TableNoDataView alloc]initWithFrame:CGRectMake(0, viewBK.bottom, kScreenWidth, 300) tip:nil];
        tableNoDataView.tag = 1005;
        [viewHeader addSubview:tableNoDataView];
    }
    
    TableNoDataView *tableNoDataView = (TableNoDataView*)[viewHeader viewWithTag:1005];
    if (nBottomListType == 0)
    {
        //分享
        if (aryShare.count == 0)
        {
            [tableNoDataView setTipText:@"还没有发表分享"];
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
        if (aryPraise.count == 0)
        {
            [tableNoDataView setTipText:@"还没有赞过分享"];
            tableNoDataView.hidden = NO;
        }
        else
        {
            tableNoDataView.hidden = YES;
        }
    }
    else
    {
        //收藏
        if([_userVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID] || _userVo.bViewFavorite)
        {
            if (aryCollection.count == 0)
            {
                [tableNoDataView setTipText:@"还没有收藏分享"];
                tableNoDataView.hidden = NO;
            }
            else
            {
                tableNoDataView.hidden = YES;
            }
        }
        else
        {
            [tableNoDataView setTipText:@"收藏夹未被公开"];
            tableNoDataView.hidden = NO;
        }
    }
    
    return viewHeader;;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat fHeight = 51.5;
    if (nBottomListType == 0)
    {
        //分享
        if (aryShare.count == 0)
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
    else
    {
        //收藏
        if (aryCollection.count == 0)
        {
            fHeight += 300;
        }
    }
    return fHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (nBottomListType != 2)
    {
        BlogVo *blog;
        if (nBottomListType == 0)
        {
            //分享
            blog = [aryShare objectAtIndex:[indexPath row]];
        }
        else if (nBottomListType == 1)
        {
            //赞
            blog = [aryPraise objectAtIndex:[indexPath row]];
        }
        
        ShareDetailViewController *shareDetailViewController = [[ShareDetailViewController alloc] init];
        shareDetailViewController.m_originalBlogVo = blog;
        if (blog.streamId.length == 0)
        {
            [Common tipAlert:@"数据异常，请求失败"];
            return;
        }
        
        [self.navigationController pushViewController:shareDetailViewController animated:YES];
    }
}

- (void)avatarViewClick
{
    SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
    //network image
    dataSource.images_ = @[@[_userVo.strMaxHeadImageURL]];
    KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
        initWithDataSource:dataSource
        andStartWithPhotoAtIndex:0];
    photoScrollViewController.bShowImageNumBarBtn = NO;
    [self.navigationController pushViewController:photoScrollViewController animated:YES];
}

@end
