//
//  ShareHomeViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/2.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ShareHomeViewController.h"
#import "RKSwipeBetweenViewControllers.h"
#import "ShareListViewController.h"
#import "CollectionShareViewController.h"
#import "UIViewExt.h"
#import "HomeViewController.h"
#import "MainSearchViewController.h"
#import "CommonNavigationController.h"
#import "UserVo.h"
#import "TitleViewButton.h"
#import "MainViewController.h"
#import "TheTableViewForTitle.h"
#import "Model.h"
//#import "ShareListViewController.h"

@interface ShareHomeViewController ()<RKSwipeBetweenViewControllersDelegate,TheTableViewForTitleDelegate>
{
    UIView *viewNavBar;
    UIButton *btnSearch;
    UIButton *btnRight;
    UIButton *btnScrollToTop;
    UIImageView *imgViewTitle;
    TitleViewButton *lblTitle;
    
    RKSwipeBetweenViewControllers *swipeNavigationController;
    ShareListViewController *shareListViewController;
    ShareListViewController *attentionShareViewController;
    CollectionShareViewController *collectionShareViewController;
//    UIWindow *window;
   
}

@property (nonatomic, strong)  TheTableViewForTitle *titleTableView;/** <#注释#> */

@end

@implementation ShareHomeViewController
- (TheTableViewForTitle *)titleTableView{
    if (_titleTableView == nil) {
        _titleTableView = [[TheTableViewForTitle alloc]init];
        _titleTableView.width = [UIScreen mainScreen].bounds.size.width / 3;
        _titleTableView.BTdelagate = self;
        _titleTableView.center = CGPointMake(lblTitle.center.x, 0);
        _titleTableView.top = CGRectGetMaxY(lblTitle.frame);
    }
    return _titleTableView;
}
#pragma TheTableViewForTitleDelegate
- (void)changeButtonStatus:(Model *)titlName{
    lblTitle.selected = NO;
    //更新UI
    swipeNavigationController.buttonText = @[titlName.tagName,@"关注",@"收藏"];
    [swipeNavigationController setupSegmentButtons];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFY_REFRESH_SKIN object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fd_interactivePopDisabled = YES;
    self.fd_prefersNavigationBarHidden = YES;

    [self initData];
    [self initView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(removeCemg) name:@"cengViwe" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changControl:) name:@"loadNewData" object:nil];


}
- (void)removeCemg{
    lblTitle.selected = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    [self.navigationController.navigationBar setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Theme_Color"]] forBarMetrics:UIBarMetricsDefault];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.homeViewController hideBottomTabBar:NO];
}
- (void)initData
{
    
}

- (void)initView
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshSkin) name:NOTIFY_REFRESH_SKIN object:nil];
    
    //top view
    viewNavBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, NAV_BAR_HEIGHT)];
    viewNavBar.backgroundColor = [SkinManage colorNamed:@"Theme_Color"];
    [self.view addSubview:viewNavBar];
    [viewNavBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.equalTo(0);
        make.height.equalTo(NAV_BAR_HEIGHT);
    }];
    
    btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSearch.layer.cornerRadius = 5;
    btnSearch.layer.masksToBounds = YES;
    btnSearch.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnSearch setImage:[SkinManage imageNamed:@"home_search_bk"] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    //[btnSearch setBackgroundImage:[UIImage imageNamed:@"home_search_bk"] forState:UIControlStateNormal];
    [viewNavBar addSubview:btnSearch];
    [btnSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(viewNavBar).insets(UIEdgeInsetsMake(28, 12, 0, 0));
        make.width.equalTo(45);
        make.height.equalTo(28);
    }];
    
    btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRight.layer.cornerRadius = 5;
    btnRight.layer.masksToBounds = YES;
    btnRight.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnRight setTitle:@"签到" forState:UIControlStateNormal];
    [btnRight setTitle:@"已签" forState:UIControlStateDisabled];
    [btnRight setTitleColor:[SkinManage colorNamed:@"Nav_Btn_Color"] forState:UIControlStateNormal];
    [btnRight setTitleColor:[SkinManage colorNamed:@"Theme_Color"] forState:UIControlStateDisabled];
    [btnRight addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [btnRight setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Nav_Btn_BK_Color"]] forState:UIControlStateNormal];
    [btnRight setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Nav_Btn_BK_Color"]] forState:UIControlStateDisabled];
    
    //27,32 43,
    [viewNavBar addSubview:btnRight];
    [btnRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(viewNavBar).insets(UIEdgeInsetsMake(kStatusBarHeight+8, 0, 8, 12));
        make.width.equalTo(45);
    }];
    
    //回到顶部操作
    btnScrollToTop = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnScrollToTop addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewNavBar addSubview:btnScrollToTop];
    [btnScrollToTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(viewNavBar).insets(UIEdgeInsetsMake(kStatusBarHeight+8, 100, 8, 100));
    }];
    
    //当日是否签到
    if ([Common getCurrentUserVo].bDaySign)
    {
        btnRight.enabled = NO;
    }
    
    NSString *strOrgName = [Common getCurrentUserVo].strCompanyName;
    if (strOrgName.length > 0) {
        lblTitle = [[TitleViewButton alloc]initWithTitle:@"SMR" normalImage:@"arrow_white_downrr" seletedImage:@"arrow_white_down"];
        [lblTitle addTarget:self action:@selector(titleAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [viewNavBar addSubview:lblTitle];
        [lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(viewNavBar.mas_centerX);
            make.top.equalTo(viewNavBar.mas_top).offset(20);
        }];
    } else {
        imgViewTitle = [[UIImageView alloc]initWithImage:[SkinManage imageNamed:@"logo_small_white"]];
        [viewNavBar addSubview:imgViewTitle];
        [imgViewTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(viewNavBar);
            make.top.equalTo(32);
            make.width.equalTo(50);
            make.height.equalTo(20);
        }];
    }
    
    //swipe view
    swipeNavigationController = [[RKSwipeBetweenViewControllers alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-49)];
    swipeNavigationController.buttonText = @[@"全部",@"关注",@"收藏"];
    swipeNavigationController.fItemWidth = 80;
    swipeNavigationController.fSelectionWidth = 34;//
    swipeNavigationController.navDelegate = self;

//    
//    //swipe view
//    swipeNavigationController = [[RKSwipeBetweenViewControllers alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-49)];
//    swipeNavigationController.buttonText = @[@"全部",@"关注",@"收藏"];
////    swipeNavigationController.tabl = self.titleTableView;
//    swipeNavigationController.fItemWidth = 80;
//    swipeNavigationController.fSelectionWidth = 34;//
//    swipeNavigationController.navDelegate = self;
    
//    //全部列表
//    MainViewController *controler = [[MainViewController alloc]init];
//    shareListViewController = controler;
////    controler.navigationController = self.navigationController;
////    shareListViewController.shareListType = ShareListAllType;
//    shareListViewController.shareHomeViewController = self;
    //全部列表
    shareListViewController = [[ShareListViewController alloc]init];
    shareListViewController.shareListType = ShareListAllType;
    shareListViewController.shareHomeViewController = self;
    
    //关注
    attentionShareViewController = [[ShareListViewController alloc]init];
    attentionShareViewController.shareListType = ShareListAttentionType;
    attentionShareViewController.shareHomeViewController = self;
    
    //收藏
    collectionShareViewController = [[UIStoryboard storyboardWithName:@"ShareModule" bundle:nil]instantiateViewControllerWithIdentifier:@"CollectionShareViewController"];
    collectionShareViewController.shareHomeViewController = self;
    
    [swipeNavigationController.viewControllerArray addObjectsFromArray:@[shareListViewController,attentionShareViewController,collectionShareViewController]];
    
    [swipeNavigationController initView];
    [self.view addSubview:swipeNavigationController];
}
/**
 * smr按钮点击事件
 */
- (void)titleAction:(UIButton *)sender{
    sender.selected = !sender.isSelected;
    if (sender.selected) {
        [self.titleTableView show];
    }else{
        [self.titleTableView hidden];
    }
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.titleTableView removeFromSuperview];
}

- (void)refreshSkin
{
    viewNavBar.backgroundColor = [SkinManage colorNamed:@"Theme_Color"];
    [btnSearch setImage:[SkinManage imageNamed:@"home_search_bk"] forState:UIControlStateNormal];
    [btnRight setTitleColor:[SkinManage colorNamed:@"Nav_Btn_Color"] forState:UIControlStateNormal];
    [btnRight setTitleColor:[SkinManage colorNamed:@"Theme_Color"] forState:UIControlStateDisabled];
    [btnRight setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Nav_Btn_BK_Color"]] forState:UIControlStateNormal];
    [btnRight setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Nav_Btn_BK_Color"]] forState:UIControlStateDisabled];
//    lblTitle.textColor = [SkinManage colorNamed:@"Nav_Bar_Title_Color"];
    imgViewTitle.image = [SkinManage imageNamed:@"logo_small_white"];
    
    [swipeNavigationController refreshSkin];
}

-(void)hideBottomWhenPushed
{
    [self.homeViewController hideBottomTabBar:YES];
}

- (void)buttonAction:(UIButton *)sender
{
    if(sender == btnSearch)
    {
        MainSearchViewController *mainSearchViewController = [[UIStoryboard storyboardWithName:@"ShareModule" bundle:nil]instantiateViewControllerWithIdentifier:@"MainSearchViewController"];
        CommonNavigationController *commonNavigationController = [[CommonNavigationController alloc]initWithRootViewController:mainSearchViewController];
        [self.homeViewController presentViewController:commonNavigationController animated:NO completion:nil];
    }
    else if (sender == btnScrollToTop)
    {
        [self updateScrollToTopState:swipeNavigationController.currentPageIndex];
        
        if (swipeNavigationController.currentPageIndex == 0)
        {
            [shareListViewController.tableViewShare setContentOffset:CGPointZero animated:YES];
        }
        else if (swipeNavigationController.currentPageIndex == 1)
        {
            [attentionShareViewController.tableViewShare setContentOffset:CGPointZero animated:YES];
        }
        else
        {
            [collectionShareViewController.collectionViewStore setContentOffset:CGPointZero animated:YES];
        }
    }
    else
    {
        //签到
        [Common showProgressView:nil view:self.view modal:NO];
        [ServerProvider signInByDay:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            if (retInfo.bSuccess)
            {
                NSNumber *numIntegral = retInfo.data;
                NSNumber *numSumIntegral = retInfo.data2;
                
                //已签到
                btnRight.enabled = NO;
                
                //显示签到成功动画
                [BusinessCommon addAnimation:numIntegral.doubleValue sum:numSumIntegral.doubleValue view:self.view];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
}

- (void)updateScrollToTopState:(NSInteger)nIndex
{
    shareListViewController.tableViewShare.scrollsToTop = NO;
    attentionShareViewController.tableViewShare.scrollsToTop = NO;
    collectionShareViewController.collectionViewStore.scrollsToTop = NO;
    
    if (nIndex == 0)
    {
        shareListViewController.tableViewShare.scrollsToTop = YES;
    }
    else if (nIndex == 1)
    {
        attentionShareViewController.tableViewShare.scrollsToTop = YES;
    }
    else
    {
        collectionShareViewController.collectionViewStore.scrollsToTop = YES;
    }
}
- (void)changControl:(NSNotification *)notification{
 
    [swipeNavigationController changtuFirst];
    
}
#pragma mark - RKSwipeBetweenViewControllersDelegate
- (void)pageIndexChanged:(NSInteger)nIndex
{
    [self updateScrollToTopState:nIndex];
}

@end
