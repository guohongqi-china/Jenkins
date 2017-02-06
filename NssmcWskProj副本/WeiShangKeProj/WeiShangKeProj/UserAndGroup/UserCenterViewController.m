//
//  UserCenterViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-17.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "UserCenterViewController.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import "Utils.h"
#import "UserEditViewController.h"
#import "ChatContentViewController.h"
#import "AlbumFolderListViewController.h"

@interface UserCenterViewController ()

@end

@implementation UserCenterViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"RefreshUserDetail" object:nil];
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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshUserDetail) name:@"RefreshUserDetail" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    self.view.backgroundColor = COLOR(241, 241, 241, 1.0);
    
    self.m_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT-51)];
    self.m_scrollView.backgroundColor = [UIColor clearColor];
    self.m_scrollView.delegate = self;
    self.m_scrollView.autoresizingMask = NO;
    self.m_scrollView.clipsToBounds = YES;
    [self.view addSubview:self.m_scrollView];
    
    //顶部信息///////////////////////////////////////////////////////////////
    self.imgViewTopBK = [[UIImageView alloc]init];
    self.imgViewTopBK.image = [UIImage imageNamed:@"user_top_bk"];
    [self.m_scrollView addSubview:self.imgViewTopBK];
    
    //head view ,name
    self.imgViewHead = [[UIImageView alloc]init];
    [self.imgViewHead.layer setBorderWidth:2.5];
    [self.imgViewHead.layer setCornerRadius:2.5];
    self.imgViewHead.layer.borderColor = [[UIColor whiteColor] CGColor];
    [self.imgViewHead.layer setMasksToBounds:YES];
    [self.m_scrollView addSubview:self.imgViewHead];
    
    self.imgViewGender = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"gender_bk"]];
    self.imgViewGender.frame = CGRectZero;
    [self.m_scrollView addSubview:self.imgViewGender];
    
    self.lblName = [[UILabel alloc]init];
    self.lblName.backgroundColor = [UIColor clearColor];
    self.lblName.font = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
    self.lblName.textColor = COLOR(115, 115, 115, 1.0);
    [self.m_scrollView addSubview:self.lblName];
    
    //分享数量
    self.btnShareComment = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnShareComment.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.btnShareComment.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.btnShareComment setTitleColor:COLOR(89, 89, 89, 1.0) forState:UIControlStateNormal];
    [self.btnShareComment.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:14.0]];
	[self.btnShareComment addTarget:self action:@selector(middleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.m_scrollView addSubview:self.btnShareComment];
    
    //问答数量
    self.btnQACount = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnQACount.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.btnQACount.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.btnQACount setTitleColor:COLOR(89, 89, 89, 1.0) forState:UIControlStateNormal];
    [self.btnQACount.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:14.0]];
	[self.btnQACount addTarget:self action:@selector(middleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.m_scrollView addSubview:self.btnQACount];
    
    //积分数量
    self.btnIntegration = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnIntegration.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.btnIntegration.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.btnIntegration setTitleColor:COLOR(89, 89, 89, 1.0) forState:UIControlStateNormal];
    [self.btnIntegration.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:14.0]];
	[self.btnIntegration addTarget:self action:@selector(middleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.m_scrollView addSubview:self.btnIntegration];
    
    //用户详情
    self.btnUserDetail = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnUserDetail.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.btnUserDetail.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.btnUserDetail.contentEdgeInsets = UIEdgeInsetsMake(0, -30, 0, 0);
    [self.btnUserDetail setTitleColor:COLOR(89, 89, 89, 1.0) forState:UIControlStateNormal];
    [self.btnUserDetail.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:14.0]];
	[self.btnUserDetail addTarget:self action:@selector(middleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.m_scrollView addSubview:self.btnUserDetail];
    
    self.imgViewUserDetailArrow = [[UIImageView alloc]init];
    self.imgViewUserDetailArrow.image = [[UIImage imageNamed:@"cell_right_arrow"] stretchableImageWithLeftCapWidth:150.5 topCapHeight:15];
    [self.m_scrollView addSubview:self.imgViewUserDetailArrow];
    
    UIView *viewLine = [[UIView alloc]init];
    viewLine.tag = 1005;
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    
    //用户签名
    self.viewSignature = [[UIView alloc]init];
    self.viewSignature.backgroundColor = COLOR(250, 250, 250, 1.0);
    [self.m_scrollView addSubview:self.viewSignature];
    
    self.lblSignature = [[UILabel alloc]init];
    self.lblSignature.backgroundColor = COLOR(250, 250, 250, 1.0);
    self.lblSignature.textColor = COLOR(164, 164, 164, 1.0);
    self.lblSignature.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    self.lblSignature.lineBreakMode = NSLineBreakByCharWrapping;
    [self.viewSignature addSubview:self.lblSignature];
    
    //职位、电话、邮箱///////////////////////////////////////////////////////////////
    self.imgViewMiddleBK = [[UIImageView alloc]init];
    self.imgViewMiddleBK.image = [[UIImage imageNamed:@"groupedit_cell_bk"] stretchableImageWithLeftCapWidth:160 topCapHeight:20];
    [self.m_scrollView addSubview:self.imgViewMiddleBK];
    
    //职位
    self.lblPosition = [[UILabel alloc]init];
    self.lblPosition.backgroundColor = [UIColor clearColor];
    self.lblPosition.textColor = COLOR(154, 154, 154, 1.0);
    self.lblPosition.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    [self.m_scrollView addSubview:self.lblPosition];
    
    self.imgViewPositionIcon = [[UIImageView alloc]init];
    self.imgViewPositionIcon.image = [UIImage imageNamed:@"user_position_icon"];
    [self.m_scrollView addSubview:self.imgViewPositionIcon];
    
    viewLine = [[UIView alloc]init];
    viewLine.tag = 1006;
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    
    //电话
    self.lblPhoneNum = [[UILabel alloc]init];
    self.lblPhoneNum.backgroundColor = [UIColor clearColor];
    self.lblPhoneNum.textColor = COLOR(154, 154, 154, 1.0);
    self.lblPhoneNum.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    [self.m_scrollView addSubview:self.lblPhoneNum];
    
    self.imgViewPhoneIcon = [[UIImageView alloc]init];
    self.imgViewPhoneIcon.image = [UIImage imageNamed:@"user_phone_icon"];
    [self.m_scrollView addSubview:self.imgViewPhoneIcon];
    
    viewLine = [[UIView alloc]init];
    viewLine.tag = 1007;
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    
    //邮箱
    self.lblEmail = [[UILabel alloc]init];
    self.lblEmail.backgroundColor = [UIColor clearColor];
    self.lblEmail.textColor = COLOR(154, 154, 154, 1.0);
    self.lblEmail.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    [self.m_scrollView addSubview:self.lblEmail];
    
    self.imgViewEmailIcon = [[UIImageView alloc]init];
    self.imgViewEmailIcon.image = [UIImage imageNamed:@"user_email_icon"];
    [self.m_scrollView addSubview:self.imgViewEmailIcon];
    
    //分享、问答、相册///////////////////////////////////////////////////////////////
    //分享
    self.imgViewBottomBK = [[UIImageView alloc]init];
    self.imgViewBottomBK.image = [[UIImage imageNamed:@"groupedit_cell_bk"] stretchableImageWithLeftCapWidth:160 topCapHeight:20];
    [self.m_scrollView addSubview:self.imgViewBottomBK];
    
    self.imgViewShareIcon = [[UIImageView alloc]init];
    self.imgViewShareIcon.image = [UIImage imageNamed:@"user_share_icon"];
    [self.m_scrollView addSubview:self.imgViewShareIcon];

    self.lblShare = [[UILabel alloc]init];
    self.lblShare.text = [Common localStr:@"Menu_Share" value:@"分享"];
    self.lblShare.backgroundColor = [UIColor clearColor];
    self.lblShare.textColor = COLOR(163, 163, 163, 1.0);
    self.lblShare.font = [UIFont fontWithName:@"Helvetica" size:(16.0)];
    [self.m_scrollView addSubview:self.lblShare];
    
    self.lblShareNum = [[UILabel alloc]init];
    self.lblShareNum.text = @"0";
    self.lblShareNum.backgroundColor = [UIColor clearColor];
    self.lblShareNum.textAlignment = NSTextAlignmentRight;
    self.lblShareNum.font = [UIFont fontWithName:@"Helvetica" size:(15.0)];
    self.lblShareNum.textColor = COLOR(153, 153, 153, 1.0);
    [self.m_scrollView addSubview:self.lblShareNum];
    
    self.imgViewShareArrow = [[UIImageView alloc]init];
    self.imgViewShareArrow.image = [[UIImage imageNamed:@"cell_right_arrow"] stretchableImageWithLeftCapWidth:150.5 topCapHeight:15];
    [self.m_scrollView addSubview:self.imgViewShareArrow];
    
    self.btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnShare addTarget:self action:@selector(middleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnShare setBackgroundImage:[Common getImageWithColor:COLOR(150, 150, 150, 0.4)] forState:UIControlStateHighlighted];
    [self.btnShare.layer setBorderWidth:1.0];
    [self.btnShare.layer setCornerRadius:3];
    self.btnShare.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.btnShare.layer setMasksToBounds:YES];
    [self.m_scrollView addSubview:self.btnShare];
    
    viewLine = [[UIView alloc]init];
    viewLine.tag = 1009;
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    
    //问答
    self.imgViewQAIcon = [[UIImageView alloc]init];
    self.imgViewQAIcon.image = [UIImage imageNamed:@"user_aq_icon"];
    [self.m_scrollView addSubview:self.imgViewQAIcon];
    
    self.lblQA = [[UILabel alloc]init];
    self.lblQA.text = [Common localStr:@"Menu_QA" value:@"问答"];
    self.lblQA.backgroundColor = [UIColor clearColor];
    self.lblQA.textColor = COLOR(163, 163, 163, 1.0);
    self.lblQA.font = [UIFont fontWithName:@"Helvetica" size:(16.0)];
    [self.m_scrollView addSubview:self.lblQA];
    
    self.lblQANum = [[UILabel alloc]init];
    self.lblQANum.text = @"0";
    self.lblQANum.backgroundColor = [UIColor clearColor];
    self.lblQANum.textAlignment = NSTextAlignmentRight;
    self.lblQANum.font = [UIFont fontWithName:@"Helvetica" size:(15.0)];
    self.lblQANum.textColor = COLOR(153, 153, 153, 1.0);
    [self.m_scrollView addSubview:self.lblQANum];
    
    self.imgViewQAArrow = [[UIImageView alloc]init];
    self.imgViewQAArrow.image = [[UIImage imageNamed:@"cell_right_arrow"] stretchableImageWithLeftCapWidth:150.5 topCapHeight:15];
    [self.m_scrollView addSubview:self.imgViewQAArrow];
    
    self.btnQA = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnQA addTarget:self action:@selector(middleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnQA setBackgroundImage:[Common getImageWithColor:COLOR(150, 150, 150, 0.4)] forState:UIControlStateHighlighted];
    [self.btnQA.layer setBorderWidth:1.0];
    [self.btnQA.layer setCornerRadius:3];
    self.btnQA.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.btnQA.layer setMasksToBounds:YES];
    [self.m_scrollView addSubview:self.btnQA];
    
    viewLine = [[UIView alloc]init];
    viewLine.tag = 1010;
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    
    //相册
    self.imgViewAlbumIcon = [[UIImageView alloc]init];
    self.imgViewAlbumIcon.image = [UIImage imageNamed:@"user_photo_icon"];
    [self.m_scrollView addSubview:self.imgViewAlbumIcon];
    
    self.lblAlbum = [[UILabel alloc]init];
    self.lblAlbum.backgroundColor = [UIColor clearColor];
    self.lblAlbum.text = [Common localStr:@"Menu_Album" value:@"相册"];
    self.lblAlbum.textColor = COLOR(163, 163, 163, 1.0);
    self.lblAlbum.font = [UIFont fontWithName:@"Helvetica" size:(16.0)];
    [self.m_scrollView addSubview:self.lblAlbum];
    
    self.lblAlbumNum = [[UILabel alloc]init];
    self.lblAlbumNum.backgroundColor = [UIColor clearColor];
    self.lblAlbumNum.text = @"";
    self.lblAlbumNum.textAlignment = NSTextAlignmentRight;
    self.lblAlbumNum.font = [UIFont fontWithName:@"Helvetica" size:(15.0)];
    self.lblAlbumNum.textColor = COLOR(153, 153, 153, 1.0);
    [self.m_scrollView addSubview:self.lblAlbumNum];
    
    self.imgViewAlbumArrow = [[UIImageView alloc]init];
    self.imgViewAlbumArrow.image = [[UIImage imageNamed:@"cell_right_arrow"] stretchableImageWithLeftCapWidth:150.5 topCapHeight:15];
    [self.m_scrollView addSubview:self.imgViewAlbumArrow];
    
    self.btnAlbum = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnAlbum addTarget:self action:@selector(middleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnAlbum setBackgroundImage:[Common getImageWithColor:COLOR(150, 150, 150, 0.4)] forState:UIControlStateHighlighted];
    [self.btnAlbum.layer setBorderWidth:1.0];
    [self.btnAlbum.layer setCornerRadius:3];
    self.btnAlbum.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.btnAlbum.layer setMasksToBounds:YES];
    [self.m_scrollView addSubview:self.btnAlbum];
    
    //底部功能按钮
    //聊天
    self.btnVoice = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnVoice setTitleColor:COLOR(255, 255, 255, 1.0) forState:UIControlStateNormal];
    [self.btnVoice setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    self.btnVoice.titleEdgeInsets = UIEdgeInsetsMake(22,0,0,0);
    [self.btnVoice.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:15.0]];
    [self.btnVoice setBackgroundImage:[UIImage imageNamed:@"btn_user_chat"] forState:UIControlStateNormal];
    self.btnVoice.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btnVoice.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.btnVoice setTitle:[Common localStr:@"UserGroup_Chat" value:@"聊天"] forState:UIControlStateNormal];
	[self.btnVoice addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnVoice];
    
    //发消息
    self.btnSendMsg = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnSendMsg setTitleColor:COLOR(255, 255, 255, 1.0) forState:UIControlStateNormal];
    [self.btnSendMsg setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    self.btnSendMsg.titleEdgeInsets = UIEdgeInsetsMake(22,0,0,0);
    [self.btnSendMsg.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:15.0]];
    [self.btnSendMsg setBackgroundImage:[UIImage imageNamed:@"btn_user_send_message"] forState:UIControlStateNormal];
    self.btnSendMsg.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btnSendMsg.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.btnSendMsg setTitle:[Common localStr:@"UserGroup_SendMessage" value:@"发消息"] forState:UIControlStateNormal];
	[self.btnSendMsg addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnSendMsg];
}

-(void)initData
{
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        //do thread work
    	ServerReturnInfo *retInfo = [ServerProvider getUserDetail:self.m_userVo.strUserID];
    	if (retInfo.bSuccess)
    	{
        	self.m_userVo = (UserVo*)retInfo.data;
        	dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshView];
                
                if (self.userDetailViewController != nil)
                {
                    self.userDetailViewController.m_userVo = self.m_userVo;
                    [self.userDetailViewController refreshView];
                }
                
                [self isHideActivity:YES];
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

-(void)refreshView
{
    [self setTopNavBarTitle:self.m_userVo.strUserName];
    if ([self.m_userVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID])
    {
        //本人修改
        UIButton *addTeamItem = [Utils buttonWithTitle:[Common localStr:@"Common_Edit" value:@"编辑"] frame:[Utils getNavRightBtnFrame:CGSizeMake(106,76)] target:self action:@selector(doEdit)];
        [self setRightBarButton:addTeamItem];
        
        self.btnVoice.frame = CGRectZero;
        //self.btnAskQuestion.frame = CGRectZero;
        self.btnSendMsg.frame = CGRectZero;
        self.m_scrollView.frame = CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT);
    }
    else
    {
        //右边按钮
        NSString *strRightButtonTitle = @"";
        if (self.m_userVo.bAttentioned)
        {
            strRightButtonTitle = [Common localStr:@"UserGroup_UnfollowUser" value:@"取消关注"];
        }
        else
        {
            strRightButtonTitle = [Common localStr:@"UserGroup_FollowUser" value:@"关注用户"];
        }
        UIButton *addTeamItem = [Utils buttonWithTitle:strRightButtonTitle frame:[Utils getNavRightBtnFrame:CGSizeMake(146,76)] target:self action:@selector(attentionUser)];
        [self setRightBarButton:addTeamItem];
        
        CGFloat fTabWidth = kScreenWidth/2;
        self.btnVoice.frame = CGRectMake(0, kScreenHeight-50, fTabWidth, 50);
        self.btnSendMsg.frame = CGRectMake(fTabWidth, kScreenHeight-50, kScreenWidth-fTabWidth, 50);
        
        self.m_scrollView.frame = CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT-51);
    }

    CGFloat fHeight = 0;
    //1.head view
    self.imgViewTopBK.frame = CGRectMake(0, fHeight, kScreenWidth, 92);
    
    NSString *phImageName = @"";
    if (self.m_userVo.gender == 1)
    {
        phImageName = @"default_m";
        self.imgViewGender.image = [UIImage imageNamed:@"gender_male"];
    }
    else
    {
        phImageName = @"default_f";
        self.imgViewGender.image = [UIImage imageNamed:@"gender_female"];
    }
    self.imgViewGender.frame = CGRectMake(63.5, 63.5, 17, 17);
    
    UIImage *phImage =[UIImage imageNamed:phImageName];
    __weak UserCenterViewController *weakSelf = self;
    self.imgViewHead.frame = CGRectMake(10, fHeight+10, 73, 73);
    [self.imgViewHead setImageWithURL:[NSURL URLWithString:self.m_userVo.strHeadImageURL] placeholderImage:phImage options:0 success:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(),^{
            weakSelf.imgViewHead.image = image;
        });}failure:^(NSError *error) {}];
    
    //1.name
    self.lblName.text = self.m_userVo.strUserName;
    self.lblName.frame = CGRectMake(90, fHeight+30, 220, 20);
    
    //分享
    self.btnShareComment.frame = CGRectMake(90, fHeight+55, 45, 28);
    [self.btnShareComment setTitle:[NSString stringWithFormat:@"%i\r\n%@",self.m_userVo.nShareCount,[Common localStr:@"Menu_Share" value:@"分享"]] forState:UIControlStateNormal];
    
    //问答
    self.btnQACount.frame = CGRectMake(145, fHeight+55, 45, 28);
    [self.btnQACount setTitle:[NSString stringWithFormat:@"%i\r\n%@",self.m_userVo.nQACount,[Common localStr:@"Menu_QA" value:@"问答"]] forState:UIControlStateNormal];
    
    //积分
    self.btnIntegration.frame = CGRectMake(200, fHeight+55, 45, 28);
    [self.btnIntegration setTitle:[NSString stringWithFormat:@"%i\r\n%@",self.m_userVo.nIntegrationCount,[Common localStr:@"UserGroup_Points" value:@"积分"]] forState:UIControlStateNormal];
    
    //详情资料
    self.btnUserDetail.frame = CGRectMake(kScreenWidth-60, fHeight+55, 75, 28);
    [self.btnUserDetail setTitle:[Common localStr:@"UserGroup_UserDetail" value:@"详情\r\n资料"] forState:UIControlStateNormal];
    
    self.imgViewUserDetailArrow.frame = CGRectMake(kScreenWidth-20, fHeight+65, 13, 13);
    
    UIView *viewLine = [self.m_scrollView viewWithTag:1005];
    viewLine.frame = CGRectMake(0, fHeight+93, kScreenWidth, 0.5);
    fHeight += 93;
    //签名
    self.lblSignature.text = self.m_userVo.strSignature;
    CGSize size = [self.lblSignature.text sizeWithFont:self.lblSignature.font constrainedToSize:CGSizeMake(kScreenWidth-20, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    if (self.lblSignature.text.length == 0)
    {
        self.lblSignature.frame = CGRectZero;
        self.viewSignature.frame = CGRectZero;
    }
    else if (size.height > 25)
    {
        //more than one line
        self.lblSignature.numberOfLines = 2;
        self.lblSignature.frame = CGRectMake(10, 0, kScreenWidth-20, 44);
        self.viewSignature.frame = CGRectMake(0, fHeight, kScreenWidth, 44);
    }
    else
    {
        self.lblSignature.numberOfLines = 1;
        self.lblSignature.frame = CGRectMake(10, 0, kScreenWidth-20, 24);
        self.viewSignature.frame = CGRectMake(0, fHeight, kScreenWidth, 24);
    }
    
    fHeight += self.lblSignature.frame.size.height;
    
    //职位、电话、邮箱///////////////////////////////////////////////////////////////
    fHeight += 10;
    CGFloat fMidBkH = fHeight;
    
    //position
    self.imgViewPositionIcon.frame= CGRectMake(23, fHeight+11, 19, 19);
    
    self.lblPosition.text = self.m_userVo.strPosition;
    self.lblPosition.frame = CGRectMake(55, fHeight+12, kScreenWidth-65, 17);
    
    viewLine = [self.m_scrollView viewWithTag:1006];
    viewLine.frame = CGRectMake(55, fHeight+40.5, kScreenWidth-67, 0.5);
    fHeight += 40.5;
    
    //phone
    self.imgViewPhoneIcon.frame= CGRectMake(23, fHeight+11, 19, 19);
    
    //如果是本人则显示，他人则判断是否显示
    NSString *strPhoneNum = @"";
    if (self.m_userVo.bViewPhone)
    {
        strPhoneNum = self.m_userVo.strPhoneNumber;
    }
    else
    {
        if ([self.m_userVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID])
        {
            strPhoneNum = [NSString stringWithFormat:@"%@ -- %@",self.m_userVo.strPhoneNumber,PHONE_UNPUBLIC_DES];
        }
        else
        {
            strPhoneNum = PHONE_UNPUBLIC_DES;
        }
    }
    self.imgViewMiddleBK.frame = CGRectMake(0, fMidBkH, kScreenWidth, 41*3);
    self.lblPhoneNum.text = strPhoneNum;
    self.lblPhoneNum.frame = CGRectMake(55, fHeight+12, kScreenWidth-65, 17);
    
    viewLine = [self.m_scrollView viewWithTag:1007];
    viewLine.frame = CGRectMake(55, fHeight+40.5, kScreenWidth-67, 0.5);
    fHeight += 41;
    
    //email
    self.imgViewEmailIcon.frame= CGRectMake(23, fHeight+11, 19, 19);
    
    self.lblEmail.text = self.m_userVo.strEmail;
    self.lblEmail.frame = CGRectMake(55, fHeight+12, kScreenWidth-65, 17);
    fHeight += 41+10;
    
    //分享、问答、相册///////////////////////////////////////////////////////////////
    //3.分享
    self.imgViewBottomBK.frame = CGRectMake(0, fHeight, kScreenWidth, 41*3);
    
    self.imgViewShareIcon.frame= CGRectMake(23, fHeight+11, 19, 19);
    self.lblShare.frame = CGRectMake(53, fHeight+10, 140, 20);
    
    self.lblShareNum.frame = CGRectMake(kScreenWidth-160, fHeight+(13), 120, (16));
    self.lblShareNum.text = [NSString stringWithFormat:@"%i",self.m_userVo.nShareCount];
    
    self.imgViewShareArrow.frame = CGRectMake(kScreenWidth-30, fHeight+((41)-13)/2, 13, 13);
    
    self.btnShare.frame = CGRectMake(10.5, fHeight+1.5, kScreenWidth-21, 41-3);
    
    viewLine = [self.m_scrollView viewWithTag:1009];
    viewLine.frame = CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5);
    
    fHeight += (41);
    
    //4.问答
    self.imgViewQAIcon.frame= CGRectMake(23, fHeight+11, 19, 19);
    self.lblQA.frame = CGRectMake(53, fHeight+10, 140, 20);
    
    self.lblQANum.frame = CGRectMake(kScreenWidth-160, fHeight+(13), 120, (16));
    self.lblQANum.text = [NSString stringWithFormat:@"%i",self.m_userVo.nQACount];
    
    self.imgViewQAArrow.frame = CGRectMake(kScreenWidth-30, fHeight+((41)-13)/2, 13, 13);
    
    self.btnQA.frame = CGRectMake(10.5, fHeight+1, kScreenWidth-21, 41-3);
    
    viewLine = [self.m_scrollView viewWithTag:1010];
    viewLine.frame = CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5);
    
    fHeight += (41);
    
    //5.相册
    self.imgViewAlbumIcon.frame= CGRectMake(23, fHeight+11, 19, 19);
    self.lblAlbum.frame = CGRectMake(53, fHeight+10, 140, 20);
    
    self.lblAlbumNum.frame = CGRectMake(kScreenWidth-160, fHeight+(13), 120, (16));
    self.lblAlbumNum.text = @"";
    
    self.imgViewAlbumArrow.frame = CGRectMake(kScreenWidth-30, fHeight+((41)-13)/2, 13, 13);
    
    self.btnAlbum.frame = CGRectMake(10.5, fHeight+1, kScreenWidth-21, 41-3);
    fHeight += (41);

    fHeight += 50;
    [self.m_scrollView setContentSize:CGSizeMake(kScreenWidth, fHeight)];
}

-(void)doEdit
{
    UserEditViewController *userEditViewController = [[UserEditViewController alloc]init];
    userEditViewController.m_userVo = self.m_userVo;
    [self.navigationController pushViewController:userEditViewController animated:YES];
}

-(void)bottomButtonAction:(UIButton*)sender
{
//    if (sender == self.btnVoice)
//    {
//        //即时聊天
//        self.m_chatObjectVo = [[ChatObjectVo alloc] init];
//        self.m_chatObjectVo.nType = 1;
//        self.m_chatObjectVo.strIMGURL = self.m_userVo.strHeadImageURL;
//        self.m_chatObjectVo.strNAME = self.m_userVo.strUserName;
//        self.m_chatObjectVo.strVestID = self.m_userVo.strUserID;
//        ChatContentViewController *chatContentViewController = [[ChatContentViewController alloc] init];
//        chatContentViewController.m_chatObjectVo = self.m_chatObjectVo;
//        [self.navigationController pushViewController:chatContentViewController animated:YES];
//    }
//    else if (sender == self.btnSendMsg)
//    {
//        //发消息
//        NSMutableArray *aryInitUserChoosed = [[NSMutableArray alloc]init];
//        [aryInitUserChoosed addObject:self.m_userVo];
//        
//        PublishMessageViewController *publishMessageViewController = [[PublishMessageViewController alloc]init];
//        publishMessageViewController.publishMessageFromType = PublishMessageDirectlyType;
//        publishMessageViewController.aryInitUser = aryInitUserChoosed;
//        [self.navigationController pushViewController:publishMessageViewController animated:YES];
//    }
}

-(void)middleButtonAction:(UIButton*)sender
{
//    if (sender == self.btnShareComment)
//    {
//        //分享好评
//    }
//    else if (sender == self.btnUserDetail)
//    {
//        //用户详情
//        if (self.userDetailViewController == nil)
//        {
//            self.userDetailViewController = [[UserDetailViewController alloc]init];
//        }
//        self.userDetailViewController.m_userVo = self.m_userVo;
//        [self.navigationController pushViewController:self.userDetailViewController animated:YES];
//    }
//    else if(sender == self.btnShare)
//    {
//        if (self.m_userVo.nShareCount == 0)
//        {
//            return;
//        }
//        //该用户分享
//        UserShareViewController *userShareViewController = [[UserShareViewController alloc]init];
//        userShareViewController.m_userVo = self.m_userVo;
//        [self.navigationController pushViewController:userShareViewController animated:YES];
//    }
//    else if(sender == self.btnQA)
//    {
//        if (self.m_userVo.nQACount == 0)
//        {
//            return;
//        }
//        //该用户问答
//        UserQAViewController *qaViewController = [[UserQAViewController alloc]init];
//        qaViewController.m_userVo = self.m_userVo;
//        [self.navigationController pushViewController:qaViewController animated:YES];
//    }
//    else if (sender == self.btnAlbum)
//    {
//        //相册
//        int nAlumbType;
//        if ([self.m_userVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID])
//        {
//            nAlumbType = ALBUM_MINE_TYPE;
//        }
//        else
//        {
//            nAlumbType = ALBUM_OTHER_USER_TYPE;
//        }
//        AlbumFolderListViewController *folderListViewController = [[AlbumFolderListViewController alloc] initWithAlbumType:nAlumbType];
//        folderListViewController.userVo = self.m_userVo;
//        folderListViewController.fromViewToAlbumType = FromUserCenterToAlbumType;
//        [self.navigationController pushViewController:folderListViewController animated:YES];
//    }
}

-(void)refreshUserDetail
{
    [self initData];
}

//关注或取消关注用户
-(void)attentionUser
{
    //取消关注用户 or 关注用户
    dispatch_async(dispatch_get_global_queue(0,0),^{
        //do thread work
        ServerReturnInfo *retInfo = [ServerProvider attentionUserAction:!self.m_userVo.bAttentioned andOtherUserID:self.m_userVo.strUserID];
        if (retInfo.bSuccess)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(self.m_userVo.bAttentioned)
                {
                    self.m_userVo.bAttentioned = NO;
                    [self.btnRightNav setTitle:[Common localStr:@"UserGroup_FollowUser" value:@"关注用户"] forState:UIControlStateNormal];
                    [self showHudView];
                }
                else
                {
                    self.m_userVo.bAttentioned = YES;
                    [self.btnRightNav setTitle:[Common localStr:@"UserGroup_UnfollowUser" value:@"取消关注"] forState:UIControlStateNormal];
                    [self showHudView];
                }
                [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateLocalUserListFromDB" object:nil];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Common tipAlert:retInfo.strErrorMsg];
            });
        }
    });
}

//hud view
-(void)showHudView
{
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.delegate = self;
    [self.view addSubview:self.hud];
    
    self.hud.mode = MBProgressHUDModeText;
    self.hud.labelText = self.m_userVo.bAttentioned ? [Common localStr:@"UserGroup_FollowSuccess" value:@"关注成功"] : [Common localStr:@"UserGroup_CancelSuccess" value:@"取消成功"];
    
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:0.8];
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    // Remove HUD from screen when the HUD was hidded
    [self.hud removeFromSuperview];
    self.hud = nil;
}

@end
