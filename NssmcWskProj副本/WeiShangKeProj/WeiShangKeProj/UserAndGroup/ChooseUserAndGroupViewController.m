//
//  ChooseUserAndGroupViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-28.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "ChooseUserAndGroupViewController.h"
#import "GroupAndUserDao.h"
#import "ChooseUserCell.h"
#import "ChooseGroupCell.h"
#import "Utils.h"

@interface ChooseUserAndGroupViewController ()

@end

@implementation ChooseUserAndGroupViewController

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
    [self initView];
    [self initData];
}

-(void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.fromViewType == FromChatListViewType)
    {
        [self setTopNavBarTitle:[Common localStr:@"UserGroup_SelectUser" value:@"选择联系人"]];
    }
    else
    {
        [self setTopNavBarTitle:[Common localStr:@"UserGroup_SelectRecipients" value:@"选择收件人"]];
    }
    
    //左边按钮
    UIButton *btnCancel = [Utils buttonWithTitle:[Common localStr:@"Common_Cancel" value:[Common localStr:@"Common_Cancel" value:@"取消"]] frame:[Utils getNavLeftBtnFrame:CGSizeMake(120,76)] target:self action:nil];
    [btnCancel addTarget:self action:@selector(doCancel) forControlEvents:UIControlEventTouchUpInside];
    [self setLeftBarButton:btnCancel];
    
    //右边按钮
    UIButton *btnSend = [Utils buttonWithTitle:[Common localStr:@"Common_OK" value:[Common localStr:@"Common_Done" value:@"完成"]] frame:[Utils getNavRightBtnFrame:CGSizeMake(100,76)] target:self action:nil];
    [btnSend addTarget:self action:@selector(doComplete) forControlEvents:UIControlEventTouchUpInside];
    [self setRightBarButton:btnSend];
    
    CGFloat fHeight = NAV_BAR_HEIGHT+5;
    //用户和群组切换、全部和已选切换
    self.btnSwitchUserAndGroup = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnSwitchUserAndGroup.frame = CGRectMake(10,fHeight,kScreenWidth/2-15,30);
    [self.btnSwitchUserAndGroup.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:15.0]];
    [self.btnSwitchUserAndGroup setBackgroundImage:[UIImage imageNamed:@"user_team"] forState:UIControlStateNormal];
    [self.btnSwitchUserAndGroup setTitle:[Common localStr:@"UserGroup_ShowGroup" value:@"显示群组"] forState:UIControlStateNormal];
    [self.btnSwitchUserAndGroup  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnSwitchUserAndGroup addTarget:self action:@selector(userAndGroupSwitch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnSwitchUserAndGroup];
    
    self.btnSwitchSelect = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnSwitchSelect.frame = CGRectMake(kScreenWidth/2+5,fHeight,kScreenWidth/2-15,30);
    [self.btnSwitchSelect.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:15.0]];
    [self.btnSwitchSelect setBackgroundImage:[UIImage imageNamed:@"user_team"] forState:UIControlStateNormal];
    [self.btnSwitchSelect setTitle:[Common localStr:@"UserGroup_ShowSelected" value:@"显示已选"] forState:UIControlStateNormal];
    [self.btnSwitchSelect  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnSwitchSelect addTarget:self action:@selector(allAndAlreadyChooseSwitch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnSwitchSelect];
    
    //搜索框
    fHeight += 30+5;
    self.searchBarData = [[UISearchBar alloc] initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 44)];
    self.searchBarData.placeholder = [Common localStr:@"Common_SearchTitle" value:@"搜索"];
    self.searchBarData.delegate = self;
    [self.view addSubview:self.searchBarData];
    
    self.searchDisplayControllerData = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBarData contentsController:self];
    self.searchDisplayControllerData.searchResultsDataSource = self;
    self.searchDisplayControllerData.searchResultsDelegate = self;
    self.searchDisplayControllerData.delegate = self;
    fHeight += 44+5;
    
    if (self.fromViewType == FromChatListViewType)
    {
        //聊天页面只显示: 用户和群组切换按钮 + 已选和全部切换按钮
    }
    else
    {
        //选择所有用户和群组
        self.btnChooseAllPersons = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnChooseAllPersons.frame = CGRectMake(10,fHeight,kScreenWidth-20,30);
        [self.btnChooseAllPersons.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:15.0]];
        [self.btnChooseAllPersons setBackgroundImage:[[UIImage imageNamed:@"user_team"] stretchableImageWithLeftCapWidth:61 topCapHeight:16.5] forState:UIControlStateNormal];
        [self.btnChooseAllPersons setTitle:[Common localStr:@"UserGroup_SelectAllUser" value:@"选择所有人"] forState:UIControlStateNormal];
        [self.btnChooseAllPersons  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnChooseAllPersons addTarget:self action:@selector(chooseAllUserOrGroup) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.btnChooseAllPersons];
        fHeight += 30+5;
    }
    
    //User List and Group List
    self.tableViewUserList = [[UITableView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, kScreenHeight-fHeight)];
    _tableViewUserList.dataSource = self;
    _tableViewUserList.delegate = self;
    _tableViewUserList.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableViewUserList];
    
    self.tableViewGroupList = [[UITableView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, kScreenHeight-fHeight)];
    _tableViewGroupList.dataSource = self;
    _tableViewGroupList.delegate = self;
    _tableViewGroupList.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewGroupList.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableViewGroupList];
    _tableViewGroupList.hidden = YES;
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
    
    self.aryGroupDBData = [NSMutableArray array];
    self.aryGroupChoosed = [NSMutableArray array];
    self.aryGroupTableData = [NSMutableArray array];
    self.aryGroupFilteredObject = [NSMutableArray array];
    
    self.nOutGroupValidNum = 0;
    self.nOutUserValidNum = 0;
    
    //////////////////////////////////////////////////////////////
    
    self.bIsAllTab = YES;
    self.bIsUserTab = YES;
    
    self.nChooseUserNumber = 0;
    self.nChooseGroupNumber = 0;
    
    //get DB user list
    GroupAndUserDao *groupAndUserDao = [[GroupAndUserDao alloc]init];
    self.aryUserDBData = [groupAndUserDao getDBUserList:NO];//not include self
    
    [self configureDataSource:self.aryUserDBFirstLetter andDic:self.dicUserDBData andOriginData:self.aryUserDBData];
    //assign table view data
    self.aryUserTableFirstLetter = self.aryUserDBFirstLetter;
    self.dicUserTableData = self.dicUserDBData;
    
    //group data
    if (self.fromViewType == FromChatListViewType)
    {
        self.aryGroupDBData = [groupAndUserDao getGroupListByType:GroupListJoinedType];
    }
    else
    {
        self.aryGroupDBData = [groupAndUserDao getGroupListByType:GroupListCouldSendType];
    }
    self.aryGroupTableData = self.aryGroupDBData;
    
    //初始化选中的数据(如果从其他页面跳转过来，会带上收件人或收件群组)
    [self initChooseData];
    
    //更新完成按钮状态
    [self updateRightButton];
}

//初始化选中的数据
-(void)initChooseData
{
    //user
    if (self.aryOutUser != nil && self.aryOutUser.count>0)
    {
        for (int i=0; i<self.aryUserDBData.count; i++)
        {
            UserVo *userVo = [self.aryUserDBData objectAtIndex:i];
            userVo.bChecked = NO;
            
            if (self.bChooseAllPeople)
            {
                //选择所有人
                self.nChooseUserNumber++;
                self.nOutUserValidNum ++;
                userVo.bChecked = YES;
                [self.aryUserChoosed addObject:userVo];
            }
            else
            {
                for (int j=0; j<self.aryOutUser.count; j++)
                {
                    UserVo *userVoTemp = [self.aryOutUser objectAtIndex:j];
                    if ([userVo.strUserID isEqualToString:userVoTemp.strUserID])
                    {
                        self.nChooseUserNumber++;
                        self.nOutUserValidNum ++;
                        userVo.bChecked = YES;
                        userVo.bCanNotCheck = userVoTemp.bCanNotCheck;
                        [self.aryUserChoosed addObject:userVo];
                    }
                }
            }
        }
    }
    
    //group
    if (self.aryOutGroup != nil && self.aryOutGroup.count>0)
    {
        for (int i=0; i<self.aryGroupDBData.count; i++)
        {
            GroupVo *groupVo = [self.aryGroupDBData objectAtIndex:i];
            groupVo.bChecked = NO;
            
            for (int j=0; j<self.aryOutGroup.count; j++)
            {
                GroupVo *groupVoTemp = [self.aryOutGroup objectAtIndex:j];
                if ([groupVo.strGroupID isEqualToString:groupVoTemp.strGroupID])
                {
                    self.nChooseGroupNumber++;
                    self.nOutGroupValidNum++;
                    groupVo.bChecked = YES;
                    groupVo.bCanNotCheck = groupVoTemp.bCanNotCheck;
                    [self.aryGroupChoosed addObject:groupVo];
                }
            }
        }
    }
    
    if(self.bIsUserTab)
    {
        if(self.bIsAllTab)
        {
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"%@(%ld)",[Common localStr:@"UserGroup_ShowSelected" value:@"显示已选"],(long)self.nChooseUserNumber] forState:UIControlStateNormal];
        }
    }
    else
    {
        if(self.bIsAllTab)
        {
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"%@(%ld)",[Common localStr:@"UserGroup_ShowSelected" value:@"显示已选"],(long)self.nChooseGroupNumber] forState:UIControlStateNormal];
        }
    }
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

- (void)doGroupSearch
{
    //1.Condition Check
    if (self.strSearchText == nil || self.strSearchText.length<=0)
    {
        return;
    }
    
    if(self.aryGroupDBData == nil || self.aryGroupDBData.count <= 0)
    {
        return;
    }
    
    [self.aryGroupFilteredObject removeAllObjects];
    NSMutableArray *aryFilteredName = [[NSMutableArray alloc]init];
    NSMutableArray *aryFilteredJP = [[NSMutableArray alloc]init];
    NSMutableArray *aryFilteredQP = [[NSMutableArray alloc]init];
    
    for (int i=0; i<self.aryGroupDBData.count; i++)
    {
        GroupVo *groupVo = (GroupVo*)[self.aryGroupDBData objectAtIndex:i];
        
        if ([groupVo.strGroupName rangeOfString:self.strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //a.match name
            [aryFilteredName addObject:groupVo];
        }
        else if ([groupVo.strJP rangeOfString:self.strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //b.match JP
            [aryFilteredJP addObject:groupVo];
        }
        else if ([groupVo.strQP rangeOfString:self.strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //c.match QP
            [aryFilteredQP addObject:groupVo];
        }
    }
    
    [self.aryGroupFilteredObject addObjectsFromArray:aryFilteredName];
    [self.aryGroupFilteredObject addObjectsFromArray:aryFilteredJP];
    [self.aryGroupFilteredObject addObjectsFromArray:aryFilteredQP];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doCancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

//选择单聊或者群聊或者创建讨论组
-(void)createDiscussion:(NSMutableArray*)aryGroupChoosedTemp andUserList:(NSMutableArray*)aryUserChoosedTemp
{
    NSMutableArray *aryChatMember = [NSMutableArray array];
    if(aryUserChoosedTemp != nil && aryUserChoosedTemp.count>0)
    {
        for (int i=0; i<aryUserChoosedTemp.count; i++)
        {
            UserVo *userVo = [aryUserChoosedTemp objectAtIndex:i];
            
            ChatObjectVo *chatObjectVo = [[ChatObjectVo alloc]init];
            chatObjectVo.nType = 1;
            chatObjectVo.strVestID = userVo.strUserID;
            chatObjectVo.strNAME = userVo.strUserName;
            chatObjectVo.strIMGURL = userVo.strHeadImageURL;
            [aryChatMember addObject:chatObjectVo];
        }
    }
    
    if (aryGroupChoosedTemp != nil && aryGroupChoosedTemp.count>0)
    {
        for (int i=0; i<aryGroupChoosedTemp.count; i++)
        {
            GroupVo *groupVo = [aryGroupChoosedTemp objectAtIndex:i];
            
            ChatObjectVo *chatObjectVo = [[ChatObjectVo alloc]init];
            chatObjectVo.nType = 2;
            chatObjectVo.strGroupID = groupVo.strGroupID;
            chatObjectVo.strGroupName = groupVo.strGroupName;
            [aryChatMember addObject:chatObjectVo];
        }
    }
    
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        //do thread work
        ServerReturnInfo *retInfo = nil;
        if(self.m_chatObjectVo == nil)
        {
            if (aryChatMember.count>1)
            {
                //生成讨论组(针对私聊加入和群组)【超过一个人】
                retInfo = [ServerProvider createOrUpdateChatDiscussion:aryChatMember andChatObject:nil];
            }
            else
            {
                //选择单聊或者群组聊
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self isHideActivity:YES];
                    [self.delegate completeChooseUserAndGroupAction:self andGroupList:aryGroupChoosedTemp andUserList:aryUserChoosedTemp andAllPeople:self.bChooseAllPeople];
                    [self.navigationController popViewControllerAnimated:NO];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"CompleteChooseAndStartChat" object:nil];
                });
            }
        }
        else
        {
            //修改讨论组成员(针对讨论组)
            retInfo = [ServerProvider createOrUpdateChatDiscussion:aryChatMember andChatObject:self.m_chatObjectVo];
        }
        
        if (retInfo != nil)
        {
            if (retInfo.bSuccess)
            {
                NSMutableArray *aryGroup = [@[retInfo.data] mutableCopy];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self isHideActivity:YES];
                    [self.delegate completeChooseUserAndGroupAction:self andGroupList:aryGroup andUserList:nil andAllPeople:self.bChooseAllPeople];
                    [self.navigationController popViewControllerAnimated:NO];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"CompleteChooseAndStartChat" object:nil];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Common tipAlert:retInfo.strErrorMsg];
                    [self isHideActivity:YES];
                });
            }
        }
    });
}

//完成选择
-(void)doComplete
{
    [self.searchBarData resignFirstResponder];
    //1.已选用户列表
    NSMutableArray *aryUserChoosedTemp = [NSMutableArray array];
    for (int i=0; i<self.aryUserDBData.count; i++)
    {
        UserVo *userVo = [self.aryUserDBData objectAtIndex:i];
        if (userVo.bChecked)
        {
            [aryUserChoosedTemp addObject:userVo];
        }
    }
    //2.已选群组列表
    NSMutableArray *aryGroupChoosedTemp = [NSMutableArray array];
    for (int i=0; i<self.aryGroupDBData.count; i++)
    {
        GroupVo *groupVo = [self.aryGroupDBData objectAtIndex:i];
        if (groupVo.bChecked)
        {
            [aryGroupChoosedTemp addObject:groupVo];
        }
    }
    
    //3.检查是否选择了所有人
    if (self.aryUserDBData.count>0)
    {
        if (self.aryUserDBData.count == aryUserChoosedTemp.count)
        {
            self.bChooseAllPeople = YES;
        }
        else
        {
            self.bChooseAllPeople = NO;
        }
    }
    else
    {
        self.bChooseAllPeople = NO;
    }
    
    if (self.fromViewType == FromChatListViewType)
    {
        //选择单聊或者群聊或者创建讨论组
        [self createDiscussion:aryGroupChoosedTemp andUserList:aryUserChoosedTemp];
    }
    else
    {
        //代理方法
        [self.delegate completeChooseUserAndGroupAction:self andGroupList:aryGroupChoosedTemp andUserList:aryUserChoosedTemp andAllPeople:self.bChooseAllPeople];
        
        //退出选择
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//用户和群组切换
-(void)userAndGroupSwitch
{
    [self.searchDisplayControllerData setActive:NO animated:YES];
    if (!self.bIsUserTab)
    {
        //群组-》用户
        self.bIsUserTab = YES;
        if (self.fromViewType == FromChatListViewType)
        {
            [self setTopNavBarTitle:[Common localStr:@"UserGroup_SelectUser" value:@"选择联系人"]];
        }
        else
        {
            [self setTopNavBarTitle:[Common localStr:@"UserGroup_SelectRecipients" value:@"选择收件人"]];
        }
        [self.btnSwitchUserAndGroup setTitle:[Common localStr:@"UserGroup_ShowGroup" value:@"显示群组"] forState:UIControlStateNormal];
        [self.btnChooseAllPersons setTitle:[Common localStr:@"UserGroup_SelectAllUser" value:@"选择所有人"] forState:UIControlStateNormal];
        
        if (self.bIsAllTab)
        {
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"%@(%ld)",[Common localStr:@"UserGroup_ShowSelected" value:@"显示已选"],(long)self.nChooseUserNumber] forState:UIControlStateNormal];
        }
        else
        {
            [self.btnSwitchSelect setTitle:[Common localStr:@"UserGroup_ShowAll" value:@"显示全部"] forState:UIControlStateNormal];
        }
        
        self.tableViewUserList.hidden = NO;
        self.tableViewGroupList.hidden = YES;
    }
    else
    {
        //用户-》群组
        self.bIsUserTab = NO;
        if (self.fromViewType == FromChatListViewType)
        {
            [self setTopNavBarTitle:[Common localStr:@"UserGroup_SelectUser" value:@"选择联系人"]];
        }
        else
        {
            [self setTopNavBarTitle:[Common localStr:@"UserGroup_SelectGroup" value:@"选择群组"]];
        }
        [self.btnSwitchUserAndGroup setTitle:[Common localStr:@"UserGroup_ShowUser" value:@"显示用户"] forState:UIControlStateNormal];
        [self.btnChooseAllPersons setTitle:[Common localStr:@"UserGroup_SelectAllGroup" value:@"选择所有群组"] forState:UIControlStateNormal];
        
        if (self.bIsAllTab)
        {
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"%@(%ld)",[Common localStr:@"UserGroup_ShowSelected" value:@"显示已选"],(long)self.nChooseGroupNumber] forState:UIControlStateNormal];
        }
        else
        {
            [self.btnSwitchSelect setTitle:[Common localStr:@"UserGroup_ShowAll" value:@"显示全部"] forState:UIControlStateNormal];
        }
        
        self.tableViewUserList.hidden = YES;
        self.tableViewGroupList.hidden = NO;
    }
}

//全部和已选tab切换
-(void)allAndAlreadyChooseSwitch
{
    [self.searchDisplayControllerData setActive:NO animated:YES];
    
    if (!self.bIsAllTab)
    {
        //由已选->全部
        self.bIsAllTab = YES;
        if (!self.bIsUserTab)
        {
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"%@(%ld)",[Common localStr:@"UserGroup_ShowSelected" value:@"显示已选"],(long)self.nChooseGroupNumber] forState:UIControlStateNormal];
        }
        else
        {
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"%@(%ld)",[Common localStr:@"UserGroup_ShowSelected" value:@"显示已选"],(long)self.nChooseUserNumber] forState:UIControlStateNormal];
        }
        //用户数据
        self.aryUserTableFirstLetter = self.aryUserDBFirstLetter;
        self.dicUserTableData = self.dicUserDBData;
        [self.tableViewUserList reloadData];
        
        //群组数据
        self.aryGroupTableData = self.aryGroupDBData;
        [self.tableViewGroupList reloadData];
    }
    else
    {
        //由全部->已选
        self.bIsAllTab = NO;
        [self.btnSwitchSelect setTitle:[Common localStr:@"UserGroup_ShowAll" value:@"显示全部"] forState:UIControlStateNormal];
        
        //用户数据
        NSMutableArray *aryFirstLetter = [NSMutableArray array];
        NSMutableDictionary *dicUserData = [NSMutableDictionary dictionary];
        [self configureDataSource:aryFirstLetter andDic:dicUserData andOriginData:self.aryUserChoosed];
        self.aryUserTableFirstLetter = aryFirstLetter;
        self.dicUserTableData = dicUserData;
        [self.tableViewUserList reloadData];
        
        //群组数据
        self.aryGroupTableData = self.aryGroupChoosed;
        [self.tableViewGroupList reloadData];
    }
}

-(void)chooseAllUserOrGroup
{
    if (self.bIsUserTab)
    {
        //全选用户
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
        
        if (self.bIsAllTab)
        {
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"%@(%ld)",[Common localStr:@"UserGroup_ShowSelected" value:@"显示已选"],(long)self.nChooseUserNumber] forState:UIControlStateNormal];
        }
        else
        {
            [self.btnSwitchSelect setTitle:[Common localStr:@"UserGroup_ShowAll" value:@"显示全部"] forState:UIControlStateNormal];
        }
        [self.tableViewUserList reloadData];
    }
    else
    {
        //全选群组
        if (self.nChooseGroupNumber == self.aryGroupDBData.count)
        {
            //全部反选(从新更新已选数组)
            [self.aryGroupChoosed removeAllObjects];
            self.nChooseGroupNumber = 0;
            
            //更新原始数组
            for (int i=0; i<self.aryGroupDBData.count; i++)
            {
                GroupVo *groupVo = [self.aryGroupDBData objectAtIndex:i];
                groupVo.bChecked = NO;
            }
        }
        else
        {
            //全部选择(从新更新已选数组)
            [self.aryGroupChoosed removeAllObjects];
            self.nChooseGroupNumber = self.aryGroupDBData.count;
            
            //更新原始数组
            for (int i=0; i<self.aryGroupDBData.count; i++)
            {
                GroupVo *groupVo = [self.aryGroupDBData objectAtIndex:i];
                groupVo.bChecked = YES;
                [self.aryGroupChoosed addObject:groupVo];
            }
        }
        
        if (self.bIsAllTab)
        {
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"%@(%ld)",[Common localStr:@"UserGroup_ShowSelected" value:@"显示已选"],(long)self.nChooseGroupNumber] forState:UIControlStateNormal];
        }
        else
        {
            [self.btnSwitchSelect setTitle:[Common localStr:@"UserGroup_ShowAll" value:@"显示全部"] forState:UIControlStateNormal];
        }
        [self.tableViewGroupList reloadData];
    }
    [self updateRightButton];
}

//完成按钮设置，当没有选择人的时候则不可点击
 - (void)updateRightButton
{
    //当没有添加人的时候，将完成按钮设置不可用
    if(self.m_chatObjectVo != nil)
    {
        if (self.m_chatObjectVo.nType == 1)
        {
            //私聊
            if ((self.nChooseUserNumber+self.nChooseGroupNumber) > self.nOutUserValidNum )
            {
                self.btnRightNav.enabled = YES;
                self.btnRightNav.alpha = 1.0;
            }
            else
            {
                self.btnRightNav.enabled = NO;
                self.btnRightNav.alpha = 0.9;
            }
        }
        else if (self.m_chatObjectVo.bDiscussion)
        {
            //讨论组 (数量超过初始传入的量则将完成安装设为有效)
            if ((self.nChooseUserNumber+self.nChooseGroupNumber) > self.nOutUserValidNum)
            {
                self.btnRightNav.enabled = YES;
                self.btnRightNav.alpha = 1.0;
            }
            else
            {
                self.btnRightNav.enabled = NO;
                self.btnRightNav.alpha = 0.9;
            }
        }
        else
        {
            //群主
            if ((self.nChooseUserNumber+self.nChooseGroupNumber) > 1 )
            {
                self.btnRightNav.enabled = YES;
                self.btnRightNav.alpha = 1.0;
            }
            else
            {
                self.btnRightNav.enabled = NO;
                self.btnRightNav.alpha = 0.7;
            }
        }
    }
    else
    {
        if ((self.nChooseUserNumber+self.nChooseGroupNumber) > 0 )
        {
            self.btnRightNav.enabled = YES;
            self.btnRightNav.alpha = 1.0;
        }
        else
        {
            self.btnRightNav.enabled = NO;
            self.btnRightNav.alpha = 0.9;
        }
    }
}

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
    else if(tableView == self.tableViewGroupList)
    {
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
        if (self.bIsUserTab)
        {
            //user page
            nRowNum = [self.aryUserFilteredObject count];
        }
        else
        {
            //group page
            nRowNum = [self.aryGroupFilteredObject count];
        }
    }
    else if(tableView == self.tableViewGroupList)
    {
        nRowNum = self.aryGroupTableData.count;
    }
    return nRowNum;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fHeight = 0.0;
    if (tableView == self.tableViewUserList)
    {
        fHeight = 60;
    }
    else if(tableView == self.searchDisplayControllerData.searchResultsTableView)
    {
        if (self.bIsUserTab)
        {
            //user page
            fHeight = 60;
        }
        else
        {
            //group page
            GroupVo *groupVo = [self.aryGroupFilteredObject objectAtIndex:[indexPath row]];
            fHeight = [ChooseGroupCell calculateCellHeight:groupVo];
        }
    }
    else if(tableView == self.tableViewGroupList)
    {
        GroupVo *groupVo = groupVo = [self.aryGroupTableData objectAtIndex:[indexPath row]];
        fHeight = [ChooseGroupCell calculateCellHeight:groupVo];
    }
    return fHeight;
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
        if (self.bIsUserTab)
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
        else
        {
            GroupVo *groupVo = [self.aryGroupFilteredObject objectAtIndex:[indexPath row]];
            static NSString *identifier=@"ChooseGroupCell";
            ChooseGroupCell *cell = (ChooseGroupCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil)
            {
                cell = [[ChooseGroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
                //改变选中背景色
                UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
                viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
                cell.selectedBackgroundView = viewSelected;
            }
            
            [cell initWithGroupVo:groupVo];
            return cell;
        }
    }
    else if (tableView == self.tableViewGroupList)
    {
        GroupVo *groupVo = [self.aryGroupTableData objectAtIndex:[indexPath row]];
        static NSString *identifier=@"ChooseGroupCell";
        ChooseGroupCell *cell = (ChooseGroupCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[ChooseGroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            //改变选中背景色
            UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
            viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
            cell.selectedBackgroundView = viewSelected;
        }
        
        [cell initWithGroupVo:groupVo];
        return cell;
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
    UserVo *userVo = nil;
    GroupVo *groupVo = nil;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableViewUserList)
    {
        NSString *strFirstLetter=[self.aryUserTableFirstLetter objectAtIndex:[indexPath section]];
        NSMutableArray *arySub=[self.dicUserTableData objectForKey:strFirstLetter];
        userVo = [arySub objectAtIndex:[indexPath row]];
        if (userVo.bCanNotCheck)
        {
            return;//不能选择
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
        
        if(self.bIsAllTab)
        {
            //全选界面
            ChooseUserCell *cell = (ChooseUserCell*)[tableView cellForRowAtIndexPath:indexPath];
            [cell updateCheckImage:userVo.bChecked];
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"%@(%ld)",[Common localStr:@"UserGroup_ShowSelected" value:@"显示已选"],(long)self.nChooseUserNumber] forState:UIControlStateNormal];
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
        if(self.bIsUserTab)
        {
            userVo = [self.aryUserFilteredObject objectAtIndex:[indexPath row]];
            if (userVo.bCanNotCheck)
            {
                return;//不能选择
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
            
            if(self.bIsAllTab)
            {
                [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"%@(%ld)",[Common localStr:@"UserGroup_ShowSelected" value:@"显示已选"],(long)self.nChooseUserNumber] forState:UIControlStateNormal];
            }
        }
        else
        {
            groupVo = [self.aryGroupFilteredObject objectAtIndex:[indexPath row]];
            if (groupVo.bCanNotCheck)
            {
                return;//不能选择
            }
            
            //反选
            groupVo.bChecked = !groupVo.bChecked;
            
            //change choosed num
            if (groupVo.bChecked)
            {
                self.nChooseGroupNumber++;
                [self.aryGroupChoosed addObject:groupVo];
            }
            else
            {
                self.nChooseUserNumber--;
                [self.aryGroupChoosed removeObject:groupVo];      //移除已选数组
            }
            //change chk image
            ChooseGroupCell *cell = (ChooseGroupCell*)[tableView cellForRowAtIndexPath:indexPath];
            [cell updateCheckImage:groupVo.bChecked];
            
            if(self.bIsAllTab)
            {
                [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"%@(%ld)",[Common localStr:@"UserGroup_ShowSelected" value:@"显示已选"],(long)self.nChooseGroupNumber] forState:UIControlStateNormal];
            }
        }
    }
    else if (tableView == self.tableViewGroupList)
    {
        //change chk image
        groupVo = [self.aryGroupTableData objectAtIndex:[indexPath row]];
        if (groupVo.bCanNotCheck)
        {
            return;//不能选择
        }
        
        groupVo.bChecked = !groupVo.bChecked;
        
        //change choosed num
        if (groupVo.bChecked)
        {
            self.nChooseGroupNumber++;
            [self.aryGroupChoosed addObject:groupVo];           //add to 已选数组
        }
        else
        {
            self.nChooseGroupNumber--;
            [self.aryGroupChoosed removeObject:groupVo];        //remove from 已选数组
        }
        
        if(self.bIsAllTab)
        {
            //全选界面
            ChooseGroupCell *cell = (ChooseGroupCell*)[tableView cellForRowAtIndexPath:indexPath];
            [cell updateCheckImage:groupVo.bChecked];
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"%@(%ld)",[Common localStr:@"UserGroup_ShowSelected" value:@"显示已选"],(long)self.nChooseGroupNumber] forState:UIControlStateNormal];
        }
        else
        {
            //已选界面
            [self.tableViewGroupList reloadData];
        }
    }
    //更新完成按钮状态
    [self updateRightButton];
}

#pragma mark - UISearchBarDelegate
- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableViewUserList scrollRectToVisible:self.searchBarData.frame animated:animated];
    [self.tableViewGroupList scrollRectToVisible:self.searchBarData.frame animated:animated];
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
    if (self.bIsUserTab)
    {
        //user page
        [self doUserSearch];
        self.searchDisplayControllerData.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    else
    {
        //group page
        [self doGroupSearch];
        self.searchDisplayControllerData.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    //auto reload data
    return YES;
}

@end
