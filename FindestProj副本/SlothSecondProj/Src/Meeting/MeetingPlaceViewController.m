//
//  MeetingPlaceViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/18.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MeetingPlaceViewController.h"
#import "MeetingPlaceCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MeetingRoomService.h"
#import "MeetingPlaceDao.h"

@interface MeetingPlaceViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *aryPlace;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewPlace;

@end

@implementation MeetingPlaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.isNeedBackItem = YES;
    [self setTitle:@"选择公司"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableViewPlace.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.tableViewPlace.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    aryPlace = [NSMutableArray array];
}

- (void)refreshView
{
    if(aryPlace.count > 0)
    {
        [_tableViewPlace reloadData];
    }
    else
    {
        [self loadData];
    }
}

- (void)loadData
{
    [Common showProgressView:nil view:self.view modal:NO];
    [MeetingRoomService getMeetingPlaceList:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            [aryPlace removeAllObjects];
            [aryPlace addObjectsFromArray:retInfo.data];
            
            if (aryPlace.count>0)
            {
                //选中上一次的选择
                MeetingPlaceVo *placeVoLast = [MeetingPlaceDao getMeetingPlaceVo];
                for (MeetingPlaceVo *placeVo in aryPlace)
                {
                    if([placeVo.strID isEqualToString:placeVoLast.strID])
                    {
                        placeVo.bCheck = YES;
                        break;
                    }
                }
                
                [_tableViewPlace reloadData];
            }
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)configureCell:(MeetingPlaceCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = NO;
    cell.entity = aryPlace[indexPath.row];
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return aryPlace.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeetingPlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeetingPlaceCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView fd_heightForCellWithIdentifier:@"MeetingPlaceCell" cacheByIndexPath:indexPath configuration:^(id cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //clear check status
    for (MeetingPlaceVo *placeVo in aryPlace)
    {
        placeVo.bCheck = NO;
    }
    
    //check current
    MeetingPlaceVo *placeVo = aryPlace[indexPath.row];
    placeVo.bCheck = YES;
    [self.delegate completedMeetingPlace:placeVo];
    
    //call delegate
    MeetingPlaceCell *cell = [_tableViewPlace cellForRowAtIndexPath:indexPath];
    cell.imgViewCheck.image = [UIImage imageNamed:@"list_selected"];
    
    [self backForePage];
}

@end
