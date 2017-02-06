//
//  ChooseChatGroupViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/2/25.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ChooseChatGroupViewController.h"
#import "ChooseChatGroupCell.h"

@interface ChooseChatGroupViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *aryGroup;
    UIRefreshControl* refreshControl;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewGroup;

@end

@implementation ChooseChatGroupViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableViewGroup.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.title = @"选择一个群";
    
    _tableViewGroup.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor clearColor];
    [refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    [_tableViewGroup addSubview:refreshControl];
}

- (void)initData
{
    aryGroup = [NSMutableArray array];
    [self refreshView];
}

-(void)refreshView
{
    [Common showProgressView:nil view:self.view modal:NO];
    [ServerProvider getJoinedChatGroupList:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        [refreshControl endRefreshing];
        if (retInfo.bSuccess)
        {
            [aryGroup removeAllObjects];
            [aryGroup addObjectsFromArray:retInfo.data];
            [_tableViewGroup reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return aryGroup.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChooseChatGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChooseChatGroupCell" forIndexPath:indexPath];
    cell.entity = aryGroup[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(self.delegate)
    {
        [self.delegate completeChooseChatGroup:aryGroup[indexPath.row]];
    }
}

@end
