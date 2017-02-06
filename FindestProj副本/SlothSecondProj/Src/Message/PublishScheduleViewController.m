//
//  PublishScheduleViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-6-10.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "PublishScheduleViewController.h"
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

@interface PublishScheduleViewController ()

@end

@implementation PublishScheduleViewController

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
    [self setTopNavBarTitle:@"发邀请"];
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
    self.m_messageVo.aryImageList = [NSMutableArray array];
    
    self.dicOffsetY = [[NSMutableDictionary alloc]init];
    
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
    
    //时间
    self.viewDateTime = [[UIView alloc]initWithFrame:CGRectZero];
    [self.scrollViewPublic addSubview:self.viewDateTime];
    
    self.lblDateTime = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblDateTime.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.lblDateTime.text = @"时间:";
    self.lblDateTime.textColor = COLOR(153, 153, 153, 1.0);
    self.lblDateTime.backgroundColor = [UIColor clearColor];
    [self.viewDateTime addSubview:self.lblDateTime];
    
    self.txtDateTime = [[UITextField alloc]initWithFrame:CGRectZero];
    self.txtDateTime.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.txtDateTime.textColor = COLOR(153, 153, 153, 1.0);
    self.txtDateTime.delegate = self;
    self.txtDateTime.returnKeyType = UIReturnKeyDefault;
    self.txtDateTime.tag = 502;
    [self.viewDateTime addSubview:self.txtDateTime];
    
    self.btnDateTime = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnDateTime addTarget:self action:@selector(doSelectDate:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnDateTime setBackgroundImage:[Common getImageWithColor:COLOR(150, 150, 150, 0.4)] forState:UIControlStateHighlighted];
    [self.viewDateTime addSubview:self.btnDateTime];
    
    self.pickerDateTime = [[CustomDatePicker alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 260) andDelegate:self];
    self.pickerDateTime.pickerView.datePickerMode = UIDatePickerModeDateAndTime;
    self.pickerDateTime.delegate = self;
    [self.view addSubview:self.pickerDateTime];//全局视图添加 pickView
    
    self.viewLineDateTime = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewLineDateTime.backgroundColor = COLOR(183, 183, 183, 1.0);
    [self.viewDateTime addSubview:self.viewLineDateTime];

    //地点
    self.viewPlace = [[UIView alloc]initWithFrame:CGRectZero];
    [self.scrollViewPublic addSubview:self.viewPlace];
    
    self.lblPlace = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblPlace.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.lblPlace.text = @"地点:";
    self.lblPlace.textColor = COLOR(153, 153, 153, 1.0);
    self.lblPlace.backgroundColor = [UIColor clearColor];
    [self.viewPlace addSubview:self.lblPlace];
    
    self.txtPlace = [[UITextField alloc]initWithFrame:CGRectZero];
    self.txtPlace.font = [UIFont fontWithName:@"Helvetica" size:17.0];
    self.txtPlace.textColor = COLOR(153, 153, 153, 1.0);
    self.txtPlace.delegate = self;
    self.txtPlace.returnKeyType = UIReturnKeyDefault;
    self.txtPlace.tag = 503;
    [self.viewPlace addSubview:self.txtPlace];
    
    self.viewLinePlace = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewLinePlace.backgroundColor = COLOR(183, 183, 183, 1.0);
    [self.viewPlace addSubview:self.viewLinePlace];
    
    [self refreshControlFrame];
}

- (void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    //时间
    self.viewDateTime.frame = CGRectMake(0, fHeight, kScreenWidth, 37);
    self.lblDateTime.frame = CGRectMake(15, 9.5, 40, 18);
    self.txtDateTime.frame = CGRectMake(60, 8.5, kScreenWidth-75, 20);
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"502"];
    self.btnDateTime.frame = self.txtDateTime.frame;
    self.pickerDateTime.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 260);
    self.viewLineDateTime.frame = CGRectMake(0, 36.5, kScreenWidth, 0.5);
    fHeight += 37;
    
    //地点
    self.viewPlace.frame = CGRectMake(0, fHeight, kScreenWidth, 37);
    self.lblPlace.frame = CGRectMake(15, 9.5, 40, 18);
    self.txtPlace.frame = CGRectMake(60, 8.5, kScreenWidth-75, 20);
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"503"];
    self.viewLinePlace.frame = CGRectMake(0, 36.5, kScreenWidth, 0.5);
    fHeight += 37;
    
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
    [self refreshControlFrame];
}

//发表正文
-(void)doSendMsg
{
    [self doPublicMsg:@"M"];
}

//发表草稿
-(void)doSendDraft
{
    [self doPublicMsg:@"D"];
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
    
    self.m_messageVo.scheduleVo = [[ScheduleVo alloc]init];
    //时间
    NSString *strDateTime = self.txtDateTime.text;
    if (strDateTime == nil || strDateTime.length == 0)
    {
        [Common tipAlert:@"时间不能为空"];
        return;
    }
    strDateTime = [strDateTime stringByAppendingString:@":00"];
    self.m_messageVo.scheduleVo.strStartTime = strDateTime;
    
    //地点(可为空)
    NSString *strPlace = self.txtPlace.text;
    self.m_messageVo.scheduleVo.strAddress = strPlace;
    
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

//显示隐藏时间控件
- (void)setPickerHidden:(UIView*)pickerViewCtrl andHide:(BOOL)hidden
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.35];
    
    int nHeight = pickerViewCtrl.frame.size.height * (-1);
    CGAffineTransform transform = hidden ? CGAffineTransformIdentity:CGAffineTransformMakeTranslation(0, nHeight);
    pickerViewCtrl.transform = transform;
    
    [UIView commitAnimations];
}

//调整键盘高度
-(void)fieldOffset:(NSUInteger)nTextTag
{
    //获取特定的UITextField偏移量
	float offset = [[self.dicOffsetY objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)nTextTag]] floatValue];
    //当前scrollView 偏移量
	float scrollOffset = self.scrollViewPublic.contentOffset.y;
    
    //键盘标准高度值
    float fHeighKey = kScreenHeight-NAV_BAR_HEIGHT-252;//中文键盘252
    //控件当前高度值（本身高度-scrollview滚动高度）
    float fCtrlHeight = offset-scrollOffset;
	
	if (fCtrlHeight>fHeighKey)
    {
        //被键盘遮挡，需要滚动到最上方
		[self.scrollViewPublic setContentOffset:CGPointMake(0, (offset-80)) animated:YES];//offset-10
	}
}

//隐藏键盘
-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch*touch =[touches anyObject];
	if(touch.phase==UITouchPhaseBegan)
    {
		//find first response view
		[self.txtConTitle resignFirstResponder];
        [self.txtViewContent resignFirstResponder];
        [self setPickerHidden:self.pickerDateTime andHide:YES];
        [self.txtPlace resignFirstResponder];
	}
}

//选择日期
-(void)doSelectDate:(UIButton*)sender
{
    [self fieldOffset:502];
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    if (sender == self.btnDateTime)
    {
        //出生日期
        [self setPickerHidden:self.pickerDateTime andHide:NO];
        NSString *strDate = self.txtDateTime.text;
        if (strDate.length>0)
        {
            NSDate *date = [self getDateFromDateTimeStr:strDate];
            if (date != nil)
            {
                [self.pickerDateTime.pickerView setDate:date animated:YES];
            }
        }
    }
}

-(NSDate*)getDateFromDateTimeStr:(NSString*)strDateTime
{
    NSDate *date = nil;
    if (strDateTime == nil || strDateTime.length == 0)
    {
        date = nil;
    }
    else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm"];
        date = [dateFormatter dateFromString:strDateTime];
    }
    return date;
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

#pragma mark - CustomDatePickerDelegate
- (void)doneDatePickerButtonClick:(CustomDatePicker*)pickerViewCtrl
{
    [self setPickerHidden:self.pickerDateTime andHide:YES];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm"];
    
    if (pickerViewCtrl == self.pickerDateTime)
    {
        NSDate *date = self.pickerDateTime.pickerView.date;
        self.txtDateTime.text = [dateFormatter stringFromDate:date];
    }
}

- (void)cancelDatePickerButtonClick:(CustomDatePicker*)pickerViewCtrl
{
    [self setPickerHidden:self.pickerDateTime andHide:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self setPickerHidden:self.pickerDateTime andHide:YES];
    //编辑时调整view
    [self fieldOffset:textField.tag];
}

@end
