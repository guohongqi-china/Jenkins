//
//  UserDetailViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-17.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "UserDetailViewController.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import "Utils.h"
#import "UserEditViewController.h"

@interface UserDetailViewController ()

@end

@implementation UserDetailViewController

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
    [self refreshView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setTopNavBarTitle:[Common localStr:@"UserGroup_DetailInfo" value:@"详情资料"]];
    
    self.m_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT)];
    self.m_scrollView.backgroundColor = [UIColor clearColor];
    self.m_scrollView.autoresizingMask = NO;
    self.m_scrollView.clipsToBounds = YES;
    [self.view addSubview:self.m_scrollView];
    
    //1.head view
    self.imgViewTopBK = [[UIImageView alloc]init];
    self.imgViewTopBK.image = [[UIImage imageNamed:@"groupedit_cell_bk"] stretchableImageWithLeftCapWidth:160 topCapHeight:20];
    [self.m_scrollView addSubview:self.imgViewTopBK];
    
    self.lblHeadImage = [[UILabel alloc]init];
    self.lblHeadImage.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.lblHeadImage.textColor = COLOR(51, 51, 51, 1.0);
    [self.m_scrollView addSubview:self.lblHeadImage];
    
    self.imgViewHead = [[UIImageView alloc]init];
    [self.m_scrollView addSubview:self.imgViewHead];
    
    //2.name
    self.imgViewBottomBK = [[UIImageView alloc]init];
    self.imgViewBottomBK.image = [[UIImage imageNamed:@"groupedit_cell_bk"] stretchableImageWithLeftCapWidth:160 topCapHeight:20];
    [self.m_scrollView addSubview:self.imgViewBottomBK];
    
    self.lblName = [[UILabel alloc]init];
    self.lblName.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.lblName.textColor = COLOR(51, 51, 51, 1.0);
    [self.m_scrollView addSubview:self.lblName];
    
    UIView *viewLine = [[UIView alloc]init];
    viewLine.tag = 1001;
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    
    //3.birthday
    self.lblBirthday = [[UILabel alloc]init];
    self.lblBirthday.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.lblBirthday.textColor = COLOR(51, 51, 51, 1.0);
    [self.m_scrollView addSubview:self.lblBirthday];
    
    viewLine = [[UIView alloc]init];
    viewLine.tag = 1002;
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    
    //4.gender
    self.lblGender = [[UILabel alloc]init];
    self.lblGender.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.lblGender.textColor = COLOR(51, 51, 51, 1.0);
    [self.m_scrollView addSubview:self.lblGender];
    
    viewLine = [[UIView alloc]init];
    viewLine.tag = 1003;
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    
    //5.position
    self.lblPosition = [[UILabel alloc]init];
    self.lblPosition.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.lblPosition.textColor = COLOR(51, 51, 51, 1.0);
    [self.m_scrollView addSubview:self.lblPosition];
    
    viewLine = [[UIView alloc]init];
    viewLine.tag = 1004;
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    
//    //6.company
//    self.lblCompany = [[UILabel alloc]init];
//    self.lblCompany.font = [UIFont fontWithName:@"Helvetica" size:16.0];
//    self.lblCompany.textColor = COLOR(51, 51, 51, 1.0);
//    [self.m_scrollView addSubview:self.lblCompany];
//    
//    viewLine = [[UIView alloc]init];
//    viewLine.tag = 1005;
//    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
//    [self.m_scrollView addSubview:viewLine];
    
    //7.phone num
    self.lblPhoneNum = [[UILabel alloc]init];
    self.lblPhoneNum.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.lblPhoneNum.textColor = COLOR(51, 51, 51, 1.0);
    [self.m_scrollView addSubview:self.lblPhoneNum];
    
    viewLine = [[UIView alloc]init];
    viewLine.tag = 1006;
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    
    //8.QQ
    self.lblQQ = [[UILabel alloc]init];
    self.lblQQ.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.lblQQ.textColor = COLOR(51, 51, 51, 1.0);
    [self.m_scrollView addSubview:self.lblQQ];
    
    viewLine = [[UIView alloc]init];
    viewLine.tag = 1007;
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    
    //9.email
    self.lblEmail = [[UILabel alloc]init];
    self.lblEmail.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.lblEmail.textColor = COLOR(51, 51, 51, 1.0);
    [self.m_scrollView addSubview:self.lblEmail];
    
    viewLine = [[UIView alloc]init];
    viewLine.tag = 1008;
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    
    //10.address
    self.lblAddress = [[UILabel alloc]init];
    self.lblAddress.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.lblAddress.textColor = COLOR(51, 51, 51, 1.0);
    self.lblAddress.numberOfLines = 0;
    [self.m_scrollView addSubview:self.lblAddress];
    
    viewLine = [[UIView alloc]init];
    viewLine.tag = 1009;
    viewLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:viewLine];
    
    //11.signature
    self.lblSignature = [[UILabel alloc]init];
    self.lblSignature.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.lblSignature.textColor = COLOR(51, 51, 51, 1.0);
    self.lblSignature.numberOfLines = 0;
    [self.m_scrollView addSubview:self.lblSignature];
}

-(void)initData
{
    
}

-(void)refreshView
{
    if ([self.m_userVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID])
    {
        //本人修改
        UIButton *addTeamItem = [Utils buttonWithTitle:[Common localStr:@"Common_Edit" value:@"编辑"] frame:[Utils getNavRightBtnFrame:CGSizeMake(106,76)] target:self action:@selector(doEdit)];
        [self setRightBarButton:addTeamItem];
    }

    CGFloat fHeight = 10;
    //1.name
    self.imgViewTopBK.frame = CGRectMake(0, fHeight, kScreenWidth, 55);
    self.lblHeadImage.text = [Common localStr:@"UserGroup_Avatar" value:@"头像"];
    self.lblHeadImage.frame = CGRectMake(20, fHeight+19, kScreenWidth-40, 17);
    
    NSString *phImageName = nil;
    NSString *strGender = @"";
    if (self.m_userVo.gender == 1)
    {
        phImageName = @"default_m";
        strGender = [Common localStr:@"UserGroup_GenderMale" value:@"男"];
    }
    else
    {
        phImageName = @"default_f";
        strGender = [Common localStr:@"UserGroup_GenderFemale" value:@"女"];
    }
    UIImage *phImage =[[UIImage imageNamed:phImageName]roundedWithSize:CGSizeMake(45,45)];
    __weak UserDetailViewController *weakSelf = self;
    self.imgViewHead.frame = CGRectMake(80, fHeight+5, 45, 45);
    [self.imgViewHead setImageWithURL:[NSURL URLWithString:self.m_userVo.strHeadImageURL] placeholderImage:phImage options:0 success:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(),^{
            weakSelf.imgViewHead.image = [image roundedWithSize:CGSizeMake(45,45)];
        });}failure:^(NSError *error) {}];
    
    fHeight += 55+10;
    
    //2.name
    CGFloat fMidStartH = fHeight;
    
    self.lblName.text = [NSString stringWithFormat:@"%@　%@",[Common localStr:@"UserGroup_Nickname" value:@"昵称"],self.m_userVo.strUserName];
    self.lblName.frame = CGRectMake(20, fHeight+12, kScreenWidth-40, 17);
    
    UIView *viewLine = [self.m_scrollView viewWithTag:1001];
    viewLine.frame = CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5);
    
    //3.birthday
    fHeight+=41;
    self.lblBirthday.text = [NSString stringWithFormat:@"%@　%@",[Common localStr:@"UserGroup_DateOfBirth" value:@"生日"],self.m_userVo.strBirthday];
    self.lblBirthday.frame = CGRectMake(20, fHeight+12, kScreenWidth-40, 17);
    
    viewLine = [self.m_scrollView viewWithTag:1002];
    viewLine.frame = CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5);
    
    //4.gender
    fHeight+=41;
    self.lblGender.text = [NSString stringWithFormat:@"%@　%@",[Common localStr:@"UserGroup_Gender" value:@"性别"],strGender];
    self.lblGender.frame = CGRectMake(20, fHeight+12, kScreenWidth-40, 17);
    
    viewLine = [self.m_scrollView viewWithTag:1003];
    viewLine.frame = CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5);
    
    //5.position
    fHeight+=41;
    self.lblPosition.text = [NSString stringWithFormat:@"%@　%@",[Common localStr:@"UserGroup_JobTitle" value:@"职务"],self.m_userVo.strPosition];
    self.lblPosition.frame = CGRectMake(20, fHeight+12, kScreenWidth-40, 17);
    
    viewLine = [self.m_scrollView viewWithTag:1004];
    viewLine.frame = CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5);
    
//    //6.company
//    fHeight+=41;
//    self.lblCompany.text = [NSString stringWithFormat:@"公司　%@",self.m_userVo.strCompanyName];
//    self.lblCompany.frame = CGRectMake(20, fHeight+12, kScreenWidth-40, 17);
//    
//    viewLine = [self.m_scrollView viewWithTag:1005];
//    viewLine.frame = CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5);
    
    //7.phone num (如果是本人则显示，他人则判断是否显示)
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
    
    fHeight+=41;
    self.lblPhoneNum.text = [NSString stringWithFormat:@"%@　%@",[Common localStr:@"UserGroup_PhoneNumber" value:@"手　　机"],strPhoneNum];
    self.lblPhoneNum.frame = CGRectMake(20, fHeight+12, kScreenWidth-40, 17);
    
    viewLine = [self.m_scrollView viewWithTag:1006];
    viewLine.frame = CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5);
    
    //8.qq
    fHeight+=41;
    self.lblQQ.text = [NSString stringWithFormat:@"%@　%@",[Common localStr:@"UserGroup_IM" value:@"QQ"],self.m_userVo.strQQ];
    self.lblQQ.frame = CGRectMake(20, fHeight+12, kScreenWidth-40, 17);
    
    viewLine = [self.m_scrollView viewWithTag:1007];
    viewLine.frame = CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5);
    
    //9.email
    fHeight+=41;
    self.lblEmail.text = [NSString stringWithFormat:@"%@　%@",[Common localStr:@"UserGroup_Email" value:@"邮箱"],self.m_userVo.strEmail];
    self.lblEmail.frame = CGRectMake(20, fHeight+12, kScreenWidth-40, 17);
    
    viewLine = [self.m_scrollView viewWithTag:1008];
    viewLine.frame = CGRectMake(10, fHeight+40.5, kScreenWidth-20, 0.5);
    
    //10.address
    fHeight+=41;
    self.lblAddress.text = [NSString stringWithFormat:@"%@　%@",[Common localStr:@"UserGroup_Address" value:@"地址"],self.m_userVo.strAddress];
    CGSize sizeText = [self.lblAddress.text sizeWithFont:self.lblAddress.font constrainedToSize:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    self.lblAddress.frame = CGRectMake(20, fHeight+12, kScreenWidth-40, sizeText.height);
    fHeight += 12+sizeText.height+12;
    
    viewLine = [self.m_scrollView viewWithTag:1009];
    viewLine.frame = CGRectMake(10, fHeight, kScreenWidth-20, 0.5);
    
    //11.signature
    self.lblSignature.text = [NSString stringWithFormat:@"%@　%@",[Common localStr:@"UserGroup_Signature" value:@"签名"],self.m_userVo.strSignature];
    sizeText = [self.lblSignature.text sizeWithFont:self.lblSignature.font constrainedToSize:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    self.lblSignature.frame = CGRectMake(20, fHeight+12, kScreenWidth-40, sizeText.height);
    fHeight += 12+sizeText.height+12;
    
    //bk
    self.imgViewBottomBK.frame = CGRectMake(0, fMidStartH, kScreenWidth, fHeight-fMidStartH);
    
    fHeight+=100;
    [self.m_scrollView setContentSize:CGSizeMake(kScreenWidth, fHeight)];
}

-(void)doEdit
{
    UserEditViewController *userEditViewController = [[UserEditViewController alloc]init];
    userEditViewController.m_userVo = self.m_userVo;
    [self.navigationController pushViewController:userEditViewController animated:YES];
}

@end
