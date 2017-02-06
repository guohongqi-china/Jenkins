//
//  AddAndEditGroupViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-9.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "AddAndEditGroupViewController.h"
#import "Utils.h"

@interface AddAndEditGroupViewController ()

@end

@implementation AddAndEditGroupViewController

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
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *btnBack = [Utils leftButtonWithTitle:[Common localStr:@"Common_Return" value:@" 返回"] frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:@selector(doBack)];
    [self setLeftBarButton:btnBack];
    self.bRefreshGroupList = NO;
    
    //新建群组按钮
    if (self.groupPageName == GroupAddPage)
    {
        self.m_groupVo = [[GroupVo alloc]init];
        self.m_groupVo.nAllowSee = 1;
        self.m_groupVo.nAllowJoin = 1;
    }
    else
    {
        self.aryChooseUser = self.m_groupVo.aryMemberVo;
    }
    [self initView];
    [self refreshView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doBack
{
    if (self.bRefreshGroupList)
    {
        if (self.groupPageName == GroupEditPage)
        {
            NSMutableDictionary *dicNotify = [[NSMutableDictionary alloc]init];
            [dicNotify setObject:self.m_groupVo forKey:@"GroupVo"];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshGroupDetail" object:dicNotify];
        }
        else if(self.groupPageName == GroupAddPage)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshGroupList" object:nil];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initView
{
    if (self.groupPageName == GroupAddPage)
    {
        //add
        [self setTopNavBarTitle:[Common localStr:@"UserGroup_CreateGroup" value:@"创建群组"]];
    }
    else
    {
        //edit
        [self setTopNavBarTitle:[Common localStr:@"UserGroup_EditGroup" value:@"编辑群组"]];
    }
    UIButton *addTeamItem = [Utils buttonWithTitle:[Common localStr:@"Common_Done" value:@"完成"] frame:[Utils getNavRightBtnFrame:CGSizeMake(106,76)] target:self action:@selector(commitGroup)];
    [self setRightBarButton:addTeamItem];
    
    //每行高度41
    self.viewScrollGroup = [[UIScrollView alloc]initWithFrame:CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT)];
    self.viewScrollGroup.backgroundColor = COLOR(255, 255, 255, 1.0);
    self.viewScrollGroup.delegate = self;
    [self.view addSubview:self.viewScrollGroup];
    
    //0.background image
    self.imgViewTopBK = [[UIImageView alloc]init];
    self.imgViewTopBK.image = [[UIImage imageNamed:@"groupedit_cell_bk"] stretchableImageWithLeftCapWidth:160 topCapHeight:20];
    [self.viewScrollGroup addSubview:self.imgViewTopBK];
    
    //1.群组名称
    self.lblGroupName = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblGroupName.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    self.lblGroupName.text = [Common localStr:@"UserGroup_GroupName" value:@"群名称"];
    self.lblGroupName.textColor = COLOR(51, 51, 51, 1.0);
    [self.viewScrollGroup addSubview:self.lblGroupName];
    
    self.txtGroupName = [[UITextField alloc]initWithFrame:CGRectZero];
    self.txtGroupName.placeholder = [Common localStr:@"UserGroup_GroupName" value:@"群名称"];
    self.txtGroupName.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    self.txtGroupName.delegate = self;
    [self.viewScrollGroup addSubview:self.txtGroupName];
    
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectZero];
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    viewLine.tag = 1001;
    [self.viewScrollGroup addSubview:viewLine];
    
    //2.群外人可以看到本群
    self.lblAllowSee = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblAllowSee.text = [Common localStr:@"UserGroup_GroupCanSee" value:@"权限　群外人可以看到本群"];
    self.lblAllowSee.textColor = COLOR(51, 51, 51, 1.0);
    self.lblAllowSee.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [self.viewScrollGroup addSubview:self.lblAllowSee];
    
    self.switchAllowSee = [[UISwitch alloc]initWithFrame:CGRectZero];
    self.switchAllowSee.on = YES;
    [self.switchAllowSee addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.viewScrollGroup addSubview:self.switchAllowSee];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectZero];
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    viewLine.tag = 1002;
    [self.viewScrollGroup addSubview:viewLine];
    
    //3.群外人可以自由加入本群
    self.lblAllowJoin = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblAllowJoin.text = [Common localStr:@"UserGroup_GroupCanJoin" value:@"　　　群外人可以自由加入本群"];
    self.lblAllowJoin.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    self.lblAllowJoin.textColor = COLOR(51, 51, 51, 1.0);
    [self.viewScrollGroup addSubview:self.lblAllowJoin];
    
    self.switchAllowJoin = [[UISwitch alloc]initWithFrame:CGRectZero];
    self.switchAllowJoin.on = YES;
    [self.viewScrollGroup addSubview:self.switchAllowJoin];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectZero];
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    viewLine.tag = 1003;
    [self.viewScrollGroup addSubview:viewLine];
    
    //4.群成员
    self.lblMemSumNum = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblMemSumNum.text = [NSString stringWithFormat:@"%@　0 %@",[Common localStr:@"UserGroup_GroupMem" value:@"群成员"],[Common localStr:@"UserGroup_Person" value:@"人"]];
    self.lblMemSumNum.textColor = COLOR(51, 51, 51, 1.0);
    self.lblMemSumNum.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    [self.viewScrollGroup addSubview:self.lblMemSumNum];
    
    //5.成员
    self.imgViewColleagueBK = [[UIImageView alloc]initWithFrame:CGRectZero];
    self.imgViewColleagueBK.image = [[UIImage imageNamed:@"groupedit_cell_bk"] stretchableImageWithLeftCapWidth:160 topCapHeight:20];
    [self.viewScrollGroup addSubview:self.imgViewColleagueBK];
    
    self.imgViewColleague = [[UIImageView alloc]initWithFrame:CGRectZero];
    self.imgViewColleague.image = [UIImage imageNamed:@"group_colleague_icon"];
    [self.viewScrollGroup addSubview:self.imgViewColleague];
    
    self.lblColleague = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblColleague.text = [Common localStr:@"UserGroup_Member" value:@"成员"];
    self.lblColleague.textColor = COLOR(51, 51, 51, 1.0);
    self.lblColleague.font = [UIFont fontWithName:@"Helvetica" size:(15.0)];
    [self.viewScrollGroup addSubview:self.lblColleague];
    
    self.lblColleagueNum = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblColleagueNum.text = [NSString stringWithFormat:@"0 %@",[Common localStr:@"UserGroup_Person" value:@"人"]];
    self.lblColleagueNum.textAlignment = NSTextAlignmentRight;
    self.lblColleagueNum.font = [UIFont fontWithName:@"Helvetica" size:(15.0)];
    self.lblColleagueNum.textColor = COLOR(51, 51, 51, 1.0);
    [self.viewScrollGroup addSubview:self.lblColleagueNum];
    
    self.imgViewColleagueArrow = [[UIImageView alloc]initWithFrame:CGRectZero];
    self.imgViewColleagueArrow.image = [[UIImage imageNamed:@"cell_right_arrow"] stretchableImageWithLeftCapWidth:150.5 topCapHeight:15];
    [self.viewScrollGroup addSubview:self.imgViewColleagueArrow];
    
    self.btnColleague = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnColleague addTarget:self action:@selector(chooseGroupMembers:) forControlEvents:UIControlEventTouchUpInside];
    self.btnColleague.frame = CGRectZero;
    [self.btnColleague setBackgroundImage:[Common getImageWithColor:COLOR(150, 150, 150, 0.4)] forState:UIControlStateHighlighted];
    [self.btnColleague.layer setBorderWidth:1.0];
    [self.btnColleague.layer setCornerRadius:3];
    self.btnColleague.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.btnColleague.layer setMasksToBounds:YES];
    [self.viewScrollGroup addSubview:self.btnColleague];
}

//提交群组到服务器(增加或编辑)
- (void)commitGroup
{
    //群组名称验证
    self.m_groupVo.strGroupName = self.txtGroupName.text;
    if (self.m_groupVo.strGroupName == nil || [self.m_groupVo.strGroupName length] <= 0)
    {
        [Common tipAlert:[Common localStr:@"UserGroup_GroupNameEmpty" value:@"群组名称不能为空"]];
        return;
    }
    
    //群外人可以看到本群
    self.m_groupVo.nAllowSee = self.switchAllowSee.on?1:0;
    
    //群外人可以自由加入本群
    self.m_groupVo.nAllowJoin = self.switchAllowJoin.on?1:0;
    
    //群组成员可以为空，默认自己
    if (self.aryChooseUser != nil && self.aryChooseUser.count>0)
    {
        self.m_groupVo.aryMemberVo = self.aryChooseUser;
    }
    
    [self isHideActivity:NO];
    if (self.groupPageName == GroupAddPage)
    {
        //增加
        dispatch_async(dispatch_get_global_queue(0,0),^{
            //do thread work
            ServerReturnInfo *retInfo = [ServerProvider createGroup:self.m_groupVo];
            if (retInfo.bSuccess)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self isHideActivity:YES];
                    [self clearValue];
                    self.bRefreshGroupList = YES;
                    [Common tipAlert:[Common localStr:@"UserGroup_CreateGroupTip" value:@"创建群组成功"]];
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
    else if (self.groupPageName == GroupEditPage)
    {
        //编辑
        dispatch_async(dispatch_get_global_queue(0,0),^{
            //do thread work
            ServerReturnInfo *retInfo = [ServerProvider editGroup:self.m_groupVo];
            if (retInfo.bSuccess)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self isHideActivity:YES];
                    self.bRefreshGroupList = YES;
                    [Common tipAlert:[Common localStr:@"UserGroup_EditGroupTip" value:@"修改群组成功"]];
                    [self doBack];
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

//选择成员
- (void)chooseGroupMembers:(UIButton*)sender
{
    if (sender == self.btnColleague)
    {
        //colleague
        if (self.chooseUserViewController == nil)
        {
            self.chooseUserViewController = [[ChooseUserViewController alloc] init];
            self.chooseUserViewController.chooseUserType = GroupEditChooseUserType;
            self.chooseUserViewController.delegate = self;
        }
        if (self.groupPageName == GroupEditPage)
        {
            self.chooseUserViewController.strGroupCreateID = self.m_groupVo.strCreatorID;
        }
        //编辑群组 已选用户
        self.chooseUserViewController.aryUserPreChoosed = self.aryChooseUser;
        [self.navigationController pushViewController:self.chooseUserViewController animated:YES];
    }
    else
    {
        //out
    }
}

-(void)clearValue
{
    self.m_groupVo = [[GroupVo alloc]init];
    self.m_groupVo.nAllowSee = 1;
    self.m_groupVo.nAllowJoin = 1;
    
    self.txtGroupName.text = @"";
    
    self.switchAllowSee.on = YES;
    self.switchAllowJoin.on = YES;
    
    if (self.aryChooseUser != nil)
    {
        [self.aryChooseUser removeAllObjects];
    }
    self.lblMemSumNum.text = [NSString stringWithFormat:@"%@　0 %@",[Common localStr:@"UserGroup_GroupMem" value:@"群成员"],[Common localStr:@"UserGroup_Person" value:@"人"]];
    self.lblColleagueNum.text = [NSString stringWithFormat:@"0 %@",[Common localStr:@"UserGroup_Person" value:@"人"]];
    self.lblOutNum.text = [NSString stringWithFormat:@"0 %@",[Common localStr:@"UserGroup_Person" value:@"人"]];
    
    [self refreshView];
}

- (void)refreshView
{
    //每行高度41
    self.viewScrollGroup.frame = CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT);
    
    //0.background image
    CGFloat fHeight = 10;
    
    //1.群组名称
    self.lblGroupName.frame = CGRectMake(20, fHeight+10, 60, 20);
    
    self.txtGroupName.frame = CGRectMake(84, fHeight+11, kScreenWidth-110, 20);
    
    UIView *viewLine = [self.viewScrollGroup viewWithTag:1001];
    viewLine.frame = CGRectMake(10, fHeight+40, kScreenWidth-20, 0.5);
    fHeight += 41;
    
    //2.群外人可以看到本群
    self.lblAllowSee.frame = CGRectMake(20, fHeight+10, 235, 20);
    
    self.switchAllowSee.frame = CGRectMake(253-10, fHeight+(41-31)/2,70, 31);
    if(iOSPlatform == 7)
    {
        self.switchAllowSee.center = CGPointMake(kScreenWidth-20-self.switchAllowSee.frame.size.width/2, self.switchAllowSee.center.y);
    }
    else
    {
        self.switchAllowSee.center = CGPointMake(kScreenWidth-10-self.switchAllowSee.frame.size.width/2, self.switchAllowSee.center.y+2);
    }
    self.switchAllowSee.on = (self.m_groupVo.nAllowSee==1)?YES:NO;
    
    viewLine = [self.viewScrollGroup viewWithTag:1002];
    viewLine.frame = CGRectMake(10, fHeight+40, kScreenWidth-20, 0.5);
    fHeight += 41;
    
    //3.群外人可以自由加入本群
    if (self.m_groupVo.nAllowSee==1)
    {
        //show
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
        
        viewLine = [self.viewScrollGroup viewWithTag:1003];
        viewLine.frame = CGRectMake(10, fHeight+40, kScreenWidth-20, 0.5);
        fHeight += 41;
    }
    else
    {
        //hide
        self.lblAllowJoin.frame = CGRectZero;
        
        self.switchAllowJoin.frame = CGRectZero;
        self.switchAllowJoin.hidden = YES;
        
        viewLine = [self.viewScrollGroup viewWithTag:1003];
        viewLine.frame = CGRectZero;
    }
    
    //4.群成员
    self.lblMemSumNum.frame = CGRectMake(20, fHeight+10, kScreenWidth-70, 20);
    fHeight += 41;
    
    //bk
    self.imgViewTopBK.frame = CGRectMake(0, 10, kScreenWidth, fHeight-10);
    
    //5.成员
    fHeight += 10;
    self.imgViewColleagueBK.frame = CGRectMake(0, fHeight, kScreenWidth, 41);
    
    self.imgViewColleague.frame = CGRectMake(20, fHeight+8, 25, 25);
    
    self.lblColleague.frame = CGRectMake(60, fHeight+10, 140, 20);
    
    self.lblColleagueNum.frame = CGRectMake(kScreenWidth-154, fHeight+(11), 120, (20));
    
    self.imgViewColleagueArrow.frame = CGRectMake(kScreenWidth-35, fHeight+((41)-13)/2, 13, 13);
    
    self.btnColleague.frame = CGRectMake(11, fHeight, kScreenWidth-22, (43.0)-3);
    
    fHeight += 41;
    
    fHeight += 252;
    fHeight += 10;
    [self.viewScrollGroup setContentSize:CGSizeMake(kScreenWidth, fHeight)];
}

-(void)switchAction:(UISwitch*)sender
{
    if ([sender isOn])
    {
        self.m_groupVo.nAllowSee = 1;
        self.m_groupVo.nAllowJoin = 1;
    }
    else
    {
        self.m_groupVo.nAllowSee = 0;
        self.m_groupVo.nAllowJoin = 0;
    }
    [self refreshView];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - ChooseUserViewControllerDelegate(完成成员选择)
-(void)completeChooseUserAction:(NSMutableArray*)aryChoosedUser
{
    self.aryChooseUser = aryChoosedUser;
    self.lblColleagueNum.text = [NSString stringWithFormat:@"%lu %@",(unsigned long)self.aryChooseUser.count,[Common localStr:@"UserGroup_Person" value:@"人"]];
    self.lblMemSumNum.text = [NSString stringWithFormat:@"%@　　%lu %@",[Common localStr:@"UserGroup_GroupMem" value:@"群成员"],(unsigned long)self.aryChooseUser.count,[Common localStr:@"UserGroup_Person" value:@"人"]];
}

@end
