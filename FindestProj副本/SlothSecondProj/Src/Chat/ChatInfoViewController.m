//
//  ChatInfoViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-5-20.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "ChatInfoViewController.h"
#import "ChatMemberCollectionCell.h"
#import "ServerURL.h"
//#import "UserCenterViewController.h"
#import "ChatListViewController.h"
#import "ChatDiscussionNameViewController.h"
#import "UIViewExt.h"
#import "MemberListViewController.h"
#import "ChooseUserViewController.h"

@interface ChatInfoViewController ()<ChooseUserViewControllerDelegate>
{
    UIView *viewCollectionSep;
    
    //全部群成员
    UILabel *lblAllMember;
    UIImageView *imgViewArrow;
    UIButton *btnAllMember;
    UIView *viewAllMemberSep;
    UIView *viewAllMember;
}

@end

@implementation ChatInfoViewController

- (void)dealloc
{
    [self tackleWhenReturn];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CompleteChooseAndStartChat" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RefreshChatInfoData" object:nil];
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
    
    self.bShowDeleteBtn = NO;
    self.m_aryChoosedGroup = [NSMutableArray array];
    self.m_aryChoosedUser = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(completeChooseAndStartChat) name:@"CompleteChooseAndStartChat" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshDataByNotify:) name:@"RefreshChatInfoData" object:nil];
    
    [self initCtrlLayout];
    [self refreshData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initCtrlLayout
{
    [self setTopNavBarTitle:[Common localStr:@"Chat_SingleTitle" value:@"聊天详情"]];
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];;
    
    //1.scroll view
    self.scollViewChatInfo = [[UIScrollView alloc]initWithFrame:CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT)];
    self.scollViewChatInfo.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.scollViewChatInfo.autoresizingMask = NO;
    self.scollViewChatInfo.clipsToBounds = YES;
    [self.view addSubview:self.scollViewChatInfo];
    
    //2.collection
    self.viewCollectionBK = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewCollectionBK.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    [self.scollViewChatInfo addSubview:self.viewCollectionBK];
    
    viewCollectionSep = [[UIView alloc]initWithFrame:CGRectZero];
    viewCollectionSep.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.viewCollectionBK addSubview:viewCollectionSep];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize=CGSizeMake(73,95);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    self.collectionMember = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionMember.dataSource = self;
    self.collectionMember.delegate = self;
    self.collectionMember.backgroundColor = [UIColor clearColor];
    self.collectionMember.showsVerticalScrollIndicator = NO;
    self.collectionMember.scrollsToTop = NO;
    [self.scollViewChatInfo addSubview:self.collectionMember];
    [self.collectionMember registerClass:[ChatMemberCollectionCell class] forCellWithReuseIdentifier:@"ChatMemberCollectionCell"];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCollection:)];
    [self.collectionMember addGestureRecognizer:tapGesture];
    
    //所有成员
    viewAllMember = [[UIView alloc]init];
    [self.viewCollectionBK addSubview:viewAllMember];
    
    btnAllMember = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAllMember setBackgroundImage:[Common getImageWithColor:COLOR(246, 246, 246, 1.0)] forState:UIControlStateHighlighted];
    btnAllMember.frame = CGRectMake(0, 0, kScreenWidth, 44);
    [btnAllMember addTarget:self action:@selector(getAllChatMember) forControlEvents:UIControlEventTouchUpInside];
    [viewAllMember addSubview:btnAllMember];
    
    viewAllMemberSep = [[UIView alloc]initWithFrame:CGRectMake(15, 0, kScreenWidth-15, 0.5)];
    viewAllMemberSep.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [viewAllMember addSubview:viewAllMemberSep];
    
    lblAllMember = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, kScreenWidth-15, 44)];
    lblAllMember.font = [UIFont systemFontOfSize:16];
    lblAllMember.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];//COLOR(51, 43, 41, 1.0);
    [viewAllMember addSubview:lblAllMember];
    
    imgViewArrow = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth-12-8, 15, 8, 14)];
    imgViewArrow.image = [SkinManage imageNamed:@"table_accessory"];
    [viewAllMember addSubview:imgViewArrow];
    
    //3.tableview
    self.tableViewChatInfo = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableViewChatInfo.dataSource = self;
    self.tableViewChatInfo.delegate = self;
    self.tableViewChatInfo.scrollEnabled = NO;
    self.tableViewChatInfo.scrollsToTop = NO;
    self.tableViewChatInfo.backgroundColor = [UIColor clearColor];
    [self.scollViewChatInfo addSubview:self.tableViewChatInfo];
    self.tableViewChatInfo.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    //4.delete button
    self.btnExitAndDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnExitAndDelete.layer.cornerRadius = 5;
    self.btnExitAndDelete.layer.masksToBounds = YES;
    [self.btnExitAndDelete setBackgroundImage:[Common getImageWithColor:COLOR(239, 111, 88, 1.0)] forState:UIControlStateNormal];
    //[self.btnExitAndDelete setBackgroundImage:[[UIImage imageNamed:@"RedBigBtnHighlight"]stretchableImageWithLeftCapWidth:12.5 topCapHeight:12.5] forState:UIControlStateHighlighted];
    [self.btnExitAndDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnExitAndDelete setTitleColor:COLOR(255, 255, 255, 0.5) forState:UIControlStateHighlighted];
    [self.btnExitAndDelete setTitle:[Common localStr:@"Chat_DeleteAndExit" value:@"删除并退出"] forState:UIControlStateNormal];
    [self.btnExitAndDelete addTarget:self action:@selector(clickExitButton) forControlEvents:UIControlEventTouchUpInside];
    [self.scollViewChatInfo addSubview:self.btnExitAndDelete];
}

- (void)refreshView:(BOOL)bAddEditButton
{
    NSUInteger nMemberNum;
    if (self.m_chatObjectVo.nType == 1)
    {
        //私聊
        [self setTopNavBarTitle:[Common localStr:@"Chat_SingleTitle" value:@"聊天详情"]];
    }
    else
    {
        //群聊
        nMemberNum = self.m_chatObjectVo.aryMember.count;
        if (!bAddEditButton)//需要增加编辑按钮
        {
            if (self.m_chatObjectVo.nType == 2 && [self.m_chatObjectVo.strVestID isEqualToString:[Common getCurrentUserVo].strUserID] && self.m_chatObjectVo.bDiscussion)
            {
                nMemberNum -= 2;
            }
            else
            {
                nMemberNum -= 1;
            }
            if (nMemberNum<1)
            {
                nMemberNum = 1;
            }
        }
        [self setTopNavBarTitle:[NSString stringWithFormat:@"%@(%lu)",[Common localStr:@"Chat_GroupTitle" value:@"聊天详情"],(unsigned long)nMemberNum]];
    }
    CGFloat fHeight = 0.0;
    
    if (bAddEditButton)//需要增加编辑按钮
    {
        if (self.m_chatObjectVo.nType == 2 && [self.m_chatObjectVo.strVestID isEqualToString:[Common getCurrentUserVo].strUserID] && self.m_chatObjectVo.bDiscussion)
        {
            //若是自己创建的聊天组，则可以增加和减少成员的按钮
            UserVo *userVo = [[UserVo alloc]init];
            userVo.strUserID = @"+";
            userVo.strUserName = @"";
            userVo.strHeadImageURL = @"";
            [self.m_chatObjectVo.aryMember addObject:userVo];
            
            userVo = [[UserVo alloc]init];
            userVo.strUserID = @"-";
            userVo.strUserName = @"";
            userVo.strHeadImageURL = @"";
            [self.m_chatObjectVo.aryMember addObject:userVo];
        }
        else
        {
            //只有增加按钮
            UserVo *userVo = [[UserVo alloc]init];
            userVo.strUserID = @"+";
            userVo.strUserName = @"";
            userVo.strHeadImageURL = @"";
            [self.m_chatObjectVo.aryMember addObject:userVo];
        }
    }
    
    //collection view and bk view
    CGFloat fCollectionH = 0.0;
    int nColumnNum = (kScreenWidth-28)/73;
    if (self.m_chatObjectVo.aryMember.count%nColumnNum == 0)
    {
        //正好整除
        fCollectionH = (self.m_chatObjectVo.aryMember.count/nColumnNum)*95;
    }
    else
    {
        //有余数
        fCollectionH = (self.m_chatObjectVo.aryMember.count/nColumnNum+1)*95;
    }
    
    self.collectionMember.frame = CGRectMake(14, fHeight+10, kScreenWidth-28, fCollectionH);
    [self.collectionMember reloadData];
    
    //table view
    if (self.m_chatObjectVo.bDiscussion)
    {
        lblAllMember.text = [NSString stringWithFormat:@"全部群成员(%lu)",(unsigned long)nMemberNum];
        
        self.viewCollectionBK.frame = CGRectMake(0, fHeight, kScreenWidth, 10+fCollectionH+44+10);
        viewAllMember.hidden = NO;
        viewAllMember.frame = CGRectMake(0, self.viewCollectionBK.height-44.5, self.viewCollectionBK.width, 44);
        viewCollectionSep.frame = CGRectMake(0, self.viewCollectionBK.height-0.5, self.viewCollectionBK.width, 0.5);
        fHeight += self.viewCollectionBK.bottom+5;
        
        self.tableViewChatInfo.frame = CGRectMake(0, fHeight, kScreenWidth,44*4+10+20*2+10);
    }
    else
    {
        self.viewCollectionBK.frame = CGRectMake(0, fHeight, kScreenWidth, 10+fCollectionH+10);
        viewAllMember.hidden = YES;
        viewCollectionSep.frame = CGRectMake(0, self.viewCollectionBK.height-0.5, self.viewCollectionBK.width, 0.5);
        fHeight += self.viewCollectionBK.bottom+5;
        
        self.tableViewChatInfo.frame = CGRectMake(0, fHeight, kScreenWidth,44*3+10+20+10);
    }
    [self.tableViewChatInfo reloadData];
    fHeight += self.tableViewChatInfo.frame.size.height;
    
    //群聊才会有删除并退出button
    if (self.m_chatObjectVo.nType == 2 && self.m_chatObjectVo.bDiscussion)
    {
        fHeight += 10;
        self.btnExitAndDelete.frame = CGRectMake(10, fHeight, kScreenWidth-20, 42);
        fHeight += 42;
    }
    fHeight += 20;
    
    [self.scollViewChatInfo setContentSize:CGSizeMake(kScreenWidth, fHeight<(kScreenHeight-NAV_BAR_HEIGHT)?(kScreenHeight-NAV_BAR_HEIGHT+0.5):fHeight)];
}

- (void)refreshData
{
    if (self.m_chatObjectVo.nType == 1)
    {
        //私聊
        [self isHideActivity:NO];
        [ServerProvider getChatSingleInfo:self.m_chatObjectVo result:^(ServerReturnInfo *retInfo) {
            [self isHideActivity:YES];
            if (retInfo.bSuccess)
            {
                self.m_chatObjectVo = retInfo.data;
                [self refreshView:YES];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
    else
    {
        //群聊
        [self isHideActivity:NO];
        [ServerProvider getChatGroupInfo:self.m_chatObjectVo result:^(ServerReturnInfo *retInfo) {
            [self isHideActivity:YES];
            if (retInfo.bSuccess)
            {
                self.m_chatObjectVo = retInfo.data;
                [self refreshView:YES];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
}

- (void)getAllChatMember
{
    NSMutableArray *aryMember = [NSMutableArray array];
    [aryMember addObjectsFromArray:self.m_chatObjectVo.aryMember];
    
    if (self.m_chatObjectVo.nType == 2 && [self.m_chatObjectVo.strVestID isEqualToString:[Common getCurrentUserVo].strUserID] && self.m_chatObjectVo.bDiscussion)
    {
        //若是自己创建的聊天组，则可以增加和减少成员的按钮
        [aryMember removeLastObject];
        [aryMember removeLastObject];
    }
    else
    {
        //只有增加按钮
        [aryMember removeLastObject];
    }
    
    MemberListViewController *memberListViewController = [[UIStoryboard storyboardWithName:@"ChatModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MemberListViewController"];
    memberListViewController.m_chatObjectVo = self.m_chatObjectVo;
    memberListViewController.aryOrignData = aryMember;
    [self.navigationController pushViewController:memberListViewController animated:YES];
}

//推送通知刷新数据
- (void)refreshDataByNotify:(NSNotification*)notification
{
    NSMutableDictionary* dicNotify = [notification object];
    NSString *strValue = [dicNotify objectForKey:@"RefreshPara"];
    if (strValue != nil && [strValue isEqualToString:@"updateNameSuccess"])
    {
        self.nRefreshState = 2;
    }
    
    [self refreshData];
}

//置顶聊天
- (void)switchTopChatAction
{
    [self isHideActivity:NO];
    [ServerProvider setTopChat:self.m_chatObjectVo result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            self.nRefreshState = 1;
            self.m_chatObjectVo.bTopMsg = !self.m_chatObjectVo.bTopMsg;
            [self.tableViewChatInfo reloadData];
            [self isHideActivity:YES];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//推送开关
- (void)switchNewMsgAction
{
    [self isHideActivity:NO];
    [ServerProvider setPushSwitch:self.m_chatObjectVo result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            self.m_chatObjectVo.bEnablePush = !self.m_chatObjectVo.bEnablePush;
            [self.tableViewChatInfo reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//删除并退出操作
- (void)clickExitButton
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[Common localStr:@"Chat_DeleteTipInfo" value:@"删除并退出后，将不再接收此群聊信息"] delegate:self cancelButtonTitle:[Common localStr:@"Common_Cancel" value:[Common localStr:@"Common_Cancel" value:@"取消"]] destructiveButtonTitle:[Common localStr:@"Common_OK" value:@"确定"] otherButtonTitles:nil];
    actionSheet.tag = 1002;
    [actionSheet showInView:self.view];
}

//click member action
- (void)clickMemberAction:(UserVo*)userVo
{
    if([userVo.strUserID isEqualToString:@"+"])
    {
        //add member
        ChooseUserViewController *chooseUserViewController = [[UIStoryboard storyboardWithName:@"UserModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ChooseUserViewController"];
        chooseUserViewController.delegate = self;
        chooseUserViewController.chooseUserType = ChooseUserUpdateChatType;
        chooseUserViewController.m_chatObjectVo = self.m_chatObjectVo;
        if (self.m_chatObjectVo.nType == 1)
        {
            //私聊
            NSMutableArray *aryMember = [NSMutableArray array];
            UserVo *userVo = [[UserVo alloc]init];
            userVo.strUserID = self.m_chatObjectVo.strVestID;
            userVo.bCanNotCheck = YES;
            [aryMember addObject:userVo];
            chooseUserViewController.aryUserPreChoosed = aryMember;
        }
        else if (self.m_chatObjectVo.bDiscussion)
        {
            //讨论组
            chooseUserViewController.aryUserPreChoosed = self.m_chatObjectVo.aryMember;
        }
        
        [self.navigationController pushViewController:chooseUserViewController animated:YES];
    }
    else if([userVo.strUserID isEqualToString:@"-"])
    {
        //show minus button
        if(self.bShowDeleteBtn)
        {
            self.bShowDeleteBtn = NO;
            [self.collectionMember reloadData];
        }
        else
        {
            self.bShowDeleteBtn = YES;
            [self.collectionMember reloadData];
        }
    }
    else
    {
        //        //view member detail
        //        UserCenterViewController *userCenterViewController = [[UserCenterViewController alloc]init];
        //        userCenterViewController.m_userVo = userVo;
        //        [self.navigationController pushViewController:userCenterViewController animated:YES];
    }
}

//delete member action
- (void)clickMinusAction:(UserVo*)userVo
{
    [self isHideActivity:NO];
    [ServerProvider deleteChatGroupMember:userVo.strUserID andGroupNodeID:self.m_chatObjectVo.strGroupNodeID result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            [self.m_chatObjectVo.aryMember removeObject:userVo];
            [self refreshView:NO];//refresh data
            [self isHideActivity:YES];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//long press member
- (void)longPressMemberAction:(UserVo*)userVo
{
    //创建者有删除功能
    if(![userVo.strUserID isEqualToString:@"+"] && [self.m_chatObjectVo.strVestID isEqualToString:[Common getCurrentUserVo].strUserID])
    {
        //show minus button
        if(self.bShowDeleteBtn)
        {
            self.bShowDeleteBtn = NO;
            [self.collectionMember reloadData];
        }
        else
        {
            self.bShowDeleteBtn = YES;
            [self.collectionMember reloadData];
        }
    }
}

//返回结束处理
- (void)tackleWhenReturn
{
    if(self.nRefreshState >= 1)
    {
        //刷新会话列表
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DoRefreshChatList" object:[@{@"RefreshPara":@"fromServer"} mutableCopy]];
        
        if (self.nRefreshState == 2)
        {
            //聊天内容标题更改
            [[NSNotificationCenter defaultCenter]postNotificationName:@"DoRefreshChatContentPage" object:[@{@"RefreshPara":@"refreshTitle",@"Title":self.m_chatObjectVo.strGroupName} mutableCopy]];
        }
        else if(self.nRefreshState == 3)
        {
            //聊天内容记录清空
            [[NSNotificationCenter defaultCenter]postNotificationName:@"DoRefreshChatContentPage" object:[@{@"RefreshPara":@"refreshData"} mutableCopy]];
        }
    }
}

- (void)tapCollection:(UITapGestureRecognizer*)gesture
{
    if(self.bShowDeleteBtn)
    {
        self.bShowDeleteBtn = NO;
        [self.collectionMember reloadData];
    }
}

#pragma mark - ChooseUserAndGroupDelegate(完成群组和成员选择)
-(void)completeChooseUserAction:(NSMutableArray*)aryChoosedUser group:(GroupVo *)groupVo
{
    [self.m_aryChoosedGroup removeAllObjects];
    [self.m_aryChoosedGroup addObject:groupVo];
}

//完成选择用户，开始进入聊天
-(void)completeChooseAndStartChat
{
    NSMutableArray *aryChatMember = [NSMutableArray array];
    if (self.m_aryChoosedGroup != nil && self.m_aryChoosedGroup.count>0)
    {
        //讨论组
        GroupVo *groupVo = [self.m_aryChoosedGroup objectAtIndex:0];
        
        ChatObjectVo *chatObjectVo = [[ChatObjectVo alloc]init];
        chatObjectVo.nType = 2;
        chatObjectVo.strGroupID = groupVo.strGroupID;
        chatObjectVo.strGroupNodeID = groupVo.strGroupNodeID;
        chatObjectVo.strGroupName = groupVo.strGroupName;
        [aryChatMember addObject:chatObjectVo];
        
        if (self.m_chatObjectVo.bDiscussion)
        {
            //讨论组（添加成员，重新刷新数据）
            [self refreshData];
            if (self.m_chatObjectVo.bUnnaming)
            {
                self.nRefreshState = 2;//未命名则刷新列表+更新聊天内容界面标题
            }
        }
        else
        {
            //知新群组或者私聊（创建讨论组，返回聊天界面）
            self.nRefreshState = 1;
            NSArray *aryViewControllers = self.navigationController.viewControllers;
            
            for (NSInteger i=aryViewControllers.count-1; i>=0; i--)
            {
                UIViewController *viewController = aryViewControllers[i];
                if ([viewController isKindOfClass:[ChatListViewController class]])
                {
                    //notification to
                    ChatListViewController *tempChatListViewController = (ChatListViewController *)viewController;
                    [tempChatListViewController completeChooseUserAction:nil group:groupVo];
                    [self.navigationController popToViewController:viewController animated:NO];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"CompleteCreateDiscussionChat" object:nil];
                    
                    break;
                }
            }
        }
    }
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1001)
    {
        //清除聊天记录
        if (buttonIndex == 0)
        {
            //confirm delete
            [self isHideActivity:NO];
            [ServerProvider clearChatHistory:self.m_chatObjectVo result:^(ServerReturnInfo *retInfo) {
                [self isHideActivity:YES];
                if (retInfo.bSuccess)
                {
                    self.nRefreshState = 3;
                }
                else
                {
                    [Common tipAlert:retInfo.strErrorMsg];
                }
            }];
        }
    }
    else if (actionSheet.tag == 1002)
    {
        //删除并退出
        if (buttonIndex == 0)
        {
            [self isHideActivity:NO];
            [ServerProvider selfExitChatGroup:self.m_chatObjectVo.strGroupNodeID result:^(ServerReturnInfo *retInfo) {
                [self isHideActivity:YES];
                if (retInfo.bSuccess)
                {
                    self.nRefreshState = 1;
                    NSArray *aryViewControllers = self.navigationController.viewControllers;
                    if (aryViewControllers != nil && aryViewControllers.count>0)
                    {
                        UIViewController *viewController = [aryViewControllers objectAtIndex:0];
                        if ([viewController isKindOfClass:[ChatListViewController class]])
                        {
                            //notification to
                            [self.navigationController popToViewController:viewController animated:YES];
                        }
                    }
                }
                else
                {
                    [Common tipAlert:retInfo.strErrorMsg];
                }
            }];
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.m_chatObjectVo.bDiscussion)
    {
        return 3;
    }
    else
    {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger nRowNum = 0;
    if (self.m_chatObjectVo.bDiscussion)
    {
        if (section == 0)
        {
            nRowNum = 1;
        }
        else if (section == 1)
        {
            nRowNum = 2;
        }
        else if (section == 2)
        {
            nRowNum = 1;
        }
    }
    else
    {
        if (section == 0)
        {
            nRowNum = 2;
        }
        else if (section == 1)
        {
            nRowNum = 1;
        }
    }
    return nRowNum;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;//section头部高度
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;//section尾部高度
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    static NSString *identifier = nil;
    identifier = @"ConfigureCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        UIView *selected = [[UIView alloc] init];
        selected.backgroundColor = [SkinManage colorNamed:@"Table_Selected_Color"];
        cell.selectedBackgroundView = selected;
        //title
        UILabel * lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 5,kScreenWidth-120,34)];
        lblTitle.font = [UIFont systemFontOfSize:16.0];
        lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
        lblTitle.backgroundColor = [UIColor clearColor];
        lblTitle.tag = 1001;
        [cell.contentView addSubview:lblTitle];
        
        //switch button
        UISwitch *switchConfigure = [[UISwitch alloc]initWithFrame:CGRectMake(0, (41-31)/2,70, 31)];
        switchConfigure.center = CGPointMake(kScreenWidth-15-switchConfigure.frame.size.width/2, switchConfigure.center.y);
        switchConfigure.tag = 1002;
        [cell.contentView addSubview:switchConfigure];
        
        UILabel * lblDiscussionName = [[UILabel alloc]initWithFrame:CGRectMake(105, 5,kScreenWidth-145,34)];
        lblDiscussionName.font = [UIFont boldSystemFontOfSize:13.0];
        lblDiscussionName.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];
        lblDiscussionName.backgroundColor = [UIColor clearColor];
        lblDiscussionName.textAlignment = NSTextAlignmentRight;
        lblDiscussionName.tag = 1003;
        [cell.contentView addSubview:lblDiscussionName];
        
        UIImageView *imgViewTableArrow = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth-12-8, 15, 8, 14)];
        imgViewTableArrow.tag = 1004;
        imgViewTableArrow.image = [SkinManage imageNamed:@"table_accessory"];
        [cell.contentView addSubview:imgViewTableArrow];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    UILabel *lblTitle = (UILabel*)[cell.contentView viewWithTag:1001];
    UISwitch *switchConfigure = (UISwitch *)[cell.contentView viewWithTag:1002];
    UILabel *lblDiscussionName = (UILabel*)[cell.contentView viewWithTag:1003];
    UIImageView *imgViewTableArrow = (UIImageView*)[cell.contentView viewWithTag:1004];
    imgViewTableArrow.hidden = YES;
    int nSectionNum = 0;
    if (self.m_chatObjectVo.bDiscussion)
    {
        nSectionNum = 0;
    }
    else
    {
        nSectionNum = -1;
    }
    if (section == nSectionNum && row == 0)
    {
        lblTitle.text = [Common localStr:@"Chat_GroupChatName" value:@"群聊名称"];
        switchConfigure.hidden = YES;
        lblDiscussionName.hidden = NO;
        if (self.m_chatObjectVo.bUnnaming)
        {
            //未命名
            lblDiscussionName.text = [Common localStr:@"Chat_NotSet" value:@"未命名"];
        }
        else
        {
            //已命名
            lblDiscussionName.text = self.m_chatObjectVo.strGroupName;
        }
        imgViewTableArrow.hidden = NO;
    }
    else if (section == (++nSectionNum) && row == 0)
    {
        lblTitle.text = [Common localStr:@"Chat_Sticky" value:@"置顶聊天"];
        switchConfigure.on = self.m_chatObjectVo.bTopMsg;
        [switchConfigure removeTarget:self action:@selector(switchTopChatAction) forControlEvents:UIControlEventValueChanged];
        [switchConfigure addTarget:self action:@selector(switchTopChatAction) forControlEvents:UIControlEventValueChanged];
        switchConfigure.hidden = NO;
        lblDiscussionName.hidden = YES;
    }
    else if(section == nSectionNum && row == 1)
    {
        lblTitle.text = [Common localStr:@"Chat_Notification" value:@"新消息通知"];
        switchConfigure.on = self.m_chatObjectVo.bEnablePush;
        [switchConfigure removeTarget:self action:@selector(switchNewMsgAction) forControlEvents:UIControlEventValueChanged];
        [switchConfigure addTarget:self action:@selector(switchNewMsgAction) forControlEvents:UIControlEventValueChanged];
        switchConfigure.hidden = NO;
        lblDiscussionName.hidden = YES;
    }
    else if (section == (++nSectionNum) && row == 0)
    {
        //清空聊天记录
        lblTitle.text = [Common localStr:@"Chat_Clear" value:@"清空聊天记录"];
        switchConfigure.hidden = YES;
        lblDiscussionName.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    if (self.m_chatObjectVo.bDiscussion)
    {
        if (section == 0 && row == 0)
        {
            //群聊名称
            ChatDiscussionNameViewController *chatDiscussionNameViewController = [[ChatDiscussionNameViewController alloc]init];
            chatDiscussionNameViewController.m_chatObjectVo = self.m_chatObjectVo;
            [self.navigationController pushViewController:chatDiscussionNameViewController animated:YES];
        }
        else if (section == 2 && row == 0)
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:[Common localStr:@"Common_Cancel" value:[Common localStr:@"Common_Cancel" value:@"取消"]] destructiveButtonTitle:[Common localStr:@"Chat_Clear" value:@"清空聊天记录"] otherButtonTitles:nil];
            actionSheet.tag = 1001;
            [actionSheet showInView:self.view];
        }
    }
    else
    {
        if (section == 1 && row == 0)
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:[Common localStr:@"Common_Cancel" value:[Common localStr:@"Common_Cancel" value:@"取消"]] destructiveButtonTitle:[Common localStr:@"Chat_Clear" value:@"清空聊天记录"] otherButtonTitles:nil];
            actionSheet.tag = 1001;
            [actionSheet showInView:self.view];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UICollectionViewDataSource UICollectionViewDelegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ChatMemberCollectionCell";
    ChatMemberCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    UserVo *userVo = [self.m_chatObjectVo.aryMember objectAtIndex:[indexPath row]];
    cell.parentViewController = self;
    cell.bShowDeleteBtn = self.bShowDeleteBtn;
    [cell initUserVo:userVo];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.m_chatObjectVo.aryMember.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

@end
