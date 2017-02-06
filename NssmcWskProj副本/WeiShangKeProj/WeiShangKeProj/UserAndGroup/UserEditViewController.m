//
//  UserEditViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-17.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "UserEditViewController.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import "UIImage+UIImageScale.h"
#import "Utils.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>
#import "EditPasswordViewController.h"

@interface UserEditViewController ()

@end

@implementation UserEditViewController

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
    
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self setTopNavBarTitle:[Common localStr:@"UserGroup_EditProfile" value:@"编辑资料"]];
    //right button
    UIButton *addTeamItem = [Utils buttonWithTitle:[Common localStr:@"Common_Done" value:@"完成"] frame:[Utils getNavRightBtnFrame:CGSizeMake(106,76)] target:self action:@selector(saveUserInfo)];
    [self setRightBarButton:addTeamItem];
    
    self.m_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT)];
    self.m_scrollView.backgroundColor = [UIColor clearColor];
    self.m_scrollView.autoresizingMask = NO;
    self.m_scrollView.clipsToBounds = YES;
    [self.view addSubview:self.m_scrollView];
    
    CGFloat fHeight = 10.0;
    //1.image head view
    self.imgViewTopBK = [[UIImageView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 55)];
    self.imgViewTopBK.image = [[UIImage imageNamed:@"groupedit_cell_bk"] stretchableImageWithLeftCapWidth:160 topCapHeight:20];
    [self.m_scrollView addSubview:self.imgViewTopBK];
    
    self.btnHead = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnHead.frame = CGRectMake(11, fHeight+2, kScreenWidth-22, 55-4);
    [self.btnHead setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnHead.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
    self.btnHead.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.btnHead setTitle:[Common localStr:@"UserGroup_ChangeAvatar" value:@"修改头像"] forState:UIControlStateNormal];
    self.btnHead.titleEdgeInsets = UIEdgeInsetsMake(0, -70, 0, 0);
    
    [self.btnHead setBackgroundImage:[Common getImageWithColor:COLOR(150, 150, 150, 0.4)] forState:UIControlStateHighlighted];
    [self.btnHead.layer setBorderWidth:1.0];
    [self.btnHead.layer setCornerRadius:3];
    self.btnHead.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.btnHead.layer setMasksToBounds:YES];
    [self.btnHead addTarget:self action:@selector(doModifyHeadImg) forControlEvents:UIControlEventTouchUpInside];
    [self.m_scrollView addSubview:self.btnHead];
    
    NSString *phImageName = nil;
    if (self.m_userVo.gender == 1)
    {
        phImageName = @"default_m";
    }
    else
    {
        phImageName = @"default_f";
    }
    UIImage *phImage =[[UIImage imageNamed:phImageName]roundedWithSize:CGSizeMake(45,45)];
    __weak UserEditViewController *weakSelf = self;
    self.imgViewHead = [[UIImageView alloc]initWithFrame:CGRectMake(20, fHeight+5, 45, 45)];
    [self.imgViewHead setImageWithURL:[NSURL URLWithString:self.m_userVo.strHeadImageURL] placeholderImage:phImage options:0 success:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(),^{
            weakSelf.imgViewHead.image = [image roundedWithSize:CGSizeMake(45,45)];
        });}failure:^(NSError *error) {}];
    [self.m_scrollView addSubview:self.imgViewHead];
    
    self.imgViewHeadArrow = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth-35, fHeight+(55-13)/2, 13, 13)];
    self.imgViewHeadArrow.image = [[UIImage imageNamed:@"cell_right_arrow"] stretchableImageWithLeftCapWidth:150.5 topCapHeight:15];
    [self.m_scrollView addSubview:self.imgViewHeadArrow];
    
    //2.name
    fHeight += 55+10;
    self.imgViewMiddleBK = [[UIImageView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 9*41+28)];
    self.imgViewMiddleBK.image = [[UIImage imageNamed:@"groupedit_cell_bk"] stretchableImageWithLeftCapWidth:160 topCapHeight:20];
    [self.m_scrollView addSubview:self.imgViewMiddleBK];
    
    self.lblName = [[UILabel alloc]initWithFrame:CGRectMake(20, fHeight+12, 75, 17)];
    self.lblName.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.lblName.textColor = COLOR(51, 51, 51, 1.0);
    self.lblName.text = [Common localStr:@"UserGroup_Nickname" value:@"昵称"];
    [self.m_scrollView addSubview:self.lblName];
    
    self.txtName = [[UITextField alloc]initWithFrame:CGRectMake(95, fHeight+12, kScreenWidth-115,17)];
    self.txtName.font = [UIFont fontWithName:APP_FONT_NAME size:16];
    self.txtName.textColor = COLOR(51, 51, 51, 1.0);
    self.txtName.placeholder = [Common localStr:@"UserGroup_Nickname" value:@"昵称"];
    self.txtName.text = self.m_userVo.strUserName;
    self.txtName.delegate = self;
    self.txtName.tag = 501;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"501"];
    [self.m_scrollView addSubview:self.txtName];
    
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5)];
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    fHeight += 41;
    
    //3.birthday
    self.lblBirthday = [[UILabel alloc]initWithFrame:CGRectMake(20, fHeight+12, 70, 17)];
    self.lblBirthday.font = [UIFont fontWithName:APP_FONT_NAME size:16];
    self.lblBirthday.textColor = COLOR(51, 51, 51, 1.0);
    self.lblBirthday.text = [Common localStr:@"UserGroup_DateOfBirth" value:@"生日"];
    [self.m_scrollView addSubview:self.lblBirthday];
    
    self.txtBirthday = [[UITextField alloc]initWithFrame:CGRectMake(95, fHeight+12, kScreenWidth-115,17)];
    self.txtBirthday.font = [UIFont fontWithName:APP_FONT_NAME size:16];
    self.txtBirthday.textColor = COLOR(51, 51, 51, 1.0);
    self.txtBirthday.placeholder = [Common localStr:@"UserGroup_DateOfBirth" value:@"生日"];
    self.txtBirthday.delegate = self;
    [self.m_scrollView addSubview:self.txtBirthday];
    self.txtBirthday.text = self.m_userVo.strBirthday;
    
    self.btnBirthday = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnBirthday addTarget:self action:@selector(doSelectDate:) forControlEvents:UIControlEventTouchUpInside];
    self.btnBirthday.frame = CGRectMake(11, fHeight+2, 298, 41-4);
    [self.btnBirthday setBackgroundImage:[Common getImageWithColor:COLOR(150, 150, 150, 0.4)] forState:UIControlStateHighlighted];
    [self.m_scrollView addSubview:self.btnBirthday];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight+40.5, 300, 0.5)];
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    
    self.pickerDate = [[CustomDatePicker alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 260) andDelegate:self];
    self.pickerDate.delegate = self;
    [self.view addSubview:self.pickerDate];
    
    fHeight += 41;
    
    //4.gender
    self.lblGender = [[UILabel alloc]initWithFrame:CGRectMake(20, fHeight+12, 70, 17)];
    self.lblGender.font = [UIFont fontWithName:APP_FONT_NAME size:16];
    self.lblGender.textColor = COLOR(51, 51, 51, 1.0);
    self.lblGender.text = [Common localStr:@"UserGroup_Gender" value:@"性别"];
    [self.m_scrollView addSubview:self.lblGender];
    
    self.txtGender = [[UITextField alloc]initWithFrame:CGRectMake(95, fHeight+12, kScreenWidth-115,17)];
    self.txtGender.font = [UIFont fontWithName:APP_FONT_NAME size:16];
    self.txtGender.textColor = COLOR(51, 51, 51, 1.0);
    self.txtGender.placeholder = [Common localStr:@"UserGroup_Gender" value:@"性别"];
    if(self.m_userVo.gender == 1)
    {
        self.txtGender.text = [Common localStr:@"UserGroup_GenderMale" value:@"男"];
    }
    else if (self.m_userVo.gender == 0)
    {
        self.txtGender.text = [Common localStr:@"UserGroup_GenderFemale" value:@"女"];
    }
    [self.m_scrollView addSubview:self.txtGender];
    
    self.btnGender = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnGender addTarget:self action:@selector(doSelectGender) forControlEvents:UIControlEventTouchUpInside];
    self.btnGender.frame = CGRectMake(11, fHeight+2, 298, 41.0-4);
    [self.btnGender setBackgroundImage:[Common getImageWithColor:COLOR(150, 150, 150, 0.4)] forState:UIControlStateHighlighted];
    [self.m_scrollView addSubview:self.btnGender];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5)];
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    fHeight += 41;
    
    //5.position
    self.lblPosition = [[UILabel alloc]initWithFrame:CGRectMake(20, fHeight+12, 70, 17)];
    self.lblPosition.text = [Common localStr:@"UserGroup_JobTitle" value:@"职务"];
    self.lblPosition.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.lblPosition.textColor = COLOR(51, 51, 51, 1.0);
    [self.m_scrollView addSubview:self.lblPosition];
    
    self.txtPosition = [[UITextField alloc]initWithFrame:CGRectMake(95, fHeight+12, kScreenWidth-115,17)];
    self.txtPosition.font = [UIFont fontWithName:APP_FONT_NAME size:16];
    self.txtPosition.textColor = COLOR(51, 51, 51, 1.0);
    self.txtPosition.placeholder = [Common localStr:@"UserGroup_JobTitle" value:@"职务"];
    self.txtPosition.text = self.m_userVo.strPosition;
    self.txtPosition.delegate = self;
    self.txtPosition.tag = 502;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"502"];
    [self.m_scrollView addSubview:self.txtPosition];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5)];
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    fHeight += 41;
    
    //6.phone number
    self.lblPhoneNum = [[UILabel alloc]initWithFrame:CGRectMake(20, fHeight+12, 70, 17)];
    self.lblPhoneNum.text = [Common localStr:@"UserGroup_PhoneNumber" value:@"手机"];
    self.lblPhoneNum.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.lblPhoneNum.textColor = COLOR(51, 51, 51, 1.0);
    [self.m_scrollView addSubview:self.lblPhoneNum];
    
    self.txtPhoneNum = [[UITextField alloc]initWithFrame:CGRectMake(95, fHeight+12, kScreenWidth-115,17)];
    self.txtPhoneNum.font = [UIFont fontWithName:APP_FONT_NAME size:16];
    self.txtPhoneNum.textColor = COLOR(51, 51, 51, 1.0);
    self.txtPhoneNum.placeholder = [Common localStr:@"UserGroup_PhoneNumber" value:@"手机"];
    self.txtPhoneNum.text = self.m_userVo.strPhoneNumber;
    self.txtPhoneNum.delegate = self;
    self.txtPhoneNum.tag = 503;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"503"];
    [self.m_scrollView addSubview:self.txtPhoneNum];
    
    fHeight += 28;
    
    self.lblViewPhone = [[UILabel alloc]initWithFrame:CGRectMake(20, fHeight+12, 200, 17)];
    self.lblViewPhone.text = [Common localStr:@"UserGroup_PublicPhone" value:@"是否公开手机"];
    self.lblViewPhone.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.lblViewPhone.textColor = COLOR(51, 51, 51, 1.0);
    [self.m_scrollView addSubview:self.lblViewPhone];
    
    self.switchViewPhone = [[UISwitch alloc]initWithFrame:CGRectMake(0, fHeight+(41-31)/2,70, 31)];
    self.switchViewPhone.center = CGPointMake(kScreenWidth-30-self.switchViewPhone.frame.size.width/2, self.switchViewPhone.center.y);
    self.switchViewPhone.on = self.m_userVo.bViewPhone;
    [self.m_scrollView addSubview:self.switchViewPhone];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5)];
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    fHeight += 41;
    
    //7.qq
    self.lblQQ = [[UILabel alloc]initWithFrame:CGRectMake(20, fHeight+12, 70, 17)];
    self.lblQQ.text = [Common localStr:@"UserGroup_IM" value:@"QQ"];
    self.lblQQ.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.lblQQ.textAlignment = NSTextAlignmentCenter;
    self.lblQQ.textColor = COLOR(51, 51, 51, 1.0);
    [self.m_scrollView addSubview:self.lblQQ];
    
    self.txtQQ = [[UITextField alloc]initWithFrame:CGRectMake(95, fHeight+12, kScreenWidth-115,17)];
    self.txtQQ.font = [UIFont fontWithName:APP_FONT_NAME size:16];
    self.txtQQ.textColor = COLOR(51, 51, 51, 1.0);
    self.txtQQ.placeholder = [Common localStr:@"UserGroup_IM" value:@"QQ"];
    self.txtQQ.text = self.m_userVo.strQQ;
    self.txtQQ.delegate = self;
    self.txtQQ.tag = 504;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"504"];
    [self.m_scrollView addSubview:self.txtQQ];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5)];
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    fHeight += 41;
    
    //8.email
    self.lblEmail = [[UILabel alloc]initWithFrame:CGRectMake(20, fHeight+12, 70, 17)];
    self.lblEmail.text = [Common localStr:@"UserGroup_Email" value:@"邮箱"];
    self.lblEmail.font = [UIFont fontWithName:APP_FONT_NAME size:16.0];
    self.lblEmail.textColor = COLOR(51, 51, 51, 1.0);
    [self.m_scrollView addSubview:self.lblEmail];
    
    self.txtEmail = [[UITextField alloc]initWithFrame:CGRectMake(95, fHeight+12, kScreenWidth-115,17)];
    self.txtEmail.font = [UIFont fontWithName:APP_FONT_NAME size:16];
    self.txtEmail.textColor = COLOR(51, 51, 51, 1.0);
    self.txtEmail.placeholder = [Common localStr:@"UserGroup_Email" value:@"邮箱"];
    self.txtEmail.text = self.m_userVo.strEmail;
    self.txtEmail.delegate = self;
    self.txtEmail.tag = 505;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"505"];
    [self.m_scrollView addSubview:self.txtEmail];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5)];
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    fHeight += 41;
    
    //9.地址
    self.lblAddress = [[UILabel alloc]initWithFrame:CGRectMake(20, fHeight+12, 70, 17)];
    self.lblAddress.text = [Common localStr:@"UserGroup_Address" value:@"地址"];
    self.lblAddress.font = [UIFont fontWithName:APP_FONT_NAME size:16.0];
    self.lblAddress.textColor = COLOR(51, 51, 51, 1.0);
    [self.m_scrollView addSubview:self.lblAddress];
    
    self.txtAddress = [[UITextField alloc]initWithFrame:CGRectMake(95, fHeight+12, kScreenWidth-115,17)];
    self.txtAddress.font = [UIFont fontWithName:APP_FONT_NAME size:16];
    self.txtAddress.textColor = COLOR(51, 51, 51, 1.0);
    self.txtAddress.placeholder = [Common localStr:@"UserGroup_Address" value:@"地址"];
    self.txtAddress.text = self.m_userVo.strAddress;
    self.txtAddress.delegate = self;
    self.txtAddress.tag = 506;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"506"];
    [self.m_scrollView addSubview:self.txtAddress];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5)];
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    fHeight += 41;
    
    //10.签名
    self.lblSignature = [[UILabel alloc]initWithFrame:CGRectMake(20, fHeight+12, 70, 17)];
    self.lblSignature.text = [Common localStr:@"UserGroup_Signature" value:@"签名"];
    self.lblSignature.font = [UIFont fontWithName:APP_FONT_NAME size:16.0];
    self.lblSignature.textColor = COLOR(51, 51, 51, 1.0);
    [self.m_scrollView addSubview:self.lblSignature];
    
    self.txtSignature = [[UITextField alloc]initWithFrame:CGRectMake(95, fHeight+12, kScreenWidth-115,17)];
    self.txtSignature.font = [UIFont fontWithName:APP_FONT_NAME size:16];
    self.txtSignature.textColor = COLOR(51, 51, 51, 1.0);
    self.txtSignature.placeholder = [Common localStr:@"UserGroup_Signature" value:@"签名"];
    self.txtSignature.text = self.m_userVo.strSignature;
    self.txtSignature.delegate = self;
    self.txtSignature.tag = 507;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"507"];
    [self.m_scrollView addSubview:self.txtSignature];
    fHeight += 41;
    
    //7.modify pwd
    fHeight += 10;
    self.imgViewBottomBK = [[UIImageView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 41)];
    self.imgViewBottomBK.image = [[UIImage imageNamed:@"groupedit_cell_bk"] stretchableImageWithLeftCapWidth:160 topCapHeight:20];
    [self.m_scrollView addSubview:self.imgViewBottomBK];
    
    self.imgViewPwd = [[UIImageView alloc]initWithFrame:CGRectMake(20, fHeight+8, 25, 25)];
    self.imgViewPwd.image = [UIImage imageNamed:@"icon_modify_pwd"];
    [self.m_scrollView addSubview:self.imgViewPwd];
    
    self.btnModifyPwd = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnModifyPwd addTarget:self action:@selector(doModifyPassword) forControlEvents:UIControlEventTouchUpInside];
    self.btnModifyPwd.frame = CGRectMake(11, fHeight+2, kScreenWidth-22, 41.0-4);
    [self.btnModifyPwd setBackgroundImage:[Common getImageWithColor:COLOR(150, 150, 150, 0.4)] forState:UIControlStateHighlighted];
    [self.btnModifyPwd.layer setBorderWidth:1.0];
    [self.btnModifyPwd.layer setCornerRadius:3];
    self.btnModifyPwd.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.btnModifyPwd.layer setMasksToBounds:YES];
    [self.btnModifyPwd.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
    [self.btnModifyPwd setTitle:[Common localStr:@"UserGroup_ChangePwd" value:@"修改密码"] forState:UIControlStateNormal];
    [self.btnModifyPwd setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    CGSize size = [Common getStringSize:self.btnModifyPwd.titleLabel.text font:self.btnModifyPwd.titleLabel.font bound:CGSizeMake(MAXFLOAT, 20) lineBreakMode:self.btnModifyPwd.titleLabel.lineBreakMode];
    self.btnModifyPwd.titleEdgeInsets = UIEdgeInsetsMake(0, -(self.btnModifyPwd.frame.size.width-size.width)+100, 0, 0);
    [self.m_scrollView addSubview:self.btnModifyPwd];
    
    self.imgViewPwdArrow = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth-35, fHeight+((41)-13)/2, 13, 13)];
    self.imgViewPwdArrow.image = [[UIImage imageNamed:@"cell_right_arrow"] stretchableImageWithLeftCapWidth:150.5 topCapHeight:15];
    [self.m_scrollView addSubview:self.imgViewPwdArrow];
    fHeight += 41+10;
    
    fHeight += 255;
    [self.m_scrollView setContentSize:CGSizeMake(kScreenWidth, fHeight)];
}

-(void)initData
{
    self.dicOffsetY = [[NSMutableDictionary alloc]init];
}

//完成编辑
-(void)saveUserInfo
{
    UserVo *userVo = [[UserVo alloc]init];
    
    //0.用户 id
    userVo.strUserID = self.m_userVo.strUserID;
    
    //1.姓名
    userVo.strUserName = self.txtName.text;
    if (userVo.strUserName.length == 0)
    {
        [Common tipAlert:[Common localStr:@"UserGroup_Name_Empty" value:@"姓名不能为空"]];
    }
    
    //2.生日
    userVo.strBirthday = self.txtBirthday.text;
    
    //3.性别
    NSString *strGender = self.txtGender.text;
    if (strGender.length == 0)
    {
        userVo.gender = 2;
    }
    else if ([strGender isEqualToString:[Common localStr:@"UserGroup_GenderMale" value:@"男"]])
    {
        userVo.gender = 1;
    }
    else if ([strGender isEqualToString:[Common localStr:@"UserGroup_GenderFemale" value:@"女"]])
    {
        userVo.gender = 0;
    }
    //4.职务
    userVo.strPosition = self.txtPosition.text;
    
    //5.手机
    userVo.strPhoneNumber = self.txtPhoneNum.text;
    userVo.bViewPhone = self.switchViewPhone.on;
    
    //6.QQ
    userVo.strQQ = self.txtQQ.text;
    
    //7.邮箱
    userVo.strEmail = self.txtEmail.text;
    
    //8.地址
    userVo.strAddress = self.txtAddress.text;
    
    //9.签名
    userVo.strSignature = self.txtSignature.text;
    
    //10.头像地址
    userVo.bHasHeadImg = self.m_userVo.bHasHeadImg;
    userVo.strHeadImgPath = self.m_userVo.strHeadImgPath;
    
    //11.
    userVo.strReceiveMessage = self.m_userVo.strReceiveMessage;
    
    //获取群组详情
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        //do thread work
    	ServerReturnInfo *retInfo = [ServerProvider editUserInfo:userVo];
    	if (retInfo.bSuccess)
    	{
        	dispatch_async(dispatch_get_main_queue(), ^{
                [Common tipAlert:[Common localStr:@"UserGroup_EditProfileSuccess" value:@"修改个人信息成功"]];
                //刷新视图
                [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshUserDetail" object:nil];
                [self.navigationController popViewControllerAnimated:YES];
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

-(void)doSelectGender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    UIActionSheet *actionSheetGender = [[UIActionSheet alloc] initWithTitle:[Common localStr:@"UserGroup_ChangeGender" value:@"性别修改"]
                                                                    delegate:self
                                                           cancelButtonTitle:[Common localStr:@"Common_Cancel" value:@"取消"]
                                                      destructiveButtonTitle:nil
                                                           otherButtonTitles:[Common localStr:@"UserGroup_GenderMale" value:@"男"],[Common localStr:@"UserGroup_GenderFemale" value:@"女"], nil];
    actionSheetGender.tag = 2001;
    [actionSheetGender showInView:self.view];
}

//选择日期
-(void)doSelectDate:(UIButton*)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    if (sender == self.btnBirthday)
    {
        //出生日期
        [self fieldOffset:self.txtBirthday.tag];
        [self setPickerHidden:self.pickerDate andHide:NO];
        NSString *strDate = self.txtBirthday.text;
        if (strDate.length>0)
        {
            NSDate *date = [Common getDateFromDateStr:strDate];
            if (date != nil)
            {
                [self.pickerDate.pickerView setDate:date animated:YES];
            }
        }
    }
}

//修改密码
-(void)doModifyPassword
{
    EditPasswordViewController *editPasswordViewController = [[EditPasswordViewController alloc]init];
    editPasswordViewController.strUserID = self.m_userVo.strUserID;
    [self.navigationController pushViewController:editPasswordViewController animated:YES];
}

//修改头像
-(void)doModifyHeadImg
{
    UIActionSheet *photoSheet = [[UIActionSheet alloc] initWithTitle:[Common localStr:@"UserGroup_ChangeAvatar" value:@"修改头像"] delegate:self  cancelButtonTitle:[Common localStr:@"Common_Cancel" value:@"取消"] destructiveButtonTitle:nil otherButtonTitles:[Common localStr:@"Common_Btn_Camera" value:@"拍照"], [Common localStr:@"Common_Choose_Photo" value:@"用户相册"], nil];
    [photoSheet showInView:self.view];
    photoSheet.tag = 2002;
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
		for(UIView*view in[self.m_scrollView subviews])
        {
			if([view isFirstResponder])
            {
				[view resignFirstResponder];
				break;
			}
		}
	}
}

//显示隐藏时间控件
- (void)setPickerHidden:(UIView*)pickerViewCtrl andHide:(BOOL)hidden
{
    int nHeight = pickerViewCtrl.frame.size.height * (-1);
    CGAffineTransform transform = hidden ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, nHeight);
    pickerViewCtrl.transform = transform;
    if (!hidden)
    {
        self.view.backgroundColor = [UIColor whiteColor];
        self.m_scrollView.frame = CGRectMake(0, NAV_BAR_HEIGHT, self.view.bounds.size.width, (kScreenHeight-NAV_BAR_HEIGHT-260+44));
    }
    else
    {
        self.m_scrollView.frame = CGRectMake(0, NAV_BAR_HEIGHT, self.view.bounds.size.width, kScreenHeight-NAV_BAR_HEIGHT);
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self setPickerHidden:self.pickerDate andHide:YES];
    //编辑时调整view
    [self fieldOffset:textField.tag];
}

#pragma mark - UITextViewDelegate
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    //text View control
	[self fieldOffset:textView.tag];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 2001)
    {
        if (buttonIndex == 0)
        {
            self.txtGender.text = [Common localStr:@"UserGroup_GenderMale" value:@"男"];
        }
        else if (buttonIndex == 1)
        {
            self.txtGender.text = [Common localStr:@"UserGroup_GenderFemale" value:@"女"];
        }
    }
    else if (actionSheet.tag == 2002)
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
            self.photoAlbumController.mediaTypes = [NSArray arrayWithObjects:@"public.image",@"public.movie", nil];
            self.photoAlbumController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.photoAlbumController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            self.photoAlbumController.allowsEditing = YES;
            [self.photoAlbumController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            
            [self presentViewController:self.photoAlbumController animated:YES completion: nil];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
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
        imageToSave = [Common rotateImage:imageToSave];
        
        // Save the new image (original or edited) to the Camera Roll
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        }
        
        float fWidth = imageToSave.size.width;
        float fHeight = imageToSave.size.height;
        
        //1.get middle image(square)
        CGRect rect;
        if(fWidth >= fHeight)
        {
            rect  = CGRectMake((fWidth-fHeight)/2, 0, fHeight, fHeight);
        }
        else
        {
            rect  = CGRectMake(0,(fHeight-fWidth)/2, fWidth, fWidth);
        }
        
        UIImage *imgTemp1 = [imageToSave getSubImage:rect];
        UIImage *imgTemp2 = [imgTemp1 scaleToSize:CGSizeMake(100,100)];
        
        self.imgViewHead.image = [imgTemp2 roundedWithSize:CGSizeMake(IMAGE_HEAD_MIDDLE, IMAGE_HEAD_MIDDLE)];
        
        //2.保存图片
        NSData *imageData = UIImageJPEGRepresentation(imgTemp2,1.0);
        NSString *imagePathDir = [Utils getTempPath];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:imagePathDir];
        if (fileExists)
        {
            //delete director
            [fileManager removeItemAtPath:imagePathDir error:nil];
        }
        
        //create director
        [fileManager createDirectoryAtPath:imagePathDir  withIntermediateDirectories:YES  attributes:nil error:nil];
        
        //save file
        NSString *imagePath = [imagePathDir stringByAppendingPathComponent:[Common createImageNameByDateTime:@"jpg"]];
        [fileManager createFileAtPath:imagePath contents:imageData attributes:nil];
        
        //3.assign userVo value
        self.m_userVo.bHasHeadImg = 1;
        self.m_userVo.strHeadImgPath = imagePath;
    }
    [picker dismissViewControllerAnimated:YES completion: nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CustomDatePickerDelegate
- (void)doneDatePickerButtonClick:(CustomDatePicker*)pickerViewCtrl
{
    [self setPickerHidden:pickerViewCtrl andHide:YES];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    if (pickerViewCtrl == self.pickerDate)
    {
        NSDate *date = pickerViewCtrl.pickerView.date;
        self.txtBirthday.text = [dateFormatter stringFromDate:date];
    }
}

- (void)cancelDatePickerButtonClick:(CustomDatePicker*)pickerViewCtrl
{
    [self setPickerHidden:pickerViewCtrl andHide:YES];
}

@end
