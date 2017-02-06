//
//  ReplyUserViewController.m
//  FindestMeetingProj
//
//  Created by 焱 孙 on 12/30/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "ReplyUserViewController.h"
#import "UserListCell.h"
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
    [self setTopNavBarTitle:@"选择提醒的人"];
    
    //搜索框
    CGFloat fHeight = NAV_BAR_HEIGHT;
    self.imgViewSearch = [[UIImageView alloc]initWithFrame:CGRectMake(10, fHeight+5, kScreenWidth-88, 30)];
    self.imgViewSearch.image = [[UIImage imageNamed:@"search_bk"] stretchableImageWithLeftCapWidth:100 topCapHeight:0];
    [self.view addSubview:self.imgViewSearch];
    
    self.txtSearch = [[UITextField alloc] initWithFrame:CGRectMake(37.5, fHeight+12, kScreenWidth-117, 16)];
    self.txtSearch.placeholder = @"输入首字母搜索";
    self.txtSearch.delegate = self;
    self.txtSearch.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    self.txtSearch.backgroundColor = [UIColor clearColor];
    self.txtSearch.returnKeyType = UIReturnKeySearch;
    self.txtSearch.clearButtonMode = UITextFieldViewModeAlways;
    [self.txtSearch addTarget:self action:@selector(textDidChange) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.txtSearch];
    
    self.btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnSearch.frame = CGRectMake(kScreenWidth-75, fHeight+5, 65, 30);
    [self.btnSearch setTitleColor:COLOR(50, 50, 50, 1.0) forState:UIControlStateNormal];
    [self.btnSearch.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
    [self.btnSearch setBackgroundImage:[[UIImage imageNamed:@"btn_search_index"] stretchableImageWithLeftCapWidth:22 topCapHeight:16] forState:UIControlStateNormal];
    [self.btnSearch setTitle:@"搜索全部" forState:UIControlStateNormal];
    [self.btnSearch addTarget:self action:@selector(doSearchAllUser) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnSearch];
    fHeight += 44;
    
    //User List and Group List
    self.tableViewUserList = [[UITableView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, kScreenHeight-fHeight)];
    _tableViewUserList.dataSource = self;
    _tableViewUserList.delegate = self;
    _tableViewUserList.backgroundColor = [UIColor clearColor];
    self.tableViewUserList.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_tableViewUserList];
    
    //search result list
    self.tableViewSearchResult = [[PullingRefreshTableView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, kScreenHeight-fHeight) pullingDelegate:self];
    self.tableViewSearchResult.dataSource = self;
    self.tableViewSearchResult.delegate = self;
    self.tableViewSearchResult.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableViewSearchResult.backgroundColor = [UIColor whiteColor];
    self.tableViewSearchResult.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:self.tableViewSearchResult];
    self.tableViewSearchResult.hidden = YES;
}

-(void)initData
{
    self.aryUserOrignalData = [NSMutableArray array];
    self.aryUserTableData = [NSMutableArray array];
    self.aryUserFilteredObject = [NSMutableArray array];
    self.bOnLineSearch = NO;
    
    [self refreshData];
}

-(void)refreshData
{
    GroupAndUserDao *groupAndUserDao = [[GroupAndUserDao alloc]init];
    self.aryUserOrignalData = [groupAndUserDao getDBUserList:NO];
    self.aryUserTableData = self.aryUserOrignalData;
    [self.tableViewUserList reloadData];
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
    
    [self.tableViewSearchResult reloadData];
}

//取消选择回复人
- (void)backButtonClicked
{
    if ([self.delegate respondsToSelector:@selector(cancelChooseUserAction:)])
    {
        [self.delegate cancelChooseUserAction:self.bClickAtButtonEnter];
    }
    
    self.txtSearch.text = @"";
    [self.txtSearch resignFirstResponder];
    [self textDidChange];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate showKeyboard];
    }];
}

//完成选择
-(void)doComplete:(UserVo*)userVo
{
    //代理方法
    if ([self.delegate respondsToSelector:@selector(completeChooseUserAction:)])
    {
        [self.delegate completeChooseUserAction:userVo];
    }
    
    self.txtSearch.text = @"";
    [self.txtSearch resignFirstResponder];
    [self textDidChange];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate showKeyboard];
    }];
}

#pragma mark - UISearch
//本地搜索关注用户
- (void)textDidChange
{
    //文字改变,要进行实时搜索
    self.strSearchText = self.txtSearch.text;

    //user page
    if (self.strSearchText.length == 0)
    {
        self.tableViewUserList.hidden = NO;
        self.tableViewSearchResult.hidden = YES;
        [self.tableViewUserList reloadData];//刷新数据
    }
    else
    {
        self.tableViewUserList.hidden = YES;
        self.tableViewSearchResult.hidden = NO;
        self.bOnLineSearch = NO;
        [self.tableViewSearchResult setHeaderHidden:YES];
        [self.tableViewSearchResult setFooterHidden:YES];
        [self doUserSearch];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self doSearchAllUser];
    [textField resignFirstResponder];
    return YES;
}

//在线搜索所有用户
-(void)doSearchAllUser
{
    self.refreshing = YES;
    self.strSearchText = self.txtSearch.text;

    //user page
    if (self.strSearchText.length == 0)
    {
        self.tableViewUserList.hidden = NO;
        self.tableViewSearchResult.hidden = YES;
    }
    else
    {
        self.tableViewUserList.hidden = YES;
        self.tableViewSearchResult.hidden = NO;
        self.m_curPageNum = 1;
        self.bOnLineSearch = YES;
        [self.tableViewSearchResult setHeaderHidden:NO];
        [self.tableViewSearchResult setFooterHidden:NO];
        [self loadAllUserSearchResult];
    }
}

//分页搜索(全部用户)
-(void)loadAllUserSearchResult
{
    if (self.aryUserFilteredObject != nil && [self.aryUserFilteredObject count] > 0)
    {
        if (self.refreshing)
        {
            //下拉刷新
            self.m_curPageNum = 1;
        }
        else
        {
            //上拖加载
        }
    }
    
    [ServerProvider getAllUserListByPage:self.m_curPageNum andSearchText:self.strSearchText andPageSize:20 result:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryTemp = retInfo.data;
            if (self.m_curPageNum == 1)
            {
                [self.aryUserFilteredObject removeAllObjects];
            }
            
            if (aryTemp != nil && [aryTemp count] > 0)
            {
                if (self.refreshing)
                {
                    //下拉刷新
                    [self.aryUserFilteredObject removeAllObjects];
                    [self.aryUserFilteredObject addObjectsFromArray:aryTemp];
                    self.m_curPageNum = 2;
                }
                else
                {
                    //上拖加载
                    [self.aryUserFilteredObject addObjectsFromArray:aryTemp];
                    self.m_curPageNum ++;
                }
                [self.tableViewSearchResult tableViewDidFinishedLoading];
            }
            else
            {
                //已全部加载完毕？？？？？？？？？？？？？
                //self.tableViewArticleList.reachedTheEnd = !refreshing;
                //[self.aryArticleList removeAllObjects];
                [self.tableViewSearchResult tableViewDidFinishedLoading];
            }
            [self.tableViewSearchResult reloadData];
        }
        else
        {
            [self.tableViewSearchResult tableViewDidFinishedLoading];
        }
    }];
}

#pragma mark Table View
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger nRowNum = 0;
    if (tableView == self.tableViewUserList)
    {
        nRowNum = [self.aryUserTableData count];
    }
    else if(tableView == self.tableViewSearchResult)
    {
        nRowNum = [self.aryUserFilteredObject count];
    }
    return nRowNum;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewUserList)
    {
        UserVo *useVo = [self.aryUserTableData objectAtIndex:[indexPath row]];
        static NSString *identifier=@"ReplyUserCell";
        UserListCell *cell = (UserListCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[UserListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            
            //改变选中背景色
            UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
            viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
            cell.selectedBackgroundView = viewSelected;
        }
        
        [cell initWithUserVo:useVo];
        return  cell;
    }
    else if(tableView == self.tableViewSearchResult)
    {
        UserVo *useVo = [self.aryUserFilteredObject objectAtIndex:[indexPath row]];
        
        static NSString *identifier=@"ReplyUserCell";
        UserListCell *cell = (UserListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[UserListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            
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
    else if (tableView == self.tableViewSearchResult)
    {
        userVo = [self.aryUserFilteredObject objectAtIndex:[indexPath row]];
    }
    [self doComplete:userVo];
}

#pragma mark - PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView
{
    if(tableView == self.tableViewSearchResult)
    {
        self.refreshing = YES;
        [self loadAllUserSearchResult];
    }
}
- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView
{
    if(tableView == self.tableViewSearchResult)
    {
        self.refreshing = NO;
        [self loadAllUserSearchResult];
    }
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (iOSPlatform<7)
    {
        [self.txtSearch resignFirstResponder];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == self.tableViewSearchResult && self.bOnLineSearch)
    {
        [self.tableViewSearchResult tableViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(scrollView == self.tableViewSearchResult && self.bOnLineSearch)
    {
        [self.tableViewSearchResult tableViewDidEndDragging:scrollView];
    }
}

@end
