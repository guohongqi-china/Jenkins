//
//  HomeViewController.m
//  Sloth
//
//  Created by Ann Yao on 12-9-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"
#import "ServerProvider.h"
#import "ServerURL.h"
#import "ChatCountDao.h"
#import "UserSettingViewController.h"
#import "RotateNavigationController.h"
#import "UIViewExt.h"
#import "FirstStartViewController.h"
#import "RegisterNameViewController.h"
#import "FindestProj-Swift.h"

@interface HomeViewController ()<UITabBarControllerDelegate,UIAlertViewDelegate>
{
    
    NSMutableArray *aryTabItem;
    UIImageView *imgViewTab;
}

@end

@implementation HomeViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RemovePublicView" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateChatUnreadAllNum" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_REFRESH_SKIN object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_BACKTOHOME object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"URLSchemeEnterForeground" object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    self.fd_interactivePopDisabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removePublicView) name:@"RemovePublicView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatUnreadAllNum) name:@"UpdateChatUnreadAllNum" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSkin) name:NOTIFY_REFRESH_SKIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToHome:) name:NOTIFY_BACKTOHOME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterCommunityDetailController) name:@"URLSchemeEnterForeground" object:nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tipNumViewChat = [[CommonTipNumView alloc]initWithFrame:CGRectMake(30.5, 3, 0, 0)];
    
    //缓存用户和群组数据
    [BusinessCommon updateServerGroupAndUserData:nil];
    
    [self initTabBar];
    
    //真实姓名和部门是否填写完整
    [self checkInfoComplete];
    
    //检查圈子是否为空
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        if ([[Common getCurrentUserVo].strCompanyID isEqualToString:@"0"]) {
            UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:nil message:@"您还没有关注任何圈子，可以到 [发现]-[扫一扫] 里面扫二维码关注感兴趣的圈子" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            alertView.tag = 1003;
            [alertView show];
        }
    });
    [self checkServerAppVersion];
    [self enterCommunityDetailController];
}

- (void)refreshSkin
{
    [UIView animateWithDuration:0.5 animations:^{
        [self setTabItemStyle:self.btnItem4];
    } completion:^(BOOL finished) {
        //        [self.tableViewMenu reloadData];
        imgViewTab.image = [SkinManage imageNamed:@"tab_bar_bk"];
        [self.btnMiddle setImage:[SkinManage imageNamed:@"tab_item_middle"] forState:UIControlStateNormal];
    }];
}

- (void)backToHome:(NSNotification *)notification
{
    UIViewController *rootController = self.navigationController.viewControllers.firstObject;
    if([rootController isKindOfClass:[FirstStartViewController class]])
    {
        //启动页面
        [self.navigationController popToRootViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_EXIT_APP object:notification.object];
    }
    else if([rootController isKindOfClass:[RegisterNameViewController class]])
    {
        //注册界面
        [self.navigationController popToRootViewControllerAnimated:NO];
        [rootController dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_EXIT_APP object:notification.object];
        }];
    }
    else
    {
        //登录界面
        [self.navigationController popToRootViewControllerAnimated:NO];
        [rootController dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_EXIT_APP object:notification.object];
        }];
    }
}

//检查是否使用URLScheme打开应用
- (void)enterCommunityDetailController {
    NSString *strOrgID = [AppDelegate getSlothAppDelegate].strURLSchemeParameter;
    if (strOrgID.length > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            [AppDelegate getSlothAppDelegate].strURLSchemeParameter = nil;
            
            CommunityDetailViewController *communityDetailViewController = [[UIStoryboard storyboardWithName:@"CommunityModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CommunityDetailViewController"];
            communityDetailViewController.strOrgID = strOrgID;
            communityDetailViewController.isFromURLScheme = YES;
            CommonNavigationController *navigationCtrl = [[CommonNavigationController alloc]initWithRootViewController:communityDetailViewController];
            [[self topMostController] presentViewController:navigationCtrl animated:YES completion:nil];
        });
    }
}

- (UIViewController*) topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

#pragma mark - Init Data
- (void)initTabBar
{
    CGFloat fTabW = (kScreenWidth)/5;
    CGFloat fTabH = 49;
    
    self.viewTab = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-fTabH, kScreenWidth, fTabH)];
    self.viewTab.backgroundColor = COLOR(249, 249, 249, 1.0);
    [self.view addSubview:_viewTab];
    
    imgViewTab = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, fTabH)];
    imgViewTab.image = [SkinManage imageNamed:@"tab_bar_bk"];
    [self.viewTab addSubview:imgViewTab];
    
    aryTabItem = [NSMutableArray array];
    
    //首页
    self.btnItem1 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnItem1.titleLabel.font = [UIFont systemFontOfSize:10];
    [self.btnItem1 setTitle:@"首页" forState:UIControlStateNormal];
    self.btnItem1.frame = CGRectMake(0, 3, fTabW, fTabH);
    [self.btnItem1 addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewTab addSubview:self.btnItem1];
    [Common setButtonImageTitlePosition:self.btnItem1 spacing:0];
    [aryTabItem addObject:self.btnItem1];
    
    //发现
    self.btnItem2 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnItem2.titleLabel.font = [UIFont systemFontOfSize:10];
    [self.btnItem2 setTitle:@"发现" forState:UIControlStateNormal];
    self.btnItem2.frame = CGRectMake(self.btnItem1.right, 3, fTabW, fTabH);
    [self.btnItem2 addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewTab addSubview:self.btnItem2];
    [Common setButtonImageTitlePosition:self.btnItem2 spacing:4];
    [aryTabItem addObject:self.btnItem2];
    
    //中间按钮
    self.btnMiddle = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnMiddle.frame = CGRectMake(self.btnItem2.right, 0, fTabW, fTabH);
    [self.btnMiddle setImage:[SkinManage imageNamed:@"tab_item_middle"] forState:UIControlStateNormal];
    [self.btnMiddle addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewTab addSubview:_btnMiddle];
    
    //消息
    self.btnItem3 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnItem3.titleLabel.font = [UIFont systemFontOfSize:10];
    [self.btnItem3 setTitle:@"消息" forState:UIControlStateNormal];
    self.btnItem3.frame = CGRectMake(self.btnMiddle.right, 3, fTabW, fTabH);
    [self.btnItem3 addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewTab addSubview:self.btnItem3];
    [Common setButtonImageTitlePosition:self.btnItem3 spacing:4];
    [aryTabItem addObject:self.btnItem3];
    
    //我
    self.btnItem4 = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnItem4.titleLabel.font = [UIFont systemFontOfSize:10];
    [self.btnItem4 setTitle:@"我" forState:UIControlStateNormal];
    self.btnItem4.frame = CGRectMake(self.btnItem3.right, 3, fTabW, fTabH);
    [self.btnItem4 addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewTab addSubview:self.btnItem4];
    [Common setButtonImageTitlePosition:self.btnItem4 spacing:4];
    [aryTabItem addObject:self.btnItem4];
    
    //view controller
    self.itemFirstViewController = [[ShareHomeViewController alloc]init];
    self.itemFirstViewController.homeViewController = self;
    self.itemFirstNavigationController = [[CommonNavigationController alloc]initWithRootViewController:self.itemFirstViewController];
    self.itemFirstNavigationController.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    
    self.itemSecondViewController = [[UIStoryboard storyboardWithName:@"HomeModule" bundle:nil]instantiateViewControllerWithIdentifier:@"DiscoveryViewController"];
    self.itemSecondViewController.homeViewController = self;
    self.itemSecondNavigationController = [[CommonNavigationController alloc]initWithRootViewController:self.itemSecondViewController];
    
    self.itemThirdViewController = [[UIStoryboard storyboardWithName:@"HomeModule" bundle:nil]instantiateViewControllerWithIdentifier:@"MessageViewController"];
    self.itemThirdViewController.homeViewController = self;
    self.itemThirdNavigationController = [[CommonNavigationController alloc]initWithRootViewController:self.itemThirdViewController];
    
    self.itemFourthViewController = [[UIStoryboard storyboardWithName:@"HomeModule" bundle:nil]instantiateViewControllerWithIdentifier:@"PersonalViewController"];
    self.itemFourthViewController.homeViewController = self;
    self.itemFourthNavigationController = [[CommonNavigationController alloc]initWithRootViewController:self.itemFourthViewController];
    
    //middle publish view
    self.publishView = [[PublishView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-49)];
    self.publishView.btnHomePop = self.btnMiddle;
    self.publishView.homeViewController = self;
    
    self.mainTabType = -1;
    [self selectTab:self.btnItem1];
    
    [self.view bringSubviewToFront:self.viewTab];
}

//设置status bar 颜色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)selectTab:(UIButton*)sender
{
    if (sender == self.btnItem1)
    {
        //首页
        if (self.mainTabType != TabItemType1)
        {
            self.mainTabType = TabItemType1;
            [self setTabItemStyle:self.btnItem1];
            
            [self switchViewController];
        }
    }
    else if (sender == self.btnItem2)
    {
        //发现
        if (self.mainTabType != TabItemType2)
        {
            self.mainTabType = TabItemType2;
            [self setTabItemStyle:self.btnItem2];
            
            [self switchViewController];
        }
    }
    else if (sender == _btnMiddle)
    {
        //中间
        if(!self.publishView.bShow)
        {
            self.publishView.bShow = YES;
//            [AppDelegate getSlothAppDelegate].currentPageName = PublishPage;
            [self setTabItemStyle:self.btnMiddle];
            
            self.publishView.mainTabType = self.mainTabType;
            [self.view addSubview:self.publishView];
            self.publishView.alpha = 0.0;
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.publishView.alpha = 1.0;
            } completion:^(BOOL finished){
                [self.publishView beginningAnimation];
            }];
        }
        else
        {
            [self.publishView closeView:YES];
        }
    }
    else if (sender == self.btnItem3)
    {
        //消息
        if (self.mainTabType != TabItemType3)
        {
            self.mainTabType = TabItemType3;
            [self setTabItemStyle:self.btnItem3];
            
            [self switchViewController];
        }
    }
    else if (sender == self.btnItem4)
    {
        //我
        if (self.mainTabType != TabItemType4)
        {
            self.mainTabType = TabItemType4;
            [self setTabItemStyle:self.btnItem4];
            
            [self switchViewController];
        }
    }
    
    if(self.publishView.bShow && sender != _btnMiddle)
    {
        self.publishView.mainTabType = self.mainTabType;
        [self.publishView closeView:YES];
    }
}

-(void)switchViewController
{
        //为了点击iOS状态栏,scrollView滚动到顶部
        //self.itemFirstViewController.tableViewShare.scrollsToTop = NO;
        self.itemFourthViewController.tableViewMenu.scrollsToTop = NO;
        self.itemFourthViewController.tableViewMenu.scrollsToTop = NO;
        self.itemSecondViewController.tableViewMenu.scrollsToTop = NO;
    
        if (self.mainTabType == TabItemType1)
        {
            [self.view addSubview:self.itemFirstNavigationController.view];
            //self.itemFirstViewController.tableViewShare.scrollsToTop = YES;
        }
        else if (self.mainTabType == TabItemType2)
        {
            [self.view addSubview:self.itemSecondNavigationController.view];
            self.itemSecondViewController.tableViewMenu.scrollsToTop = YES;
        }
        else if (self.mainTabType == TabItemType3)
        {
            [self.view addSubview:self.itemThirdNavigationController.view];
            self.itemThirdViewController.tableViewMenu.scrollsToTop = YES;
            
            [self.itemThirdViewController updateNoticeNum:YES];
        }
        else if (self.mainTabType == TabItemType4)
        {
            [self.view addSubview:self.itemFourthNavigationController.view];
            self.itemFourthViewController.tableViewMenu.scrollsToTop = YES;
        }
        [self.view bringSubviewToFront:self.viewTab];
}

-(void)hideBottomTabBar:(BOOL)bHide
{
    CGFloat fTabH = 49;
    if (bHide)
    {
        //如果已经隐藏则不需要
        if(self.viewTab.top < (kScreenHeight-10))
        {
            [UIView animateWithDuration:0.2 animations:^{
                self.viewTab.frame = CGRectMake(0, kScreenHeight, kScreenWidth, fTabH);
            }];
        }
    }
    else
    {
        //如果已经显示则不需要再显示
        if(self.viewTab.top > (kScreenHeight-10))
        {
            [UIView animateWithDuration:0.2 animations:^{
                self.viewTab.frame = CGRectMake(0, kScreenHeight-fTabH, kScreenWidth, fTabH);
            }];
        }
    }
}

//remove public view
-(void)removePublicView
{
    [self.publishView closeView:NO];
}

//更新聊天未读数量
- (void)updateChatUnreadAllNum
{
    [self.tipNumViewChat updateTipNum:[ChatCountDao getUnseenChatSumNum]];
}

//检查是否输入了真实姓名和所属公司
- (void)checkInfoComplete
{
    if (![Common getInfoCompleteState])
    {
        if (iOSPlatform>=8)
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请完善您的个人资料：姓名，公司" preferredStyle:UIAlertControllerStyleAlert];
            
            // Create the actions.
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"更改" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                UIAlertView *alertView = [UIAlertView new];
                alertView.tag = 1002;
                [self alertView:alertView clickedButtonAtIndex:1];
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
            }];
            
            // Add the actions.
            [alertController addAction:cancelAction];
            [alertController addAction:otherAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"提示" message:@"请完善您的个人资料：姓名，公司" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"更改",nil];
            alertView.tag = 1002;
            [alertView show];
        }
    }
}

//检查服务器应用版本更新
- (void)checkServerAppVersion
{
    //版本号检测
    NSString *strVersion = [Common getServerAppVersion];
    if (strVersion != nil && ![[Common getAppVersion] isEqualToString:strVersion])
    {
        UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@iOS端发布了新版本，您确定要升级到最新应用",Constants.strAppName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        alertView.tag = 1001;
        [alertView show];
    }
}

- (void)setTabItemStyle:(UIButton *)btnItem
{
    UIImage *imgItem;
    UIColor *color;
    
    for (NSUInteger i=1; i<=aryTabItem.count; i++)
    {
        UIButton *btnTempItem = aryTabItem[i-1];
        if (btnTempItem == btnItem)
        {
            //高亮状态
            imgItem = [UIImage imageNamed:[NSString stringWithFormat:@"tab_item%lu_h",(unsigned long)i]];
            color = [SkinManage colorNamed:@"Tab_Item_Color_H"];
        }
        else
        {
            //普通状态
            imgItem = [SkinManage imageNamed:[NSString stringWithFormat:@"tab_item%lu",(unsigned long)i]];
            color = [SkinManage colorNamed:@"Tab_Item_Color"];
        }
        
        [btnTempItem setImage:imgItem forState:UIControlStateNormal];
        [btnTempItem setTitleColor:color forState:UIControlStateNormal];
        
        [btnTempItem setImage:imgItem forState:UIControlStateHighlighted];
        [btnTempItem setTitleColor:color forState:UIControlStateHighlighted];
        
        [Common setButtonImageTitlePosition:btnTempItem spacing:2];
    }
}

- (void)selectTabByType:(MainTabType)type
{
    UIButton *btnTemp;
    if(type == TabItemType1)
    {
        btnTemp = self.btnItem1;
    }
    else if(type == TabItemType2)
    {
        btnTemp = self.btnItem2;
    }
    else if(type == TabItemType3)
    {
        btnTemp = self.btnItem3;
    }
    else if(type == TabItemType4)
    {
        btnTemp = self.btnItem4;
    }
    
    [self setTabItemStyle:btnTemp];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001)
    {
        //版本更新
        if (buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[ServerURL getVersionUpdateURL]]];
        }
    }
    else if (alertView.tag == 1002)
    {
        //真实姓名和部门是否填写整
        if (buttonIndex == 1)
        {
            UserSettingViewController *userEditViewController = [[UIStoryboard storyboardWithName:@"UserModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"UserSettingViewController"];
            [self.navigationController pushViewController:userEditViewController animated:YES];
        }
    }
}

@end
