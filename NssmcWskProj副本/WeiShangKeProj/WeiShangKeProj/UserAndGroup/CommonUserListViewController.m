//
//  CommonUserListViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-13.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "CommonUserListViewController.h"
#import "Utils.h"
#import "KxMenu.h"
#import "GroupAndUserDao.h"
#import "UserListCell.h"

@interface CommonUserListViewController ()

@end

@implementation CommonUserListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self initData];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //[self showBottomTab];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerAddPanGesture object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerRemovePanGesture object:nil];
}

-(void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self setTopNavBarTitle:[Common localStr:@"UserGroup_GroupMem" value:@"群组成员"]];
    
    //搜索框
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.placeholder = [Common localStr:@"Common_SearchTitle" value:@"搜索"];
    self.searchBar.delegate = self;
    self.searchBar.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, 44);
    [self.view addSubview:self.searchBar];
    
    self.userSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.userSearchDisplayController.searchResultsDataSource = self;
    self.userSearchDisplayController.searchResultsDelegate = self;
    self.userSearchDisplayController.delegate = self;
    
    self.tableViewUserList = [[UITableView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT+44, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-44)];
    _tableViewUserList.dataSource = self;
    _tableViewUserList.delegate = self;
    _tableViewUserList.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableViewUserList];
}

-(void)initData
{
    self.strExpandUserID = @"";
    self.aryFirstLetter = [NSMutableArray array];
    self.dicTableData = [NSMutableDictionary dictionary];
    self.aryFilteredObject = [NSMutableArray array];
    
    //get DB user list
    if (self.commonUserListType == CommonUserListChatType || self.commonUserListType == CommonTransferGroupType)
    {
        self.aryDBData = self.aryGroupMemData;
    }
    [self configureDataSource];
}

//configure data source
-(void)configureDataSource
{
    //1.init 27 array
    NSMutableArray *aryParent = [NSMutableArray array];
    for (int i=0; i<=26; i++)
    {
        NSMutableArray *arySub = [NSMutableArray array];
        [aryParent addObject:arySub];
    }
    
    //2.data classify
    for (int i=0; i<self.aryDBData.count; i++)
    {
        UserVo *userVo = (UserVo*)[self.aryDBData objectAtIndex:i];
        NSString *strJP = userVo.strJP;
        if (strJP.length>0)
        {
            //大写字母的ASCii的值为65～90
            int nFirstLetter = [strJP characterAtIndex:0];
            if (nFirstLetter>=65 && nFirstLetter<=90)
            {
                [[aryParent objectAtIndex:nFirstLetter%65] addObject:userVo];
            }
            else
            {
                [[aryParent objectAtIndex:26] addObject:userVo];
            }
        }
        else
        {
            [[aryParent objectAtIndex:26] addObject:userVo];
        }
    }
    
    //3.init dictionary
    for (int i=0; i<aryParent.count; i++)
    {
        NSMutableArray *arySub = [aryParent objectAtIndex:i];
        if (arySub.count>0)
        {
            if (i == 26)
            {
                //#
                [self.aryFirstLetter addObject:@"#"];
                [self.dicTableData setObject:arySub forKey:@"#"];
            }
            else
            {
                //A,B,C...
                NSString *strFirstLetter = [NSString stringWithFormat:@"%c",65+i];
                [self.aryFirstLetter addObject:strFirstLetter];
                [self.dicTableData setObject:arySub forKey:strFirstLetter];
            }
        }
    }
}

- (void)showSideMenu
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kDrawerOpenLeftSide object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doSearch
{
    //1.Condition Check
    if (self.strSearchText == nil || self.strSearchText.length<=0)
    {
        return;
    }
    
    if(self.aryDBData == nil || self.aryDBData.count <= 0)
    {
        return;
    }
    
    [self.aryFilteredObject removeAllObjects];
    NSMutableArray *aryFilteredName = [[NSMutableArray alloc]init];
    NSMutableArray *aryFilteredJP = [[NSMutableArray alloc]init];
    NSMutableArray *aryFilteredQP = [[NSMutableArray alloc]init];
    
    for (int i=0; i<self.aryDBData.count; i++)
    {
        UserVo *userVo = (UserVo*)[self.aryDBData objectAtIndex:i];
        
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
    
    [self.aryFilteredObject addObjectsFromArray:aryFilteredName];
    [self.aryFilteredObject addObjectsFromArray:aryFilteredJP];
    [self.aryFilteredObject addObjectsFromArray:aryFilteredQP];
}

#pragma mark Table View
//分区个数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableViewUserList)
    {
        //用户列表tableview(tableViewUserList)
        return [self.aryFirstLetter count];
    }
    else
    {
        //搜索结果tableView(userSearchDisplayController.searchResultsTableView)
        return 1;
    }
}

//所在分区所占的行数。
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableViewUserList)
    {
        NSString *strKey=[self.aryFirstLetter objectAtIndex:section];
        NSArray *aryGroupData=[self.dicTableData objectForKey:strKey];
        return  [aryGroupData count];
    }
    else
    {
        return [self.aryFilteredObject count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fHeight = 0.0;
    if (tableView == self.tableViewUserList)
    {
        NSString *strFirstLetter=[self.aryFirstLetter objectAtIndex:[indexPath section]];
        NSArray *aryGroupData=[self.dicTableData objectForKey:strFirstLetter];
        UserVo *userVo = [aryGroupData objectAtIndex:[indexPath row]];
        
        if ([self.strExpandUserID isEqualToString:userVo.strUserID])
        {
            fHeight = 60+48.5;
        }
        else
        {
            fHeight = 60;
        }
    }
    else
    {
        UserVo *userVo = [self.aryFilteredObject objectAtIndex:[indexPath row]];
        if ([self.strSearchExpandUserID isEqualToString:userVo.strUserID])
        {
            fHeight = 60+48.5;
        }
        else
        {
            fHeight = 60;
        }
    }
    return fHeight;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewUserList)
    {
        NSString *strFirstLetter=[self.aryFirstLetter objectAtIndex:[indexPath section]];
        NSArray *aryGroupData=[self.dicTableData objectForKey:strFirstLetter];
        UserVo *useVo = [aryGroupData objectAtIndex:[indexPath row]];
        
        static NSString *identifier=@"UserListCell";
        UserListCell *cell = (UserListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[UserListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            
            //改变选中背景色
            UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
            viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
            cell.selectedBackgroundView = viewSelected;
        }
        
        cell.parentViewController = self;
        [cell initWithUserVo:useVo andExpandID:self.strExpandUserID];
        return  cell;
    }
    else
    {
        UserVo *useVo = [self.aryFilteredObject objectAtIndex:[indexPath row]];
        
        static NSString *identifier=@"UserListCell";
        UserListCell *cell = (UserListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[UserListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            
            //改变选中背景色
            UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
            viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
            cell.selectedBackgroundView = viewSelected;
        }
        
        cell.parentViewController = self;
        [cell initWithUserVo:useVo andExpandID:self.strSearchExpandUserID];
        return  cell;
    }
}

//把每个分区打上标记key
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableViewUserList)
    {
        NSString *key=[self.aryFirstLetter objectAtIndex:section];
        return key;
    }
    else
    {
        return @"";
    }
}

//在单元格最右放添加索引
-(NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.tableViewUserList)
    {
        return self.aryFirstLetter;
    }
    else
    {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewUserList)
    {
        NSString *strFirstLetter=[self.aryFirstLetter objectAtIndex:[indexPath section]];
        NSArray *aryGroupData=[self.dicTableData objectForKey:strFirstLetter];
        UserVo *userVo = [aryGroupData objectAtIndex:[indexPath row]];
        
        if (self.commonUserListType == CommonTransferGroupType)
        {
            self.userVoCurrentChoose = userVo;
            UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:[Common localStr:@"Common_Alert" value:@"提示"]  message:[NSString stringWithFormat:@"%@：%@-%@？",[Common localStr:@"UserGroup_TransferGroup" value:@"您确定要转让该群组到用户"],userVo.strUserName,userVo.strPosition] delegate:self cancelButtonTitle:[Common localStr:@"Common_OK" value:@"确定"] otherButtonTitles:[Common localStr:@"Common_Cancel" value:@"取消"],nil];
            [alertView show];
        }
        else
        {
            if ([self.strExpandUserID isEqualToString:userVo.strUserID])
            {
                //the same UserID,then pinch
                self.strExpandUserID = @"";
            }
            else
            {
                self.strExpandUserID = userVo.strUserID;
            }
            [self.tableViewUserList reloadData];
        }
    }
    else if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        UserVo *userVo = [self.aryFilteredObject objectAtIndex:[indexPath row]];
        if (self.commonUserListType == CommonTransferGroupType)
        {
            self.userVoCurrentChoose = userVo;
            UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:[Common localStr:@"Common_Alert" value:@"提示"]  message:[NSString stringWithFormat:@"%@：%@-%@？",[Common localStr:@"UserGroup_TransferGroup" value:@"您确定要转让该群组到用户"],userVo.strUserName,userVo.strPosition] delegate:self cancelButtonTitle:[Common localStr:@"Common_OK" value:@"确定"] otherButtonTitles:[Common localStr:@"Common_Cancel" value:@"取消"],nil];
            [alertView show];
        }
        else
        {
            if ([self.strSearchExpandUserID isEqualToString:userVo.strUserID])
            {
                //the same UserID,then pinch
                self.strSearchExpandUserID = @"";
            }
            else
            {
                self.strSearchExpandUserID = userVo.strUserID;
            }
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    self.strSearchExpandUserID = @"";
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //恢复初始状态 （恢复原来数据）
    self.strSearchExpandUserID = @"";
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //要进行实时搜索
    self.strSearchExpandUserID = @"";
    [self doSearch];
    //auto reload data
    return YES;
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0)
    {
        [self.delegate completeChooseUserForTransferGroup:self.userVoCurrentChoose];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
