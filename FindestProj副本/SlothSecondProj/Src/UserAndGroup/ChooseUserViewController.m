//
//  ChooseUserViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/27.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ChooseUserViewController.h"
#import "ChooseUserCell.h"
#import "GroupAndUserDao.h"
#import "Utils.h"
#import "UserVo.h"
#import "MJRefresh.h"
#import "ChooseChatGroupViewController.h"
#import "UIButton+WebCache.h"
#import "UIViewExt.h"
#import "NSString+Function.h"
#import "VNetworkFramework.h"
#import "ServerURL.h"
@interface ChooseUserViewController ()<ChooseUserCellDelegate,ChooseChatGroupDelegate,UITableViewDataSource,UITableViewDelegate>
{
    ChooseChatGroupViewController *chooseChatGroupViewController;
    UIScrollView *scrollViewChoosed;
    
    MJRefreshFooter *refreshFooter;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewUserList;
@property (weak, nonatomic) IBOutlet UITableView *tableViewSearchResult;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;

@property (weak, nonatomic) IBOutlet UIView *viewSearchSep;
@property (weak, nonatomic) IBOutlet UILabel *chooselabel;

@property (weak, nonatomic) IBOutlet UIView *groupView;

@property (weak, nonatomic) IBOutlet UIView *txtChooseGroupSep;
@property (weak, nonatomic) IBOutlet UIImageView *searchImgView;


@property (weak, nonatomic) IBOutlet UIButton *btnChooseGroup;

@property (weak, nonatomic) IBOutlet UIView *viewChoosedContainer;      //已选视图容器
@property (weak, nonatomic) IBOutlet UIView *viewChooseedContainerView;
@property (weak, nonatomic) IBOutlet UILabel *lblChoosedNum;
@property (weak, nonatomic) IBOutlet UIImageView *tableViewImg;

@end

@implementation ChooseUserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self initView];
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateChooseGroupMembers];
    [self initChoosedView];
}

-(void)initView
{
    self.fd_interactivePopDisabled = YES;
    
    self.title = @"联系人";
    //导航按钮
    self.navigationItem.rightBarButtonItem = [self rightBtnItemWithTitle:@"完成"];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [_btnChooseGroup setBackgroundImage:[Common getImageWithColor:COLOR(246, 246, 246, 1.0)] forState:UIControlStateHighlighted];
    
    
    _tableViewUserList.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    _tableViewUserList.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    _tableViewUserList.sectionIndexColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    _tableViewUserList.sectionIndexBackgroundColor = [UIColor clearColor];
    [_tableViewUserList registerNib:[UINib nibWithNibName:@"ChooseUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ChooseUserCell"];
    [_tableViewSearchResult registerNib:[UINib nibWithNibName:@"ChooseUserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ChooseUserCell"];
    _tableViewSearchResult.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    _tableViewSearchResult.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.searchImgView.image = [SkinManage imageNamed:@"search _icon"];
    scrollViewChoosed = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth-100, 56)];
    scrollViewChoosed.autoresizingMask = NO;
    scrollViewChoosed.clipsToBounds = YES;
    scrollViewChoosed.showsHorizontalScrollIndicator = NO;
    [_viewChoosedContainer addSubview:scrollViewChoosed];
    
    if (self.chooseUserType == ChooseUserCreateChatType)
    {
        self.tableViewUserList.tableHeaderView = self.groupView;
    }
    else
    {
        _tableViewUserList.tableHeaderView = nil;
    }
    [self.view layoutIfNeeded];
    
    //上拉加载更多
    @weakify(self)
    refreshFooter =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self)
        [self loadAllUserSearchResult:NO];
    }];
    
    
    //    @weakify(self)
    //    _tableViewSearchResult.mj_footer =  [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
    //        @strongify(self)
    //        [self loadAllUserSearchResult:NO];
    //    }];
    
    _viewSearchSep.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.searchView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.viewChoosedContainer.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.viewChooseedContainerView.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.groupView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.txtChooseGroupSep.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.lblChoosedNum.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.chooselabel.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.tableViewImg.image = [SkinManage imageNamed:@"table_accessory"];
}
- (void)loadData33333{
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dicPageInfo = [[NSMutableDictionary alloc] init];
    [dicPageInfo setObject:@"1" forKey:@"pageNumber"];
    [dicPageInfo setObject:@1000000 forKey:@"pageSize"];
    [bodyDic setObject:dicPageInfo forKey:@"pageInfo"];
    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getMyAttentionUserListURL]];
    [networkFramework startRequestToServer:@"POST" parameter:bodyDic result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            
        }
        else
        {
            retInfo.bSuccess = YES;
            
            NSMutableArray *aryMemberList = nil;
            NSArray *aryJSONUserList = [responseObject objectForKey:@"content"];
            
        }
    }];
    
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
    self.bOnLineSearch = NO;
    
    self.nChooseUserNumber = 0;
    
    //get DB user list
    GroupAndUserDao *groupAndUserDao = [[GroupAndUserDao alloc]init];
    BOOL bContainerSelf = NO;
//#warning  ............. 首字母
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
                if(self.chooseUserType != ChooseUserAtType)
                {
                    userVo.bCanNotCheck = YES;
                }
                [self.aryUserChoosed addObject:userVo];
            }
        }
    }
    //    [self.btnAlreadyChooseTab setTitle:[NSString stringWithFormat:@"已选(%lu)",(unsigned long)self.nChooseUserNumber] forState:UIControlStateNormal];
    [self.tableViewUserList reloadData];
}

//完成选择
-(void)righBarClick
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
        return;
    }
    else
    {
        if (self.chooseUserType == ChooseUserCreateChatType || self.chooseUserType == ChooseUserUpdateChatType)
        {
            [self createDiscussion:nil andUserList:aryTempChoosed];
        }
        else
        {
            //at选择人
            [self.delegate completeChooseUserAction:aryTempChoosed group:nil];
            [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)chooseChatGroup:(id)sender
{
    if(!chooseChatGroupViewController)
    {
        chooseChatGroupViewController = [[UIStoryboard storyboardWithName:@"ChatModule" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"ChooseChatGroupViewController"];
        chooseChatGroupViewController.delegate = self;
    }
    
    [self.navigationController pushViewController:chooseChatGroupViewController animated:YES];
}

//选择单聊或者群聊或者创建讨论组
-(void)createDiscussion:(NSMutableArray*)aryGroupChoosedTemp andUserList:(NSMutableArray*)aryUserChoosedTemp
{
    NSMutableArray *aryChatMember = [NSMutableArray array];
    
    if (aryGroupChoosedTemp != nil && aryGroupChoosedTemp.count>0)
    {
        //直接选择一个讨论组进行聊天
        [self.delegate completeChooseUserAction:nil group:aryGroupChoosedTemp[0]];
        self.txtSearch.delegate = nil;//防止crash
        [self.navigationController popViewControllerAnimated:NO];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"CompleteChooseAndStartChat" object:nil];
    }
    else if(aryUserChoosedTemp != nil && aryUserChoosedTemp.count>0)
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
        
        //聊天模块
        if (aryChatMember.count>0)
        {
            if(self.m_chatObjectVo == nil)
            {
                ChatObjectVo *chatObjectVo = aryChatMember[0];
                if (aryChatMember.count>1)
                {
                    //生成讨论组(针对私聊加入和群组)【超过一个人】(选择一个群组选择群组聊天，直接创建讨论组)
                    [Common showProgressView:nil view:self.view modal:NO];
                    [ServerProvider createOrUpdateChatDiscussion:aryChatMember andChatObject:nil result:^(ServerReturnInfo *retInfo) {
                        [Common hideProgressView:self.view];
                        if (retInfo.bSuccess)
                        {
                            NSMutableArray *aryGroup = [@[retInfo.data] mutableCopy];
                            [self.delegate completeChooseUserAction:aryUserChoosedTemp group:aryGroup[0]];
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
                    //选择单聊
                    if ([chatObjectVo.strVestID isEqualToString:[Common getCurrentUserVo].strUserID])
                    {
                        [Common bubbleTip:@"不能选择自己进行私聊" andView:self.view];
                    }
                    else
                    {
                        [self.delegate completeChooseUserAction:aryUserChoosedTemp group:nil];
                        self.txtSearch.delegate = nil;//防止crash
                        [self.navigationController popViewControllerAnimated:NO];
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"CompleteChooseAndStartChat" object:nil];
                    }
                }
            }
            else
            {
                //修改讨论组成员(针对讨论组)
                [Common showProgressView:nil view:self.view modal:NO];
                [ServerProvider createOrUpdateChatDiscussion:aryChatMember andChatObject:self.m_chatObjectVo result:^(ServerReturnInfo *retInfo) {
                    [Common hideProgressView:self.view];
                    if (retInfo.bSuccess)
                    {
                        NSMutableArray *aryGroup = [@[retInfo.data] mutableCopy];
                        [self.delegate completeChooseUserAction:aryUserChoosedTemp group:aryGroup[0]];
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
}

#pragma mark 选择人底部已选视图
- (void)initChoosedView
{
    //移除之前的视图
    for (UIView *viewSub in scrollViewChoosed.subviews)
    {
        if ([viewSub isKindOfClass:[UIButton class]])
        {
            [viewSub removeFromSuperview];
        }
    }
    
    for (int i=0;i<self.aryUserChoosed.count;i++)
    {
        //生成button
        UserVo *userVo = self.aryUserChoosed[i];
        
        [self createUserButton:userVo frame:CGRectMake(50*i+10, 8, 40, 40)];
    }
    
    //创建一个占位按钮
    [self createUserButton:nil frame:CGRectMake(50*self.aryUserChoosed.count+10, 8, 40, 40)];
    
    scrollViewChoosed.contentSize = CGSizeMake(self.aryUserChoosed.count*50, 56);
    if (scrollViewChoosed.width < scrollViewChoosed.contentSize.width)
    {
        [scrollViewChoosed setContentOffset:CGPointMake(scrollViewChoosed.contentSize.width-scrollViewChoosed.width, 0) animated:YES];
    }
    
    //更新数量文本
    [self updateChoosedNumText];
}

- (void)minusChoosedUser:(NSString *)strUserID
{
    [UIView animateWithDuration:0.4 animations:^{
        BOOL bFound = NO;
        for (int i=0;i<self.aryUserChoosed.count;i++)
        {
            UserVo *userVo = self.aryUserChoosed[i];
            
            //找到button
            if (bFound)
            {
                //更新位置
                UIButton *btnUser = [scrollViewChoosed viewWithTag:userVo.strUserID.integerValue];
                btnUser.frame = CGRectMake(50*(i-1)+10, 8, 40, 40);
            }
            else
            {
                if ([userVo.strUserID isEqualToString:strUserID])
                {
                    bFound = YES;
                    UIButton *btnUser = [scrollViewChoosed viewWithTag:strUserID.integerValue];
                    [btnUser removeFromSuperview];
                }
            }
        }
        UIButton *btnPlaceHolder = [scrollViewChoosed viewWithTag:-1];
        btnPlaceHolder.frame = CGRectMake(50*(self.aryUserChoosed.count-1)+10, 8, 40, 40);
        
        //如果是@界面，超过10个不显示占位按钮
        if ((self.nChooseUserNumber-1) >= 10 && self.chooseUserType == ChooseUserAtType)
        {
            scrollViewChoosed.contentSize = CGSizeMake((self.aryUserChoosed.count-1)*50, 56);
        }
        else
        {
            scrollViewChoosed.contentSize = CGSizeMake((self.aryUserChoosed.count)*50, 56);
        }
        
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)addChoosedUser:(UserVo *)userVo
{
    [self createUserButton:userVo frame:CGRectMake(50*(self.aryUserChoosed.count-1)+10, 8, 40, 40)];
    
    UIButton *btnPlaceHolder = [scrollViewChoosed viewWithTag:-1];
    btnPlaceHolder.frame = CGRectMake(50*self.aryUserChoosed.count+10, 8, 40, 40);
    
    //如果是@界面，超过10个不显示占位按钮
    if (self.nChooseUserNumber >= 10 && self.chooseUserType == ChooseUserAtType)
    {
        scrollViewChoosed.contentSize = CGSizeMake((self.aryUserChoosed.count)*50, 56);
    }
    else
    {
        scrollViewChoosed.contentSize = CGSizeMake((self.aryUserChoosed.count+1)*50, 56);
    }
    
    if (scrollViewChoosed.width < scrollViewChoosed.contentSize.width)
    {
        [scrollViewChoosed setContentOffset:CGPointMake(scrollViewChoosed.contentSize.width-scrollViewChoosed.width, 0) animated:YES];
    }
}

//创建按钮视图
- (void)createUserButton:(UserVo *)userVo frame:(CGRect)rect
{
    UIButton *btnUser = [UIButton buttonWithType:UIButtonTypeCustom];
    btnUser.layer.cornerRadius = 5;
    btnUser.layer.masksToBounds = YES;
    btnUser.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [btnUser setContentHorizontalAlignment:UIControlContentHorizontalAlignmentFill];
    [btnUser setContentVerticalAlignment:UIControlContentVerticalAlignmentFill];
    
    if (userVo == nil)
    {
        btnUser.tag = -1;
        [btnUser setImage:[SkinManage imageNamed:@"user_placeholder"] forState:UIControlStateNormal];
    }
    else
    {
        btnUser.tag = userVo.strUserID.integerValue;
        [btnUser sd_setImageWithURL:[NSURL URLWithString:userVo.strHeadImageURL] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_m"]];
    }
    
    btnUser.frame = rect;
    [btnUser addTarget: self action:@selector(userButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [scrollViewChoosed addSubview:btnUser];
    
    if (userVo.bCanNotCheck)
    {
        btnUser.enabled = NO;
    }
}

//单击按钮（取消选择用户）
- (void)userButtonClicked:(UIButton *)sender
{
    if(sender.tag != -1)
    {
        NSString *strUserID = [NSString stringWithFormat:@"%li",(long)sender.tag];
        [self minusChoosedUser:strUserID];
        
        //属性Table的UI和数据
        self.nChooseUserNumber--;
        [self removeUserFromChoosedList:strUserID];//移除已选数组(采用循环ID判断)
        [self.tableViewSearchResult reloadData];
        [self.tableViewUserList reloadData];
        
        //更新数量文本
        [self updateChoosedNumText];
        
        if (self.nChooseUserNumber > 0)
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else
        {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
}

- (void)updateChoosedNumText
{
    NSString *strText;
    if (self.chooseUserType == ChooseUserAtType)
    {
        strText = [NSString stringWithFormat:@"(%li/10)",(unsigned long)self.nChooseUserNumber];
        
        UIButton *btnPlaceHolder = [scrollViewChoosed viewWithTag:-1];
        if (self.nChooseUserNumber >= 10)
        {
            btnPlaceHolder.hidden = YES;
        }
        else
        {
            btnPlaceHolder.hidden = NO;
        }
    }
    else
    {
        strText = [NSString stringWithFormat:@"(%li)",(unsigned long)self.nChooseUserNumber];
    }
    _lblChoosedNum.text = strText;
}

#pragma mark ChooseChatGroupDelegate
-(void)completeChooseChatGroup:(GroupVo *)groupVo
{
    [chooseChatGroupViewController.navigationController popViewControllerAnimated:NO];
    [self createDiscussion:[@[groupVo] mutableCopy] andUserList:nil];
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
        
        ChooseUserCell *cell = (ChooseUserCell*)[tableView dequeueReusableCellWithIdentifier:@"ChooseUserCell" forIndexPath:indexPath];
        cell.delegate = self;
        cell.entity = useVo;
        return  cell;
    }
    else
    {
        UserVo *useVo = [self.aryUserFilteredObject objectAtIndex:[indexPath row]];
        ChooseUserCell *cell = (ChooseUserCell *)[tableView dequeueReusableCellWithIdentifier:@"ChooseUserCell" forIndexPath:indexPath];
        cell.delegate = self;
        cell.entity = useVo;
        return  cell;
    }
}

//把每个分区打上标记key
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (tableView == self.tableViewUserList)
    {
        static NSString *header = @"ActivitySectionHeader1";
        UITableViewHeaderFooterView *viewHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:header];
//        if (viewHeader == nil)
//        {
            viewHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:header];
            viewHeader.contentView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
            UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, kScreenWidth, 40)];
            lblTitle.text = [self.aryUserTableFirstLetter objectAtIndex:section];
            lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
            lblTitle.font = [UIFont systemFontOfSize:16];
            lblTitle.textAlignment = NSTextAlignmentLeft;
            [viewHeader addSubview:lblTitle];
            
//        }
        
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
        if (userVo.bCanNotCheck)
        {
            return;//不能选择
        }
        
        if (self.chooseUserType == ChooseUserAtType)
        {
            //如果超过10个这不能选择
            if (self.nChooseUserNumber >= 10 && !userVo.bChecked)
            {
                [Common bubbleTip:@"最多只能添加10个联系人" andView:self.view];
                return;
            }
        }
        
        //反选
        userVo.bChecked = !userVo.bChecked;
        
        //change choosed num
        if (userVo.bChecked)
        {
            self.nChooseUserNumber++;
            [self.aryUserChoosed addObject:userVo];
            
            //增加底部选择人视图
            [self addChoosedUser:userVo];
        }
        else
        {
            //移除底部选择人视图
            [self minusChoosedUser:userVo.strUserID];
            
            self.nChooseUserNumber--;
            [self removeUserFromChoosedList:userVo.strUserID];//移除已选数组(采用循环ID判断)
        }
        
        ChooseUserCell *cell = (ChooseUserCell*)[tableView cellForRowAtIndexPath:indexPath];
        [cell updateCheckImage:userVo.bChecked];
    }
    else if (tableView == self.tableViewSearchResult)
    {
        UserVo *userVo = [self.aryUserFilteredObject objectAtIndex:[indexPath row]];
        if (userVo.bCanNotCheck)
        {
            return;//不能选择
        }
        
        if (self.chooseUserType == ChooseUserAtType)
        {
            //如果超过10个这不能选择
            if (self.nChooseUserNumber >= 10 && !userVo.bChecked)
            {
                [Common bubbleTip:@"最多只能添加10个联系人" andView:self.view];
                return;
            }
        }
        
        //反选
        userVo.bChecked = !userVo.bChecked;
        
        //change choosed num
        if (userVo.bChecked)
        {
            self.nChooseUserNumber++;
            [self.aryUserChoosed addObject:userVo];
            
            //增加底部选择人视图
            [self addChoosedUser:userVo];
        }
        else
        {
            //移除底部选择人视图
            [self minusChoosedUser:userVo.strUserID];
            
            self.nChooseUserNumber--;
            [self removeUserFromChoosedList:userVo.strUserID];//移除已选数组(采用循环ID判断)
        }
        //change chk image
        ChooseUserCell *cell = (ChooseUserCell*)[tableView cellForRowAtIndexPath:indexPath];
        [cell updateCheckImage:userVo.bChecked];
    }
    
    if (self.nChooseUserNumber > 0)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    //更新数量文本
    [self updateChoosedNumText];
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.txtSearch resignFirstResponder];
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
- (IBAction)textDidChange
{
    //文字改变,要进行实时搜索
    self.strSearchText = self.txtSearch.text;
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
        _tableViewSearchResult.mj_footer = nil;
        
        [self doUserSearch];
    }
}

//UITextFieldDelegate
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
        _tableViewSearchResult.mj_footer = refreshFooter;
        [self loadAllUserSearchResult:YES];
    }
}

//分页搜索(全部用户)
-(void)loadAllUserSearchResult:(BOOL)bRefreshing
{
    if (bRefreshing)
    {
        //下拉刷新
        self.m_curPageNum = 1;
    }
    else
    {
        //上拖加载
    }
    
    [ServerProvider getAllUserListByPage:self.m_curPageNum andSearchText:self.strSearchText andPageSize:20 result:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryTemp = retInfo.data;
            if (bRefreshing)
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
            
            //是否所有加载完成
            if ([retInfo.data2 boolValue])
            {
                [self.tableViewSearchResult.mj_footer endRefreshingWithNoMoreData];
            }
            else
            {
                [self.tableViewSearchResult.mj_footer endRefreshing];
            }
            
            [self.tableViewSearchResult reloadData];
        }
        else
        {
            [self.tableViewSearchResult.mj_footer endRefreshing];
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//移除单个已选用户，通过ID迭代判断
-(void)removeUserFromChoosedList:(NSString*)strUserID
{
    for (int i=0; i<self.aryUserChoosed.count; i++)
    {
        UserVo *userVoTemp = [self.aryUserChoosed objectAtIndex:i];
        if ([userVoTemp.strUserID isEqualToString:strUserID])
        {
            [self.aryUserChoosed removeObject:userVoTemp];
            break;
        }
    }
}

@end
