//
//  ActivityDetailOldViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-5-29.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "ActivityDetailOldViewController.h"
#import "FullScreenWebViewController.h"
//#import "UserCenterViewController.h"
//#import "CommentMainViewController.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extras.h"
#import "Utils.h"
#import "PraiseVo.h"
#import "SDWebImageDataSource.h"
#import "KTPhotoScrollViewController.h"
#import "ActivityProjectVo.h"
#import "ActivityProjectOldViewController.h"
#import "PublishMessageViewController.h"
#import "AttachmentVo.h"
#import "DocViewController.h"
#import "FileBrowserViewController.h"
#import "Common.h"
#import "SkinManage.h"
#import "DepartmentVo.h"
#import "FieldVo.h"
#import "CommonNavigationController.h"
#import "ActivityService.h"
#import "UIViewExt.h"

#import "ActivitySuccessViewController.h"
#import "ActivityProjectViewController.h"

@interface ActivityDetailOldViewController ()

@end

@implementation ActivityDetailOldViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PublishNewComment" object:nil];
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
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(publishNewComment) name:@"PublishNewComment" object:nil];
    
    self.aryProjectList = [[NSMutableArray alloc] init];
    self.dicOffsetY = [[NSMutableDictionary alloc]init];
    self.bReturnRefresh = NO;
    [self initView];
    [self initProjectListData];
    [self refreshBlogVoData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//加载项目列表
- (void)initProjectListData
{
//    self.nWebViewHeight = 1;
//    if (self.m_blogVo.streamId.length == 0)
//    {
//        [Common tipAlert:@"数据异常，请求失败"];
//        return;
//    }
//    [self isHideActivity:NO];
//    [ActivityService getActivityProjectList:self.m_blogVo.streamId result:^(ServerReturnInfo *retInfo) {
//        [self isHideActivity:YES];
//        if (retInfo.bSuccess)
//        {
//            self.aryProjectList = retInfo.data;
//        }
//        else
//        {
//            [Common tipAlert:retInfo.strErrorMsg];
//        }
//    }];
}

//刷新报名BlogVo
- (void)refreshBlogVoData
{
    [self isHideActivity:NO];
    [ServerProvider getShareDetailBlog:self.m_blogVo.streamId type:@"blog" result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            self.m_blogVo = retInfo.data;
            [self refreshView];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)initView
{
    [self setTopNavBarTitle:@"活动"];
    self.nWebViewHeight = 1;
    self.view.backgroundColor = COLOR(242, 242, 242, 1.0);
    
    //UIScrollView
    self.m_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-50)];
    self.m_scrollView.backgroundColor = [UIColor clearColor];
    self.m_scrollView.delegate = self;
    self.m_scrollView.autoresizingMask = NO;
    self.m_scrollView.clipsToBounds = YES;
    [self.view addSubview:self.m_scrollView];
    
    //0. container
    self.viewContainer = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewContainer.backgroundColor = [UIColor whiteColor];
    self.viewContainer.layer.borderColor = [COLOR(211, 211, 211, 1.0) CGColor];
    [self.viewContainer.layer setBorderWidth:0.5];
	[self.viewContainer.layer setCornerRadius:6];
	[self.viewContainer.layer setMasksToBounds:YES];
    [self.m_scrollView addSubview:self.viewContainer];
    
    //1. 标题
    self.lblArticleTitle = [[UILabel alloc]init];
    self.lblArticleTitle.font = [UIFont boldSystemFontOfSize:16];
    self.lblArticleTitle.numberOfLines = 0;
    self.lblArticleTitle.textColor = COLOR(0, 0, 0, 1.0);
    [self.m_scrollView addSubview:_lblArticleTitle];
    
    //2. lineview
    self.viewLine1 = [[UIView alloc]init];
    self.viewLine1.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:self.viewLine1];
    
    //3.content
    self.webViewContent = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.webViewContent.delegate = self;
    [self.webViewContent setAutoresizesSubviews:YES];
    [self.webViewContent setAutoresizingMask:UIViewAutoresizingNone];
    [self.webViewContent setUserInteractionEnabled:YES];
    //内容小于frame时纵向不滚动
    self.webViewContent.scrollView.alwaysBounceVertical = NO;
    [self.webViewContent setOpaque:NO ]; //透明
    self.webViewContent.backgroundColor=[UIColor whiteColor];
    [self.m_scrollView addSubview: self.webViewContent];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleWebViewImage:)];
    tap.delegate = self;
    [self.webViewContent addGestureRecognizer:tap];
    
    //活动备注信息
    self.lblActivityRemark = [[UILabel alloc]init];
    self.lblActivityRemark.font = [UIFont boldSystemFontOfSize:14];
    self.lblActivityRemark.numberOfLines = 0;
    self.lblActivityRemark.textColor = COLOR(233, 139, 150, 1.0);
    self.lblActivityRemark.lineBreakMode = NSLineBreakByWordWrapping;
    [self.m_scrollView addSubview:self.lblActivityRemark];
    
    //附件列表
    
    //项目列表
    
    //会议报名
    [self initMeetingView];
    
    //4. 头像
    self.imageHead = [[UIImageView alloc]init];
    self.imageHead.image = [UIImage imageNamed:@"default_m"];
    self.imageHead.userInteractionEnabled = YES;
    [self.imageHead.layer setMasksToBounds:YES];
    [self.imageHead.layer setBorderWidth:1.0];
    [self.imageHead.layer setCornerRadius:3];
    _imageHead.layer.borderColor = [[UIColor clearColor]CGColor];
    [self.m_scrollView addSubview:_imageHead];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeaderImageView)];
    [self.imageHead addGestureRecognizer:singleTap];
    
    //5. 发件人名称
    self.lblName = [[UILabel alloc]init];
    self.lblName.font = [UIFont fontWithName:APP_FONT_NAME size:17];
    self.lblName.textColor = COLOR(0, 0, 0, 1.0);
    [self.m_scrollView addSubview:_lblName];
    
    //时间
    self.lblTime = [[UILabel alloc]init];
    self.lblTime.font = [UIFont fontWithName:APP_FONT_NAME size:13];
    self.lblTime.textColor = COLOR(153, 153, 153, 1.0);
    self.lblTime.textAlignment = NSTextAlignmentRight;
    [self.m_scrollView addSubview:_lblTime];
    
    //赞列表
    self.lblPraiseDetail = [[UILabel alloc] initWithFrame:CGRectZero];
    self.lblPraiseDetail.backgroundColor = [UIColor clearColor];
    self.lblPraiseDetail.font = [UIFont systemFontOfSize:14];
    self.lblPraiseDetail.textAlignment = NSTextAlignmentLeft;
    self.lblPraiseDetail.textColor = COLOR(153, 153, 153, 1.0);
    self.lblPraiseDetail.numberOfLines = 0;
    [self.m_scrollView addSubview:self.lblPraiseDetail];
    
    self.lblPraiseDes = [[UILabel alloc] initWithFrame:CGRectZero];
    self.lblPraiseDes.backgroundColor = [UIColor clearColor];
    self.lblPraiseDes.font = [UIFont systemFontOfSize:14];
    self.lblPraiseDes.textAlignment = NSTextAlignmentLeft;
    self.lblPraiseDes.lineBreakMode = NSLineBreakByTruncatingTail;
    self.lblPraiseDes.textColor = COLOR(51, 51, 51, 1.0);
    [self.m_scrollView addSubview:self.lblPraiseDes];
    
    self.btnShowDetail = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.btnShowDetail setTitleColor:COLOR(51, 149, 215, 1.0) forState:UIControlStateNormal];
    [self.btnShowDetail.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0]];
    self.btnShowDetail.frame = CGRectZero;
    [self.btnShowDetail addTarget:self action:@selector(showDetailReceiverList) forControlEvents:UIControlEventTouchUpInside];
    [self.m_scrollView addSubview:self.btnShowDetail];

    //6. 底部按钮
    self.viewBottom = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight-50, kScreenWidth, 50)];
    self.viewBottom.backgroundColor = COLOR(249, 249, 249, 1.0);
    [self.view addSubview:_viewBottom];
    
    self.imgViewTabLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 1.5)];
    self.imgViewTabLine.image = [[UIImage imageNamed:@"tab_line"]stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [self.viewBottom addSubview:self.imgViewTabLine];
    
    CGFloat fTabW = kScreenWidth/3;
    //赞
    self.btnPraise = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnPraise.frame = CGRectMake(0, 0, fTabW, 50);
    [self.btnPraise setTitleColor:COLOR(93, 93, 93, 1.0) forState:UIControlStateNormal];
    [self.btnPraise setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    self.btnPraise.titleEdgeInsets = UIEdgeInsetsMake(22,0,0,0);
    [self.btnPraise.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:14.0]];
    [self.btnPraise setBackgroundImage:[[UIImage imageNamed:@"btn_share_praise"] stretchableImageWithLeftCapWidth:22 topCapHeight:0] forState:UIControlStateNormal];
    self.btnPraise.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btnPraise.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.btnPraise addTarget:self action:@selector(doPraise) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBottom addSubview:self.btnPraise];
    
    UIView *viewSeparate = [[UIView alloc]initWithFrame:CGRectMake(self.btnPraise.right, 15, 0.5, 20)];
    viewSeparate.backgroundColor = COLOR(188, 188, 188, 1.0);
    [self.viewBottom addSubview:viewSeparate];
    
    //转发
    self.btnForward = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnForward.frame = CGRectMake(fTabW, 0, fTabW, 50);
    [self.btnForward setTitleColor:COLOR(93, 93, 93, 1.0) forState:UIControlStateNormal];
    [self.btnForward setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    self.btnForward.titleEdgeInsets = UIEdgeInsetsMake(22,0,0,0);
    [self.btnForward.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:14.0]];
    [self.btnForward setBackgroundImage:[UIImage imageNamed:@"btn_share_forward"] forState:UIControlStateNormal];
    self.btnForward.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btnForward.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.btnForward setTitle:@"转发" forState:UIControlStateNormal];
    [self.btnForward addTarget:self action:@selector(doForward) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBottom addSubview:self.btnForward];
    
    viewSeparate = [[UIView alloc]initWithFrame:CGRectMake(self.btnForward.right, 15, 0.5, 20)];
    viewSeparate.backgroundColor = COLOR(188, 188, 188, 1.0);
    [self.viewBottom addSubview:viewSeparate];
    
    //评论
    self.btnComment = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnComment.frame = CGRectMake(fTabW*2, 0, kScreenWidth-2*fTabW, 50);
    [self.btnComment setTitleColor:COLOR(93, 93, 93, 1.0) forState:UIControlStateNormal];
    [self.btnComment setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    self.btnComment.titleEdgeInsets = UIEdgeInsetsMake(22,0,0,0);
    [self.btnComment.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:14.0]];
    [self.btnComment setBackgroundImage:[UIImage imageNamed:@"btn_share_comment_107"] forState:UIControlStateNormal];
    self.btnComment.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btnComment.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.btnComment addTarget:self action:@selector(doReply) forControlEvents:UIControlEventTouchUpInside];
    [self.viewBottom addSubview:self.btnComment];
    
    self.pickerDepartment = [[CustomPicker alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 260) andDelegate:self];
    self.pickerDepartment.delegate = self;
    [self.view addSubview:self.pickerDepartment];
}

//初始化报名UI
-(void)initMeetingView
{
    self.viewMeetingContainer = [[UIView alloc]init];
    self.viewMeetingContainer.backgroundColor = COLOR(230, 230, 230, 1.0);
    self.viewMeetingContainer.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.viewMeetingContainer.layer setBorderWidth:0.5];
    [self.viewMeetingContainer.layer setCornerRadius:6];
    [self.viewMeetingContainer.layer setMasksToBounds:YES];
    [self.m_scrollView addSubview:self.viewMeetingContainer];
    self.viewMeetingContainer.hidden = YES;
    
    self.lblRealName = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblRealName.clipsToBounds = YES;
    self.lblRealName.font = [UIFont boldSystemFontOfSize:15];
    self.lblRealName.textColor = COLOR(84, 84, 84, 1.0);
    self.lblRealName.backgroundColor = [UIColor clearColor];
    self.lblRealName.text = @"姓名";
    [self.viewMeetingContainer addSubview:self.lblRealName];
    
    self.txtRealName = [[InsetsTextField alloc]initWithFrame:CGRectZero];
    self.txtRealName.background = [UIImage imageNamed:@"txt_signup_bk"];
    self.txtRealName.delegate = self;
    self.txtRealName.font = [UIFont systemFontOfSize:15.0];
    self.txtRealName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.viewMeetingContainer addSubview:self.txtRealName];
    
    self.lblGender = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblGender.clipsToBounds = YES;
    self.lblGender.font = [UIFont boldSystemFontOfSize:15];
    self.lblGender.textColor = COLOR(84, 84, 84, 1.0);
    self.lblGender.backgroundColor = [UIColor clearColor];
    self.lblGender.text = @"性别";
    [self.viewMeetingContainer addSubview:self.lblGender];
    
    self.txtGender = [[InsetsTextField alloc]initWithFrame:CGRectZero];
    self.txtGender.background = [UIImage imageNamed:@"txt_signup_bk"];
    self.txtGender.delegate = self;
    self.txtGender.font = [UIFont systemFontOfSize:15.0];
    self.txtGender.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.viewMeetingContainer addSubview:self.txtGender];
    
    self.lblPhoneNum = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblPhoneNum.clipsToBounds = YES;
    self.lblPhoneNum.font = [UIFont boldSystemFontOfSize:15];
    self.lblPhoneNum.textColor = COLOR(84, 84, 84, 1.0);
    self.lblPhoneNum.backgroundColor = [UIColor clearColor];
    self.lblPhoneNum.text = @"电话";
    [self.viewMeetingContainer addSubview:self.lblPhoneNum];
    
    self.txtPhoneNum = [[InsetsTextField alloc]initWithFrame:CGRectZero];
    self.txtPhoneNum.background = [UIImage imageNamed:@"txt_signup_bk"];
    self.txtPhoneNum.delegate = self;
    self.txtPhoneNum.font = [UIFont systemFontOfSize:15.0];
    self.txtPhoneNum.keyboardType = UIKeyboardTypePhonePad;
    self.txtPhoneNum.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.viewMeetingContainer addSubview:self.txtPhoneNum];
    
    self.lblEmail = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblEmail.clipsToBounds = YES;
    self.lblEmail.font = [UIFont boldSystemFontOfSize:15];
    self.lblEmail.textColor = COLOR(84, 84, 84, 1.0);
    self.lblEmail.backgroundColor = [UIColor clearColor];
    self.lblEmail.text = @"邮箱";
    [self.viewMeetingContainer addSubview:self.lblEmail];
    
    self.txtEmail = [[InsetsTextField alloc]initWithFrame:CGRectZero];
    self.txtEmail.background = [UIImage imageNamed:@"txt_signup_bk"];
    self.txtEmail.delegate = self;
    self.txtEmail.font = [UIFont systemFontOfSize:15.0];
    self.txtEmail.keyboardType = UIKeyboardTypeEmailAddress;
    self.txtEmail.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.viewMeetingContainer addSubview:self.txtEmail];
    
    self.lblDepartment = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblDepartment.clipsToBounds = YES;
    self.lblDepartment.font = [UIFont boldSystemFontOfSize:15];
    self.lblDepartment.textColor = COLOR(84, 84, 84, 1.0);
    self.lblDepartment.backgroundColor = [UIColor clearColor];
    self.lblDepartment.text = @"所属公司";
    [self.viewMeetingContainer addSubview:self.lblDepartment];
    
    self.txtDepartment = [[InsetsTextField alloc]initWithFrame:CGRectZero];
    self.txtDepartment.background = [UIImage imageNamed:@"txt_signup_bk"];
    self.txtDepartment.delegate = self;
    self.txtDepartment.font = [UIFont systemFontOfSize:15.0];
    self.txtDepartment.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.viewMeetingContainer addSubview:self.txtDepartment];
    
    self.btnSignup = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnSignup setTitleColor:COLOR(255, 255, 255, 1.0) forState:UIControlStateNormal];
    [self.btnSignup setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [self.btnSignup.titleLabel setFont:[UIFont boldSystemFontOfSize:23]];
    [self.btnSignup setBackgroundImage:[SkinManage imageNamed:@"activity_project_state"] forState:UIControlStateNormal];
    [self.btnSignup addTarget:self action:@selector(signupMeeting) forControlEvents:UIControlEventTouchUpInside];
    [self.viewMeetingContainer addSubview:self.btnSignup];
}

- (void)refreshView
{
    if (self.m_blogVo == nil)
    {
        return;
    }
    
    CGFloat fHeight = 28;
    
    //1. 标题
    self.lblArticleTitle.text = self.m_blogVo.strTitle;
    CGSize sizeTitle = [Common getStringSize:self.lblArticleTitle.text font:self.lblArticleTitle.font bound:CGSizeMake(kScreenWidth-50, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    self.lblArticleTitle.frame = CGRectMake(25,fHeight,kScreenWidth-50,sizeTitle.height);
    fHeight += sizeTitle.height;
    
    //2. lineview
    fHeight += 5;
    self.viewLine1.frame = CGRectMake(25, fHeight, kScreenWidth-50, 0.5);
    
    //3.content(webview)
    fHeight += 5;
    self.webViewContent.frame = CGRectMake(16.5, fHeight, kScreenWidth-33, self.nWebViewHeight);
    NSString *strContent = self.m_blogVo.strContent;
    if(self.m_blogVo.scheduleVo != nil)
    {
        strContent = [strContent stringByAppendingString:self.m_blogVo.scheduleVo.strScheduleContent];
    }
    [self.webViewContent loadHTMLString:strContent baseURL:nil];
    fHeight += self.nWebViewHeight;
    
    //活动备注信息,判断前N名字段是否小于0，小于0不显示，大于0则显示
    if(self.m_blogVo.nActivityJoinRank >= 0)
    {
        NSString *strTip = [NSString stringWithFormat:@"该活动前 %li 位报名者可获得 %li 积分，其余可获得 %li 积分。",(long)self.m_blogVo.nActivityJoinRank,(long)self.m_blogVo.nUpIntegral,(long)self.m_blogVo.nDownIntegral];
        self.lblActivityRemark.text = strTip;
        CGSize sizeRemark = [Common getStringSize:strTip font:self.lblActivityRemark.font bound:CGSizeMake(kScreenWidth-30, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        fHeight += 5;
        self.lblActivityRemark.frame = CGRectMake(25, fHeight, kScreenWidth-50, sizeRemark.height);
        fHeight += sizeRemark.height;
    }
    else
    {
        self.lblActivityRemark.frame = CGRectZero;
    }
    
    //附件列表
    fHeight += [self initAttachmentView:fHeight];
    
    if (self.m_blogVo.nComefrom == 14)
    {
        //会议报名 会议报名表单
        self.viewMeetingContainer.hidden = NO;
        fHeight += [self refreshMeetingView:fHeight];
    }
    else
    {
        //活动报名 项目列表
        fHeight += 15;
        self.viewMeetingContainer.hidden = YES;
        fHeight += [self initProjectListView:fHeight];
    }
    
    //5 头像
    fHeight += 20;
    self.imageHead.frame = CGRectMake(25,fHeight,40,40);
    UIImage *phImageName = [[UIImage imageNamed:@"default_m"]roundedWithSize:CGSizeMake(40,40)];
    [self.imageHead sd_setImageWithURL:[NSURL URLWithString:self.m_blogVo.vestImg] placeholderImage:phImageName];
    
    //6 姓名
    self.lblName.frame = CGRectMake(70,fHeight+11.5,kScreenWidth-120,20);
    self.lblName.text  = self.m_blogVo.strCreateByName;
    
    //7 时间
    self.lblTime.frame = CGRectMake(kScreenWidth-170,fHeight+13.5,145,13);
    self.lblTime.text  = [Common getDateTimeAndNoSecond:self.m_blogVo.strCreateDate];
    fHeight += 40;
    
    //赞列表
    if ([self.m_blogVo.aryPraiseList count] > 0)
    {
        if (self.bShow)
        {
            //已展开
            [_btnShowDetail setTitle:@"隐藏详情" forState:UIControlStateNormal];
            self.btnShowDetail.frame = CGRectMake(kScreenWidth-70, fHeight+5, 56, 27);
            
            self.lblPraiseDes.frame = CGRectZero;
            NSMutableString *strValue = [[NSMutableString alloc] init];
            [strValue appendString:@"赞："];
            for (int i =0 ;i < [self.m_blogVo.aryPraiseList count];i++)
            {
                PraiseVo *praiseVo = [self.m_blogVo.aryPraiseList objectAtIndex:i];
                if (i == [self.m_blogVo.aryPraiseList count] - 1)
                {
                    [strValue appendString:praiseVo.strAliasName];
                }
                else
                {
                    [strValue appendString:praiseVo.strAliasName];
                    [strValue appendString:@"、"];
                }
            }
            if (strValue.length>0)
            {
                CGSize sizeValue = [Common getStringSize:strValue font:self.lblPraiseDetail.font bound:CGSizeMake(kScreenWidth-95, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
                self.lblPraiseDetail.text = strValue;
                self.lblPraiseDetail.frame = CGRectMake(25, fHeight+10, kScreenWidth-95, sizeValue.height);
                if (sizeValue.height > 17)
                {
                    _btnShowDetail.hidden = NO;
                }
                else
                {
                    _btnShowDetail.hidden = YES;
                }
                fHeight += sizeValue.height + 16;
            }
            else
            {
                self.lblPraiseDetail.frame = CGRectZero;
                fHeight += 16;
            }
        }
        else
        {
            //已隐藏
            [_btnShowDetail setTitle:@"显示详情" forState:UIControlStateNormal];
            self.btnShowDetail.frame = CGRectMake(kScreenWidth-70, fHeight+5, 56, 27);
            
            NSMutableString *strReceiver = [NSMutableString string];
            [strReceiver appendString:@"赞："];
            for (int i =0 ;i < [self.m_blogVo.aryPraiseList count];i++)
            {
                PraiseVo *praiseVo = [self.m_blogVo.aryPraiseList objectAtIndex:i];
                if (i == [self.m_blogVo.aryPraiseList count] - 1)
                {
                    [strReceiver appendString:praiseVo.strAliasName];
                }
                else
                {
                    [strReceiver appendString:praiseVo.strAliasName];
                    [strReceiver appendString:@"、"];
                }
            }
            
            self.lblPraiseDes.text = strReceiver;
            self.lblPraiseDes.frame = CGRectMake(25, fHeight+10, kScreenWidth-95, 17);
            
            CGSize size = [Common getStringSize:strReceiver font:self.lblPraiseDes.font bound:CGSizeMake(kScreenWidth-95, MAXFLOAT) lineBreakMode:self.lblPraiseDes.lineBreakMode];
            if (size.height > 17)
            {
                _btnShowDetail.hidden = NO;
            }
            else
            {
                _btnShowDetail.hidden = YES;
            }
            self.lblPraiseDetail.frame = CGRectZero;
            fHeight += 26;
        }
    }
    
    //8 BK view
    fHeight += 20;
    self.viewContainer.frame = CGRectMake(10,15,kScreenWidth-20,fHeight-15);
    
    fHeight += 15;
    //滚动高度
    self.m_scrollView.frame = CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT-50);
    [self.m_scrollView setContentSize:CGSizeMake(kScreenWidth,fHeight)];
    
    NSString *strPraise = [NSString stringWithFormat:@"赞 %ld", (long)self.m_blogVo.nPraiseCount];
    [self.btnPraise setTitle:strPraise forState:UIControlStateNormal];
    
    NSString *strComment = [NSString stringWithFormat:@"评论 %ld", (long)self.m_blogVo.nCommentCount];
    [self.btnComment setTitle:strComment forState:UIControlStateNormal];
}

//初始化附件视图
-(CGFloat)initAttachmentView:(CGFloat)fTopHeight
{
    CGFloat fHeight = 0.0;
    if (self.viewAttachmentContainer != nil)
    {
        [self.viewAttachmentContainer removeFromSuperview];
    }
    if(self.m_blogVo.aryAttachmentList.count == 0)
    {
        return fHeight;
    }
    
    self.viewAttachmentContainer = [[UIView alloc]init];
    self.viewAttachmentContainer.backgroundColor = [UIColor clearColor];
    
    for (int i=0; i<self.m_blogVo.aryAttachmentList.count; i++)
    {
        fHeight += 10.0;
        AttachmentVo *attachmentVo = [self.m_blogVo.aryAttachmentList objectAtIndex:i];
        
        //BK
        UIImageView *imgViewAttachmentBK = [[UIImageView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth-50, 47)];
        imgViewAttachmentBK.image = [[UIImage imageNamed:@"common_cell_bk"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
        [self.viewAttachmentContainer addSubview:imgViewAttachmentBK];
        
        //attachment icon
        UIImageView *imgViewAttachmentIcon = [[UIImageView alloc]initWithFrame:CGRectMake(8, fHeight+(47-32)/2, 32, 32)];
        imgViewAttachmentIcon.image = [UIImage imageNamed:[Common getFileIconImageByName:attachmentVo.strAttachmentName]];
        [self.viewAttachmentContainer addSubview:imgViewAttachmentIcon];
        
        //attachment name
        UILabel *lblAttachmentName = [[UILabel alloc]initWithFrame:CGRectMake(40+5, fHeight+11, kScreenWidth-118, 15)];
        lblAttachmentName.text = attachmentVo.strAttachmentName;
        lblAttachmentName.textColor = COLOR(51, 51, 51, 1.0);
        lblAttachmentName.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        lblAttachmentName.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.viewAttachmentContainer addSubview:lblAttachmentName];
        
        //attachment size
        UILabel *lblAttachmentSize = [[UILabel alloc]initWithFrame:CGRectMake(40+5, fHeight+27, kScreenWidth-118, 13)];
        lblAttachmentSize.textColor = COLOR(153, 153, 153, 1.0);
        lblAttachmentSize.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        [self.viewAttachmentContainer addSubview:lblAttachmentSize];
        if (attachmentVo.lAttachmentSize>(1024*1024))
        {
            //Mb
            lblAttachmentSize.text = [NSString stringWithFormat:@"%.2f MB",(double)attachmentVo.lAttachmentSize/(1024*1024)];
        }
        else
        {
            //Kb
            lblAttachmentSize.text = [NSString stringWithFormat:@"%.2f KB",(double)attachmentVo.lAttachmentSize/1024];
        }
        
        //attachment arrow
        UIImageView *imgViewAttachmentArrow = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth-67, fHeight+(47-13)/2, 13, 13)];
        imgViewAttachmentArrow.image = [[UIImage imageNamed:@"cell_right_arrow"] stretchableImageWithLeftCapWidth:150.5 topCapHeight:15];
        [self.viewAttachmentContainer addSubview:imgViewAttachmentArrow];
        
        //attachment button
        UIButton *btnAttachment = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAttachment.tag = 1000+i;
        btnAttachment.frame = CGRectMake(1, fHeight+1, kScreenWidth-52, 47-2);
        [btnAttachment addTarget:self action:@selector(doViewAttachment:) forControlEvents:UIControlEventTouchUpInside];
        [btnAttachment setBackgroundImage:[Common getImageWithColor:COLOR(150, 150, 150, 0.4)] forState:UIControlStateHighlighted];
        [self.viewAttachmentContainer addSubview:btnAttachment];
        [btnAttachment.layer setBorderWidth:1.0];
        [btnAttachment.layer setCornerRadius:3];
        btnAttachment.layer.borderColor = [[UIColor clearColor] CGColor];
        [btnAttachment.layer setMasksToBounds:YES];
        fHeight += 47;
    }
    self.viewAttachmentContainer.frame = CGRectMake(25, fTopHeight, kScreenWidth-50, fHeight);
    [self.m_scrollView addSubview:self.viewAttachmentContainer];
    
    return fHeight;
}

//项目列表
-(CGFloat)initProjectListView:(CGFloat)fTopHeight
{
    CGFloat fProjectHeight = 40;
    if (self.viewProjectList != nil)
    {
        [self.viewProjectList removeFromSuperview];
    }
    
    self.viewProjectList = [[UIView alloc]init];
    self.viewProjectList.backgroundColor = COLOR(230, 230, 230, 1.0);
    self.viewProjectList.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.viewProjectList.layer setBorderWidth:0.5];
    [self.viewProjectList.layer setCornerRadius:6];
    [self.viewProjectList.layer setMasksToBounds:YES];
    [self.m_scrollView addSubview:self.viewProjectList];
    
    UILabel *lblProjectTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 11.5, kScreenWidth-90, 17)];
    lblProjectTitle.font = [UIFont boldSystemFontOfSize:16];
    lblProjectTitle.textColor = COLOR(84, 84, 84, 1.0);
    lblProjectTitle.backgroundColor = [UIColor clearColor];
    lblProjectTitle.text = @"报名项目";
    [self.viewProjectList addSubview:lblProjectTitle];
    
    for (int i=0; i<self.aryProjectList.count; i++)
    {
        ActivityProjectVo *projectVo = [self.aryProjectList objectAtIndex:i];
        //bk
        UIView *viewProject = [[UIView alloc]initWithFrame:CGRectMake(20, fProjectHeight, kScreenWidth-90, 48)];
        viewProject.backgroundColor = COLOR(255, 255, 255, 1.0);
        viewProject.layer.borderColor = [[UIColor clearColor] CGColor];
        [viewProject.layer setBorderWidth:0.5];
        [viewProject.layer setCornerRadius:6];
        [viewProject.layer setMasksToBounds:YES];
        [self.viewProjectList addSubview:viewProject];
        
        //name
        UILabel *lblProjectName = [[UILabel alloc]init];
        lblProjectName.font = [UIFont fontWithName:APP_FONT_NAME size:13];
        lblProjectName.textColor = COLOR(138, 138, 138, 1.0);
        lblProjectName.text = projectVo.strProjectName;
        lblProjectName.frame = CGRectMake(35, fProjectHeight+7, kScreenWidth-125, 14);
        [self.viewProjectList addSubview:lblProjectName];
        
        //state
        UILabel *lblProjectState = [[UILabel alloc]init];
        lblProjectState.font = [UIFont fontWithName:APP_FONT_NAME size:13];
        lblProjectState.textColor = COLOR(138, 138, 138, 1.0);
        lblProjectState.frame = CGRectMake(35, fProjectHeight+24+3, kScreenWidth-125, 14);
        [self.viewProjectList addSubview:lblProjectState];
        
        if (projectVo.nStatus == 1)
        {
            lblProjectState.text = @"报名已经结束";
            lblProjectState.textColor = COLOR(138, 138, 138, 1.0);
        }
        else if (projectVo.nStatus == 2)
        {
            lblProjectState.text = @"报名尚未开始";
            lblProjectState.textColor = COLOR(207, 2, 26, 1.0);
        }
        else if (projectVo.nStatus == 3)
        {
            lblProjectState.text = @"报名正在进行";
            lblProjectState.textColor = COLOR(65, 117, 5, 1.0);
        }
        
        UILabel *lblSignupCount = [[UILabel alloc]init];
        lblSignupCount.font = [UIFont fontWithName:APP_FONT_NAME size:13];
        lblSignupCount.backgroundColor = COLOR(160, 160, 160, 1.0);
        lblSignupCount.textColor = COLOR(255, 255, 255, 1.0);
        lblSignupCount.textAlignment = NSTextAlignmentCenter;
        [lblSignupCount.layer setBorderWidth:0.5];
        [lblSignupCount.layer setCornerRadius:3.5];
        [lblSignupCount.layer setMasksToBounds:YES];
        lblSignupCount.layer.borderColor = [[UIColor clearColor] CGColor];
        lblSignupCount.text = [NSString stringWithFormat:@"%li 人",(long)projectVo.nSignupCount];
        CGSize sizeCount = [Common getStringSize:lblSignupCount.text font:lblSignupCount.font bound:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByWordWrapping];
        lblSignupCount.frame = CGRectMake(127, fProjectHeight+24+1, sizeCount.width+10, 20);
        [self.viewProjectList addSubview:lblSignupCount];
        
        //arrow
        UIImageView *imgViewArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow_gray_right"]];
        imgViewArrow.frame = CGRectMake(kScreenWidth-90, fProjectHeight+17.5, 13, 13);
        [self.viewProjectList addSubview:imgViewArrow];
        
        //UIButton
        UIButton *btnTransparent = [Utils getTransparentButton:CGRectMake(20, fProjectHeight, kScreenWidth-90, 48) target:self action:@selector(clickProjectDetail:)];
        [btnTransparent.layer setCornerRadius:6];
        btnTransparent.tag = 1000+i;
        [self.viewProjectList addSubview:btnTransparent];
        
        fProjectHeight += 48+16;
        
    }
    fProjectHeight += 10;
    self.viewProjectList.frame = CGRectMake(25, fTopHeight, kScreenWidth-50, fProjectHeight);
    
    return self.viewProjectList.frame.size.height;
}

//刷新会议报名
-(CGFloat)refreshMeetingView:(CGFloat)fTopHeight
{
    self.lblRealName.frame = CGRectZero;
    self.txtRealName.frame = CGRectZero;
    self.lblGender.frame = CGRectZero;
    self.txtGender.frame = CGRectZero;
    self.lblPhoneNum.frame = CGRectZero;
    self.txtPhoneNum.frame = CGRectZero;
    self.lblEmail.frame = CGRectZero;
    self.txtEmail.frame = CGRectZero;
    self.lblDepartment.frame = CGRectZero;
    self.txtDepartment.frame = CGRectZero;
    
    CGFloat fHeight = 0;
    if (self.m_blogVo.nSurveyFlag == 1)
    {
        //已报名
        self.btnSignup.frame = CGRectMake(22, 20, kScreenWidth-94, 46);
        [self.btnSignup setTitle:@"你已报名" forState:UIControlStateNormal];
        self.btnSignup.userInteractionEnabled = NO;
        
        self.viewMeetingContainer.frame = CGRectMake(25, fTopHeight, kScreenWidth-50, 88);
        fHeight += 88;
    }
    else if (self.m_blogVo.bOverDue)
    {
        //已过期
        self.btnSignup.frame = CGRectMake(22, 20, kScreenWidth-94, 46);
        [self.btnSignup setTitle:@"报名已经结束" forState:UIControlStateNormal];
        self.btnSignup.userInteractionEnabled = NO;
        
        self.viewMeetingContainer.frame = CGRectMake(25, fTopHeight, kScreenWidth-50, 88);
        fHeight += 88;
    }
    else if (self.m_blogVo.nSignupMemberNum >= self.m_blogVo.nTotalMemberNum)
    {
        //超过报名人数上限
        self.btnSignup.frame = CGRectMake(22, 20, kScreenWidth-94, 46);
        [self.btnSignup setTitle:@"报名人数已满" forState:UIControlStateNormal];
        self.btnSignup.userInteractionEnabled = NO;
        
        self.viewMeetingContainer.frame = CGRectMake(25, fTopHeight, kScreenWidth-50, 88);
        fHeight += 88;
    }
    else
    {
        //可以正常报名
        CGFloat fSignupH = 20;
        self.lblRealName.frame = CGRectMake(20, fSignupH+10, kScreenWidth-70, 16);
        self.txtRealName.frame = CGRectMake(20, fSignupH+35, kScreenWidth-90, 28);
        self.txtRealName.tag = 501;
        [self.dicOffsetY setObject:[NSNumber numberWithFloat:fTopHeight+fSignupH+35] forKey:@"501"];
        fSignupH += 63;
        
        self.lblGender.frame = CGRectMake(20, fSignupH+10, kScreenWidth-70, 16);
        self.txtGender.frame = CGRectMake(20, fSignupH+35, kScreenWidth-90, 28);
        self.txtGender.tag = 502;
        [self.dicOffsetY setObject:[NSNumber numberWithFloat:fTopHeight+fSignupH+35] forKey:@"502"];
        fSignupH += 63;
        
        self.lblPhoneNum.frame = CGRectMake(20, fSignupH+10, kScreenWidth-70, 16);
        self.txtPhoneNum.frame = CGRectMake(20, fSignupH+35, kScreenWidth-90, 28);
        self.txtPhoneNum.tag = 503;
        [self.dicOffsetY setObject:[NSNumber numberWithFloat:fTopHeight+fSignupH+35] forKey:@"503"];
        fSignupH += 63;
        
        self.lblEmail.frame = CGRectMake(20, fSignupH+10, kScreenWidth-70, 16);
        self.txtEmail.frame = CGRectMake(20, fSignupH+35, kScreenWidth-90, 28);
        self.txtEmail.tag = 504;
        [self.dicOffsetY setObject:[NSNumber numberWithFloat:fTopHeight+fSignupH+35] forKey:@"504"];
        fSignupH += 63;
        
        self.lblDepartment.frame = CGRectMake(20, fSignupH+10, kScreenWidth-70, 16);
        self.txtDepartment.frame = CGRectMake(20, fSignupH+35, kScreenWidth-90, 28);
        self.txtDepartment.tag = 505;
        [self.dicOffsetY setObject:[NSNumber numberWithFloat:fTopHeight+fSignupH+35] forKey:@"505"];
        fSignupH += 63;
        
        //自定义字段
        if (self.m_blogVo.aryMeetingField.count>0)
        {
            if (self.viewFieldContainer != nil)
            {
                [self.viewFieldContainer removeFromSuperview];
            }
            
            self.viewFieldContainer = [[UIView alloc]initWithFrame: CGRectMake(0, fSignupH, kScreenWidth-50, self.m_blogVo.aryMeetingField.count*63)];
            self.viewFieldContainer.backgroundColor = [UIColor clearColor];
            
            CGFloat fFieldH = 0;
            for (int i=0;i<self.m_blogVo.aryMeetingField.count;i++)
            {
                FieldVo *fieldVo = self.m_blogVo.aryMeetingField[i];
                
                UILabel *lblField = [[UILabel alloc]initWithFrame: CGRectMake(20, fFieldH+10, kScreenWidth-70, 16)];
                lblField.clipsToBounds = YES;
                lblField.font = [UIFont boldSystemFontOfSize:15];
                lblField.textColor = COLOR(84, 84, 84, 1.0);
                lblField.backgroundColor = [UIColor clearColor];
                lblField.text = fieldVo.strName;
                [self.viewFieldContainer addSubview:lblField];
                
                InsetsTextField *txtField = [[InsetsTextField alloc]initWithFrame:CGRectMake(20, fFieldH+35, kScreenWidth-90, 28)];
                txtField.background = [UIImage imageNamed:@"txt_signup_bk"];
                txtField.delegate = self;
                txtField.font = [UIFont systemFontOfSize:15.0];
                txtField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                txtField.tag = 2000+i;
                [self.dicOffsetY setObject:[NSNumber numberWithFloat:fTopHeight+fSignupH+fFieldH+35] forKey:[NSString stringWithFormat:@"%i",2000+i]];
                [self.viewFieldContainer addSubview:txtField];
                fFieldH += 63;
            }
            [self.viewMeetingContainer addSubview:self.viewFieldContainer];
            fSignupH += self.viewFieldContainer.frame.size.height;
        }
        
        self.btnSignup.frame = CGRectMake(22, fSignupH + 20, kScreenWidth-94, 46);
        self.btnSignup.userInteractionEnabled = YES;
        [self.btnSignup setTitle:@"我要报名" forState:UIControlStateNormal];
        fSignupH += 88;
        
        self.viewMeetingContainer.frame = CGRectMake(25, fTopHeight, kScreenWidth-50, fSignupH);
        fHeight = fSignupH;
    }
    return fHeight;
}

- (void)previewImage:(NSString*)url
{
    SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
    dataSource.images_ = [NSArray arrayWithObject:[NSArray arrayWithObject:[NSURL URLWithString:url]]];
    
    KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
                                                              initWithDataSource:dataSource
                                                              andStartWithPhotoAtIndex:0];
    [self.navigationController pushViewController:photoScrollViewController animated:YES];
}

- (void)handleWebViewImage:(UITapGestureRecognizer *)sender
{
    if (!self.bScrolling)
    {
        CGPoint touchPoint = [sender locationInView:self.webViewContent];
        NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).getAttribute('img-max')", touchPoint.x, touchPoint.y];
        NSString *strImgMax = [_webViewContent stringByEvaluatingJavaScriptFromString:imgURL];
        if (strImgMax != nil && strImgMax.length>0)
        {
            //先获取大图
            [self previewImage:strImgMax];
        }
        else
        {
            //大图不存在，则获取中图
            NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
            NSString *strImgSrc = [_webViewContent stringByEvaluatingJavaScriptFromString:imgURL];
            if (strImgSrc != nil && strImgSrc.length>0)
            {
                [self previewImage:strImgSrc];
            }
        }
    }
}

- (void)clickProjectDetail:(UIButton*)sender
{
    ActivityProjectVo *projectVo = [self.aryProjectList objectAtIndex:sender.tag-1000];
//    ActivityProjectOldViewController *activityProjectViewController = [[ActivityProjectOldViewController alloc]init];
//    activityProjectViewController.m_activityProjectVo = projectVo;
//    activityProjectViewController.m_blogVo = self.m_blogVo;
//    [self.navigationController pushViewController:activityProjectViewController animated:YES];
    
//    ActivitySuccessViewController *activitySuccessViewController = [[UIStoryboard storyboardWithName:@"ActivityModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ActivitySuccessViewController"];
//    activitySuccessViewController.m_activityProjectVo = projectVo;
//    activitySuccessViewController.m_blogVo = self.m_blogVo;
//    [self.navigationController pushViewController:activitySuccessViewController animated:YES];
    
    ActivityProjectViewController *activitySuccessViewController = [[UIStoryboard storyboardWithName:@"ActivityModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ActivityProjectViewController"];
    activitySuccessViewController.m_activityProjectVo = projectVo;
    activitySuccessViewController.m_blogVo = self.m_blogVo;
    [self.navigationController pushViewController:activitySuccessViewController animated:YES];

}

///////////////////////////////////////////////////////////////////////////////////
//1.赞
- (void)doPraise
{
//    [self isHideActivity:NO];
//    [ServerProvider paiserBlog:self.m_blogVo.streamId result:^(ServerReturnInfo *retInfo) {
//        [self isHideActivity:YES];
//        if (retInfo.bSuccess)
//        {
//            NSString  *paiserStr = retInfo.data;
//            if (paiserStr.length > 0)
//            {
//                //赞成功
//                _isFavorite = 0;
//                self.m_blogVo.nPraiseCount +=1;
//                //add praiseVo
//                PraiseVo *praiseVo = [[PraiseVo alloc]init];
//                praiseVo.strID = [Common getCurrentUserVo].strUserID;
//                praiseVo.strAliasName = [Common getCurrentUserVo].strUserName;
//                [self.m_blogVo.aryPraiseList addObject:praiseVo];
//            }
//            else
//            {
//                //取消赞成功
//                _isFavorite = 1;
//                self.m_blogVo.nPraiseCount -=1;
//                //remove praiseVo
//                for (PraiseVo *praiseVo in self.m_blogVo.aryPraiseList)
//                {
//                    if ([praiseVo.strID isEqualToString:[Common getCurrentUserVo].strUserID])
//                    {
//                        [self.m_blogVo.aryPraiseList removeObject:praiseVo];
//                        break;
//                    }
//                }
//            }
//            
//            [self paiserSuccess];
//            [self refreshView];
//            self.bReturnRefresh = YES;
//        }
//        else
//        {
//            [Common tipAlert:retInfo.strErrorMsg];
//        }
//    }];
}

- (void)paiserSuccess
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.mode = MBProgressHUDModeText;
    HUD.tag = 1;
    HUD.labelText = (_isFavorite == 0 ? @"点赞成功" : @"取消赞成功");
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:1];
}

//2.评论
- (void)doReply
{
//    CommentMainViewController *commentMainViewController = [[CommentMainViewController alloc]init];
//    commentMainViewController.strArticleID = self.m_blogVo.streamId;
//    [self.navigationController pushViewController:commentMainViewController animated:YES];
}

//3.转发消息
-(void)doForward
{
    MessageVo *messageVo = [[MessageVo alloc]init];
    messageVo.strID = @"";
    messageVo.strTitle = self.m_blogVo.strTitle;
    messageVo.strTextContent = self.m_blogVo.strText;
    messageVo.strAuthorName = self.m_blogVo.strCreateByName;
    messageVo.strHtmlContent = self.m_blogVo.strContent;
    
    PublishMessageViewController *publishMessageViewController = [[PublishMessageViewController alloc]init];
    publishMessageViewController.m_preMessageVo = messageVo;
    publishMessageViewController.publishMessageFromType = PublishMessageForwardType;

    CommonNavigationController *navController = [[CommonNavigationController alloc] initWithRootViewController:publishMessageViewController];
    navController.navigationBarHidden = YES;
    [self presentViewController:navController animated:YES completion:nil];
}

//选择性别
-(void)doSelectGender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    UIActionSheet *actionSheetGender = [[UIActionSheet alloc] initWithTitle:@"性别修改"
                                                                   delegate:self
                                                          cancelButtonTitle:@"取消"
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:@"男",@"女", nil];
    actionSheetGender.tag = 2001;
    [actionSheetGender showInView:self.view];
}

//选择所属公司
-(void)doSelectPickerView:(UITextField*)textField
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    if (textField == self.txtDepartment)
    {
        //部门
        [self fieldOffset:self.txtDepartment.tag];
        [self setPickerHidden:self.pickerDepartment andHide:NO];
        if (self.strDepartmentID != nil && self.strDepartmentID.length>0)
        {
            for (int i=0; i<[Common getCurrentUserVo].aryDepartmentList.count; i++)
            {
                DepartmentVo *deparmentVo = [[Common getCurrentUserVo].aryDepartmentList objectAtIndex:i];
                if ([deparmentVo.strDepartmentID isEqualToString:self.strDepartmentID])
                {
                    [self.pickerDepartment.pickerView selectRow:i inComponent:0 animated:YES];
                    break;
                }
            }
        }
    }
}

//会议报名
-(void)signupMeeting
{
    NSString *strRealName = self.txtRealName.text;
    if (strRealName.length == 0)
    {
        [Common tipAlert:@"姓名不能为空"];
        return;
    }
    
    NSString *strGender = self.txtGender.text;
    if (strGender.length == 0)
    {
        [Common tipAlert:@"性别不能为空"];
        return;
    }
    
    NSString *strPhoneNum = self.txtPhoneNum.text;
    if (strPhoneNum.length == 0)
    {
        [Common tipAlert:@"电话不能为空"];
        return;
    }
    else if (strPhoneNum.length<8 || strPhoneNum.length>11)
    {
        [Common tipAlert:@"电话号码格式不正确"];
        return;
    }
    
    NSString *strEmail = self.txtEmail.text;
    if (strEmail.length == 0)
    {
        [Common tipAlert:@"邮箱不能为空"];
        return;
    }
    else if(![Common validateEmail:strEmail])
    {
        [Common tipAlert:@"邮箱格式不正确"];
        return;
    }
    
    if (self.strDepartmentID == nil || self.strDepartmentID.length == 0)
    {
        [Common tipAlert:@"所属公司不能为空"];
        return;
    }
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    UserVo *userVo = [[UserVo alloc]init];
    //meeting id
    userVo.strMeetingID = self.m_blogVo.strRefID;
    
    userVo.strUserName = strRealName;
    if ([strGender isEqualToString:@"男"])
    {
        userVo.gender = 1;
    }
    else if ([strGender isEqualToString:@"女"])
    {
        userVo.gender = 0;
    }
    userVo.strPhoneNumber = strPhoneNum;
    userVo.strEmail = strEmail;
    userVo.strDepartmentId = self.strDepartmentID;
    
    //自定义字段（都是非必填的）
    for (int i=0; i<self.m_blogVo.aryMeetingField.count; i++)
    {
        FieldVo *fieldVo = self.m_blogVo.aryMeetingField[i];
        InsetsTextField *txtField = (InsetsTextField *)[self.viewFieldContainer viewWithTag:2000+i];
        fieldVo.strValue = txtField.text;
    }
    userVo.aryCustomField = self.m_blogVo.aryMeetingField;
    
    [self setPickerHidden:self.pickerDepartment andHide:YES];
    
    [self isHideActivity:NO];
    [ServerProvider signupMeeting:userVo result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            [self refreshBlogVoData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//显示隐藏赞列表
-(void)showDetailReceiverList
{
    self.bShow = !self.bShow;
    [self refreshView];
}

//显示隐藏UIPickerView
- (void)setPickerHidden:(UIView*)pickerViewCtrl andHide:(BOOL)hidden
{
    int nHeight = pickerViewCtrl.frame.size.height * (-1);
    CGAffineTransform transform = hidden ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, nHeight);
    pickerViewCtrl.transform = transform;
    if (!hidden)
    {
        self.viewBottom.hidden = YES;
        self.view.backgroundColor = [UIColor whiteColor];
        self.m_scrollView.frame = CGRectMake(0, NAV_BAR_HEIGHT, self.view.bounds.size.width, (kScreenHeight-NAV_BAR_HEIGHT-260+44));
    }
    else
    {
        self.viewBottom.hidden = NO;
        self.m_scrollView.frame = CGRectMake(0, NAV_BAR_HEIGHT, self.view.bounds.size.width, kScreenHeight-NAV_BAR_HEIGHT);
    }
}

//clear self.m_blogVo data
- (void)clearBlogVoData
{
    NSString *strArticleID = self.m_blogVo.streamId;
    self.m_blogVo = [[BlogVo alloc]init];
    self.m_blogVo.streamId = strArticleID;
}

- (void)backButtonClicked
{
    if (self.bReturnRefresh)
    {
        //需要刷新报名列表
        [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshActivityList" object:nil userInfo:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tapHeaderImageView
{
//    UserCenterViewController *userCenterViewController = [[UserCenterViewController alloc]init];
//    UserVo *userVo = [[UserVo alloc]init];
//    userVo.strUserID = self.m_blogVo.strCreateBy;
//    userCenterViewController.m_userVo = userVo;
//    [self.navigationController pushViewController:userCenterViewController animated:YES];
}

//new comment public then refresh data
- (void)publishNewComment
{
    self.bReturnRefresh = YES;
    [self refreshBlogVoData];
}

//attachment/////////////////////////////////////////////////////////////////////////////////
//查看附件
-(void)doViewAttachment:(UIButton*)sender
{
    FileBrowserViewController *fileBrowserViewController = [[FileBrowserViewController alloc]init];
    AttachmentVo *attachmentVo = [self.m_blogVo.aryAttachmentList objectAtIndex:(sender.tag-1000)];
    FileVo *fileVo = [[FileVo alloc]init];
    fileVo.strID = attachmentVo.strID;
    fileVo.strName = attachmentVo.strAttachmentName;
    fileVo.strFileURL = attachmentVo.strAttachmentURL;
    fileVo.lFileSize = attachmentVo.lAttachmentSize;
    fileBrowserViewController.m_fileVo = fileVo;
    [self.navigationController pushViewController:fileBrowserViewController animated:YES];
}

//调整键盘高度
-(void)fieldOffset:(NSUInteger)nTextTag
{
    //获取特定的UITextField偏移量
    float offset = [[self.dicOffsetY objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)nTextTag]] floatValue];
    //当前scrollView 偏移量
    float scrollOffset = self.m_scrollView.contentOffset.y;
    
    //键盘标准高度值
    float fHeighKey = kScreenHeight-NAV_BAR_HEIGHT-252;//中文键盘252
    //控件当前高度值（本身高度-scrollview滚动高度）
    float fCtrlHeight = offset-scrollOffset;
    
    if (fCtrlHeight>fHeighKey)
    {
        //被键盘遮挡，需要滚动到最上方
        [self.m_scrollView setContentOffset:CGPointMake(0, (offset-80)) animated:YES];//offset-10
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

#pragma mark - CustomPickerDelegate
- (void)donePickerButtonClick:(CustomPicker*)pickerViewCtrl
{
    [self setPickerHidden:pickerViewCtrl andHide:YES];
    if (pickerViewCtrl == self.pickerDepartment)
    {
        if ([Common getCurrentUserVo].aryDepartmentList.count>0)
        {
            DepartmentVo *departmentVo = [[Common getCurrentUserVo].aryDepartmentList objectAtIndex:[pickerViewCtrl getSelectedRowNum]];
            self.strDepartmentID = departmentVo.strDepartmentID;
            self.txtDepartment.text = departmentVo.strDepartmentName;
            [self.pickerDepartment.pickerView reloadComponent:0];
        }
    }
}

- (void)cancelPickerButtonClick:(CustomPicker*)pickerViewCtrl
{
    [self setPickerHidden:pickerViewCtrl andHide:YES];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 2001)
    {
        if (buttonIndex == 0)
        {
            self.txtGender.text = @"男";
        }
        else if (buttonIndex == 1)
        {
            self.txtGender.text = @"女";
        }
    }
}

#pragma mark - UITextField
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == self.txtGender)
    {
        [self doSelectGender];
        return NO;
    }
    else if(textField == self.txtDepartment)
    {
        [self doSelectPickerView:textField];
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.txtRealName)
    {
        [self.txtGender becomeFirstResponder];
    }
    else if(textField == self.txtGender)
    {
        [self.txtPhoneNum becomeFirstResponder];
    }
    else if(textField == self.txtPhoneNum)
    {
        [self.txtEmail becomeFirstResponder];
    }
    else if(textField == self.txtEmail)
    {
        [self.txtDepartment becomeFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //编辑时调整view
    [self fieldOffset:textField.tag];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView == self.webViewContent)
    {
        if (self.nWebViewHeight>1)
        {
            self.m_scrollView.hidden = NO;
            [self isHideActivity:YES];
        }
        else
        {
            CGRect frame = webView.frame;
            NSString *fitHeight = [webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
            frame.size.height = [fitHeight floatValue];
            webView.frame = frame;
            self.nWebViewHeight = frame.size.height;
            [self refreshView];
            
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        NSString *strURL = [request URL].absoluteString;
        if (strURL != nil && strURL.length>0)
        {
            NSRange range = [strURL rangeOfString:@"tel:"];
            if(range.length>0 && range.location == 0)
            {
                NSString *strPhoneTipInfo = [NSString stringWithFormat:@"您确定要呼叫 %@ ？",[strURL substringFromIndex:4]];
                if ([Common ask:strPhoneTipInfo] == 1)
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strURL]];
                }
            }
            else
            {
                FullScreenWebViewController *fullScreenWebViewController = [[FullScreenWebViewController alloc]init];
                fullScreenWebViewController.urlFile = [request URL];
                [self.parentViewController.navigationController pushViewController:fullScreenWebViewController animated:YES];
            }
        }
        return NO;
    }
    else
    {
        [self isHideActivity:NO];
    }
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == self.m_scrollView)
    {
        self.bScrolling = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.m_scrollView)
    {
        __block ActivityDetailOldViewController* bself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
            bself.bScrolling = NO;
        });
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark Picker Data Source Methods
//1 选取器组件的个数，也就是滚轮的个数
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//2 每个组件的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger nRowNum = 0;
    if (pickerView == self.pickerDepartment.pickerView)
    {
        nRowNum = [Common getCurrentUserVo].aryDepartmentList.count;
    }
    return nRowNum;
}

//3 绑定选取器上面的数据，主要是文本
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *strText = @"";
    if (pickerView == self.pickerDepartment.pickerView)
    {
        DepartmentVo *departmentVo = [[Common getCurrentUserVo].aryDepartmentList objectAtIndex:row];
        strText = departmentVo.strDepartmentName;
    }
    return strText;
}

@end
