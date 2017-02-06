//
//  PublishMessageViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-27.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "PublishMessageViewController.h"
#import "Utils.h"
#import "UIImage+UIImageScale.h"
#import "ResizeImage.h"
#import "UIImage+Extras.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "KTPhotoScrollViewController.h"
#import "SDWebImageDataSource.h"
#import "ReceiverVo.h"
#import "UserVo.h"
#import "UIImage+Category.h"
#import "AttachmentVo.h"
#import <AVFoundation/AVFoundation.h>

@interface PublishMessageViewController ()

@end

@implementation PublishMessageViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PublishEnterType" object:nil];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doBack) name:@"PublishEnterType" object:nil];
    
    [self initView];
    [self initData];
    
    //分享图片进入
    if (self.strShareImgPath != nil && self.imgShareThumb!= nil)
    {
        [self addAttachmentWithPath:self.strShareImgPath image:self.imgShareThumb andType:0];
        [self clickToolViewBtn:nil];
    }
}

-(void)initView
{
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
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
    self.scrollViewPublic.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.scrollViewPublic.delegate = self;
    self.scrollViewPublic.autoresizingMask = NO;
    self.scrollViewPublic.clipsToBounds = YES;
    [self.view addSubview:self.scrollViewPublic];
    
    //receiver
    self.viewReceiver = [[UIView alloc]initWithFrame:CGRectZero];
    [self.scrollViewPublic addSubview:self.viewReceiver];
    self.viewReceiver.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.imgViewArrowIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"receiver_icon_right"]];
    [self.viewReceiver addSubview:self.imgViewArrowIcon];
    
    self.lblReceiverTitle = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblReceiverTitle.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.lblReceiverTitle.text = @"收件人:";
    self.lblReceiverTitle.textColor = COLOR(153, 153, 153, 1.0);
    self.lblReceiverTitle.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];
    self.lblReceiverTitle.backgroundColor = [UIColor clearColor];
    [self.viewReceiver addSubview:self.lblReceiverTitle];
    
    self.lblReceiverName = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblReceiverName.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.lblReceiverName.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];
    self.lblReceiverName.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];
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
    self.viewLineReceiver.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.viewReceiver addSubview:self.viewLineReceiver];
    
    //CC
    self.viewCC = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewCC.clipsToBounds = YES;
    [self.scrollViewPublic addSubview:self.viewCC];
    
    self.lblCCTitle = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblCCTitle.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.lblCCTitle.text = @"抄送:";
    self.lblCCTitle.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];
    self.lblCCTitle.backgroundColor = [UIColor clearColor];
    [self.viewCC addSubview:self.lblCCTitle];
    
    self.lblCCName = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblCCName.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.lblCCName.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];
    self.lblCCName.backgroundColor = [UIColor clearColor];
    [self.viewCC addSubview:self.lblCCName];
    
    self.btnAddCC = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnAddCC.frame = CGRectZero;
    [self.btnAddCC setImage:[UIImage imageNamed:@"btn_add_receiver"] forState:UIControlStateNormal];
    [self.btnAddCC addTarget:self action:@selector(addReceiver:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewCC addSubview:self.btnAddCC];
    
    self.viewLineCC = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewLineCC.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.viewCC addSubview:self.viewLineCC];
    
    //BC
    self.viewBC = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewBC.clipsToBounds = YES;
    [self.scrollViewPublic addSubview:self.viewBC];
    
    self.lblBCTitle = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblBCTitle.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.lblBCTitle.text = @"密送:";
    self.lblBCTitle.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];
    self.lblBCTitle.backgroundColor = [UIColor clearColor];
    [self.viewBC addSubview:self.lblBCTitle];
    
    self.lblBCName = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblBCName.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.lblBCName.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];
    self.lblBCName.backgroundColor = [UIColor clearColor];
    [self.viewBC addSubview:self.lblBCName];
    
    self.btnAddBC = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnAddBC.frame = CGRectZero;
    [self.btnAddBC setImage:[UIImage imageNamed:@"btn_add_receiver"] forState:UIControlStateNormal];
    [self.btnAddBC addTarget:self action:@selector(addReceiver:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBC addSubview:self.btnAddBC];
    
    self.viewLineBC = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewLineBC.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.viewBC addSubview:self.viewLineBC];
    
    //title
    self.viewConTitle = [[UIView alloc]initWithFrame:CGRectZero];
    [self.scrollViewPublic addSubview:self.viewConTitle];
    
    self.lblConTitle = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblConTitle.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.lblConTitle.text = @"主题:";
    self.lblConTitle.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];
    self.lblConTitle.backgroundColor = [UIColor clearColor];
    [self.viewConTitle addSubview:self.lblConTitle];
    
    self.txtConTitle = [[UITextField alloc] initWithFrame:CGRectZero];
    self.txtConTitle.delegate = self;
    self.txtConTitle.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.txtConTitle.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];
    self.txtConTitle.returnKeyType = UIReturnKeyDefault;
    [self.viewConTitle addSubview:self.txtConTitle];
    
    self.viewLineConTitle = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewLineConTitle.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.viewConTitle addSubview:self.viewLineConTitle];
    
    //content
    self.viewContent = [[UIView alloc]initWithFrame:CGRectZero];
    [self.scrollViewPublic addSubview:self.viewContent];
    
    self.txtViewContent = [[MPTextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    self.txtViewContent.placeholderText = @"正文:";
    self.txtViewContent.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.txtViewContent.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];
    self.txtViewContent.backgroundColor = [UIColor clearColor];
    [self.viewContent addSubview:self.txtViewContent];
    self.txtViewContent.placeholderLabel.textColor = [SkinManage colorNamed:@"Nav_Btn_BK_Color"];
    
    //转发的原文显示
    self.viewOrigBK = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewOrigBK.backgroundColor = [SkinManage colorNamed:@"viewOrigBK"];
    self.viewOrigBK.layer.borderWidth = 1;
    self.viewOrigBK.layer.borderColor = [[SkinManage colorNamed:@"viewOrigBKBorder_color"] CGColor];
    self.viewOrigBK.layer.cornerRadius = 5;
    self.viewOrigBK.layer.masksToBounds = YES;
    [self.scrollViewPublic addSubview:self.viewOrigBK];
    
    self.lblOrigAuthor = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblOrigAuthor.backgroundColor = [UIColor clearColor];
    self.lblOrigAuthor.font = [UIFont systemFontOfSize:15];
    self.lblOrigAuthor.textColor = [SkinManage colorNamed:@"OrigAuthor_label_color"];//COLOR(0,116,172,1.0);
    [self.viewOrigBK addSubview:self.lblOrigAuthor];
    
    self.lblOrigContent = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblOrigContent.backgroundColor = [UIColor clearColor];
    self.lblOrigContent.font = [UIFont systemFontOfSize:16];
    self.lblOrigContent.textColor = [SkinManage colorNamed:@"metting_Tite_color"];//COLOR(0,0,0,1.0);
    self.lblOrigContent.numberOfLines = 0;
    self.lblOrigContent.lineBreakMode = NSLineBreakByWordWrapping;
    [self.viewOrigBK addSubview:self.lblOrigContent];
    
    //attach view and tool view
    self.attachView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-45, kScreenWidth, 45)];
    [self.view addSubview:self.attachView];
    
    if (self.enterType == PublishMessageType)
    {
        //message
        self.btnAttach = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnAttach.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
        self.btnAttach.frame = CGRectMake(kScreenWidth-60, 10, 50, 25);
        [self.btnAttach setBackgroundImage:[[UIImage imageNamed:@"btn_attach_bk"] stretchableImageWithLeftCapWidth:16 topCapHeight:9] forState:UIControlStateNormal];
        [self.btnAttach setTitle:@"照片" forState:UIControlStateNormal];
        [self.btnAttach addTarget:self action:@selector(clickToolViewBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.attachView addSubview:self.btnAttach];
        
        [self setTopNavBarTitle:@"发消息"];
    }
    
    //工具栏
    self.toolView = [[ToolView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, TOOL_VIEW_HEIGHT)];
    self.toolView.toolViewDelegate = self;
    [self.view addSubview:self.toolView];
    self.toolView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.toolView.scrollViewFacial.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    if ([SkinManage getCurrentSkin] == SkinNightType) {
        self.toolView.topView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        self.toolView.lineImgView.image = [UIImage imageWithColor:[SkinManage colorNamed:@"Wire_Frame_Color"]];
    }
    
    
    
    
    
    //注册键盘侦听事件
    [self registerForKeyboardNotifications];
    
    [self refreshControlFrame];
}

-(void)refreshControlFrame
{
    /////////////////////////////////////////////////////
    CGFloat fHeight = 0.0;
    //scrollview
    self.scrollViewPublic.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT);
    
    //receiver
    self.viewReceiver.frame = CGRectMake(0, fHeight, kScreenWidth, 37);
    
    self.imgViewArrowIcon.frame = CGRectMake(3, 13.5, 10, 10);
    
    self.lblReceiverTitle.frame = CGRectMake(15, 9.5, 70, 18);
    
    self.lblReceiverName.frame = CGRectMake(75, 9.5, 190, 18);
    
    self.btnAddReceiver.frame = CGRectMake(kScreenWidth-57, 0, 57, 37);
    
    self.btnAddArrowIcon.frame = CGRectMake(0, 0, 80, 37);
    
    self.viewLineReceiver.frame = CGRectMake(0, 36.5, kScreenWidth, 0.5);
    fHeight += 37;
    
    if(self.bShowCCAndBCC)
    {
        //CC
        self.viewCC.frame = CGRectMake(0, fHeight, kScreenWidth, 37);
        
        self.lblCCTitle.frame = CGRectMake(15, 9.5, 40, 18);
        
        self.lblCCName.frame = CGRectMake(55, 9.5, 190, 18);
        
        self.btnAddCC.frame = CGRectMake(kScreenWidth-57, 0, 57, 37);
        
        self.viewLineCC.frame = CGRectMake(0, 36.5, kScreenWidth, 0.5);
        fHeight += 37;
        
        //BC
        self.viewBC.frame = CGRectMake(0, fHeight, kScreenWidth, 37);
        
        self.lblBCTitle.frame = CGRectMake(15, 9.5, 40, 18);
        
        self.lblBCName.frame = CGRectMake(60, 9.5, 185, 18);
        
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
    
    self.txtConTitle.frame = CGRectMake(60, 8.5, 245, 20);
    
    self.viewLineConTitle.frame = CGRectMake(0, 36.5, kScreenWidth, 0.5);
    fHeight += 37;
    
    //content
    self.viewContent.frame = CGRectMake(0, fHeight, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-fHeight);
    
    self.txtViewContent.frame = CGRectMake(10, 0, kScreenWidth-20, kScreenHeight-NAV_BAR_HEIGHT-fHeight);
    
    fHeight += self.viewContent.frame.size.height;
    
    //转发的原文显示
    self.viewOrigBK.frame = CGRectMake(10, fHeight, kScreenWidth-20, 0);
    
    self.lblOrigAuthor.frame = CGRectZero;
    
    self.lblOrigContent.frame = CGRectZero;
    
    fHeight +=50;
    [self.scrollViewPublic setContentSize:CGSizeMake(kScreenWidth, fHeight)];
}

-(void)initData
{
    self.bShowCCAndBCC = NO;
    self.attachList = [[NSMutableArray alloc] init];
    self.aryReceiverList = [[NSMutableArray alloc] init];
    self.aryCCList = [[NSMutableArray alloc] init];
    self.aryBCList = [[NSMutableArray alloc] init];
    
    self.m_publishMsgType = PublishMessageType;
    self.m_messageVo = [[MessageVo alloc]init];
    self.m_messageVo.aryAttachmentList = [NSMutableArray array];
    self.m_messageVo.aryImageList = [NSMutableArray array];
    
    //初始选择的收件人信息
    if (self.publishMessageFromType == PublishMessageReplyType)
    {
        //回复
        UserVo *userVo = [[UserVo alloc]init];
        userVo.strUserID = self.m_preMessageVo.strAuthorID;
        userVo.strUserName = self.m_preMessageVo.strAuthorName;
        self.aryInitUserChoosed = [NSMutableArray array];
        [self.aryInitUserChoosed addObject:userVo];
        
        self.m_messageVo.strTitleID = self.m_preMessageVo.strTitleID;
        self.m_messageVo.strReturnID = self.m_preMessageVo.strID;
        
        self.txtConTitle.text = [NSString stringWithFormat:@"Re:%@",self.m_preMessageVo.strTitle];
    }
    else if (self.publishMessageFromType == PublishMessageForwardType)
    {
        //转发
        self.m_messageVo.strParentID = self.m_preMessageVo.strParentID;
        
        CGFloat fHeight = 10;
        
        //1.引用博文作者
        NSString *contentTemp = [NSString stringWithFormat:@" - 转自:%@ ", self.m_preMessageVo.strAuthorName];
        self.lblOrigAuthor.text = contentTemp;
        self.lblOrigAuthor.frame = CGRectMake(20, fHeight, kScreenWidth-40, 16);
        fHeight += 16;
        
        //2.引用博文内容
        fHeight += 10;
        NSString *strContent = self.m_preMessageVo.strTextContent;
        if (strContent.length >150)
        {
            strContent = [NSString stringWithFormat:@"%@ ...",[strContent substringToIndex:150]];
        }
        
        if(self.m_preMessageVo.voteVo != nil)
        {
            //如果是投票，则拼接投票信息
            NSMutableString *strVoteTemp = [NSMutableString string];
            [strVoteTemp appendString:@"\n\n 投票信息:"];
            
            //投票项
            for (int i=0; i<self.m_preMessageVo.voteVo.aryVoteOption.count; i++)
            {
                VoteOptionVo *voteOptionVo = [self.m_preMessageVo.voteVo.aryVoteOption objectAtIndex:i];
                [strVoteTemp appendFormat:@"\n %i. %@",i+1,voteOptionVo.strOptionName];
                int nPercent = 0;
                if (self.m_preMessageVo.voteVo.nVoteTotal != 0)
                {
                    nPercent = 100*(voteOptionVo.nCount*1.0/self.m_preMessageVo.voteVo.nVoteTotal);
                }
                [strVoteTemp appendFormat:@"\n投票详情:  (%li 票 / %i%%)",(long)voteOptionVo.nCount,nPercent];
            }
            [strVoteTemp appendFormat:@"\n总投票数 %li",(long)self.m_preMessageVo.voteVo.nVoteTotal];
            
            strContent = [NSString stringWithFormat:@"%@%@",strContent,strVoteTemp];
        }
        else if (self.m_preMessageVo.scheduleVo != nil)
        {
            //如果是邀请，则拼接邀请信息
            NSMutableString *strScheduleTemp = [NSMutableString string];
            [strScheduleTemp appendString:@"\n\n邀请信息: "];
            [strScheduleTemp appendFormat:@"\n开始时间: %@",self.m_preMessageVo.scheduleVo.strStartTime];
            [strScheduleTemp appendFormat:@"\n地点: %@",self.m_preMessageVo.scheduleVo.strAddress];
            [strScheduleTemp appendFormat:@"\n确认参加: %@",[BusinessCommon getScheduleMemberByType:1 andArray:self.m_preMessageVo.scheduleVo.aryUserJoinState]];
            [strScheduleTemp appendFormat:@"\n不能参加: %@",[BusinessCommon getScheduleMemberByType:2 andArray:self.m_preMessageVo.scheduleVo.aryUserJoinState]];
            [strScheduleTemp appendFormat:@"\n暂时待定: %@",[BusinessCommon getScheduleMemberByType:3 andArray:self.m_preMessageVo.scheduleVo.aryUserJoinState]];
            
            strContent = [NSString stringWithFormat:@"%@%@",strContent,strScheduleTemp];
        }
        self.lblOrigContent.text = strContent;
        
        CGSize sizeTitle = [Common getStringSize:self.lblOrigContent.text font:self.lblOrigContent.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        self.lblOrigContent.frame = CGRectMake(20, fHeight, kScreenWidth-40, sizeTitle.height);
        fHeight += sizeTitle.height;
        
        //3.bk view
        fHeight += 10;
        self.viewOrigBK.frame = CGRectMake(10, self.viewOrigBK.frame.origin.y, kScreenWidth-20, fHeight);
        
        fHeight += 10;
        //set scrollview
        CGSize size = self.scrollViewPublic.contentSize;
        [self.scrollViewPublic setContentSize:CGSizeMake(kScreenWidth, size.height+fHeight)];
        
        self.txtConTitle.text = [NSString stringWithFormat:@"Fw:%@",self.m_preMessageVo.strTitle];
        
        self.m_messageVo.strParentID = self.m_preMessageVo.strID;
    }
    //初始化选中的数据
    [self initChooseData];
}

- (void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self refreshControlFrame];
}

//发表正文
-(void)doSendMsg
{
    [self doPublicMsg:@"M"];
}

//strMsgType(M-正文;D-草稿)
-(void)doPublicMsg:(NSString*)strMsgType
{
    //id (有id表示草稿修改、发布)
    
    //attachment list
    for (int i=0; i<self.attachList.count; i++)
    {
        AttachmentVo *attachmentVo = [self.attachList objectAtIndex:i];
        if (attachmentVo.nAttachType == 0)
        {
            //image
            [self.m_messageVo.aryImageList addObject:attachmentVo.strAttachLocalPath];
        }
        else
        {
            //attachment
            [self.m_messageVo.aryAttachmentList addObject:attachmentVo.strAttachLocalPath];
        }
    }
    
    //回复发表
    //title id
    //return id
    
    //转发发表
    //parent id
    
    //title name
    self.m_messageVo.strTitle = self.txtConTitle.text;
    if(self.m_messageVo.strTitle == nil || self.m_messageVo.strTitle.length == 0)
    {
        [Common tipAlert:@"主题不能为空"];
        return;
    }
    
    //content
    if(self.publishMessageFromType == PublishMessageForwardType)
    {
        //转发合并内容
        self.m_messageVo.strTextContent = [NSString stringWithFormat:@"%@<br><br><br><hr>%@",self.txtViewContent.text,self.m_preMessageVo.strHtmlContent];
        
        if(self.m_preMessageVo.voteVo != nil)
        {
            //如果是投票，则拼接投票信息
            NSMutableString *strVoteTemp = [NSMutableString string];
            [strVoteTemp appendString:@"<br><br><span style=\"font-size:16px;font-weight: bold;\">投票信息:</span>"];
            
            //投票项
            for (int i=0; i<self.m_preMessageVo.voteVo.aryVoteOption.count; i++)
            {
                VoteOptionVo *voteOptionVo = [self.m_preMessageVo.voteVo.aryVoteOption objectAtIndex:i];
                [strVoteTemp appendFormat:@"<br>&nbsp;%i.&nbsp;%@",i+1,voteOptionVo.strOptionName];
                int nPercent = 0;
                if (self.m_preMessageVo.voteVo.nVoteTotal != 0)
                {
                    nPercent = 100*(voteOptionVo.nCount*1.0/self.m_preMessageVo.voteVo.nVoteTotal);
                }
                [strVoteTemp appendFormat:@"<br>投票详情:  (%li 票 / %i%%)",(long)voteOptionVo.nCount,nPercent];
                
                if (voteOptionVo.strImage !=nil && voteOptionVo.strImage.length>0)
                {
                    [strVoteTemp appendFormat:@"<br><img src=\"%@\" style=\"height:120px\">",voteOptionVo.strImage];
                }
            }
            [strVoteTemp appendFormat:@"<br>总投票数&nbsp;%li",(long)self.m_preMessageVo.voteVo.nVoteTotal];
            
            self.m_messageVo.strTextContent = [NSString stringWithFormat:@"%@%@",self.m_messageVo.strTextContent,strVoteTemp];
        }
        else if (self.m_preMessageVo.scheduleVo != nil)
        {
            //如果是邀请，则拼接邀请信息
            NSMutableString *strScheduleTemp = [NSMutableString string];
            [strScheduleTemp appendString:@"<br><br><span style=\"font-size:16px;font-weight: bold;\">邀请信息:</span>"];
            [strScheduleTemp appendFormat:@"<br>开始时间:&nbsp;%@",self.m_preMessageVo.scheduleVo.strStartTime];
            [strScheduleTemp appendFormat:@"<br>地点:&nbsp;%@",self.m_preMessageVo.scheduleVo.strAddress];
            [strScheduleTemp appendFormat:@"<br>确认参加:&nbsp;%@",[BusinessCommon getScheduleMemberByType:1 andArray:self.m_preMessageVo.scheduleVo.aryUserJoinState]];
            [strScheduleTemp appendFormat:@"<br>不能参加:&nbsp;%@",[BusinessCommon getScheduleMemberByType:2 andArray:self.m_preMessageVo.scheduleVo.aryUserJoinState]];
            [strScheduleTemp appendFormat:@"<br>暂时待定:&nbsp;%@",[BusinessCommon getScheduleMemberByType:3 andArray:self.m_preMessageVo.scheduleVo.aryUserJoinState]];
            
            self.m_messageVo.strTextContent = [NSString stringWithFormat:@"%@%@",self.m_messageVo.strTextContent,strScheduleTemp];
        }
    }
    else
    {
        self.m_messageVo.strTextContent = self.txtViewContent.text;
    }
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
    self.m_messageVo.voteVo = self.voteVo;
    
    //schedule
    self.m_messageVo.scheduleVo = self.scheduleVo;
    
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
    
    //标签列表
    
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

//add tag
-(void)addTag:(UIButton*)sender
{
    
}

//tool view button
- (void)clickToolViewBtn:(UIButton*)sender
{
    if (self.keyboardIsShow || self.toolView.frame.origin.y == kScreenHeight)
    {
        [[Utils findFirstResponderBeneathView:self.view] resignFirstResponder];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.toolView.frame = CGRectMake(0, kScreenHeight-TOOL_VIEW_HEIGHT, kScreenWidth, TOOL_VIEW_HEIGHT);
            self.attachView.frame = CGRectMake(0, kScreenHeight-TOOL_VIEW_HEIGHT-self.attachView.frame.size.height, kScreenWidth, self.attachView.frame.size.height);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.toolView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, KEYBOARD_HEIGHT);
            self.attachView.frame = CGRectMake(0, kScreenHeight-self.attachView.frame.size.height, kScreenWidth, self.attachView.frame.size.height);
        }];
    }
}

//1.将ALAsset对象转化为 AttachmentVo
-(void)transferAssetsToAttachmentVo:(NSMutableArray *)aryAssets
{
    if (aryAssets != nil)
    {
        [self.attachList removeAllObjects];
        [self.toolView deleteAllSubView];
        
        //如果外部照片分享传入
        if (self.strShareImgPath != nil && self.imgShareThumb!= nil)
        {
            [self addAttachmentWithPath:self.strShareImgPath image:self.imgShareThumb andType:0];
        }
        
        NSInteger nIndex = self.attachList.count;
        for (int i=0;i<aryAssets.count;i++,nIndex++)
        {
            ALAsset *asset = aryAssets[i];
            ALAssetRepresentation* representation = [asset defaultRepresentation];
            [representation orientation];
            
            //图片缩放处理
            UIImage *imageToSave = [UIImage imageWithCGImage:[representation fullScreenImage] scale:0.8 orientation:UIImageOrientationUp];
            CGSize sizeImage = [representation dimensions];
            if (sizeImage.width>IMAGE_MAX_SIZE && sizeImage.height>IMAGE_MAX_SIZE)
            {
                sizeImage = CGSizeMake(1024, (1024*sizeImage.height)/sizeImage.width);
            }
            imageToSave = [ResizeImage imageWithImage:imageToSave scaledToSize:sizeImage];
            
            //保存图片
            NSData *imageData = UIImageJPEGRepresentation(imageToSave, 0.8f);
            //自动清理上次产生的图片以及目录"tmp/TempFile"
            NSString *imagePath = [[Utils getTempPath] stringByAppendingPathComponent:[Common createImageNameByDateTimeAndPara:nIndex]];
            [imageData writeToFile:imagePath atomically:YES];
            
            AttachmentVo *attachmentVo = [[AttachmentVo alloc]init];
            attachmentVo.nAttachType = 0;
            attachmentVo.strAttachLocalPath = imagePath;
            [self.attachList addObject:attachmentVo];
            [self.toolView addImageToContent:imageToSave index:nIndex target:self action:@selector(previewButton:)];
        }
    }
}

//2.将拍照产生的ALAsset对象转化为AttachmentVo
-(void)addAssetToAttachmentVo:(ALAsset *)asset
{
    if (asset != nil)
    {
        ALAssetRepresentation* representation = [asset defaultRepresentation];
        [representation orientation];
        
        //图片缩放处理
        UIImage *imageToSave = [UIImage imageWithCGImage:[representation fullScreenImage] scale:0.8 orientation:UIImageOrientationUp];
        CGSize sizeImage = [representation dimensions];
        if (sizeImage.width>IMAGE_MAX_SIZE && sizeImage.height>IMAGE_MAX_SIZE)
        {
            sizeImage = CGSizeMake(1024, (1024*sizeImage.height)/sizeImage.width);
        }
        imageToSave = [ResizeImage imageWithImage:imageToSave scaledToSize:sizeImage];
        
        //保存图片
        NSData *imageData = UIImageJPEGRepresentation(imageToSave, 0.8f);
        //自动清理上次产生的图片以及目录"tmp/TempFile"
        NSString *imagePath = [[Utils getTempPath] stringByAppendingPathComponent:[Common createImageNameByDateTimeAndPara:0]];
        [imageData writeToFile:imagePath atomically:YES];
        
        AttachmentVo *attachmentVo = [[AttachmentVo alloc]init];
        attachmentVo.nAttachType = 0;
        attachmentVo.strAttachLocalPath = imagePath;
        NSUInteger count = self.attachList.count;
        [self.attachList addObject:attachmentVo];
        [self.toolView addImageToContent:imageToSave index:count target:self action:@selector(previewButton:)];
        
        if (self.aryAssets == nil)
        {
            self.aryAssets = [NSMutableArray array];
        }
        [self.aryAssets addObject:asset];
    }
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Notification
//键盘侦听事件
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.scrollViewPublic.contentInset.top, 0.0, kbSize.height, 0.0);
    self.scrollViewPublic.contentInset = contentInsets;
    self.scrollViewPublic.scrollIndicatorInsets = contentInsets;
    //[self.scrollViewPublic scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    self.attachView.frame = CGRectMake(0, kScreenHeight-kbSize.height-self.attachView.frame.size.height, kScreenWidth, self.attachView.frame.size.height);
    self.toolView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, TOOL_VIEW_HEIGHT);
    [UIView commitAnimations];
    
    self.keyboardIsShow = YES;
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.scrollViewPublic.contentInset.top, 0.0, 0.0, 0.0);
    self.scrollViewPublic.contentInset = contentInsets;
    self.scrollViewPublic.scrollIndicatorInsets = contentInsets;
    //[self.publishTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    self.attachView.frame = CGRectMake(0, kScreenHeight-self.attachView.frame.size.height, kScreenWidth, self.attachView.frame.size.height);
    [UIView commitAnimations];
    
    self.keyboardIsShow = NO;
}

#pragma mark - Tool view delegate
//拍照
- (void)cameraButton:(id)sender
{
    if (self.attachList.count >= 9)
    {
        [Common bubbleTip:@"最多选择9张照片" andView:self.view];
    }
    else
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
            return;
        }
        
        //判断隐私中相机是否启用
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus != AVAuthorizationStatusAuthorized && authStatus != AVAuthorizationStatusNotDetermined)
        {
            [Common tipAlert:[NSString stringWithFormat:@"请在iPhone的“设置-隐私-相机”选项中，允许%@访问你的相机。",APP_NAME]];
            return;
        }
        
        UIImagePickerController *photoController = [[UIImagePickerController alloc] init];
        photoController.delegate = self;
        photoController.sourceType = UIImagePickerControllerSourceTypeCamera;
        photoController.mediaTypes = @[(NSString*)kUTTypeImage];
        photoController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        photoController.allowsEditing = NO;
        [self presentViewController:photoController animated:YES completion:nil];
    }
}

//相册
- (void)photoButton:(id)sender
{
    if (self.attachList.count >= 9)
    {
        [Common bubbleTip:@"最多选择9张照片" andView:self.view];
    }
    else
    {
        if (self.aryAssets == nil)
        {
            self.aryAssets = [NSMutableArray array];
        }
        
        CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
        picker.assetsFilter = [ALAssetsFilter allPhotos];
        picker.delegate = self;
        picker.selectedAssets = [NSMutableArray arrayWithArray:self.aryAssets];//共用一个数组引用，需要重新初始化一个
        [self presentViewController:picker animated:YES completion:^(void){}];
    }
}

#pragma mark - Assets Picker Delegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:^(void){
        
    }];
    
    self.aryAssets = [NSMutableArray arrayWithArray:assets];
    [self transferAssetsToAttachmentVo:self.aryAssets];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAssetForSelection:(ALAsset *)asset
{
    // Enable video clips if they are at least 5s
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
    {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return lround(duration) >= 5;
    }
    else
    {
        return YES;
    }
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    NSInteger nMaxUploadNum = 9;
    if (self.strShareImgPath != nil && self.imgShareThumb!= nil)
    {
        nMaxUploadNum = 8;
    }
    if (picker.selectedAssets.count >= nMaxUploadNum)
    {
        [Common bubbleTip:[NSString stringWithFormat:@"最多选择%li张照片",(long)nMaxUploadNum] andView:picker.view];
    }
    
    if (!asset.defaultRepresentation)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Your asset has not yet been downloaded to your device"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    
    return (picker.selectedAssets.count < nMaxUploadNum && asset.defaultRepresentation != nil);
}
//默认进入相机胶卷相册
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker isDefaultAssetsGroup:(ALAssetsGroup *)group
{
    return ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos);
}

#pragma mark - UIImagePickerControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //    [navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor blackColor]}];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSUInteger nAttachAndImageCount = self.attachList.count;
    if (nAttachAndImageCount >= 9) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"最大允许上传照片个数为9个。"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage;
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //保存到系统相册,然后获取ALAsset
        ALAssetsLibrary *library = [Common defaultAssetsLibrary];
        [library writeImageToSavedPhotosAlbum:[originalImage CGImage] orientation:(ALAssetOrientation)[originalImage imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
            if (error == nil)
            {
                [library assetForURL:assetURL resultBlock:^(ALAsset *asset){
                    [self addAssetToAttachmentVo:asset];
                } failureBlock:^(NSError *error ){
                    DLog(@"Error loading asset");
                }];
            }
            else
            {
                [Common tipAlert:error.localizedDescription];
            }
        }];
    }
    [picker  dismissViewControllerAnimated:YES completion: nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker  dismissViewControllerAnimated:YES completion:nil];
}

//nType,0:图片，1:附件
- (void)addAttachmentWithPath:(NSString *)path image:(UIImage *)image andType:(int)nType
{
    AttachmentVo *attachmentVo = [[AttachmentVo alloc]init];
    attachmentVo.nAttachType = nType;
    attachmentVo.strAttachLocalPath = path;
    NSUInteger count = [self.attachList count];
    [self.attachList addObject:attachmentVo];
    [self.toolView addImageToContent:image index:count target:self action:@selector(previewButton:)];
}

- (void)previewButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    self.previewButton = button;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"预览", @"移除", nil];
    actionSheet.tag = button.tag;
    [actionSheet showInView:self.view];
}

#pragma mark - Action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUInteger tag = self.previewButton.tag;
    AttachmentVo *attachmentVo = [self.attachList objectAtIndex:tag];
    if (buttonIndex == 0)
    {
        //预览
        if (attachmentVo.nAttachType == 0)
        {
            //图片
            NSMutableArray *aryImageURL = [NSMutableArray array];
            for (AttachmentVo *attachmentVo  in self.attachList)
            {
                if (attachmentVo.strAttachLocalPath == nil)
                {
                    continue;
                }
                
                NSURL *urlMax = [NSURL fileURLWithPath:attachmentVo.strAttachLocalPath];
                NSURL *urlMin = [NSURL fileURLWithPath:attachmentVo.strAttachLocalPath];
                
                if (urlMax == nil || urlMin == nil)
                {
                    continue;
                }
                
                NSArray *ary = @[urlMax,urlMin];
                [aryImageURL addObject:ary];
            }
            
            SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
            dataSource.images_ = aryImageURL;
            KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
                                                                      initWithDataSource:dataSource
                                                                      andStartWithPhotoAtIndex:tag];
            photoScrollViewController.bShowToolBarBtn = NO;
            [self.navigationController pushViewController:photoScrollViewController animated:YES];
        }
        else
        {
            //other attachment
        }
    }
    else if (buttonIndex == 1)
    {
        //移除
        if (attachmentVo.strAttachLocalPath)
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL fileExists = [fileManager fileExistsAtPath:attachmentVo.strAttachLocalPath];
            if (fileExists)
            {
                [fileManager removeItemAtPath:attachmentVo.strAttachLocalPath error:nil];
            }
            
            [self.attachList removeObjectAtIndex:tag];
            [self.toolView deleteSubView:tag];
            
            //如果删除外部分享照片
            if (self.strShareImgPath != nil && self.imgShareThumb!= nil && tag == 0)
            {
                self.strShareImgPath = nil;
                self.imgShareThumb = nil;
            }
            else
            {
                [self.aryAssets removeObjectAtIndex:tag];
            }
        }
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

@end
