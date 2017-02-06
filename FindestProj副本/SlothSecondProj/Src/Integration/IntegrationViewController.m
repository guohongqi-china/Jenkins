//
//  IntegrationViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "IntegrationViewController.h"
#import "MenuVo.h"
#import "UserVo.h"
#import "IntegrationViewCell.h"
#import "MyIntegrationViewController.h"
#import "IntegrationDetailManageViewController.h"

@interface IntegrationViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *aryMenu;
    UIRefreshControl* refreshControl;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewIntegration;

@end

@implementation IntegrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.title = @"我的积分";
    
    self.tableViewIntegration.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewIntegration.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    //添加刷新
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    [self.tableViewIntegration addSubview:refreshControl];
    [self.tableViewIntegration sendSubviewToBack:refreshControl];
}

- (void)initData
{
    aryMenu = [NSMutableArray array];
    NSMutableArray *aryFirst = [NSMutableArray array];
    MenuVo *menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"currentIntegration";
    menuVo.strName = @"当前积分";
    menuVo.strRemark = [NSString stringWithFormat:@"%g",[Common getCurrentUserVo].fIntegrationCount];
    [aryFirst addObject:menuVo];
    
    menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"integrationDetail";
    menuVo.strName = @"积分明细";
    [aryFirst addObject:menuVo];
    [aryMenu addObject:aryFirst];
}

- (void)refreshView
{
    [ServerProvider getUserDetail:[Common getCurrentUserVo].strUserID result:^(ServerReturnInfo *retInfo) {
        [refreshControl endRefreshing];
        if (retInfo.bSuccess)
        {
            MenuVo *menuVo = aryMenu[0][0];
            menuVo.strRemark = [NSString stringWithFormat:@"%g",[Common getCurrentUserVo].fIntegrationCount];
            [self.tableViewIntegration reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return aryMenu.count;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *aryTemp = aryMenu[section];
    return aryTemp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IntegrationViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IntegrationViewCell" forIndexPath:indexPath];
    MenuVo *menuVo = aryMenu[indexPath.section][indexPath.row];
    cell.entity = menuVo;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    MenuVo *menuVo = (aryMenu[indexPath.section])[indexPath.row];
    
    if([menuVo.strID isEqualToString:@"currentIntegration"])
    {
        MyIntegrationViewController *myIntegrationViewController = [[UIStoryboard storyboardWithName:@"IntegrationModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MyIntegrationViewController"];
        [self.navigationController pushViewController:myIntegrationViewController animated:YES];
    }
    else if([menuVo.strID isEqualToString:@"integrationDetail"])
    {
        IntegrationDetailManageViewController *integrationDetailManageViewController = [[IntegrationDetailManageViewController alloc]init];
        [self.navigationController pushViewController:integrationDetailManageViewController animated:YES];
    }
    else
    {
        //去抽奖
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
