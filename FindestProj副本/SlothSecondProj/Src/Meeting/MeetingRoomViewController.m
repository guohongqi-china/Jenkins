//
//  MeetingRoomViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/18.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MeetingRoomViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MeetingRoomCell.h"
#import "MeetingRoomService.h"
#import "MeetingDialViewController.h"

@interface MeetingRoomViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *aryRoom;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewRoom;


@end

@implementation MeetingRoomViewController

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
    self.isNeedBackItem = YES;
    [self setTitle:@"选择会议室"];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableViewRoom.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewRoom.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [_tableViewRoom registerNib:[UINib nibWithNibName:@"MeetingRoomCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MeetingRoomCell"];
}

- (void)initData
{
    aryRoom = [NSMutableArray array];
    
    if (self.bookVo)
    {
        [Common showProgressView:nil view:self.view modal:NO];
        [MeetingRoomService getMeetingRoomListByParameter:self.bookVo result:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            if (retInfo.bSuccess)
            {
                [aryRoom addObjectsFromArray:retInfo.data];
                [_tableViewRoom reloadData];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
}

- (void)configureCell:(MeetingRoomCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = NO;
    cell.entity = aryRoom[indexPath.row];
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return aryRoom.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeetingRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeetingRoomCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:@"MeetingRoomCell" cacheByIndexPath:indexPath configuration:^(id cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MeetingDialViewController *meetingDialViewController = [[UIStoryboard storyboardWithName:@"MeetingBooking" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"MeetingDialViewController"];
    self.bookVo.roomVo = aryRoom[indexPath.row];
    meetingDialViewController.bookVo = self.bookVo;
    meetingDialViewController.aryRoom = aryRoom;
    [self.navigationController pushViewController:meetingDialViewController animated:YES];
}

@end
