//
//  MeetingBookDetailViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/21.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MeetingBookDetailViewController.h"
#import "MeetingBookDetailCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "KeyValueVo.h"
#import "MeetingRoomService.h"
#import "MeetingBookingViewController.h"

@interface MeetingBookDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *aryData;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewBookDetail;

@end

@implementation MeetingBookDetailViewController

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
    self.isNeedBackItem = YES;
    [self setTitle:@"预约详情"];
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    
    
    
    
    
    
    self.navigationItem.rightBarButtonItem = [self rightBtnItemWithTitle:@"完成"];
    
    _tableViewBookDetail.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    _tableViewBookDetail.backgroundColor = self.tableViewBookDetail.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    UIView *viewHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 12)];
    viewHeader.backgroundColor = self.tableViewBookDetail.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    _tableViewBookDetail.tableHeaderView = viewHeader;
    
    UIView *viewFooter = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 108)];
    viewFooter.backgroundColor = self.tableViewBookDetail.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    _tableViewBookDetail.tableFooterView = viewFooter;
}

- (void)initData
{
    aryData = [NSMutableArray array];
    
    KeyValueVo *valueVo = [[KeyValueVo alloc]init];
    valueVo.strKey = @"会议时间";
    NSString *strDate = [Common getDateTimeStrFromDate:self.bookVo.dateBook format:@"MM月dd日"];
    strDate = [NSString stringWithFormat:@"%@ %@    %@-%@",strDate,[Common getDateWeekStrFromDate:self.bookVo.dateBook],self.bookVo.strStartTime,self.bookVo.strEndTime];
    valueVo.strValue = strDate;
    [aryData addObject:valueVo];
    
    valueVo = [[KeyValueVo alloc]init];
    valueVo.strKey = @"会议地点";
    valueVo.strValue = self.bookVo.strPlaceName;
    valueVo.strRemark = self.bookVo.strPlaceDesc;
    [aryData addObject:valueVo];
    
    valueVo = [[KeyValueVo alloc]init];
    valueVo.strKey = @"会议室";
    valueVo.strValue = self.bookVo.roomVo.strName;
    valueVo.strRemark = self.bookVo.roomVo.strDesc;
    [aryData addObject:valueVo];
    
    valueVo = [[KeyValueVo alloc]init];
    valueVo.strKey = @"预约人";
    valueVo.strValue = self.bookVo.strUserName;
    [aryData addObject:valueVo];
    
    valueVo = [[KeyValueVo alloc]init];
    valueVo.strKey = @"预约人联系电话";
    valueVo.strValue = self.bookVo.strContact;
    [aryData addObject:valueVo];
    
    valueVo = [[KeyValueVo alloc]init];
    valueVo.strKey = @"会议主题";
    valueVo.strValue = self.bookVo.strTitle;
    [aryData addObject:valueVo];
    
    valueVo = [[KeyValueVo alloc]init];
    valueVo.strKey = @"备注";
    valueVo.strValue = self.bookVo.strRemark;
    [aryData addObject:valueVo];
}

- (void)righBarClick
{
    [Common showProgressView:@"预定中..." view:self.view modal:NO];
    [MeetingRoomService reserveMeetingRoomByBookVo:self.bookVo result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            [self backToBookingController];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)backToBookingController
{
    for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[MeetingBookingViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            [Common bubbleTip:@"会议预订成功" andView:controller.view];
            break;
        }
    }
}

- (void)configureCell:(MeetingBookDetailCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = NO;
    cell.entity = aryData[indexPath.row];
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return aryData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeetingBookDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeetingBookDetailCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:@"MeetingBookDetailCell" cacheByIndexPath:indexPath configuration:^(id cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
