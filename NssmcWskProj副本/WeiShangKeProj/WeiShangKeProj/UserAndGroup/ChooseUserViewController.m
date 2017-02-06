//
//  ChooseUserViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-9.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "ChooseUserViewController.h"
#import "GroupAndUserDao.h"
#import "Utils.h"
#import "UserVo.h"
#import "ChooseUserCell.h"

@interface ChooseUserViewController ()

@end

@implementation ChooseUserViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self allAndAlreadyChooseTabSwitch:self.btnAllTab];
    [self updateChooseGroupMembers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    //左边按钮
    UIButton *btnCancel = [Utils buttonWithTitle:[Common localStr:@"Common_Cancel" value:@"取消"] frame:[Utils getNavLeftBtnFrame:CGSizeMake(120,76)] target:self action:nil];
    [btnCancel addTarget:self action:@selector(doCancel) forControlEvents:UIControlEventTouchUpInside];
    [self setLeftBarButton:btnCancel];
    
    //右边按钮
    UIButton *btnSend = [Utils buttonWithTitle:[Common localStr:@"Common_Done" value:@"完成"] frame:[Utils getNavRightBtnFrame:CGSizeMake(100,76)] target:self action:nil];
    [btnSend addTarget:self action:@selector(doComplete) forControlEvents:UIControlEventTouchUpInside];
    [self setRightBarButton:btnSend];
    
    if (self.chooseUserType == GroupEditChooseUserType)
    {
        [self setTopNavBarTitle:[Common localStr:@"UserGroup_SelectGroupMem" value:@"选择群组成员"]];
    }
    else
    {
        [self setTopNavBarTitle:[Common localStr:@"UserGroup_SelectRecipients" value:@"选择收件人"]];
    }
    
    CGFloat fHeight = NAV_BAR_HEIGHT;
    //搜索框
    self.searchBarData = [[UISearchBar alloc] initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 44)];
    self.searchBarData.placeholder = [Common localStr:@"Common_SearchTitle" value:@"搜索"];
    self.searchBarData.delegate = self;
    [self.view addSubview:self.searchBarData];
    
    self.searchDisplayControllerData = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBarData contentsController:self];
    self.searchDisplayControllerData.searchResultsDataSource = self;
    self.searchDisplayControllerData.searchResultsDelegate = self;
    self.searchDisplayControllerData.delegate = self;
    
    //选择所有用户和群组
    fHeight += 44+5;
    self.btnChooseAllPersons = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnChooseAllPersons.frame = CGRectMake(9.5,fHeight,kScreenWidth-20,30);
    [self.btnChooseAllPersons.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:15.0]];
    [self.btnChooseAllPersons setBackgroundImage:[[UIImage imageNamed:@"user_team"] stretchableImageWithLeftCapWidth:61 topCapHeight:16.5] forState:UIControlStateNormal];
    [self.btnChooseAllPersons setTitle:[Common localStr:@"UserGroup_SelectAllUser" value:@"选择所有人"] forState:UIControlStateNormal];
    [self.btnChooseAllPersons  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnChooseAllPersons addTarget:self action:@selector(chooseAllUserOrGroup) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnChooseAllPersons];
    
    //User List and Group List
    fHeight += 30+5;
    self.tableViewUserList = [[UITableView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, kScreenHeight-fHeight-50)];
    _tableViewUserList.dataSource = self;
    _tableViewUserList.delegate = self;
    _tableViewUserList.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableViewUserList];
    
    //5.全部和已选
    self.imgViewBottomTabBK = [[UIImageView alloc]initWithFrame:CGRectMake(10,kScreenHeight-40,kScreenWidth-20,30.5)];
    self.imgViewBottomTabBK.image = [UIImage imageNamed:@"choose_group_user_tab1"];
    [self.view addSubview:self.imgViewBottomTabBK];
    
    self.btnAllTab = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnAllTab.frame = CGRectMake(9.5, kScreenHeight-40+2, kScreenWidth/2-9.5, 30.5);
    [self.btnAllTab.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:14.0]];
    [self.btnAllTab setTitle:[Common localStr:@"UserGroup_All" value:@"全部"] forState:UIControlStateNormal];
    [self.btnAllTab addTarget:self action:@selector(allAndAlreadyChooseTabSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnAllTab];
    
    self.btnAlreadyChooseTab = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnAlreadyChooseTab.frame = CGRectMake(kScreenWidth/2, kScreenHeight-40+2, kScreenWidth/2-9.5, 30.5);
    [self.btnAlreadyChooseTab.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:(14.0)]];
    [self.btnAlreadyChooseTab setTitle:[Common localStr:@"UserGroup_Selected" value:@"已选"] forState:UIControlStateNormal];
    [self.btnAlreadyChooseTab addTarget:self action:@selector(allAndAlreadyChooseTabSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnAlreadyChooseTab];
    
    if (self.bIsAllTab)
    {
        [self.btnAllTab setTitleColor:COLOR(255, 255, 255, 1.0) forState:UIControlStateNormal];
        [self.btnAlreadyChooseTab setTitleColor:COLOR(142, 142, 142, 1.0) forState:UIControlStateNormal];
    }
    else
    {
        [self.btnAllTab setTitleColor:COLOR(142, 142, 142, 1.0) forState:UIControlStateNormal];
        [self.btnAlreadyChooseTab setTitleColor:COLOR(255, 255, 255, 1.0) forState:UIControlStateNormal];
    }
}

-(void)initData
{
    self.aryUserDBData = [NSMutableArray array];
    self.aryUserChoosed = [NSMutableArray array];
    self.aryUserDBFirstLetter = [NSMutableArray array];
    self.dicUserDBData = [NSMutableDictionary dictionary];
    
    self.aryUserTableFirstLetter = [NSMutableArray array];
    self.dicUserTableData = [NSMutableDictionary dictionary];
    
    self.aryUserFilteredObject = [NSMutableArray array];
    
    //////////////////////////////////////////////////////////////
    
    self.bIsAllTab = YES;
    
    self.nChooseUserNumber = 0;
    
    //get DB user list
    GroupAndUserDao *groupAndUserDao = [[GroupAndUserDao alloc]init];
    BOOL bContainerSelf = YES;
    self.aryUserDBData = [groupAndUserDao getDBUserList:bContainerSelf];
    
    [self configureDataSource:self.aryUserDBFirstLetter andDic:self.dicUserDBData andOriginData:self.aryUserDBData];
    //assign table view data
    self.aryUserTableFirstLetter = self.aryUserDBFirstLetter;
    self.dicUserTableData = self.dicUserDBData;
}

//configure data source
-(void)configureDataSource:(NSMutableArray*)aryFirstLetter andDic:(NSMutableDictionary*)dicUserData andOriginData:(NSMutableArray*)aryOrignData
{
    //1.init 27 array
    NSMutableArray *aryParent = [NSMutableArray array];
    for (int i=0; i<=26; i++)
    {
        NSMutableArray *arySub = [NSMutableArray array];
        [aryParent addObject:arySub];
    }
    
    //2.data classify
    for (int i=0; i<aryOrignData.count; i++)
    {
        UserVo *userVo = (UserVo*)[aryOrignData objectAtIndex:i];
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
                [aryFirstLetter addObject:@"#"];
                [dicUserData setObject:arySub forKey:@"#"];
            }
            else
            {
                //A,B,C...
                NSString *strFirstLetter = [NSString stringWithFormat:@"%c",65+i];
                [aryFirstLetter addObject:strFirstLetter];
                [dicUserData setObject:arySub forKey:strFirstLetter];
            }
        }
    }
}

//更新选择成员
-(void)updateChooseGroupMembers
{
    //从新更新已选数组
    [self.aryUserChoosed removeAllObjects];
    self.nChooseUserNumber = 0;
    
    //更新原始数组
    for (int i=0; i<self.aryUserDBData.count; i++)
    {
        UserVo *userVo = [self.aryUserDBData objectAtIndex:i];
        userVo.bChecked = NO;
        
        for (int j=0; j<self.aryUserPreChoosed.count; j++)
        {
            UserVo *userVoTemp = [self.aryUserPreChoosed objectAtIndex:j];
            if ([userVo.strUserID isEqualToString:userVoTemp.strUserID])
            {
                self.nChooseUserNumber++;
                userVo.bChecked = YES;
                [self.aryUserChoosed addObject:userVo];
            }
        }
    }
    [self.btnAlreadyChooseTab setTitle:[NSString stringWithFormat:@"%@(%lu)",[Common localStr:@"UserGroup_Selected" value:@"已选"],(unsigned long)self.nChooseUserNumber] forState:UIControlStateNormal];
    [self.tableViewUserList reloadData];
}

-(void)doCancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

//完成选择
-(void)doComplete
{
    //call delegate method
    NSMutableArray *aryTempChoosed = [NSMutableArray array];
    for (UserVo *userTemp in self.aryUserChoosed)
    {
        UserVo *userVo = [[UserVo alloc]init];
        userVo.strUserID = userTemp.strUserID;
        userVo.strUserName = userTemp.strUserName;
        userVo.strHeadImageURL = userTemp.strHeadImageURL;
        userVo.strQP = userTemp.strQP;
        userVo.strJP = userTemp.strJP;
        [aryTempChoosed addObject:userVo];
    }
    
    if(aryTempChoosed.count == 0)
    {
        [Common tipAlert:[Common localStr:@"UserGroup_SelectMem" value:@"请选择成员"]];
        return;
    }
    else
    {
        [self.delegate completeChooseUserAction:aryTempChoosed];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)chooseAllUserOrGroup
{
    if (self.nChooseUserNumber == self.aryUserDBData.count)
    {
        //全部反选(从新更新已选数组)
        [self.aryUserChoosed removeAllObjects];
        self.nChooseUserNumber = 0;
        
        //更新原始数组
        for (int i=0; i<self.aryUserDBData.count; i++)
        {
            UserVo *userVo = [self.aryUserDBData objectAtIndex:i];
            userVo.bChecked = NO;
        }
    }
    else
    {
        //全部选择(从新更新已选数组)
        [self.aryUserChoosed removeAllObjects];
        self.nChooseUserNumber = self.aryUserDBData.count;
        
        //更新原始数组
        for (int i=0; i<self.aryUserDBData.count; i++)
        {
            UserVo *userVo = [self.aryUserDBData objectAtIndex:i];
            userVo.bChecked = YES;
            [self.aryUserChoosed addObject:userVo];
        }
    }
    
    [self.btnAlreadyChooseTab setTitle:[NSString stringWithFormat:@"%@(%lu)",[Common localStr:@"UserGroup_Selected" value:@"已选"],(unsigned long)self.nChooseUserNumber] forState:UIControlStateNormal];
    [self.tableViewUserList reloadData];
}

//全部和已选tab切换
-(void)allAndAlreadyChooseTabSwitch:(UIButton*)sender
{
    [self.searchDisplayControllerData setActive:NO animated:YES];
    
    if (sender == self.btnAllTab)
    {
        if (!self.bIsAllTab)
        {
            //由已选->全部
            self.bIsAllTab = YES;
            self.imgViewBottomTabBK.image = [UIImage imageNamed:@"choose_group_user_tab1"];
            
            //用户数据
            self.aryUserTableFirstLetter = self.aryUserDBFirstLetter;
            self.dicUserTableData = self.dicUserDBData;
            [self.tableViewUserList reloadData];
            //text color
            [self.btnAllTab setTitleColor:COLOR(255, 255, 255, 1.0) forState:UIControlStateNormal];
            [self.btnAlreadyChooseTab setTitleColor:COLOR(142, 142, 142, 1.0) forState:UIControlStateNormal];
        }
    }
    else
    {
        if (self.bIsAllTab)
        {
            //由全部->已选
            self.bIsAllTab = NO;
            self.imgViewBottomTabBK.image = [UIImage imageNamed:@"choose_group_user_tab2"];
            
            //用户数据
            NSMutableArray *aryFirstLetter = [NSMutableArray array];
            NSMutableDictionary *dicUserData = [NSMutableDictionary dictionary];
            [self configureDataSource:aryFirstLetter andDic:dicUserData andOriginData:self.aryUserChoosed];
            self.aryUserTableFirstLetter = aryFirstLetter;
            self.dicUserTableData = dicUserData;
            [self.tableViewUserList reloadData];
            //text color
            [self.btnAllTab setTitleColor:COLOR(142, 142, 142, 1.0) forState:UIControlStateNormal];
            [self.btnAlreadyChooseTab setTitleColor:COLOR(255, 255, 255, 1.0) forState:UIControlStateNormal];
        }
    }
}

- (void)doUserSearch
{
    //1.Condition Check
    if (self.strSearchText == nil || self.strSearchText.length<=0)
    {
        return;
    }
    
    if(self.aryUserDBData == nil || self.aryUserDBData.count <= 0)
    {
        return;
    }
    
    [self.aryUserFilteredObject removeAllObjects];
    NSMutableArray *aryFilteredName = [[NSMutableArray alloc]init];
    NSMutableArray *aryFilteredJP = [[NSMutableArray alloc]init];
    NSMutableArray *aryFilteredQP = [[NSMutableArray alloc]init];
    
    for (int i=0; i<self.aryUserDBData.count; i++)
    {
        UserVo *userVo = (UserVo*)[self.aryUserDBData objectAtIndex:i];
        
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

//------------------------------------------------------
#pragma mark Table View
//分区个数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUInteger nSectionNum = 0;
    if (tableView == self.tableViewUserList)
    {
        //用户列表tableview(tableViewUserList)
        nSectionNum = [self.aryUserTableFirstLetter count];
    }
    else if(tableView == self.searchDisplayControllerData.searchResultsTableView)
    {
        //搜索结果tableView(searchDisplayControllerData.searchResultsTableView)
        nSectionNum = 1;
    }
    return nSectionNum;
}

//所在分区所占的行数。
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger nRowNum = 0;
    if (tableView == self.tableViewUserList)
    {
        NSString *strKey=[self.aryUserTableFirstLetter objectAtIndex:section];
        NSArray *aryGroupData=[self.dicUserTableData objectForKey:strKey];
        nRowNum = [aryGroupData count];
    }
    else if(tableView == self.searchDisplayControllerData.searchResultsTableView)
    {
        nRowNum = [self.aryUserFilteredObject count];
    }
    return nRowNum;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewUserList)
    {
        NSString *strFirstLetter = [self.aryUserTableFirstLetter objectAtIndex:[indexPath section]];
        NSArray *arySub = [self.dicUserTableData objectForKey:strFirstLetter];
        UserVo *useVo = [arySub objectAtIndex:[indexPath row]];
        
        static NSString *identifier=@"ChooseUserCell";
        ChooseUserCell *cell = (ChooseUserCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[ChooseUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            
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
        
        static NSString *identifier=@"ChooseUserCell";
        ChooseUserCell *cell = (ChooseUserCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[ChooseUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            
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

//把每个分区打上标记key
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableViewUserList)
    {
        NSString *key=[self.aryUserTableFirstLetter objectAtIndex:section];
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
        return self.aryUserTableFirstLetter;
    }
    else
    {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableViewUserList)
    {
        NSString *strFirstLetter=[self.aryUserTableFirstLetter objectAtIndex:[indexPath section]];
        NSMutableArray *arySub=[self.dicUserTableData objectForKey:strFirstLetter];
        UserVo *userVo = [arySub objectAtIndex:[indexPath row]];
        //群主不能选择
        if (self.chooseUserType == GroupEditChooseUserType && self.strGroupCreateID != nil && [userVo.strUserID isEqualToString:self.strGroupCreateID])
        {
            [Common tipAlert:[Common localStr:@"UserGroup_NotSelOwn" value:@"群主不能选择"]];
            return;
        }
        
        //反选
        userVo.bChecked = !userVo.bChecked;
        
        //change choosed num
        if (userVo.bChecked)
        {
            self.nChooseUserNumber++;
            [self.aryUserChoosed addObject:userVo];
        }
        else
        {
            self.nChooseUserNumber--;
            [self.aryUserChoosed removeObject:userVo];      //移除已选数组
        }
        
        [self.btnAlreadyChooseTab setTitle:[NSString stringWithFormat:@"%@(%lu)",[Common localStr:@"UserGroup_Selected" value:@"已选"],(unsigned long)self.nChooseUserNumber] forState:UIControlStateNormal];
        
        if(self.bIsAllTab)
        {
            //全选界面
            ChooseUserCell *cell = (ChooseUserCell*)[tableView cellForRowAtIndexPath:indexPath];
            [cell updateCheckImage:userVo.bChecked];
        }
        else
        {
            //已选界面
            [arySub removeObject:userVo];    //移除TableView数据(与搜索同一个)
            if (arySub.count == 0)
            {
                [self.aryUserTableFirstLetter removeObject:strFirstLetter];
            }
            [self.tableViewUserList reloadData];
        }
    }
    else if (tableView == self.searchDisplayControllerData.searchResultsTableView)
    {
        UserVo *userVo = [self.aryUserFilteredObject objectAtIndex:[indexPath row]];
        
        //群主不能选择
        if (self.chooseUserType == GroupEditChooseUserType && self.strGroupCreateID != nil && [userVo.strUserID isEqualToString:self.strGroupCreateID])
        {
            [Common tipAlert:[Common localStr:@"UserGroup_NotSelOwn" value:@"群主不能选择"]];
            return;
        }

        //反选
        userVo.bChecked = !userVo.bChecked;
        
        //change choosed num
        if (userVo.bChecked)
        {
            self.nChooseUserNumber++;
            [self.aryUserChoosed addObject:userVo];
        }
        else
        {
            self.nChooseUserNumber--;
            [self.aryUserChoosed removeObject:userVo];      //移除已选数组
        }
        //change chk image
        ChooseUserCell *cell = (ChooseUserCell*)[tableView cellForRowAtIndexPath:indexPath];
        [cell updateCheckImage:userVo.bChecked];
        
        [self.btnAlreadyChooseTab setTitle:[NSString stringWithFormat:@"%@(%lu)",[Common localStr:@"UserGroup_Selected" value:@"已选"],(unsigned long)self.nChooseUserNumber] forState:UIControlStateNormal];
    }
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
