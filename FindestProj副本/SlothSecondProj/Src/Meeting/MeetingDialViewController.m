//
//  MeetingDialViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/22.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MeetingDialViewController.h"
#import "MeetingRoomCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MeetingRoomService.h"
#import "MeetingDialView.h"
#import "MeetingBookingFormViewController.h"
#import "MeetingRoomViewController.h"

@interface MeetingDialViewController ()<UITableViewDataSource,UITableViewDelegate,MeetingDialDelegate>
{
    MeetingDialView *meetingDialView;
    UIBarButtonItem *rightItem;
    
    MeetingRoomVo *m_meetingRoomVo;
    
    NSMutableArray *aryTableData;
}

@property (weak, nonatomic) IBOutlet UILabel *lblMeetingDate;
@property (weak, nonatomic) IBOutlet UIView *viewDialContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableViewMeeting;

@end

@implementation MeetingDialViewController

- (void)dealloc
{
    DLog(@"MeetingDialViewController dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initData];
    [self getMeetingRoomDetailInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [meetingDialView closeTimer];
}

- (void)initView
{
    self.isNeedBackItem = YES;
    self.fd_interactivePopDisabled = YES;
    [self setTitle:self.bookVo.roomVo.strName];
    self.view.backgroundColor = [UIColor whiteColor];
    
    rightItem = [self rightBtnItemWithTitle:@"完成"];
    rightItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = rightItem;
    
    NSString *strDate = [Common getDateTimeStrFromDate:self.bookVo.dateBook format:@"MM月dd日"];
    strDate = [NSString stringWithFormat:@"%@ %@",strDate,[Common getDateWeekStrFromDate:self.bookVo.dateBook]];
    _lblMeetingDate.text = strDate;
    _lblMeetingDate.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    meetingDialView = [[MeetingDialView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 424)];
    meetingDialView.delegate = self;
    meetingDialView.strBookDate = self.bookVo.strBookDate;
    [self.viewDialContainer addSubview:meetingDialView];
    self.viewDialContainer.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    //change by fjz 5.16   NO -> YES
    _tableViewMeeting.scrollEnabled = YES;
    _tableViewMeeting.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    _tableViewMeeting.backgroundColor =[SkinManage colorNamed:@"Page_BK_Color"];
    [_tableViewMeeting registerNib:[UINib nibWithNibName:@"MeetingRoomCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MeetingRoomCell"];
}

- (void)initData
{
    aryTableData = [NSMutableArray array];
    [aryTableData addObjectsFromArray:self.aryRoom];
    [aryTableData removeObject:self.bookVo.roomVo];
}

- (void)getMeetingRoomDetailInfo
{
    [Common showProgressView:nil view:self.view modal:YES];
    [MeetingRoomService getMeetingRoomDetail:nil room:self.bookVo.roomVo.strID date:[Common getDateTimeStrFromDate:self.bookVo.dateBook format:@"yyyy-MM-dd"]
    result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            NSArray *aryData = retInfo.data;
            if (aryData.count>0)
            {
                m_meetingRoomVo = aryData[0];
                
                //用字典初始化已预订记录
                NSMutableDictionary *dicReserved = [[NSMutableDictionary alloc]init];
                for (MeetingBookVo *bookVo in m_meetingRoomVo.aryBookInfo)
                {
                    [dicReserved setObject:bookVo forKey:[NSString stringWithFormat:@"%li",(unsigned long)bookVo.nTimeID]];
                }
                
                [meetingDialView refreshBookRecord:dicReserved];
            }
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)righBarClick
{
    self.bookVo.strStartTime = [meetingDialView getStartTimeString];
    self.bookVo.strEndTime = [meetingDialView getEndTimeString];
    
    MeetingBookingFormViewController *meetingBookingFormViewController = [[UIStoryboard storyboardWithName:@"MeetingBooking" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"MeetingBookingFormViewController"];
    meetingBookingFormViewController.bookVo = self.bookVo;
    [self.navigationController pushViewController:meetingBookingFormViewController animated:YES];
}

- (void)backForePage
{
    [meetingDialView closeTimer];
    
    for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[MeetingRoomViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            break;
        }
    }
}

- (void)configureCell:(MeetingRoomCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = NO;
    cell.entity = aryTableData[indexPath.row];
}

#pragma mark - MeetingDialDelegate
- (void)dialViewStateChanged:(NSInteger)nState timeSegment:(NSMutableArray *)aryTimeSegment
{
    if(nState == 3)
    {
        rightItem.enabled = YES;
        self.bookVo.aryTimeSegment = [NSMutableArray array];
        [self.bookVo.aryTimeSegment addObjectsFromArray:aryTimeSegment];
    }
    else
    {
        rightItem.enabled = NO;
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return aryTableData.count;
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
    self.bookVo.roomVo = aryTableData[indexPath.row];
    meetingDialViewController.bookVo = self.bookVo;
    meetingDialViewController.aryRoom = _aryRoom;
    [self.navigationController pushViewController:meetingDialViewController animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *header = @"MeetingSectionHeader";
    UITableViewHeaderFooterView *viewHeader;
    viewHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:header];
    if (viewHeader == nil)
    {
        viewHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:header];
        viewHeader.contentView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        
        UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, kScreenWidth-24, 35)];
        lblTitle.text = @"其他会议室";
        lblTitle.font = [UIFont systemFontOfSize:14];
        lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
        lblTitle.textAlignment = NSTextAlignmentLeft;
        [viewHeader addSubview:lblTitle];
    }
    
    return viewHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

@end
