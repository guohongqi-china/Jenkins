//
//  PublishVoteViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-6-10.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "PublishVoteViewController.h"
#import "Utils.h"
#import "UIImage+UIImageScale.h"
#import "ResizeImage.h"
#import "UIImage+Extras.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "KTPhotoScrollViewController.h"
#import "SDWebImageDataSource.h"
#import "ReceiverVo.h"
#import "UserVo.h"
#import "AttachmentVo.h"

@interface PublishVoteViewController ()

@end

@implementation PublishVoteViewController

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
    [self setTopNavBarTitle:@"发投票"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doBack) name:@"PublishEnterType" object:nil];
    
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData
{
    self.bShowCCAndBCC = NO;
    self.aryReceiverList = [[NSMutableArray alloc] init];
    self.aryCCList = [[NSMutableArray alloc] init];
    self.aryBCList = [[NSMutableArray alloc] init];
    
    self.m_messageVo = [[MessageVo alloc]init];
    self.m_messageVo.aryAttachmentList = [NSMutableArray array];
    self.m_messageVo.aryImageList = [NSMutableArray array];
    
    self.dicOffsetY = [[NSMutableDictionary alloc]init];
    
    //vote object
    self.voteVo = [[VoteVo alloc]init];
    
    self.nOptionId = 100;
    self.voteVo.aryVoteOption = [NSMutableArray array];
    VoteOptionVo *voteOptionVo = [[VoteOptionVo alloc]init];
    voteOptionVo.nOptionId = self.nOptionId;
    [self.voteVo.aryVoteOption addObject:voteOptionVo];
    
    self.nOptionId += 1;
    voteOptionVo = [[VoteOptionVo alloc]init];
    voteOptionVo.nOptionId = self.nOptionId;
    [self.voteVo.aryVoteOption addObject:voteOptionVo];
    
    //注册键盘侦听事件
    [self registerForKeyboardNotifications];
    
    //初始化选中的数据
    [self initChooseData];
}

-(void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    //左边按钮
    UIButton *btnCancel = [Utils buttonWithTitle:@"取消" frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:nil];
    [btnCancel addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    [self setLeftBarButton:btnCancel];
    
    //右边按钮
    UIButton *btnSend = [Utils buttonWithTitle:@"发送" frame:[Utils getNavRightBtnFrame:CGSizeMake(100,76)] target:self action:nil];
    [btnSend addTarget:self action:@selector(doSendMsg) forControlEvents:UIControlEventTouchUpInside];
    [self setRightBarButton:btnSend];
    
    /////////////////////////////////////////////////////
    //scrollview
    self.scrollViewPublic = [[UIScrollView alloc]initWithFrame:CGRectZero];
    self.scrollViewPublic.backgroundColor = COLOR(249,249,249,1.0);
    self.scrollViewPublic.delegate = self;
    self.scrollViewPublic.autoresizingMask = NO;
    self.scrollViewPublic.clipsToBounds = YES;
    [self.view addSubview:self.scrollViewPublic];
    
    //receiver
    self.viewReceiver = [[UIView alloc]initWithFrame:CGRectZero];
    [self.scrollViewPublic addSubview:self.viewReceiver];
    
    self.imgViewArrowIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"receiver_icon_right"]];
    [self.viewReceiver addSubview:self.imgViewArrowIcon];
    
    self.lblReceiverTitle = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblReceiverTitle.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.lblReceiverTitle.text = @"收件人:";
    self.lblReceiverTitle.textColor = COLOR(153, 153, 153, 1.0);
    self.lblReceiverTitle.backgroundColor = [UIColor clearColor];
    [self.viewReceiver addSubview:self.lblReceiverTitle];
    
    self.lblReceiverName = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblReceiverName.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.lblReceiverName.textColor = COLOR(153, 153, 153, 1.0);
    self.lblReceiverName.backgroundColor = [UIColor clearColor];
    [self.viewReceiver addSubview:self.lblReceiverName];
    
    self.btnAddArrowIcon = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnAddArrowIcon.frame = CGRectZero;
    [self.btnAddArrowIcon addTarget:self action:@selector(showCarbonAndBlindCopy) forControlEvents:UIControlEventTouchUpInside];
    [self.viewReceiver addSubview:self.btnAddArrowIcon];
    
    self.btnAddReceiver = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnAddReceiver.frame = CGRectZero;
    [self.btnAddReceiver setImage:[UIImage imageNamed:@"btn_add_receiver"] forState:UIControlStateNormal];
    [self.btnAddReceiver addTarget:self action:@selector(addReceiver:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewReceiver addSubview:self.btnAddReceiver];
    
    self.viewLineReceiver = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewLineReceiver.backgroundColor = COLOR(183, 183, 183, 1.0);
    [self.viewReceiver addSubview:self.viewLineReceiver];
    
    //CC
    self.viewCC = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewCC.clipsToBounds = YES;
    [self.scrollViewPublic addSubview:self.viewCC];
    
    self.lblCCTitle = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblCCTitle.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.lblCCTitle.text = @"抄送:";
    self.lblCCTitle.textColor = COLOR(153, 153, 153, 1.0);
    self.lblCCTitle.backgroundColor = [UIColor clearColor];
    [self.viewCC addSubview:self.lblCCTitle];
    
    self.lblCCName = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblCCName.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.lblCCName.textColor = COLOR(153, 153, 153, 1.0);
    self.lblCCName.backgroundColor = [UIColor clearColor];
    [self.viewCC addSubview:self.lblCCName];
    
    self.btnAddCC = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnAddCC.frame = CGRectZero;
    [self.btnAddCC setImage:[UIImage imageNamed:@"btn_add_receiver"] forState:UIControlStateNormal];
    [self.btnAddCC addTarget:self action:@selector(addReceiver:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewCC addSubview:self.btnAddCC];
    
    self.viewLineCC = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewLineCC.backgroundColor = COLOR(183, 183, 183, 1.0);
    [self.viewCC addSubview:self.viewLineCC];
    
    //BC
    self.viewBC = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewBC.clipsToBounds = YES;
    [self.scrollViewPublic addSubview:self.viewBC];
    
    self.lblBCTitle = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblBCTitle.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.lblBCTitle.text = @"密送:";
    self.lblBCTitle.textColor = COLOR(153, 153, 153, 1.0);
    self.lblBCTitle.backgroundColor = [UIColor clearColor];
    [self.viewBC addSubview:self.lblBCTitle];
    
    self.lblBCName = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblBCName.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.lblBCName.textColor = COLOR(153, 153, 153, 1.0);
    self.lblBCName.backgroundColor = [UIColor clearColor];
    [self.viewBC addSubview:self.lblBCName];
    
    self.btnAddBC = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnAddBC.frame = CGRectZero;
    [self.btnAddBC setImage:[UIImage imageNamed:@"btn_add_receiver"] forState:UIControlStateNormal];
    [self.btnAddBC addTarget:self action:@selector(addReceiver:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBC addSubview:self.btnAddBC];
    
    self.viewLineBC = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewLineBC.backgroundColor = COLOR(183, 183, 183, 1.0);
    [self.viewBC addSubview:self.viewLineBC];
    
    //title
    self.viewConTitle = [[UIView alloc]initWithFrame:CGRectZero];
    [self.scrollViewPublic addSubview:self.viewConTitle];
    
    self.lblConTitle = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblConTitle.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.lblConTitle.text = @"主题:";
    self.lblConTitle.textColor = COLOR(153, 153, 153, 1.0);
    self.lblConTitle.backgroundColor = [UIColor clearColor];
    [self.viewConTitle addSubview:self.lblConTitle];
    
    self.txtConTitle = [[UITextField alloc] initWithFrame:CGRectZero];
    self.txtConTitle.delegate = self;
    self.txtConTitle.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.txtConTitle.textColor = COLOR(153, 153, 153, 1.0);
    self.txtConTitle.delegate = self;
    self.txtConTitle.returnKeyType = UIReturnKeyDefault;
    self.txtConTitle.tag = 501;
    [self.viewConTitle addSubview:self.txtConTitle];
    
    self.viewLineConTitle = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewLineConTitle.backgroundColor = COLOR(183, 183, 183, 1.0);
    [self.viewConTitle addSubview:self.viewLineConTitle];
    
    //content
    self.viewContent = [[UIView alloc]initWithFrame:CGRectZero];
    [self.scrollViewPublic addSubview:self.viewContent];
    
    self.txtViewContent = [[MPTextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    self.txtViewContent.placeholderText = @"正文:";
    self.txtViewContent.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.txtViewContent.textColor = COLOR(153, 153, 153, 1.0);
    self.txtViewContent.backgroundColor = [UIColor clearColor];
    [self.viewContent addSubview:self.txtViewContent];
    
    self.viewLineContent = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewLineContent.backgroundColor = COLOR(183, 183, 183, 1.0);
    [self.viewContent addSubview:self.viewLineContent];
    
    //vote
    self.tableViewVote = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableViewVote.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableViewVote.dataSource = self;
    self.tableViewVote.delegate = self;
    self.tableViewVote.backgroundColor = [UIColor clearColor];
    [self.scrollViewPublic addSubview:self.tableViewVote];
    
    [self.tableViewVote reloadData];
    [self refreshView];
}

- (void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)refreshView
{
    /////////////////////////////////////////////////////
    CGFloat fHeight = 0.0;
    //scrollview
    self.scrollViewPublic.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT);
    
    //receiver
    self.viewReceiver.frame = CGRectMake(0, fHeight, kScreenWidth, 37);
    self.imgViewArrowIcon.frame = CGRectMake(3, 13.5, 10, 10);
    self.lblReceiverTitle.frame = CGRectMake(15, 9.5, 70, 18);
    self.lblReceiverName.frame = CGRectMake(75, 9.5, kScreenWidth-130, 18);
    self.btnAddReceiver.frame = CGRectMake(kScreenWidth-57, 0, 57, 37);
    self.btnAddArrowIcon.frame = CGRectMake(0, 0, 80, 37);
    self.viewLineReceiver.frame = CGRectMake(0, 36.5, kScreenWidth, 0.5);
    fHeight += 37;
    
    if(self.bShowCCAndBCC)
    {
        //CC
        self.viewCC.frame = CGRectMake(0, fHeight, kScreenWidth, 37);
        self.lblCCTitle.frame = CGRectMake(15, 9.5, 40, 18);
        self.lblCCName.frame = CGRectMake(60, 9.5, kScreenWidth-135, 18);
        self.btnAddCC.frame = CGRectMake(kScreenWidth-57, 0, 57, 37);
        self.viewLineCC.frame = CGRectMake(0, 36.5, kScreenWidth, 0.5);
        fHeight += 37;
        
        //BC
        self.viewBC.frame = CGRectMake(0, fHeight, kScreenWidth, 37);
        self.lblBCTitle.frame = CGRectMake(15, 9.5, 40, 18);
        self.lblBCName.frame = CGRectMake(60, 9.5, kScreenWidth-135, 18);
        self.btnAddBC.frame = CGRectMake(kScreenWidth-57, 0, 57, 37);
        self.viewLineBC.frame = CGRectMake(0, 36.5, kScreenWidth, 0.5);
        fHeight += 37;
    }
    else
    {
        //CC
        self.viewCC.frame = CGRectZero;
        
        //BC
        self.viewBC.frame = CGRectZero;
    }
    
    //title
    self.viewConTitle.frame = CGRectMake(0, fHeight, kScreenWidth, 37);
    self.lblConTitle.frame = CGRectMake(15, 9.5, 40, 18);
    self.txtConTitle.frame = CGRectMake(60, 8.5, kScreenWidth-75, 20);
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"501"];
    self.viewLineConTitle.frame = CGRectMake(0, 36.5, kScreenWidth, 0.5);
    fHeight += 37;
    
    //content
    self.viewContent.frame = CGRectMake(0, fHeight, kScreenWidth, 250);
    self.txtViewContent.frame = CGRectMake(10, 0, kScreenWidth-20, 249.5);
    self.viewLineContent.frame = CGRectMake(0, 249.5, kScreenWidth, 0.5);
    fHeight += 250;
    
    //vote
    fHeight += 5;
    self.tableViewVote.frame = CGRectMake(0, fHeight, kScreenWidth, self.tableViewVote.contentSize.height);
    fHeight += self.tableViewVote.contentSize.height;
    
    fHeight +=260;
    [self.scrollViewPublic setContentSize:CGSizeMake(kScreenWidth, fHeight)];
}

//初始化选中的数据
-(void)initChooseData
{
    NSMutableString *userNames = [NSMutableString string];
    //1.group
    for ( int i = 0 ; i < [self.aryInitGroupChoosed count]; i++)
    {
        GroupVo *groupVo = [self.aryInitGroupChoosed objectAtIndex:i];
        
        ReceiverVo *receiverVo = [[ReceiverVo alloc]init];
        receiverVo.strID = groupVo.strGroupID;
        receiverVo.strName = groupVo.strGroupName;
        receiverVo.strType = @"S";
        receiverVo.strCCType = @"T";
        [self.aryReceiverList addObject:receiverVo];
        [userNames appendFormat:@"%@,",receiverVo.strName];
    }
    
    //2.user
    for ( int i = 0 ; i < [self.aryInitUserChoosed count] ; i++ )
    {
        UserVo *userVo = [self.aryInitUserChoosed objectAtIndex:i];
        
        ReceiverVo *receiverVo = [[ReceiverVo alloc]init];
        receiverVo.strID = userVo.strUserID;
        receiverVo.strName = userVo.strUserName;
        receiverVo.strType = @"U";
        receiverVo.strCCType = @"T";
        [self.aryReceiverList addObject:receiverVo];
        [userNames appendFormat:@"%@,",receiverVo.strName];
    }
    self.lblReceiverName.text = userNames;
}

//显示隐藏抄送和密送
-(void)showCarbonAndBlindCopy
{
    if (self.bShowCCAndBCC)
    {
        self.bShowCCAndBCC = NO;
        self.imgViewArrowIcon.image = [UIImage imageNamed:@"receiver_icon_right"];
    }
    else
    {
        self.bShowCCAndBCC = YES;
        self.imgViewArrowIcon.image = [UIImage imageNamed:@"receiver_icon_down"];
    }
    [self refreshView];
}

//发表正文
-(void)doSendMsg
{
    [self doPublicMsg:@"M"];
}

//strMsgType(M-正文;D-草稿)
-(void)doPublicMsg:(NSString*)strMsgType
{
    //title name
    self.m_messageVo.strTitle = self.txtConTitle.text;
    if(self.m_messageVo.strTitle == nil || self.m_messageVo.strTitle.length == 0)
    {
        [Common tipAlert:@"主题不能为空"];
        return;
    }
    
    self.m_messageVo.strTextContent = self.txtViewContent.text;
    if(self.m_messageVo.strTextContent == nil || self.m_messageVo.strTextContent.length == 0)
    {
        [Common tipAlert:@"内容不能为空"];
        return;
    }
    
    //msg type
    self.m_messageVo.strMsgType = strMsgType;
    
    //ComeFromType
    self.m_messageVo.nComeFromType = 1;
    
    //邮件接收列表
    
    //vote
    int nVoteOptionCount = 0;
    for (int i=0; i<self.voteVo.aryVoteOption.count; i++)
    {
        VoteOptionVo *voteOptionVo = [self.voteVo.aryVoteOption objectAtIndex:i];
        if ((voteOptionVo.strOptionName != nil && voteOptionVo.strOptionName.length>0) || voteOptionVo.strImage !=nil)
        {
            nVoteOptionCount ++;
        }
    }
    
    if (nVoteOptionCount < 2)
    {
        [Common tipAlert:@"有效的投票选项不能少于2项"];
        return;
    }

    self.m_messageVo.voteVo = self.voteVo;
    
    //所有人
    
    //收件人列表
    self.m_messageVo.aryReceiverList = self.aryReceiverList;
    if (self.m_messageVo.aryReceiverList == nil || self.m_messageVo.aryReceiverList.count==0)
    {
        [Common tipAlert:@"收件人不能为空"];
        return;
    }
    
    //抄送人列表
    self.m_messageVo.aryCCList = self.aryCCList;
    
    //密送人列表
    self.m_messageVo.aryBCCList = self.aryBCList;
    
    //post action
    [self isHideActivity:NO];
    [ServerProvider publishMsg:self.m_messageVo andPublishType:self.publishMessageFromType result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            [self doBack];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

-(void)doBack
{
    [self backButtonClicked];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"RemovePublicView" object:nil];
}

//选择收件人
-(void)addReceiver:(UIButton*)sender
{
    if (sender == self.btnAddReceiver)
    {
        //receiver
        if (self.chooseReceiverList == nil)
        {
            self.chooseReceiverList = [[ChooseUserAndGroupViewController alloc]init];
            self.chooseReceiverList.aryOutUser = self.aryInitUserChoosed;
            self.chooseReceiverList.aryOutGroup = self.aryInitGroupChoosed;
            self.chooseReceiverList.delegate = self;
        }
        [self.navigationController pushViewController:self.chooseReceiverList animated:YES];
    }
    else if (sender == self.btnAddCC)
    {
        //CC
        if (self.chooseCCList == nil)
        {
            self.chooseCCList = [[ChooseUserAndGroupViewController alloc]init];
            self.chooseCCList.delegate = self;
        }
        [self.navigationController pushViewController:self.chooseCCList animated:YES];
    }
    else if (sender == self.btnAddBC)
    {
        //BC
        if (self.chooseBCList == nil)
        {
            self.chooseBCList = [[ChooseUserAndGroupViewController alloc]init];
            self.chooseBCList.delegate = self;
        }
        [self.navigationController pushViewController:self.chooseBCList animated:YES];
    }
}

//删除Cell
- (void)deleteButton:(UIButton*)btnRemove
{
    NSInteger nTag = btnRemove.tag-3000;
    if (nTag < self.voteVo.aryVoteOption.count)
    {
        [self.voteVo.aryVoteOption removeObjectAtIndex:btnRemove.tag-3000];
        [self.tableViewVote reloadData];
        [self refreshView];
    }
}

//add option cell
-(void)addOption
{
    //add option vo
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    self.nOptionId += 1;
    VoteOptionVo *voteOptionVo = [[VoteOptionVo alloc]init];
    voteOptionVo.nOptionId = self.nOptionId;
    [self.voteVo.aryVoteOption addObject:voteOptionVo];
    
    [self.tableViewVote reloadData];
    [self refreshView];
}

//选择类型
- (void)typeButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.selected)
    {
        return;
    }
    
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    
    UIButton *radioButton = (UIButton *)[cell viewWithTag:1];
    UIButton *checkButton = (UIButton *)[cell viewWithTag:2];
    
    UIImage *radioImage = radioButton.imageView.image;
    UIImage *checkImage = checkButton.imageView.image;
    
    [radioButton setImage:checkImage forState:UIControlStateNormal];
    [checkButton setImage:radioImage forState:UIControlStateNormal];
    
    radioButton.selected = !radioButton.selected;
    checkButton.selected = !checkButton.selected;
    
    if (radioButton.selected)
    {
        //single check
        self.voteVo.nVoteType = 0;
    }
    else
    {
        //multiple check
        self.voteVo.nVoteType = 1;
    }
}

//隐藏键盘
-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch*touch =[touches anyObject];
    if(touch.phase==UITouchPhaseBegan)
    {
        //find first response view
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    }
}

#pragma mark - ChooseUserAndGroupDelegate
-(void)completeChooseUserAndGroupAction:(ChooseUserAndGroupViewController*)chooseController andGroupList:(NSMutableArray*)aryChoosedGroup andUserList:(NSMutableArray*)aryChoosedUser
{
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        if (chooseController == self.chooseReceiverList)
        {
            [self.aryReceiverList removeAllObjects];
            
            NSMutableString *userNames = [NSMutableString string];
            for ( int i = 0 ; i < [aryChoosedGroup count] ; i++)
            {
                GroupVo *groupVo = [aryChoosedGroup objectAtIndex:i];
                
                ReceiverVo *receiverVo = [[ReceiverVo alloc]init];
                receiverVo.strID = groupVo.strGroupID;
                receiverVo.strName = groupVo.strGroupName;
                receiverVo.strType = @"S";
                receiverVo.strCCType = @"T";
                [self.aryReceiverList addObject:receiverVo];
                [userNames appendFormat:@"%@,",receiverVo.strName];
            }
            
            for ( int i = 0 ; i < [aryChoosedUser count] ; i++ )
            {
                UserVo *userVo = [aryChoosedUser objectAtIndex:i];
                
                ReceiverVo *receiverVo = [[ReceiverVo alloc]init];
                receiverVo.strID = userVo.strUserID;
                receiverVo.strName = userVo.strUserName;
                receiverVo.strType = @"U";
                receiverVo.strCCType = @"T";
                [self.aryReceiverList addObject:receiverVo];
                [userNames appendFormat:@"%@,",receiverVo.strName];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lblReceiverName.text = userNames;
                [self isHideActivity:YES];
            });
        }
        else if (chooseController == self.chooseCCList)
        {
            [self.aryCCList removeAllObjects];
            
            NSMutableString *userNames = [NSMutableString string];
            for ( int i = 0 ; i < [aryChoosedGroup count] ; i++)
            {
                GroupVo *groupVo = [aryChoosedGroup objectAtIndex:i];
                
                ReceiverVo *receiverVo = [[ReceiverVo alloc]init];
                receiverVo.strID = groupVo.strGroupID;
                receiverVo.strName = groupVo.strGroupName;
                receiverVo.strType = @"S";
                receiverVo.strCCType = @"C";
                [self.aryCCList addObject:receiverVo];
                [userNames appendFormat:@"%@,",receiverVo.strName];
            }
            
            for ( int i = 0 ; i < [aryChoosedUser count] ; i++ )
            {
                UserVo *userVo = [aryChoosedUser objectAtIndex:i];
                
                ReceiverVo *receiverVo = [[ReceiverVo alloc]init];
                receiverVo.strID = userVo.strUserID;
                receiverVo.strName = userVo.strUserName;
                receiverVo.strType = @"U";
                receiverVo.strCCType = @"C";
                [self.aryCCList addObject:receiverVo];
                [userNames appendFormat:@"%@,",receiverVo.strName];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lblCCName.text = userNames;
                [self isHideActivity:YES];
            });
        }
        else if (chooseController == self.chooseBCList)
        {
            [self.aryBCList removeAllObjects];
            
            NSMutableString *userNames = [NSMutableString string];
            for ( int i = 0 ; i < [aryChoosedGroup count] ; i++)
            {
                GroupVo *groupVo = [aryChoosedGroup objectAtIndex:i];
                
                ReceiverVo *receiverVo = [[ReceiverVo alloc]init];
                receiverVo.strID = groupVo.strGroupID;
                receiverVo.strName = groupVo.strGroupName;
                receiverVo.strType = @"S";
                receiverVo.strCCType = @"B";
                [self.aryBCList addObject:receiverVo];
                [userNames appendFormat:@"%@,",receiverVo.strName];
            }
            
            for ( int i = 0 ; i < [aryChoosedUser count] ; i++ )
            {
                UserVo *userVo = [aryChoosedUser objectAtIndex:i];
                
                ReceiverVo *receiverVo = [[ReceiverVo alloc]init];
                receiverVo.strID = userVo.strUserID;
                receiverVo.strName = userVo.strUserName;
                receiverVo.strType = @"U";
                receiverVo.strCCType = @"B";
                [self.aryBCList addObject:receiverVo];
                [userNames appendFormat:@"%@,",receiverVo.strName];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.lblBCName.text = userNames;
                [self isHideActivity:YES];
            });
        }
    });
}

#pragma mark - Notification
//键盘侦听事件
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *)aNotification
{
    if(!self.txtConTitle.isFirstResponder && !self.txtViewContent.isFirstResponder)
    {
        NSDictionary* info = [aNotification userInfo];
        CGSize sizeKeyBoard = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        CGFloat fContentOffset = self.scrollViewPublic.contentOffset.y;
        CGFloat fCurHeight = 469+(self.selectedIndexPath.row+1)*60;
        CGFloat fDifferentH = fCurHeight - (fContentOffset+kScreenHeight-NAV_BAR_HEIGHT-sizeKeyBoard.height);
        if (fDifferentH > 0)
        {
            [self.scrollViewPublic setContentOffset:CGPointMake(0, (fContentOffset+fDifferentH+36)) animated:YES];//offset-10
        }
    }
} 
#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self indexPathFromView:textField];
}

- (void)indexPathFromView:(UIView *)view
{
    UITableViewCell *cell = nil;
    if (iOSPlatform >= 8 )
    {
        cell = (UITableViewCell*)view.superview.superview;
    }
    else if (iOSPlatform == 7 )
    {
        cell = (UITableViewCell*)view.superview.superview.superview;
    }
    else
    {
        cell = (UITableViewCell*)view.superview.superview;
    }
    
    self.selectedIndexPath = [self.tableViewVote indexPathForCell:cell];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidChange:(UITextField*)textView
{
    NSString *tmpStr = textView.text;
    for (int i=0; i<self.voteVo.aryVoteOption.count; i++)
    {
        VoteOptionVo* voteOptionVo = (VoteOptionVo*)[self.voteVo.aryVoteOption objectAtIndex:i];
        if(voteOptionVo.nOptionId == textView.tag)
        {
            voteOptionVo.strOptionName = tmpStr;
            break;
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger nRowNum = 0;
    if (section == 0)
    {
        nRowNum = 1;
    }
    else if (section == 1)
    {
        nRowNum = [self.voteVo.aryVoteOption count];
    }
    return nRowNum;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fHeight = 0.0;
    if ([indexPath section] == 0)
    {
        fHeight = 90;
    }
    else
    {
        fHeight = 60;
    }
    return fHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    static NSString *identifier = nil;
    
    if (section == 0 && row == 0)
    {//类型
        identifier = @"TypeCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            
            UILabel * lalType = [[UILabel alloc]initWithFrame:CGRectMake(15, 5,80,34)];
            lalType.text = @"投票选项:";
            lalType.font = [UIFont systemFontOfSize:17.0];
            lalType.textColor =[UIColor blackColor];
            lalType.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:lalType];
            
            //单选
            UIButton *radioButton = [UIButton buttonWithType:UIButtonTypeCustom];
            radioButton.frame = CGRectMake(80,5, 100, 44);
            [radioButton setImage:[UIImage imageNamed:@"selectedVote"] forState:UIControlStateNormal];
            [radioButton setImageEdgeInsets:UIEdgeInsetsMake(-8.0, 0.0, 0.0, 0.0)];
            [radioButton setTitle:@"单选" forState:UIControlStateNormal];
            [radioButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [radioButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
            [radioButton setTitleEdgeInsets:UIEdgeInsetsMake(-8.0, 20, 0.0, 0.0)];
            radioButton.tag = 1;
            radioButton.selected = YES;
            [radioButton addTarget:self action:@selector(typeButton:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:radioButton];
            
            //多选
            UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
            checkButton.frame = CGRectMake(200, 5, 100, 44);
            [checkButton setImage:[UIImage imageNamed:@"unselectedVote"] forState:UIControlStateNormal];
            [checkButton setImageEdgeInsets:UIEdgeInsetsMake(-8.0, 0.0, 0.0, 0.0)];
            [checkButton setTitle:@"多选" forState:UIControlStateNormal];
            [checkButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [checkButton.titleLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
            [checkButton setTitleEdgeInsets:UIEdgeInsetsMake(-8.0, 20, 0.0, 0.0)];
            checkButton.tag = 2;
            [checkButton addTarget:self action:@selector(typeButton:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:checkButton];
            
            //增加投票选项
            UILabel * lblVoteType2 = [[UILabel alloc]initWithFrame:CGRectMake(20,45+5,100,34)];
            lblVoteType2.text = @"投票选项:";
            lblVoteType2.font = [UIFont systemFontOfSize:18.0];
            lblVoteType2.textColor =[UIColor blackColor];
            lblVoteType2.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:lblVoteType2];
            
            UIButton *btnAddVoteOption = [UIButton buttonWithType:UIButtonTypeCustom];
            btnAddVoteOption.frame = CGRectMake(kScreenWidth-70,45+5, 57, 37);
            [btnAddVoteOption setImage:[UIImage imageNamed:@"btn_add_receiver"] forState:UIControlStateNormal];
            btnAddVoteOption.tag = 3;
            [btnAddVoteOption addTarget:self action:@selector(addOption) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btnAddVoteOption];
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    else if (section == 1)
    {
        //选项内容
        identifier = @"OptionCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            //头像
            UIButton *iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
            iconButton.frame = CGRectMake(10,10, 40, 40);
            iconButton.tag = indexPath.row + 1000;
            [cell.contentView addSubview:iconButton];
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(60, 2*PADDING_Y, kScreenWidth-140, 40)];
            textField.placeholder = @"投票选项";
            textField.delegate = self;
            [cell.contentView addSubview:textField];
            
            UIButton *removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [removeButton setImage:[UIImage imageNamed:@"btn_remove_receiver"] forState:UIControlStateNormal];
            removeButton.frame = CGRectMake(kScreenWidth-70, 10, 57, 37);
            [removeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            removeButton.tag = indexPath.row + 3000;
            [cell.contentView addSubview:removeButton];
        }
        
        VoteOptionVo *voteOption = [self.voteVo.aryVoteOption objectAtIndex:indexPath.row];
        int nFinded = 0;
        for(UIView *tempView in cell.contentView.subviews)
        {
            if([tempView isKindOfClass:[UITextField class]])
            {
                UITextField *txtOption = (UITextField*)tempView;
                txtOption.tag = voteOption.nOptionId;
                txtOption.text = voteOption.strOptionName;
                [txtOption removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
                [txtOption addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            }
            else if([tempView isKindOfClass:[UIButton class]])
            {
                if (tempView.tag >= 3000)
                {
                    //remove button
                    UIButton *btnRemove = (UIButton*)tempView;
                    btnRemove.tag = indexPath.row + 3000;
                    
                    [btnRemove removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
                    [btnRemove addTarget:self action:@selector(deleteButton:) forControlEvents:UIControlEventTouchUpInside];
                }
                else
                {
                    //image button
                    UIButton *btnAddIcon = (UIButton*)tempView;
                    btnAddIcon.tag = indexPath.row + 1000;
                    
                    UIImage *iconImg = nil;
                    if (voteOption.strImage != nil && voteOption.strImage.length > 0)
                    {
                        iconImg = [[UIImage imageWithContentsOfFile:voteOption.strImage] roundedWithSize:CGSizeMake(40,40)];
                    }
                    else
                    {
                        iconImg = [[UIImage imageNamed:@"vote_default"] roundedWithSize:CGSizeMake(40,40)];
                    }
                    [btnAddIcon setImage:iconImg forState:UIControlStateNormal];
                    [btnAddIcon removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
                    [btnAddIcon addTarget:self action:@selector(addIconButton:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            
            //check is or not finded
            if (nFinded == 2)
            {
                break;
            }
        }
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;//section头部高度
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;//section尾部高度
}

-(void)addIconButton:(UIButton *)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    VoteOptionVo *voteOption = [self.voteVo.aryVoteOption objectAtIndex:sender.tag-1000];
    
    if (voteOption.strImage != nil && voteOption.strImage.length >0)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"预览", @"移除", nil];
        actionSheet.tag = sender.tag+888;
        [actionSheet showInView:self.view];
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"用户相册", nil];
        actionSheet.tag = sender.tag;
        [actionSheet showInView:self.view];
    }
    self.btnTag = sender.tag;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //    [navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor blackColor]}];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (editedImage)
        {
            imageToSave = editedImage;
        }
        else
        {
            imageToSave = originalImage;
        }
        
        // Save the new image (original or edited) to the Camera Roll
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        }
        
        //当图片尺寸过大，进行缩放处理
        CGSize sizeImage = CGSizeMake(imageToSave.size.width, imageToSave.size.height);
        if (sizeImage.width>IMAGE_MAX_SIZE && sizeImage.height>IMAGE_MAX_SIZE)
        {
            sizeImage = CGSizeMake(1024, (1024*sizeImage.height)/sizeImage.width);
        }
        imageToSave = [ResizeImage imageWithImage:imageToSave scaledToSize:sizeImage];
        
        //保存图片
        NSData *imageData = UIImageJPEGRepresentation(imageToSave, 0.8f);
        NSString *imagePath = [[Utils tmpDirectory] stringByAppendingPathComponent:[Common createImageNameByDateTime]];
        [imageData writeToFile:imagePath atomically:YES];
        
        //显示缩略图
        UIImage *thumbnailImage = [ResizeImage imageWithImage:imageToSave scaledToSize:CGSizeMake(64*2.0, 64*2.0)];
        [self addAttachmentWithPath:imagePath image:thumbnailImage];
    }
    [picker  dismissViewControllerAnimated:YES completion: nil];
}

- (void)addAttachmentWithPath:(NSString *)path image:(UIImage *)image
{
    VoteOptionVo *voteOption = [self.voteVo.aryVoteOption objectAtIndex:self.btnTag-1000];
    voteOption.strImage = path;
    [self.tableViewVote reloadData];
}

#pragma mark - Action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == self.btnTag + 888)
    {
        VoteOptionVo *voteOption = [self.voteVo.aryVoteOption objectAtIndex:self.btnTag-1000];
        
        if (buttonIndex == 0)
        {
            //预览
            SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
            dataSource.images_ = [NSArray arrayWithObject:[NSArray arrayWithObject:[NSURL fileURLWithPath:voteOption.strImage]]];
            
            KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
                                                                      initWithDataSource:dataSource
                                                                      andStartWithPhotoAtIndex:0];
            photoScrollViewController.bShowToolBarBtn = NO;
            [self presentViewController:photoScrollViewController animated:YES completion: nil];
        }
        else if (buttonIndex == 1)
        {
            //移除
            if (voteOption.strImage)
            {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                BOOL fileExists = [fileManager fileExistsAtPath:voteOption.strImage];
                if (fileExists)
                {
                    [fileManager removeItemAtPath:voteOption.strImage error:nil];
                }
                
                VoteOptionVo *voteOption = [self.voteVo.aryVoteOption objectAtIndex:self.btnTag-1000];
                voteOption.strImage = nil;
                [self.tableViewVote reloadData];
            }
        }
    }
    else
    {
        if (buttonIndex == 0)
        {
            //拍照
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
            {
                return;
            }
            self.photoController = [[UIImagePickerController alloc] init];
            self.photoController.delegate = self;
            self.photoController.mediaTypes = @[(NSString*)kUTTypeImage];
            self.photoController.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.photoController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            self.photoController.allowsEditing = YES;
            [self.photoController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            
            [self presentViewController:self.photoController animated:YES completion: nil];
        }
        else if (buttonIndex == 1)
        {
            //用户相册
            self.photoAlbumController = [[UIImagePickerController alloc]init];
            self.photoAlbumController.delegate = self;
            self.photoAlbumController.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
            self.photoAlbumController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.photoAlbumController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            self.photoAlbumController.allowsEditing = YES;
            [self.photoAlbumController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            
            [self presentViewController:self.photoAlbumController animated:YES completion: nil];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker  dismissViewControllerAnimated:YES completion:nil];
}

@end
