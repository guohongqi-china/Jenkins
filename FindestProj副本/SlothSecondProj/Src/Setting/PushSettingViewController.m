//
//  PushSettingViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/28.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "PushSettingViewController.h"
#import "NotifyVo.h"
#import "PushSettingCell.h"
#import "NotifyService.h"

@interface PushSettingViewController ()
{
    NSMutableArray *aryData;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewPush;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *footerLabel;

@end

@implementation PushSettingViewController

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
    [self setTitle:@"推送消息设置"];
    
    self.tableViewPush.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewPush.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.headerLabel.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    self.footerLabel.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
}

- (void)initData
{
    aryData = [NSMutableArray array];
    
    [Common showProgressView:nil view:self.view modal:NO];
    [NotifyService getPushSwitchSettingList:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            [aryData addObjectsFromArray:retInfo.data];
            [self.tableViewPush reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)updatePushSetting:(NotifyVo*)notifyVo
{
    NSMutableArray *aryBody = [[NSMutableArray alloc]init];
    
    for (NSArray *arySection in aryData)
    {
        for (NotifyVo *notifyVo in arySection)
        {
            if (notifyVo.nPush == 1)
            {
                [aryBody addObject:@{@"subclassId":[NSNumber numberWithInteger:notifyVo.notifySubType]}];
            }
        }
    }
    
    [Common showProgressView:nil view:self.view modal:NO];
    [NotifyService updatePushSwitchSetting:aryBody result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            
        }
        else
        {
            notifyVo.nPush = (notifyVo.nPush) == 1?0:1;
            [self.tableViewPush reloadData];
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return aryData.count;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *aryTemp = aryData[section];
    return aryTemp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PushSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PushSettingCell" forIndexPath:indexPath];
    cell.parentController = self;
    cell.entity = aryData[indexPath.section][indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //section头部高度
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //section尾部高度
    CGFloat fHeight = 10;
    return fHeight;
}

@end
