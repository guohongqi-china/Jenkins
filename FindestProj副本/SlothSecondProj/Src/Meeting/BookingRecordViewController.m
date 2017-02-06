//
//  BookingRecordViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/21.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "BookingRecordViewController.h"
#import "BookingRecordCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MeetingRoomService.h"
#import "NoSearchView.h"

@interface BookingRecordViewController ()<UITableViewDataSource,UITableViewDelegate,BookingRecordCellDelegate,UIAlertViewDelegate>
{
    NSMutableArray *aryRecord;
    NoSearchView *noSearchView;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewRecord;
@property (copy, nonatomic) NSString *bookList;

@end

@implementation BookingRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initData:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.isNeedBackItem = YES;
    [self setTitle:@"我的会议预订"];
    
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    _tableViewRecord.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewRecord.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    [_tableViewRecord registerNib:[UINib nibWithNibName:@"BookingRecordCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"BookingRecordCell"];
    
    noSearchView = [[NoSearchView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT) andDes:@"还没有会议预订"];
}

- (void)initData:(BOOL)showHint
{
    aryRecord = [NSMutableArray array];
    
    [Common showProgressView:nil view:self.view modal:NO];
    [MeetingRoomService getMyReserveMeetingList:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            [aryRecord addObjectsFromArray:retInfo.data];
            [_tableViewRecord reloadData];
            if (showHint) {
                [Common tipAlert:@"取消成功!"];
            }
            
            if (aryRecord.count == 0)
            {
                [self.view addSubview:noSearchView];
            }
            else
            {
                [noSearchView removeFromSuperview];
            }
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)configureCell:(BookingRecordCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = NO;
    
    BOOL bLastRow = NO;
    if(indexPath.row == (aryRecord.count-1))
    {
        bLastRow = YES;
    }
    
    [cell setEntity:aryRecord[indexPath.row] lastRow:bLastRow];
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return aryRecord.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookingRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookingRecordCell" forIndexPath:indexPath];
    cell.delegate = self;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:@"BookingRecordCell" cacheByIndexPath:indexPath configuration:^(id cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
 
//#warning ..................预订会议删除功能后台改接口

#pragma mark - <BookingRecordCellDelegate>
- (void)deleteButtonClickWithBookingRecordCell:(BookingRecordCell *)cell
{
    self.bookList = cell.entity.bookList;
    UIAlertView *showAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确认取消会议吗？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
    [showAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [MeetingRoomService cancelReserveMeetingRoomParasms:self.bookList result:^(ServerReturnInfo *retInfo) {
            if (retInfo.bSuccess)
            {
                [self initData:YES];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
            
        }];

    }
}



@end
