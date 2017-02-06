//
//  ChexiangJobViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/24.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ChexiangJobViewController.h"
#import "JobListCell.h"
#import "JobVo.h"
#import "JobWebViewController.h"
#import "VerifyJobViewController.h"
#import "CertificateUploadViewController.h"
#import "ServerURL.h"
#import "CheXiangService.h"
#import "CommonNavigationController.h"

@interface ChexiangJobViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSMutableArray *aryJob;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewChexiang;

@end

@implementation ChexiangJobViewController

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
    //车享家
    self.title = @"车享家";
    
    //解绑按钮
    self.navigationItem.rightBarButtonItem = [self rightBtnItemWithTitle:@"移除"];
    
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewChexiang.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewChexiang.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.tableViewChexiang registerNib:[UINib nibWithNibName:@"JobListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"JobListCell"];
}

- (void)initData
{
    aryJob = [NSMutableArray array];
    
    //车享家
    NSMutableArray *aryFirst = [NSMutableArray array];
    JobVo *jobVo = [[JobVo alloc]init];
    jobVo.strID = @"1";
    jobVo.strName = @"我的工作台";
    if (self.strMyWorkbenchURL.length == 0)
    {
        self.strMyWorkbenchURL = [NSString stringWithFormat:@"%@%@",[ServerURL getChexiangWorkbenchURL],self.strChexiangAccount];
    }
    jobVo.strJobURL = self.strMyWorkbenchURL;
    [aryFirst addObject:jobVo];
    
    jobVo = [[JobVo alloc]init];
    jobVo.strID = @"2";
    jobVo.strName = @"百宝箱";
    [aryFirst addObject:jobVo];
    [aryJob addObject:aryFirst];
}

- (void)righBarClick
{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"您确定要移除该工作？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

- (void)removeJobAction
{
    [Common showProgressView:@"移除中..." view:self.view modal:NO];
    [CheXiangService editChexiangJob:self.strJobID type:2 result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            //移除则退出去，并且刷新我的工作
            [[NSNotificationCenter defaultCenter]postNotificationName:@"CheXiangRefreshJobNotification" object:nil];
            [self backForePage];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        //解绑
        [Common showProgressView:@"移除中..." view:self.view modal:YES];
        [CheXiangService unbindCheXiangAccount:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            if (retInfo.bSuccess)
            {
                //解绑后调用移除操作
                [self removeJobAction];
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
    if (indexPath.row == 0)
    {
        //我的工作台
        JobWebViewController *jobWebViewController = [[UIStoryboard storyboardWithName:@"JobModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"JobWebViewController"];
        jobWebViewController.nFlag = 1;
        jobWebViewController.jobVo = jobVo;
        [self.navigationController pushViewController:jobWebViewController animated:YES];
    }
    else
    {
        //百宝箱
        CertificateUploadViewController *certificateUploadViewController = [[CertificateUploadViewController alloc]init];
        [self.navigationController pushViewController:certificateUploadViewController animated:YES];
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
