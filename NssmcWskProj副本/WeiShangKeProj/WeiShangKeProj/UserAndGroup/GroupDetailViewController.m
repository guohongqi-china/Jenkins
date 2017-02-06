//
//  GroupDetailViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-10.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "GroupDetailViewController.h"
#import "UserVo.h"
#import "Utils.h"
#import "AddAndEditGroupViewController.h"
#import "GroupAndUserDao.h"

@interface GroupDetailViewController ()

@end

@implementation GroupDetailViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"RefreshGroupDetail" object:nil];
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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshGroupDetail:) name:@"RefreshGroupDetail" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData
{
    if(self.m_groupVo == nil && self.strGroupID != nil && self.strGroupID.length>0)
    {
        //重新更新数据，然后查找
        [self isHideActivity:NO];
        dispatch_async(dispatch_get_global_queue(0,0),^{
            [BusinessCommon updateServerGroupAndUserData];
            dispatch_async(dispatch_get_main_queue(), ^{
                GroupAndUserDao *groupAndUserDao = [[GroupAndUserDao alloc]init];
                self.m_groupVo = [groupAndUserDao getGroupVoByID:self.strGroupID];
                [self refreshView];
                [self isHideActivity:YES];
            });
        });
    }
    else
    {
        [self refreshView];
    }
}

- (void)initView
{
    [self setTopNavBarTitle:self.m_groupVo.strGroupName];
    
    UIButton *btnBack = [Utils leftButtonWithTitle:[Common localStr:@"Common_Return" value:@" 返回"] frame:[Utils getNavLeftBtnFrame:CGSizeMake(106,76)] target:self action:@selector(doBack)];
    [self setLeftBarButton:btnBack];
    
    if (self.m_groupVo.nGroupType == 1)
    {
        UIButton *addTeamItem = [Utils buttonWithTitle:[Common localStr:@"Common_Edit" value:@"编辑"] frame:[Utils getNavRightBtnFrame:CGSizeMake(106,76)] target:self action:@selector(doEditGroup)];
        [self setRightBarButton:addTeamItem];
    }
    
    //每行高度41
    self.viewScrollGroup = [[UIScrollView alloc]initWithFrame:CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT)];
    self.viewScrollGroup.backgroundColor = COLOR(255, 255, 255, 1.0);
    self.viewScrollGroup.delegate = self;
    [self.view addSubview:self.viewScrollGroup];
    
    //0.background image
    CGFloat fHeight = 10;
    self.imgViewTopBK = [[UIImageView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 5*41)];
    self.imgViewTopBK.image = [[UIImage imageNamed:@"groupedit_cell_bk"] stretchableImageWithLeftCapWidth:160 topCapHeight:20];
    [self.viewScrollGroup addSubview:self.imgViewTopBK];
    
    //1.群组名称
    self.lblGroupName = [[UILabel alloc]initWithFrame:CGRectMake(20, fHeight+10, 280, 20)];
    self.lblGroupName.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    self.lblGroupName.text = [NSString stringWithFormat:@"%@　%@",[Common localStr:@"UserGroup_GroupName" value:@"群名称"],self.m_groupVo.strGroupName==nil?@"":self.m_groupVo.strGroupName];
    self.lblGroupName.textColor = COLOR(51, 51, 51, 1.0);
    [self.viewScrollGroup addSubview:self.lblGroupName];
    
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight+40, 300, 0.5)];
    viewLine.tag = 1001;
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.viewScrollGroup addSubview:viewLine];
    fHeight += 41;
    
    //2.群外人可以看到本群
    self.lblAllowSee = [[UILabel alloc]initWithFrame:CGRectMake(20, fHeight+10, 250, 20)];
    self.lblAllowSee.text = [Common localStr:@"UserGroup_GroupCanSee" value:@"权限　群外人可以看到本群"];
    self.lblAllowSee.textColor = COLOR(51, 51, 51, 1.0);
    self.lblAllowSee.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [self.viewScrollGroup addSubview:self.lblAllowSee];
    
    self.switchAllowSee = [[UISwitch alloc]initWithFrame:CGRectMake(253-10, fHeight+(41-31)/2,70, 20)];
    self.switchAllowSee.center = CGPointMake(300-self.switchAllowSee.frame.size.width/2, self.switchAllowSee.center.y);
    self.switchAllowSee.on = (self.m_groupVo.nAllowSee==1)?YES:NO;
    self.switchAllowSee.userInteractionEnabled = NO;
    [self.viewScrollGroup addSubview:self.switchAllowSee];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight+40, 300, 0.5)];
    viewLine.tag = 1002;
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.viewScrollGroup addSubview:viewLine];
    fHeight += 41;
    
    //3.群外人可以自由加入本群
    self.lblAllowJoin = [[UILabel alloc]initWithFrame:CGRectMake(20, fHeight+10, 235, 20)];
    self.lblAllowJoin.text = [Common localStr:@"UserGroup_GroupCanJoin" value:@"　　　群外人可以自由加入本群"];
    self.lblAllowJoin.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    self.lblAllowJoin.textColor = COLOR(51, 51, 51, 1.0);
    [self.viewScrollGroup addSubview:self.lblAllowJoin];
    
    self.switchAllowJoin = [[UISwitch alloc]initWithFrame:CGRectMake(253-10, fHeight+(41-31)/2,70, 31)];
    self.switchAllowJoin.center = CGPointMake(300-self.switchAllowJoin.frame.size.width/2, self.switchAllowJoin.center.y);
    self.switchAllowJoin.on = (self.m_groupVo.nAllowJoin==1)?YES:NO;
    self.switchAllowJoin.userInteractionEnabled = NO;
    [self.viewScrollGroup addSubview:self.switchAllowJoin];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight+40, 300, 0.5)];
    viewLine.tag = 1003;
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.viewScrollGroup addSubview:viewLine];
    fHeight += 41;

    //4.群主
    self.lblGroupOwner = [[UILabel alloc]initWithFrame:CGRectMake(20, fHeight+10, 250, 20)];
    self.lblGroupOwner.text = [NSString stringWithFormat:@"%@　　%@",[Common localStr:@"UserGroup_GroupOwner" value:@"群主"],(self.m_groupVo.strCreatorName == nil)?@"":self.m_groupVo.strCreatorName];
    self.lblGroupOwner.textColor = COLOR(51, 51, 51, 1.0);
    self.lblGroupOwner.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [self.viewScrollGroup addSubview:self.lblGroupOwner];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight+40, 300, 0.5)];
    viewLine.tag = 1004;
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.viewScrollGroup addSubview:viewLine];
    fHeight += 41;
    
    //5.群成员
    self.lblMemSumNum = [[UILabel alloc]initWithFrame:CGRectMake(20, fHeight+10, 250, 20)];
    self.lblMemSumNum.text = [NSString stringWithFormat:@"%@　%lu %@",[Common localStr:@"UserGroup_GroupMem" value:@"群成员"],(unsigned long)self.m_groupVo.aryMemberVo.count,[Common localStr:@"UserGroup_Person" value:@"人"]];
    self.lblMemSumNum.textColor = COLOR(51, 51, 51, 1.0);
    self.lblMemSumNum.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [self.viewScrollGroup addSubview:self.lblMemSumNum];
    fHeight += 41;
    
    //6.成员
    fHeight += 10;
    self.imgViewColleagueBK = [[UIImageView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 41)];
    self.imgViewColleagueBK.image = [[UIImage imageNamed:@"groupedit_cell_bk"] stretchableImageWithLeftCapWidth:160 topCapHeight:20];
    [self.viewScrollGroup addSubview:self.imgViewColleagueBK];
    
    self.imgViewColleague = [[UIImageView alloc]initWithFrame:CGRectMake(20, fHeight+8, 25, 25)];
    self.imgViewColleague.image = [UIImage imageNamed:@"group_colleague_icon"];
    [self.viewScrollGroup addSubview:self.imgViewColleague];
    
    self.lblColleague = [[UILabel alloc]initWithFrame:CGRectMake(60, fHeight+10, 140, 20)];
    self.lblColleague.text = [Common localStr:@"UserGroup_Member" value:@"成员"];
    self.lblColleague.textColor = COLOR(51, 51, 51, 1.0);
    self.lblColleague.font = [UIFont fontWithName:@"Helvetica" size:(15.0)];
    [self.viewScrollGroup addSubview:self.lblColleague];
    
    self.lblColleagueNum = [[UILabel alloc]initWithFrame:CGRectMake(166, fHeight+(11), 120, (20))];
    self.lblColleagueNum.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)self.m_groupVo.aryMemberVo.count,[Common localStr:@"UserGroup_Person" value:@"人"]];
    self.lblColleagueNum.textAlignment = NSTextAlignmentRight;
    self.lblColleagueNum.font = [UIFont fontWithName:@"Helvetica" size:(16.0)];
    self.lblColleagueNum.textColor = COLOR(51, 51, 51, 1.0);
    [self.viewScrollGroup addSubview:self.lblColleagueNum];
    
    self.imgViewColleagueArrow = [[UIImageView alloc]initWithFrame:CGRectMake(285, fHeight+((41)-13)/2, 13, 13)];
    self.imgViewColleagueArrow.image = [[UIImage imageNamed:@"cell_right_arrow"] stretchableImageWithLeftCapWidth:150.5 topCapHeight:15];
    [self.viewScrollGroup addSubview:self.imgViewColleagueArrow];
    
    self.btnColleague = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnColleague addTarget:self action:@selector(viewGroupMembers:) forControlEvents:UIControlEventTouchUpInside];
    self.btnColleague.frame = CGRectMake(11, fHeight, 298, (43.0)-3);
    [self.btnColleague setBackgroundImage:[Common getImageWithColor:COLOR(150, 150, 150, 0.4)] forState:UIControlStateHighlighted];
    [self.btnColleague.layer setBorderWidth:1.0];
    [self.btnColleague.layer setCornerRadius:3];
    self.btnColleague.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.btnColleague.layer setMasksToBounds:YES];
    [self.viewScrollGroup addSubview:self.btnColleague];
    fHeight += (41);
    
    //line
    fHeight += 30;
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, 320, 0.5)];
    viewLine.tag = 1005;
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.viewScrollGroup addSubview:viewLine];
    fHeight += 7.5;
    
    //转让按钮
    self.btnTransferGroup = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnTransferGroup setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnTransferGroup.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0]];
    [self.btnTransferGroup setBackgroundImage:[UIImage imageNamed:@"btn_group_action"] forState:UIControlStateNormal];
    [self.btnTransferGroup setTitle:[Common localStr:@"UserGroup_TransferGroup" value:@"转让群组"] forState:UIControlStateNormal];
    [self.btnTransferGroup addTarget:self action:@selector(doGroupAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewScrollGroup addSubview:self.btnTransferGroup];
    
    //解散按钮
    self.btnDismissGroup = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnDismissGroup setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnDismissGroup.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0]];
    [self.btnDismissGroup setBackgroundImage:[UIImage imageNamed:@"btn_group_action"] forState:UIControlStateNormal];
    [self.btnDismissGroup setTitle:[Common localStr:@"UserGroup_DismissGroup" value:@"解散群组"] forState:UIControlStateNormal];
    [self.btnDismissGroup addTarget:self action:@selector(doGroupAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewScrollGroup addSubview:self.btnDismissGroup];

    //退出按钮
    self.btnExit = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnExit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnExit.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0]];
    [self.btnExit setBackgroundImage:[UIImage imageNamed:@"btn_group_action"] forState:UIControlStateNormal];
    [self.btnExit setTitle:[Common localStr:@"UserGroup_ExitGroup" value:@"退出群组"] forState:UIControlStateNormal];
    [self.btnExit addTarget:self action:@selector(doGroupAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewScrollGroup addSubview:self.btnExit];
    
    //加入按钮
    self.btnJoin = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnJoin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnJoin.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0]];
    [self.btnJoin setBackgroundImage:[UIImage imageNamed:@"btn_group_action"] forState:UIControlStateNormal];
    [self.btnJoin setTitle:[Common localStr:@"UserGroup_JoinGroup" value:@"加入群组"] forState:UIControlStateNormal];
    [self.btnJoin addTarget:self action:@selector(doGroupAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewScrollGroup addSubview:self.btnJoin];
    
    //8.相关按钮
    if (self.m_groupVo.nGroupType == 1)
    {
        //本人是群主 (转让和解散群组)
        fHeight += 10;
        self.btnTransferGroup.frame = CGRectMake((kScreenWidth-200)/2, fHeight, 200, 30);
        fHeight += 30;
        
        fHeight += 10;
        self.btnDismissGroup.frame = CGRectMake((kScreenWidth-200)/2, fHeight, 200, 30);
        fHeight += 30;
        
        //hide other button
        self.btnExit.frame = CGRectZero;
        self.btnJoin.frame = CGRectZero;
    }
    else if (self.m_groupVo.nGroupType == 2)
    {
        //已加入(退出群组)
        fHeight += 10;
        self.btnExit.frame = CGRectMake((kScreenWidth-200)/2, fHeight, 200, 30);
        fHeight += 30;
        
        self.btnTransferGroup.frame = CGRectZero;
        self.btnDismissGroup.frame = CGRectZero;
        self.btnJoin.frame = CGRectZero;
    }
    else if(self.m_groupVo.nAllowJoin == 1)
    {
        //未加入(加入群组)
        fHeight += 10;
        self.btnJoin.frame = CGRectMake((kScreenWidth-200)/2, fHeight, 200, 30);
        fHeight += 30;
        
        self.btnTransferGroup.frame = CGRectZero;
        self.btnDismissGroup.frame = CGRectZero;
        self.btnExit.frame = CGRectZero;
    }
    
    //fHeight += 252;
    fHeight += 100;
    [self.viewScrollGroup setContentSize:CGSizeMake(kScreenWidth, fHeight)];
}

//刷新视图数据
-(void)refreshView
{
    [self setTopNavBarTitle:self.m_groupVo.strGroupName];
    
    //编辑群组按钮
    if (self.m_groupVo.nGroupType == 1)
    {
        //管理者
        UIButton *addTeamItem = [Utils buttonWithTitle:[Common localStr:@"Common_Edit" value:@"编辑"] frame:[Utils getNavRightBtnFrame:CGSizeMake(106,76)] target:self action:@selector(doEditGroup)];
        [self setRightBarButton:addTeamItem];
    }
    
    //每行高度43
    self.viewScrollGroup.frame = CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT);
    
    //0.background image
    CGFloat fHeight = 10;
    
    //1.群组名称
    self.lblGroupName.frame = CGRectMake(20, fHeight+10, kScreenWidth-40, 20);
    self.lblGroupName.text = [NSString stringWithFormat:@"%@　%@",[Common localStr:@"UserGroup_GroupName" value:@"群名称"],(self.m_groupVo.strGroupName==nil)?@"":self.m_groupVo.strGroupName];
    
    UIView *viewLine = [self.view viewWithTag:1001];
    viewLine.frame = CGRectMake(10, fHeight+40, kScreenWidth-20, 0.5);
    fHeight += 41;
    
    //2.群外人可以看到本群
    self.lblAllowSee.frame = CGRectMake(20, fHeight+10, kScreenWidth-70, 20);
    
    self.switchAllowSee.frame = CGRectMake(253-10, fHeight+(41-31)/2,70, 20);
    if(iOSPlatform == 7)
    {
        self.switchAllowSee.center = CGPointMake(kScreenWidth-20-self.switchAllowSee.frame.size.width/2, self.switchAllowSee.center.y);
    }
    else
    {
        self.switchAllowSee.center = CGPointMake(kScreenWidth-10-self.switchAllowSee.frame.size.width/2, self.switchAllowSee.center.y+2);
    }
    self.switchAllowSee.on = (self.m_groupVo.nAllowSee==1)?YES:NO;
    
    viewLine = [self.view viewWithTag:1002];
    viewLine.frame = CGRectMake(10, fHeight+40, kScreenWidth-20, 0.5);
    fHeight += 41;
    
    //3.群外人可以自由加入本群
    if(self.m_groupVo.nAllowSee==1)
    {
        self.lblAllowJoin.frame = CGRectMake(20, fHeight+10, kScreenWidth-70, 20);
        
        self.switchAllowJoin.frame = CGRectMake(253-10, fHeight+(41-31)/2,70, 20);
        if(iOSPlatform == 7)
        {
            self.switchAllowJoin.center = CGPointMake(kScreenWidth-20-self.switchAllowJoin.frame.size.width/2, self.switchAllowJoin.center.y);
        }
        else
        {
            self.switchAllowJoin.center = CGPointMake(kScreenWidth-10-self.switchAllowJoin.frame.size.width/2, self.switchAllowJoin.center.y+2);
        }
        self.switchAllowJoin.on = (self.m_groupVo.nAllowJoin==1)?YES:NO;
        self.switchAllowJoin.hidden = NO;
        
        viewLine = [self.view viewWithTag:1003];
        viewLine.frame = CGRectMake(10, fHeight+40, kScreenWidth-20, 0.5);
        fHeight += 41;
    }
    else
    {
        self.lblAllowJoin.frame = CGRectZero;
        
        self.switchAllowJoin.hidden = YES;
        
        viewLine = [self.view viewWithTag:1003];
        viewLine.frame = CGRectZero;
    }
    
    //4.群主
    self.lblGroupOwner.frame = CGRectMake(20, fHeight+10, kScreenWidth-70, 20);
    self.lblGroupOwner.text = [NSString stringWithFormat:@"%@　　%@",[Common localStr:@"UserGroup_GroupOwner" value:@"群主"],(self.m_groupVo.strCreatorName == nil)?@"":self.m_groupVo.strCreatorName];
    
    viewLine = [self.view viewWithTag:1004];
    viewLine.frame = CGRectMake(10, fHeight+40, kScreenWidth-20, 0.5);
    fHeight += 41;
    
    //5.群成员
    self.lblMemSumNum.frame = CGRectMake(20, fHeight+10, kScreenWidth-70, 20);
    self.lblMemSumNum.text = [NSString stringWithFormat:@"%@　%lu %@",[Common localStr:@"UserGroup_GroupMem" value:@"群成员"],(unsigned long)self.m_groupVo.aryMemberVo.count,[Common localStr:@"UserGroup_Person" value:@"人"]];
    fHeight += 41;
    
    self.imgViewTopBK.frame = CGRectMake(0, 10, kScreenWidth, fHeight-10);
    
    //6.成员
    fHeight += 10;
    self.imgViewColleagueBK.frame = CGRectMake(0, fHeight, kScreenWidth, 41);
    
    self.imgViewColleague.frame = CGRectMake(15, fHeight+5, 30, 30);
    
    self.lblColleague.frame = CGRectMake(55, fHeight+10, 140, 20);
    
    self.lblColleagueNum.frame = CGRectMake(kScreenWidth-154, fHeight+(11), 120, (20));
    self.lblColleagueNum.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)self.m_groupVo.aryMemberVo.count,[Common localStr:@"UserGroup_Person" value:@"人"]];
    
    self.imgViewColleagueArrow.frame = CGRectMake(kScreenWidth-35, fHeight+((41)-13)/2, 13, 13);
    
    self.btnColleague.frame = CGRectMake(11, fHeight, kScreenWidth-22, (43.0)-3);
    fHeight += (41);
    
    //line
    fHeight += 30;
    viewLine = [self.view viewWithTag:1005];
    viewLine.frame = CGRectMake(0, fHeight, kScreenWidth, 0.5);
    fHeight += 7.5;
    
    //8.相关按钮
    if (self.m_groupVo.nGroupType == 1)
    {
        //本人是群主 (转让和解散群组)
        fHeight += 10;
        self.btnTransferGroup.frame = CGRectMake((kScreenWidth-200)/2, fHeight, 200, 30);
        fHeight += 30;
        
        fHeight += 10;
        self.btnDismissGroup.frame = CGRectMake((kScreenWidth-200)/2, fHeight,200, 30);
        fHeight += 30;
        
        //hide other button
        self.btnExit.frame = CGRectZero;
        self.btnJoin.frame = CGRectZero;
    }
    else if (self.m_groupVo.nGroupType == 2)
    {
        //已加入(退出群组)
        fHeight += 10;
        self.btnExit.frame = CGRectMake((kScreenWidth-200)/2, fHeight, 200, 30);
        fHeight += 30;
                
        self.btnTransferGroup.frame = CGRectZero;
        self.btnDismissGroup.frame = CGRectZero;
        self.btnJoin.frame = CGRectZero;
    }
    else if(self.m_groupVo.nAllowJoin == 1)
    {
        //未加入(加入群组)，并且是允许加入
        fHeight += 10;
        self.btnJoin.frame = CGRectMake((kScreenWidth-200)/2, fHeight, 200, 30);
        fHeight += 30;
        
        self.btnTransferGroup.frame = CGRectZero;
        self.btnDismissGroup.frame = CGRectZero;
        self.btnExit.frame = CGRectZero;
    }
    
    fHeight += 252;
    [self.viewScrollGroup setContentSize:CGSizeMake(kScreenWidth, fHeight)];
}

-(void)doEditGroup
{
    AddAndEditGroupViewController *addAndEditGroupViewController = [[AddAndEditGroupViewController alloc]init];
    addAndEditGroupViewController.groupPageName = GroupEditPage;
    addAndEditGroupViewController.m_groupVo = self.m_groupVo;
    [self.navigationController pushViewController:addAndEditGroupViewController animated:YES];
}

-(void)viewGroupMembers:(UIButton*)sender
{
    CommonUserListViewController *userListViewController = [[CommonUserListViewController alloc]init];
    userListViewController.commonUserListType = CommonUserListChatType;
    userListViewController.aryGroupMemData = self.m_groupVo.aryMemberVo;
    [self.navigationController pushViewController:userListViewController animated:YES];
}

-(void)doGroupAction:(UIButton*)sender
{
    if (sender == self.btnTransferGroup)
    {
        //转让群组
        CommonUserListViewController *commonUserListViewController = [[CommonUserListViewController alloc]init];
        commonUserListViewController.delegate = self;
        commonUserListViewController.commonUserListType = CommonTransferGroupType;
        commonUserListViewController.aryGroupMemData = self.m_groupVo.aryMemberVo;
        [self.navigationController pushViewController:commonUserListViewController animated:YES];
    }
    else if (sender == self.btnDismissGroup)
    {
        //解散群组
        if ([Common ask:[Common localStr:@"UserGroup_DismissAsk" value:@"您确定要解散该群组吗？"]])
        {
            [self isHideActivity:NO];
            dispatch_async(dispatch_get_global_queue(0,0),^{
                ServerReturnInfo *retInfo = [ServerProvider dismissGroup:self.m_groupVo.strGroupID];
                if (retInfo.bSuccess)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.bRefreshGroupList = YES;
                        [self doBack];
                        [Common tipAlert:[Common localStr:@"UserGroup_DismissSuccess" value:@"解散群组成功"]];
                        [self isHideActivity:YES];
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self isHideActivity:YES];
                        [Common tipAlert:retInfo.strErrorMsg];
                    });
                }
            });
        }
    }
    else if (sender == self.btnExit)
    {
        //退出群组
        if ([Common ask:[Common localStr:@"UserGroup_ExitAsk" value:@"您确定要退出该群组吗？"]])
        {
            [self isHideActivity:NO];
            dispatch_async(dispatch_get_global_queue(0,0),^{
                ServerReturnInfo *retInfo = [ServerProvider exitGroup:self.m_groupVo.strGroupID andUserID:[Common getCurrentUserVo].strUserID];
                if (retInfo.bSuccess)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //update self to data
                        self.m_groupVo.nGroupType = 3;
                        self.m_groupVo.nIsGroupMember = 0;
                        
                        for (UserVo *userVo in self.m_groupVo.aryMemberVo)
                        {
                            if ([userVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID])
                            {
                                [self.m_groupVo.aryMemberVo removeObject:userVo];
                                break;
                            }
                        }
                        
                        //
                        [self refreshView];
                        self.bRefreshGroupList = YES;
                        [Common tipAlert:[Common localStr:@"UserGroup_ExitSuccess" value:@"退出群组成功"]];
                        [self isHideActivity:YES];
                    });
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self isHideActivity:YES];
                        [Common tipAlert:retInfo.strErrorMsg];
                    });
                }
            });
        }
    }
    else if (sender == self.btnJoin)
    {
        //加入群组
        [self isHideActivity:NO];
        dispatch_async(dispatch_get_global_queue(0,0),^{
            //do thread work
            ServerReturnInfo *retInfo = [ServerProvider joinGroup:self.m_groupVo.strGroupID andUserID:[Common getCurrentUserVo].strUserID];
            if (retInfo.bSuccess)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //update self to data
                    self.m_groupVo.nGroupType = 2;
                    self.m_groupVo.nIsGroupMember = 1;
                    UserVo *userVo = [[UserVo alloc]init];
                    userVo.strUserID = [Common getCurrentUserVo].strUserID;
                    userVo.strUserName = [Common getCurrentUserVo].strUserName;
                    [self.m_groupVo.aryMemberVo addObject:userVo];
                    
                    //
                    [self isHideActivity:YES];
                    [self refreshView];
                    self.bRefreshGroupList = YES;
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
}

-(void)doBack
{
    if (self.bRefreshGroupList)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshGroupList" object:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refreshGroupDetail:(NSNotification*)notification
{
    //after edit refresh group
    NSMutableDictionary* dicNotify = [notification object];
    GroupVo *groupVo = (GroupVo *)[dicNotify objectForKey:@"GroupVo"];
    self.m_groupVo = groupVo;
    [self refreshView];
    
    self.bRefreshGroupList = YES;
}

#pragma mark -  CommonUserListDelegate
-(void)completeChooseUserForTransferGroup:(UserVo*)userVo
{
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        ServerReturnInfo *retInfo = [ServerProvider transferGroup:self.m_groupVo.strGroupID andUserID:userVo.strUserID];
        if (retInfo.bSuccess)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self isHideActivity:YES];
                self.bRefreshGroupList = YES;
                //assign data
                self.m_groupVo.strCreatorID = userVo.strUserID;
                self.m_groupVo.strCreatorName = userVo.strUserName;
                self.m_groupVo.nGroupType = 2;
                [self refreshView];
                [Common tipAlert:[Common localStr:@"UserGroup_TransferSuccess" value:@"转让群组成功"]];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self isHideActivity:YES];
                [Common tipAlert:retInfo.strErrorMsg];
            });
        }
    });
}

@end
