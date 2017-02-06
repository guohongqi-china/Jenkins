//
//  MyJobListViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/22.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MyJobListViewController.h"
#import "JobListCell.h"
#import "JobVo.h"
#import "JobWebViewController.h"
#import "VerifyJobViewController.h"
#import "CertificateUploadViewController.h"
#import "ServerURL.h"
#import "CheXiangService.h"
#import "CommonNavigationController.h"
#import "ChexiangJobViewController.h"
#import "NoSearchView.h"

@interface MyJobListViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSMutableArray *aryJob;
    NoSearchView *noSearchView;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewJob;

@end

@implementation MyJobListViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CheXiangVerifyJobNotification" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CheXiangRefreshJobNotification" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    if (self.jobListPageType == MyJobListPageType)
    {
        self.title = @"我的工作";
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(verifyJobNotification:) name:@"CheXiangVerifyJobNotification" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshJobNotification) name:@"CheXiangRefreshJobNotification" object:nil];
    }
    else
    {
        self.title = @"添加工作";
    }
    
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewJob.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewJob.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.tableViewJob registerNib:[UINib nibWithNibName:@"JobListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"JobListCell"];
    
    noSearchView = [[NoSearchView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT) andDes:@"没有工作数据"];
}

- (void)initData
{
    aryJob = [NSMutableArray array];
    
    if (self.jobListPageType == MyJobListPageType)
    {
        [self loadJobData:1];
    }
    else
    {
        [self loadJobData:2];
    }
}

- (void)loadJobData:(NSInteger)nType
{
    [Common showProgressView:nil view:self.view modal:NO];
    [CheXiangService getMyJobListByType:nType result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            [aryJob removeAllObjects];
            
            NSMutableArray *aryFirst = [NSMutableArray array];
            [aryFirst addObjectsFromArray:retInfo.data];
            if(aryFirst.count > 0)
            {
                [aryJob addObject:aryFirst];
            }
            
            if(nType == 1)
            {
                NSMutableArray *arySecond = [NSMutableArray array];
                JobVo *jobVo = [[JobVo alloc]init];
                jobVo.strID = @"0";
                jobVo.strName = @"添加工作";
                [arySecond addObject:jobVo];
                [aryJob addObject:arySecond];
            }
            
            if (aryJob.count == 0)
            {
                [self.view addSubview:noSearchView];
            }
            else
            {
                [noSearchView removeFromSuperview];
            }
            
            [self.tableViewJob reloadData];
        }
        else
        {
            //失败则进入车享登录页面
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//进入工作模块
- (void)enterJob:(JobVo*)jobVo
{
    //调用车享家帐号关联验证接口 ??????????????
    [Common showProgressView:nil view:self.view modal:NO];
    [CheXiangService verifyCheXiangAccount:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            if([jobVo.strName isEqualToString:@"车享家"])
            {
                //跳转车享家
                ChexiangJobViewController *chexiangJobViewController = [[UIStoryboard storyboardWithName:@"JobModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ChexiangJobViewController"];
                chexiangJobViewController.strChexiangAccount = retInfo.data;
                chexiangJobViewController.strMyWorkbenchURL = retInfo.data3;
                [self.navigationController pushViewController:chexiangJobViewController animated:YES];
            }
            else
            {
                //H5 工作页面
                JobWebViewController *jobWebViewController = [[UIStoryboard storyboardWithName:@"JobModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"JobWebViewController"];
                jobWebViewController.nFlag = 0;
                jobWebViewController.jobVo = jobVo;
                [self.navigationController pushViewController:jobWebViewController animated:YES];
            }
        }
        else
        {
            //失败则进入车享登录页面
            VerifyJobViewController *verifyJobViewController = [[UIStoryboard storyboardWithName:@"JobModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"VerifyJobViewController"];
            verifyJobViewController.jobVo = jobVo;
            CommonNavigationController *navController = [[CommonNavigationController alloc] initWithRootViewController:verifyJobViewController];
            navController.navigationBarHidden = YES;
            [self presentViewController:navController animated:YES completion:nil];
        }
    }];
}

//添加工作
- (void)addJob:(JobVo *)jobVo
{
    
}

//验证工作成功
- (void)verifyJobNotification:(NSNotification*)notification
{
    //跳转到车享家
    NSDictionary *dicParam = notification.object;
    ChexiangJobViewController *chexiangJobViewController = [[UIStoryboard storyboardWithName:@"JobModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ChexiangJobViewController"];
    chexiangJobViewController.strJobID = dicParam[@"JobId"];
    chexiangJobViewController.strChexiangAccount = dicParam[@"ChexiangAccount"];
    chexiangJobViewController.strMyWorkbenchURL = dicParam[@"MyWorkbenchURL"];
    [self.navigationController pushViewController:chexiangJobViewController animated:YES];
}

//刷新工作列表
- (void)refreshJobNotification
{
    [self loadJobData:1];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSMutableArray *aryFirst = aryJob[0];
        JobVo *jobVo = aryFirst[alertView.tag-1000];
        
        [Common showProgressView:@"添加中..." view:self.view modal:NO];
        [CheXiangService editChexiangJob:jobVo.strID type:1 result:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            if (retInfo.bSuccess)
            {
                [aryFirst removeObject:jobVo];
                [self.tableViewJob reloadData];
                
                [Common bubbleTip:@"添加工作成功" andView:self.view];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"CheXiangRefreshJobNotification" object:nil];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return aryJob.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *aryTemp = aryJob[section];
    return aryTemp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JobListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JobListCell" forIndexPath:indexPath];
    cell.entity = aryJob[indexPath.section][indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JobVo *jobVo = aryJob[indexPath.section][indexPath.row];
    
    if (self.jobListPageType == MyJobListPageType)
    {
        //我的工作列表页面
        if ([jobVo.strID isEqualToString:@"0"])
        {
            //添加工作
            MyJobListViewController *addJobViewController = [[UIStoryboard storyboardWithName:@"JobModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MyJobListViewController"];
            addJobViewController.jobListPageType = AddJobListPageType;
            [self.navigationController pushViewController:addJobViewController animated:YES];
        }
        else
        {
            [self enterJob:jobVo];
        }
    }
    else
    {
        //添加工作页面
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"您确定要添加该工作？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 1000+indexPath.row;
        [alertView show];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //section头部高度
    CGFloat fHeight = 15;
    return fHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //section尾部高度
    return CGFLOAT_MIN;
}

@end
