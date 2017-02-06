//
//  ChooseReviewerViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 4/27/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "ChooseReviewerViewController.h"
#import "SuggestionDetailViewController.h"
#import "ChooseReviewerCell.h"

@interface ChooseReviewerViewController ()

@end

@implementation ChooseReviewerViewController

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

-(void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self setTopNavBarTitle:@"选择审核人"];
    
    //搜索框
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.placeholder = @"搜索真实姓名";
    self.searchBar.delegate = self;
    self.searchBar.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, 44);
    [self.view addSubview:self.searchBar];
    
    self.userSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.userSearchDisplayController.searchResultsDataSource = self;
    self.userSearchDisplayController.searchResultsDelegate = self;
    self.userSearchDisplayController.delegate = self;
    self.userSearchDisplayController.searchResultsTableView.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.userSearchDisplayController.searchResultsTableView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewUserList = [[UITableView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT+44, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-44)];
    _tableViewUserList.dataSource = self;
    _tableViewUserList.delegate = self;
    _tableViewUserList.backgroundColor = [UIColor clearColor];
    _tableViewUserList.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    _tableViewUserList.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.view addSubview:_tableViewUserList];
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
}

- (void)initData
{
    self.aryUser = [NSMutableArray array];
    self.aryUserFilter = [NSMutableArray array];
}

- (void)doSearch
{
    if (self.strSearchText == nil || self.strSearchText.length<=0)
    {
        return;
    }
    
    [self isHideActivity:NO];
    [ServerProvider getCompanyUserByTrueName:self.strSearchText result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            [self.aryUserFilter removeAllObjects];
            [self.aryUserFilter addObjectsFromArray:retInfo.data];
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

#pragma mark Table View
//所在分区所占的行数。
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableViewUserList)
    {
        return  [self.aryUser count];
    }
    else
    {
        return [self.aryUserFilter count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserVo *useVo = nil;
    if (tableView == self.tableViewUserList)
    {
        useVo = self.aryUser[indexPath.row];
    }
    else
    {
        useVo = self.aryUserFilter[indexPath.row];
    }
    
    static NSString *identifier=@"UserListFilterCell";
    ChooseReviewerCell *cell = (ChooseReviewerCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[ChooseReviewerCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
        //改变选中背景色
        UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
        viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
        cell.selectedBackgroundView = viewSelected;
    }
    
    [cell initWithUserVo:useVo];
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UserVo *useVo = nil;
    if (tableView == self.tableViewUserList)
    {
        useVo = self.aryUser[indexPath.row];
    }
    else
    {
        useVo = self.aryUserFilter[indexPath.row];
    }
    
    if(self.suggestionDetailViewController != nil)
    {
        [self.suggestionDetailViewController finishedChooseReviewer:useVo];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UISearchBarDelegate
- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableViewUserList scrollRectToVisible:self.searchBar.frame animated:animated];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //文字改变
    self.strSearchText = searchText;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //恢复初始状态 （恢复原来数据）
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //要进行实时搜索
    [self doSearch];
    //auto reload data
    return NO;
}

@end
