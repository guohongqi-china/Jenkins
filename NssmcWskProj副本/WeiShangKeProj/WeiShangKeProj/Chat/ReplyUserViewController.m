//
//  ReplyUserViewController.m
//  FindestMeetingProj
//
//  Created by 焱 孙 on 12/30/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "ReplyUserViewController.h"
#import "ReplyUserCell.h"
#import "GroupAndUserDao.h"

@interface ReplyUserViewController ()

@end

@implementation ReplyUserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self setTopNavBarTitle:[Common localStr:@"Chat_Select_Answer" value:@"选择回复人"]];
    
    //搜索框
    CGFloat fHeight = NAV_BAR_HEIGHT;
    self.searchBarData = [[UISearchBar alloc] initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 44)];
    self.searchBarData.placeholder = [Common localStr:@"Common_SearchTitle" value:@"搜索"];
    self.searchBarData.delegate = self;
    [self.view addSubview:self.searchBarData];
    
    self.searchDisplayControllerData = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBarData contentsController:self];
    self.searchDisplayControllerData.searchResultsDataSource = self;
    self.searchDisplayControllerData.searchResultsDelegate = self;
    self.searchDisplayControllerData.delegate = self;
    fHeight += 44;
    
    //User List and Group List
    self.tableViewUserList = [[UITableView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, kScreenHeight-fHeight)];
    _tableViewUserList.dataSource = self;
    _tableViewUserList.delegate = self;
    _tableViewUserList.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableViewUserList];
}

-(void)initData
{
    self.aryUserOrignalData = [NSMutableArray array];
    self.aryUserTableData = [NSMutableArray array];
    self.aryUserFilteredObject = [NSMutableArray array];
    
    [self refreshData];
}

-(void)refreshData
{
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        //do thread work
        ServerReturnInfo *retInfo = [ServerProvider getChatGroupInfo:self.chatObjectVo];
        if (retInfo.bSuccess)
        {
            self.chatObjectVo = retInfo.data;
            self.aryUserOrignalData = self.chatObjectVo.aryMember;//只显示名称和头像，不用查询DB
            self.aryUserTableData = self.aryUserOrignalData;
            
            //从DB获取UserList
//            GroupAndUserDao *groupAndUserDao = [[GroupAndUserDao alloc]init];
//            self.aryUserOrignalData = [groupAndUserDao getGroupChatUserList:self.chatObjectVo.aryMember];
//            self.aryUserTableData = self.aryUserOrignalData;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableViewUserList reloadData];
                [self isHideActivity:YES];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Common tipAlert:retInfo.strErrorMsg];
                [self isHideActivity:YES];
            });
        }
    });
}

- (void)doUserSearch
{
    //1.Condition Check
    if (self.strSearchText == nil || self.strSearchText.length<=0)
    {
        return;
    }
    
    if(self.aryUserOrignalData == nil || self.aryUserOrignalData.count <= 0)
    {
        return;
    }
    
    [self.aryUserFilteredObject removeAllObjects];
    //为了排序的优先级显示，优先显示名字匹配的记录，再简拼、全拼、其他
    NSMutableArray *aryFilteredName = [[NSMutableArray alloc]init];
    NSMutableArray *aryFilteredJP = [[NSMutableArray alloc]init];
    NSMutableArray *aryFilteredQP = [[NSMutableArray alloc]init];
    
    for (int i=0; i<self.aryUserOrignalData.count; i++)
    {
        UserVo *userVo = (UserVo*)[self.aryUserOrignalData objectAtIndex:i];
        
        if ([userVo.strUserName rangeOfString:self.strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //a.match name
            [aryFilteredName addObject:userVo];
        }
        else if ([userVo.strJP rangeOfString:self.strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //b.match JP
            [aryFilteredJP addObject:userVo];
        }
        else if ([userVo.strQP rangeOfString:self.strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //c.match QP
            [aryFilteredQP addObject:userVo];
        }
    }
    
    [self.aryUserFilteredObject addObjectsFromArray:aryFilteredName];
    [self.aryUserFilteredObject addObjectsFromArray:aryFilteredJP];
    [self.aryUserFilteredObject addObjectsFromArray:aryFilteredQP];
}

//完成选择
-(void)doComplete:(UserVo*)userVo
{
    //代理方法
    [self.delegate completeChooseUserAction:userVo];
    
    //退出选择
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Table View
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger nRowNum = 0;
    if (tableView == self.tableViewUserList)
    {
        nRowNum = [self.aryUserTableData count];
    }
    else if(tableView == self.searchDisplayControllerData.searchResultsTableView)
    {
        nRowNum = [self.aryUserFilteredObject count];
    }
    return nRowNum;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fHeight = 0.0;
    if (tableView == self.tableViewUserList)
    {
        UserVo *useVo = [self.aryUserTableData objectAtIndex:[indexPath row]];
        fHeight = [ReplyUserCell calculateCellHeight:useVo];
    }
    else if(tableView == self.searchDisplayControllerData.searchResultsTableView)
    {
        UserVo *useVo = [self.aryUserFilteredObject objectAtIndex:[indexPath row]];
        fHeight = [ReplyUserCell calculateCellHeight:useVo];
    }
    return fHeight;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewUserList)
    {
        UserVo *useVo = [self.aryUserTableData objectAtIndex:[indexPath row]];
        static NSString *identifier=@"ReplyUserCell";
        ReplyUserCell *cell = (ReplyUserCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[ReplyUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            
            //改变选中背景色
            UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
            viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
            cell.selectedBackgroundView = viewSelected;
        }
        
        [cell initWithUserVo:useVo];
        return  cell;
    }
    else if(tableView == self.searchDisplayControllerData.searchResultsTableView)
    {
        UserVo *useVo = [self.aryUserFilteredObject objectAtIndex:[indexPath row]];
        
        static NSString *identifier=@"ReplyUserCell";
        ReplyUserCell *cell = (ReplyUserCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[ReplyUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            
            //改变选中背景色
            UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
            viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
            cell.selectedBackgroundView = viewSelected;
        }
        
        [cell initWithUserVo:useVo];
        return  cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UserVo *userVo = nil;
    if (tableView == self.tableViewUserList)
    {
        userVo = [self.aryUserTableData objectAtIndex:[indexPath row]];
    }
    else if (tableView == self.searchDisplayControllerData.searchResultsTableView)
    {
        userVo = [self.aryUserFilteredObject objectAtIndex:[indexPath row]];
    }
    [self doComplete:userVo];
}

#pragma mark - UISearchBarDelegate
- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableViewUserList scrollRectToVisible:self.searchBarData.frame animated:animated];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //文字改变
    self.strSearchText = searchText;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //恢复初始状态 （恢复原来数据）
    [self.tableViewUserList reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //要进行实时搜索
    [self doUserSearch];
    self.searchDisplayControllerData.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    //auto reload data
    return YES;
}

@end
