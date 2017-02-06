//
//  ChooseUserAndGroupViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-28.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "ChooseUserAndGroupViewController.h"
#import "GroupAndUserDao.h"
#import "ChooseGroupCell.h"
#import "Utils.h"
#import "NSString+Function.h"

@interface ChooseUserAndGroupViewController ()

@end

@implementation ChooseUserAndGroupViewController

- (void)dealloc
{
    self.txtSearch = nil;
}

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
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    if (self.fromViewType == FromChatListViewType)
    {
        [self setTopNavBarTitle:@"选择联系人"];
    }
    else
    {
        [self setTopNavBarTitle:@"选择收件人"];
    }
    
    //左边按钮
    UIButton *btnCancel = [Utils buttonWithTitle:@"取消" frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:nil];
    [btnCancel addTarget:self action:@selector(doCancel) forControlEvents:UIControlEventTouchUpInside];
    [self setLeftBarButton:btnCancel];
    
    //右边按钮
    UIButton *btnSend = [Utils buttonWithTitle:@"完成" frame:[Utils getNavRightBtnFrame:CGSizeMake(100,76)] target:self action:nil];
    [btnSend addTarget:self action:@selector(doComplete) forControlEvents:UIControlEventTouchUpInside];
    [self setRightBarButton:btnSend];
    
    CGFloat fHeight = NAV_BAR_HEIGHT+5;
    //用户和群组切换、全部和已选切换
    self.btnSwitchUserAndGroup = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnSwitchUserAndGroup.frame = CGRectMake(10,fHeight,kScreenWidth/2-15,30);
    [self.btnSwitchUserAndGroup.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:15.0]];
    [self.btnSwitchUserAndGroup setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Choose_User_Btn_bg_color"]] forState:UIControlStateNormal];
    [self.btnSwitchUserAndGroup setTitle:@"显示群组" forState:UIControlStateNormal];
    [self.btnSwitchUserAndGroup setTitleColor:[SkinManage colorNamed:@"Choose_User_Btn_title_color"] forState:UIControlStateNormal];
    [self.btnSwitchUserAndGroup setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [self.btnSwitchUserAndGroup.layer setBorderWidth:1.0];
    [self.btnSwitchUserAndGroup.layer setCornerRadius:4];
    self.btnSwitchUserAndGroup.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.btnSwitchUserAndGroup.layer setMasksToBounds:YES];
    [self.btnSwitchUserAndGroup addTarget:self action:@selector(userAndGroupSwitch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnSwitchUserAndGroup];
    
    self.btnSwitchSelect = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnSwitchSelect.frame = CGRectMake(kScreenWidth/2+5,fHeight,kScreenWidth/2-15,30);
    [self.btnSwitchSelect.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:15.0]];
    [self.btnSwitchSelect setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Choose_User_Btn_bg_color"]] forState:UIControlStateNormal];
    [self.btnSwitchSelect setTitle:@"显示已选" forState:UIControlStateNormal];
    [self.btnSwitchSelect  setTitleColor:[SkinManage colorNamed:@"Choose_User_Btn_title_color"] forState:UIControlStateNormal];
    [self.btnSwitchSelect setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [self.btnSwitchSelect.layer setBorderWidth:1.0];
    [self.btnSwitchSelect.layer setCornerRadius:4];
    self.btnSwitchSelect.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.btnSwitchSelect.layer setMasksToBounds:YES];
    [self.btnSwitchSelect addTarget:self action:@selector(allAndAlreadyChooseSwitch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnSwitchSelect];
    
    //搜索框
    fHeight += 30+5;
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
    [self.btnSearch setTitleColor:[SkinManage colorNamed:@"message_color"] forState:UIControlStateNormal];
    [self.btnSearch.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
    [self.btnSearch setBackgroundImage:[[UIImage imageNamed:@"btn_search_index"] stretchableImageWithLeftCapWidth:22 topCapHeight:16] forState:UIControlStateNormal];
    [self.btnSearch setTitle:@"搜索全部" forState:UIControlStateNormal];
    [self.btnSearch addTarget:self action:@selector(doSearchAllUser) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnSearch];
    
    fHeight += 40+5;
    
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
        [self.btnChooseAllPersons setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Choose_User_Btn_bg_color"]] forState:UIControlStateNormal];
        [self.btnChooseAllPersons setTitle:@"选择所有关注用户" forState:UIControlStateNormal];
        [self.btnChooseAllPersons setTitleColor:[SkinManage colorNamed:@"Choose_User_Btn_title_color"] forState:UIControlStateNormal];
        [self.btnChooseAllPersons setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
        [self.btnChooseAllPersons.layer setBorderWidth:1.0];
        [self.btnChooseAllPersons.layer setCornerRadius:4];
        self.btnChooseAllPersons.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.btnChooseAllPersons.layer setMasksToBounds:YES];
        [self.btnChooseAllPersons addTarget:self action:@selector(chooseAllUserOrGroup) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.btnChooseAllPersons];
        fHeight += 30+5;
    }
    //User List and Group List
    self.tableViewUserList = [[UITableView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, kScreenHeight-fHeight)];
    _tableViewUserList.dataSource = self;
    _tableViewUserList.delegate = self;
    _tableViewUserList.backgroundColor = [UIColor clearColor];
    self.tableViewUserList.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    _tableViewUserList.sectionIndexColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    _tableViewUserList.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    _tableViewUserList.sectionIndexBackgroundColor = [UIColor clearColor];
    _tableViewUserList.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_tableViewUserList];
    
    self.tableViewGroupList = [[UITableView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, kScreenHeight-fHeight)];
    _tableViewGroupList.dataSource = self;
    _tableViewGroupList.delegate = self;
    _tableViewGroupList.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableViewGroupList.backgroundColor = [UIColor clearColor];
    self.tableViewGroupList.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    _tableViewGroupList.sectionIndexColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    _tableViewGroupList.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    _tableViewGroupList.sectionIndexBackgroundColor = [UIColor clearColor];
    _tableViewGroupList.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_tableViewGroupList];
    _tableViewGroupList.hidden = YES;
    
    //search result list
    self.tableViewSearchResult = [[PullingRefreshTableView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, kScreenHeight-fHeight) pullingDelegate:self];
    self.tableViewSearchResult.dataSource = self;
    self.tableViewSearchResult.delegate = self;
    self.tableViewSearchResult.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableViewSearchResult.backgroundColor = [UIColor whiteColor];
    self.tableViewSearchResult.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewSearchResult.sectionIndexColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.tableViewSearchResult.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableViewSearchResult.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.tableViewSearchResult.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:self.tableViewSearchResult];
    self.tableViewSearchResult.hidden = YES;
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
    
    self.bOnLineSearch = NO;
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
        //匹配选择的和关注的用户数据
        for (int i=0; i<self.aryOutUser.count; i++)
        {
            BOOL bFind = NO;
            UserVo *userVoOut = [self.aryOutUser objectAtIndex:i];
            
            for (int j=0; j<self.aryUserDBData.count; j++)
            {
                UserVo *userVo = [self.aryUserDBData objectAtIndex:j];
                userVo.bChecked = NO;
                
                if ([userVo.strUserID isEqualToString:userVoOut.strUserID])
                {
                    self.nChooseUserNumber++;
                    self.nOutUserValidNum ++;
                    userVo.bChecked = YES;
                    userVo.bCanNotCheck = userVoOut.bCanNotCheck;
                    [self.aryUserChoosed addObject:userVo];
                    bFind = YES;
                    break;
                }
            }
            
            //从讨论组页面过来，增加尚未关注的人
            if (self.fromViewType == FromChatListViewType && !bFind)
            {
                if (![userVoOut.strUserID isEqualToString:@"+"] && ![userVoOut.strUserID isEqualToString:@"-"])
                {
                    self.nChooseUserNumber++;
                    self.nOutUserValidNum ++;
                    
                    UserVo *userNew = [[UserVo alloc]init];
                    userNew.strUserID = userVoOut.strUserID;
                    userNew.strUserName = userVoOut.strUserName;
                    userNew.strHeadImageURL = userVoOut.strHeadImageURL;
                    userNew.strPosition = userVoOut.strPosition;
                    userNew.bChecked = YES;
                    userNew.bCanNotCheck = userVoOut.bCanNotCheck;
                    
                    [self.aryUserChoosed addObject:userNew];
                    [self.aryUserDBData addObject:userNew];
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
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"显示已选(%ld)",(long)self.nChooseUserNumber] forState:UIControlStateNormal];
        }
    }
    else
    {
        if(self.bIsAllTab)
        {
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"显示已选(%ld)",(long)self.nChooseGroupNumber] forState:UIControlStateNormal];
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
        NSString *strJP = [userVo.strJP trimLeftAndRightSpace];
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
    
    [self.tableViewSearchResult reloadData];
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
    
    [self.tableViewSearchResult reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doCancel
{
    self.txtSearch.delegate = nil;
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
    
    if (aryChatMember.count>0)
    {
        if(self.m_chatObjectVo == nil)
        {
            ChatObjectVo *chatObjectVo = aryChatMember[0];
            if (aryChatMember.count>1 || (aryChatMember.count == 1 && chatObjectVo.nType != 1))
            {
                //生成讨论组(针对私聊加入和群组)【超过一个人】(选择一个群组选择群组聊天，直接创建讨论组)
                [self isHideActivity:NO];
                [ServerProvider createOrUpdateChatDiscussion:aryChatMember andChatObject:nil result:^(ServerReturnInfo *retInfo) {
                    [self isHideActivity:YES];
                    if (retInfo.bSuccess)
                    {
                        NSMutableArray *aryGroup = [@[retInfo.data] mutableCopy];
                        [self isHideActivity:YES];
                        [self.delegate completeChooseUserAndGroupAction:self andGroupList:aryGroup andUserList:nil];
                        self.txtSearch.delegate = nil;
                        [self.navigationController popViewControllerAnimated:NO];
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"CompleteChooseAndStartChat" object:nil];
                    }
                    else
                    {
                        [Common tipAlert:retInfo.strErrorMsg];
                    }
                }];
            }
            else
            {
                //选择单聊或者群组聊
                if ([chatObjectVo.strVestID isEqualToString:[Common getCurrentUserVo].strUserID])
                {
                    [Common bubbleTip:@"不能选择自己进行私聊" andView:self.view];
                }
                else
                {
                    [self.delegate completeChooseUserAndGroupAction:self andGroupList:aryGroupChoosedTemp andUserList:aryUserChoosedTemp];
                    self.txtSearch.delegate = nil;//防止crash
                    [self.navigationController popViewControllerAnimated:NO];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"CompleteChooseAndStartChat" object:nil];
                }
            }
        }
        else
        {
            //修改讨论组成员(针对讨论组)
            [self isHideActivity:NO];
            [ServerProvider createOrUpdateChatDiscussion:aryChatMember andChatObject:self.m_chatObjectVo result:^(ServerReturnInfo *retInfo) {
                [self isHideActivity:YES];
                if (retInfo.bSuccess)
                {
                    NSMutableArray *aryGroup = [@[retInfo.data] mutableCopy];
                    [self isHideActivity:YES];
                    [self.delegate completeChooseUserAndGroupAction:self andGroupList:aryGroup andUserList:nil];
                    self.txtSearch.delegate = nil;
                    [self.navigationController popViewControllerAnimated:NO];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"CompleteChooseAndStartChat" object:nil];
                }
                else
                {
                    [Common tipAlert:retInfo.strErrorMsg];
                }
            }];
        }
    }
}
//完成选择
-(void)doComplete
{
    [self.txtSearch resignFirstResponder];
    //1.已选用户列表 aryUserDBData应该替换为
    NSMutableArray *aryUserChoosedTemp = [NSMutableArray array];
    for (int i=0; i<self.aryUserChoosed.count; i++)
    {
        UserVo *userVo = [self.aryUserChoosed objectAtIndex:i];
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
    
    if (self.fromViewType == FromChatListViewType)
    {
        //选择单聊或者群聊或者创建讨论组
        [self createDiscussion:aryGroupChoosedTemp andUserList:aryUserChoosedTemp];
    }
    else
    {
        //代理方法
        [self.delegate completeChooseUserAndGroupAction:self andGroupList:self.aryGroupChoosed andUserList:self.aryUserChoosed];
        
        //退出选择
        self.txtSearch.delegate = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//用户和群组切换
-(void)userAndGroupSwitch
{
    if (!self.bIsUserTab)
    {
        //群组-》用户
        self.bIsUserTab = YES;
        if (self.fromViewType == FromChatListViewType)
        {
            [self setTopNavBarTitle:@"选择联系人"];
        }
        else
        {
            [self setTopNavBarTitle:@"选择收件人"];
        }
        [self.btnSwitchUserAndGroup setTitle:@"显示群组" forState:UIControlStateNormal];
        [self.btnChooseAllPersons setTitle:@"选择所有关注用户" forState:UIControlStateNormal];
        
        if (self.bIsAllTab)
        {
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"显示已选(%ld)",(long)self.nChooseUserNumber] forState:UIControlStateNormal];
        }
        else
        {
            [self.btnSwitchSelect setTitle:@"显示关注" forState:UIControlStateNormal];
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
            [self setTopNavBarTitle:@"选择联系人"];
        }
        else
        {
            [self setTopNavBarTitle:@"选择群组"];
        }
        [self.btnSwitchUserAndGroup setTitle:@"显示用户" forState:UIControlStateNormal];
        [self.btnChooseAllPersons setTitle:@"选择所有群组" forState:UIControlStateNormal];
        
        if (self.bIsAllTab)
        {
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"显示已选(%ld)",(long)self.nChooseGroupNumber] forState:UIControlStateNormal];
        }
        else
        {
            [self.btnSwitchSelect setTitle:@"显示全部" forState:UIControlStateNormal];
        }
        
        self.tableViewUserList.hidden = YES;
        self.tableViewGroupList.hidden = NO;
    }
}

//全部和已选tab切换
-(void)allAndAlreadyChooseSwitch
{
    if (!self.bIsAllTab)
    {
        //由已选->全部
        self.bIsAllTab = YES;
        if (!self.bIsUserTab)
        {
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"显示已选(%ld)",(long)self.nChooseGroupNumber] forState:UIControlStateNormal];
        }
        else
        {
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"显示已选(%ld)",(long)self.nChooseUserNumber] forState:UIControlStateNormal];
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
        if (!self.bIsUserTab)
        {
            [self.btnSwitchSelect setTitle:@"显示全部" forState:UIControlStateNormal];
        }
        else
        {
            [self.btnSwitchSelect setTitle:@"显示关注" forState:UIControlStateNormal];
        }
        
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
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"显示已选(%ld)",(long)self.nChooseUserNumber] forState:UIControlStateNormal];
        }
        else
        {
            [self.btnSwitchSelect setTitle:@"显示关注" forState:UIControlStateNormal];
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
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"显示已选(%ld)",(long)self.nChooseGroupNumber] forState:UIControlStateNormal];
        }
        else
        {
            [self.btnSwitchSelect setTitle:@"显示全部" forState:UIControlStateNormal];
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
    else if(tableView == self.tableViewSearchResult)
    {
        //搜索结果tableView
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
    else if(tableView == self.tableViewSearchResult)
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
    else if(tableView == self.tableViewSearchResult)
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

#pragma mark - 返回cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableViewUserList)
    {
        NSString *strFirstLetter = [self.aryUserTableFirstLetter objectAtIndex:[indexPath section]];
        NSArray *arySub = [self.dicUserTableData objectForKey:strFirstLetter];
        UserVo *useVo = [arySub objectAtIndex:[indexPath row]];
        
        static NSString *identifier=@"ChooseUserOldCell";
        ChooseUserOldCell *cell = (ChooseUserOldCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[ChooseUserOldCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            
            //改变选中背景色
            //            UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
            //            viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
            //            cell.selectedBackgroundView = viewSelected;
        }
        //cell.delegate = self;
        [cell initWithUserVo:useVo];
        return  cell;
    }
    else if(tableView == self.tableViewSearchResult)
    {
        if (self.bIsUserTab)
        {
            UserVo *useVo = [self.aryUserFilteredObject objectAtIndex:[indexPath row]];
            
            static NSString *identifier=@"ChooseUserOldCell";
            ChooseUserOldCell *cell = (ChooseUserOldCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil)
            {
                cell = [[ChooseUserOldCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
                
                //                //改变选中背景色
                //                UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
                //                viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
                //                cell.selectedBackgroundView = viewSelected;
            }
            cell.delegate = self;
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
                viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
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
            viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
            cell.selectedBackgroundView = viewSelected;
        }
        
        [cell initWithGroupVo:groupVo];
        return cell;
    }
    return nil;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (tableView == self.tableViewUserList)
    {
        static NSString *header = @"ActivitySectionHeader1";
        UITableViewHeaderFooterView *viewHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:header];
        if (viewHeader == nil)
        {
            viewHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:header];
            viewHeader.contentView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
            UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, kScreenWidth, 40)];
            lblTitle.text = [self.aryUserTableFirstLetter objectAtIndex:section];
            lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
            lblTitle.font = [UIFont systemFontOfSize:16];
            lblTitle.textAlignment = NSTextAlignmentLeft;
            [viewHeader addSubview:lblTitle];
            
        }
        return viewHeader;
    }else{
        return nil;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableViewUserList)
    {
        return 40;
    }
    else
    {
        return CGFLOAT_MIN;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

#pragma mark - 在单元格最右放添加索引
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
            [self removeUserFromChoosedList:userVo];//移除已选数组(采用循环ID判断)
        }
        
        if(self.bIsAllTab)
        {
            //全选界面
            ChooseUserOldCell *cell = (ChooseUserOldCell*)[tableView cellForRowAtIndexPath:indexPath];
            [cell updateCheckImage:userVo.bChecked];
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"显示已选(%ld)",(long)self.nChooseUserNumber] forState:UIControlStateNormal];
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
    else if (tableView == self.tableViewSearchResult)
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
                [self removeUserFromChoosedList:userVo];//移除已选数组(采用循环ID判断)
            }
            //change chk image
            ChooseUserOldCell *cell = (ChooseUserOldCell*)[tableView cellForRowAtIndexPath:indexPath];
            [cell updateCheckImage:userVo.bChecked];
            
            if(self.bIsAllTab)
            {
                [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"显示已选(%ld)",(long)self.nChooseUserNumber] forState:UIControlStateNormal];
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
                [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"显示已选(%ld)",(long)self.nChooseGroupNumber] forState:UIControlStateNormal];
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
            [self.btnSwitchSelect setTitle:[NSString stringWithFormat:@"显示已选(%ld)",(long)self.nChooseGroupNumber] forState:UIControlStateNormal];
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

#pragma mark - ChooseUserOldCellDelegate
-(UserVo*)isUserVoChecked:(UserVo*)userVo
{
    UserVo *userVoResult = nil;
    NSPredicate *predicateUserID = [NSPredicate predicateWithFormat:@"SELF.strUserID == %@",userVo.strUserID];//字符串不需要'%@'
    NSArray *aryResult = [self.aryUserChoosed filteredArrayUsingPredicate:predicateUserID];
    if (aryResult.count > 0)
    {
        userVoResult = [aryResult objectAtIndex:0];
    }
    return userVoResult;
}

#pragma mark - UISearch
//本地搜索关注用户
- (void)textDidChange
{
    //文字改变,要进行实时搜索
    self.strSearchText = self.txtSearch.text;
    if (self.bIsUserTab)
    {
        //user page
        if (self.strSearchText.length == 0)
        {
            self.tableViewUserList.hidden = NO;
            self.tableViewSearchResult.hidden = YES;
            [self.tableViewUserList reloadData];//刷新数据
            
            //set disable choose all person
            [self.btnChooseAllPersons setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Choose_User_Btn_bg_color"]] forState:UIControlStateNormal];
            self.btnChooseAllPersons.enabled = YES;
        }
        else
        {
            self.tableViewUserList.hidden = YES;
            self.tableViewSearchResult.hidden = NO;
            self.bOnLineSearch = NO;
            [self.tableViewSearchResult setHeaderHidden:YES];
            [self.tableViewSearchResult setFooterHidden:YES];
            //set disable choose all person
            [self.btnChooseAllPersons setBackgroundImage:[Common getImageWithColor:SLOTH_GRAY] forState:UIControlStateNormal];
            self.btnChooseAllPersons.enabled = NO;
            
            [self doUserSearch];
        }
    }
    else
    {
        //group page
        if (self.strSearchText.length == 0)
        {
            self.tableViewGroupList.hidden = NO;
            self.tableViewSearchResult.hidden = YES;
            
            //set disable choose all person
            [self.btnChooseAllPersons setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Choose_User_Btn_bg_color"]] forState:UIControlStateNormal];
            self.btnChooseAllPersons.enabled = YES;
        }
        else
        {
            self.tableViewGroupList.hidden = YES;
            self.tableViewSearchResult.hidden = NO;
            self.bOnLineSearch = NO;
            [self.tableViewSearchResult setHeaderHidden:YES];
            [self.tableViewSearchResult setFooterHidden:YES];
            
            //set disable choose all person
            [self.btnChooseAllPersons setBackgroundImage:[Common getImageWithColor:SLOTH_GRAY] forState:UIControlStateNormal];
            self.btnChooseAllPersons.enabled = NO;
            
            [self doGroupSearch];
        }
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
    self.strSearchText = self.txtSearch.text;
    if (self.bIsUserTab)
    {
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
    else
    {
        //group page do nothing
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

//移除单个已选用户，通过ID迭代判断
-(void)removeUserFromChoosedList:(UserVo*)userVo
{
    for (int i=0; i<self.aryUserChoosed.count; i++)
    {
        UserVo *userVoTemp = [self.aryUserChoosed objectAtIndex:i];
        if ([userVoTemp.strUserID isEqualToString:userVo.strUserID])
        {
            [self.aryUserChoosed removeObject:userVoTemp];
            break;
        }
    }
}

@end
