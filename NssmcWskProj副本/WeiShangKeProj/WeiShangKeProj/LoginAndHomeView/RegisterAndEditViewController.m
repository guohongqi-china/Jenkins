//
//  RegisterAndEditViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-4-1.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "RegisterAndEditViewController.h"
#import "Masonry.h"
#import "TheCountdownButton.h"
#import "math.h"
#import "CustomerVo.h"
#import "UIViewExt.h"
#import "RegexUtility.h"
#import "Utils.h"
#import "UIButton+WebCache.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "ResizeImage.h"
#import "SDWebImageManager.h"
#import "SDWebImageDataSource.h"
#import "KTPhotoScrollViewController.h"
#import "ServerURL.h"
#import "TichetServise.h"
#import "MBProgressHUD+GHQ.h"
@interface RegisterAndEditViewController ()<UIAlertViewDelegate,UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,CustomDatePickerDelegate>
{
    CGFloat fKeyboardH;
    NSMutableArray *aryCertPic;
    BOOL isAppear;
    NSMutableArray *comNameArr;
    NSMutableArray *comNumArr;
    NSString *compId;
    NSMutableDictionary *companyDic;
    TheCountdownButton *senderVt;
}
@property(nonatomic,strong) NSMutableArray *companyArr;
@property (weak, nonatomic) IBOutlet UIScrollView *m_scrollView;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;

@property (nonatomic, strong) UIButton *imageButton;/** <#注释#> */

@property (weak, nonatomic) IBOutlet UILabel *lblLoginName;
@property (weak, nonatomic) IBOutlet UITextField *txtLoginName;
@property (weak, nonatomic) IBOutlet UILabel *lblLoginNameStar;

@property (weak, nonatomic) IBOutlet UILabel *lblPwd;
@property (weak, nonatomic) IBOutlet UITextField *txtPwd;
@property (weak, nonatomic) IBOutlet UILabel *lblPwdStar;

@property (weak, nonatomic) IBOutlet UILabel *lblRepeatPwd;
@property (weak, nonatomic) IBOutlet UITextField *txtRepeatPwd;
@property (weak, nonatomic) IBOutlet UILabel *lblRepeatPwdStar;

@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblEmailStar;

@property (weak, nonatomic) IBOutlet UILabel *lblCode;
@property (weak, nonatomic) IBOutlet UITextField *txtCode;
@property (weak, nonatomic) IBOutlet UIButton *btnCode;
@property (weak, nonatomic) IBOutlet UILabel *lblCodeStar;

@property (weak, nonatomic) IBOutlet UILabel *lblAliasName;
@property (weak, nonatomic) IBOutlet UITextField *txtAliasName;
@property (weak, nonatomic) IBOutlet UILabel *lblAliasNameStar;

@property (weak, nonatomic) IBOutlet UILabel *lblRealName;
@property (weak, nonatomic) IBOutlet UITextField *txtRealName;
@property (weak, nonatomic) IBOutlet UILabel *lblRealNameStar;

@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblPhoneStar;

@property (weak, nonatomic) IBOutlet UILabel *lblEducation;
@property (weak, nonatomic) IBOutlet UITextField *txtEduction;
@property (weak, nonatomic) IBOutlet UILabel *lblEducationStar;

@property (weak, nonatomic) IBOutlet UILabel *lblCompany;
@property (weak, nonatomic) IBOutlet UITextField *txtCompany;
@property (weak, nonatomic) IBOutlet UILabel *lblCompanyStar;

@property (weak, nonatomic) IBOutlet UILabel *lblSeniority;
@property (weak, nonatomic) IBOutlet UITextField *txtSeniority;
@property (weak, nonatomic) IBOutlet UILabel *lblSeniorityStar;

@property (weak, nonatomic) IBOutlet UILabel *lblIntroduction;
@property (weak, nonatomic) IBOutlet UITextView *txtIntroduction;
@property (weak, nonatomic) IBOutlet UILabel *lblIntroductionStar;

@property (weak, nonatomic) IBOutlet UIView *viewSeperate1;

@property (weak, nonatomic) IBOutlet UILabel *lblGender;
@property (weak, nonatomic) IBOutlet UIButton *btnMale;
@property (weak, nonatomic) IBOutlet UIButton *btnFemale;

@property (weak, nonatomic) IBOutlet UILabel *lblBirthday;
@property (weak, nonatomic) IBOutlet UITextField *txtBirthday;
@property(nonatomic,strong)CustomDatePicker *pickerDate;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewBirthdatyIcon;

@property (weak, nonatomic) IBOutlet UILabel *lblNation;
@property (weak, nonatomic) IBOutlet UITextField *txtNation;

@property (weak, nonatomic) IBOutlet UILabel *lblHouseHold;
@property (weak, nonatomic) IBOutlet UITextField *txtHouseHold;

@property (weak, nonatomic) IBOutlet UILabel *lblSchool;
@property (weak, nonatomic) IBOutlet UITextField *txtSchool;

@property (weak, nonatomic) IBOutlet UIView *viewSeperate2;
@property (weak, nonatomic) IBOutlet UILabel *lblCertificate;
@property (weak, nonatomic) IBOutlet UIView *viewCertContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnAddCertPic;

- (IBAction)buttonAction:(id)sender;
@end

@implementation RegisterAndEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        senderVt = [[TheCountdownButton alloc]initWithFrame:CGRectZero timeCount:60 title:@"获取验证码" target:self action:@selector(getIdentifyingCode) actionBlock:^{
            senderVt.selected = NO;
            
        }];
        _btnCode.hidden = YES;

    }
    return self;
}
- (void)loadData{

    
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL getUserInformationURL]];
    [networkFramework startRequestToServer:@"GET" parameter:nil result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
        }
        else
        {
            retInfo.data = responseObject;
            
        }
        
    }];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadData];
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.viewType == RegisterUserType)
    {
        [self setTopNavBarTitle:[Common localStr:@"Login_Activation" value:@"注册"]];
    }
    else
    {
        [self setTopNavBarTitle:@"编辑资料"];
        senderVt.hidden = YES;
        senderVt.enabled = NO;
    }
    isAppear = YES;
    comNameArr = [NSMutableArray arrayWithCapacity:0];
    comNumArr = [NSMutableArray arrayWithCapacity:0];
    UIButton *btnRight = [Utils buttonWithTitle:@"完成" frame:[Utils getNavRightBtnFrame:CGSizeMake(100,76)] target:self action:@selector(doCommit)];
    [self setRightBarButton:btnRight];
    
    
    
    [self initView];
    [self initData];
    [self toGetCompanyName];
    
    
}
- (void)toGetCompanyName
{
    ServerReturnInfo *retInfo = [ServerProvider toGetTheCompanyName];
    if (retInfo.bSuccess)
    {
        companyDic = [NSMutableDictionary dictionary];
        self.companyArr = retInfo.data;
        for (CustomerVo *model in self.companyArr) {
            NSString *comName = model.name;
            [comNameArr addObject:comName];
            
             NSString *comId = model.ID;
            [comNumArr addObject:comId];
            [companyDic setObject:comId forKey:comName];
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Common tipAlert:retInfo.strErrorMsg];
        });
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    NSLog(@"viewWillAppear:%@",NSStringFromCGSize(self.view.size));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    NSLog(@"viewDidAppear:%@",NSStringFromCGSize(self.view.size));
}

- (void)initView
{
    NSNumber *fLabelLPadding = @10;      //Left Padding
    NSNumber *fLabelTopPadding = @20;    //Top Padding
    CGSize sizeLabel = CGSizeMake(65, 21);
    
    NSNumber *fTextLPadding = @10;
    NSNumber *fTextRPadding = @-30;
    NSNumber *fTextH = @30;    //text height
    
    CGSize sizeStar = CGSizeMake(20, 20);
    NSNumber *numStarR = @0;
    
    [self.m_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(NAV_BAR_HEIGHT-20, 0, 0, 0));
    }];
    
    [self.viewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.m_scrollView);
        make.width.equalTo(kScreenWidth);
        //不指定高度，然后让最后一个视图与viewContainer的bottom建立约束
    }];
    
    //必填项
    if (self.viewType == RegisterUserType)
    {
        //登录名
        [_lblLoginName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
            make.top.equalTo(_viewContainer.mas_top).offset(fLabelTopPadding);
            make.size.equalTo(sizeLabel);
        }];
        
        [_txtLoginName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_lblLoginName.mas_trailing).offset(fTextLPadding);
            make.trailing.equalTo(_viewContainer.mas_trailing).offset(fTextRPadding);
            make.height.equalTo(fTextH);
            make.centerY.equalTo(_lblLoginName.mas_centerY);
        }];
        
        [_lblLoginNameStar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_viewContainer.mas_trailing).offset(numStarR);
            make.size.equalTo(sizeStar);
            make.centerY.equalTo(_lblLoginName.mas_centerY);
        }];
        
        //密码
        [_lblPwd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
            make.top.equalTo(_lblLoginName.mas_bottom).offset(fLabelTopPadding);
            make.size.equalTo(sizeLabel);
        }];
        
        [_txtPwd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_lblPwd.mas_trailing).offset(fTextLPadding);
            make.trailing.equalTo(_viewContainer.mas_trailing).offset(fTextRPadding);
            make.height.equalTo(fTextH);
            make.centerY.equalTo(_lblPwd.mas_centerY);
        }];
        
        [_lblPwdStar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_viewContainer.mas_trailing).offset(numStarR);
            make.size.equalTo(sizeStar);
            make.centerY.equalTo(_lblPwd.mas_centerY);
        }];
        
        //重复密码
        [_lblRepeatPwd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
            make.top.equalTo(_lblPwd.mas_bottom).offset(fLabelTopPadding);
            make.size.equalTo(sizeLabel);
        }];
        
        [_txtRepeatPwd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_lblRepeatPwd.mas_trailing).offset(fTextLPadding);
            make.trailing.equalTo(_viewContainer.mas_trailing).offset(fTextRPadding);
            make.height.equalTo(fTextH);
            make.centerY.equalTo(_lblRepeatPwd.mas_centerY);
        }];
        
        [_lblRepeatPwdStar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_viewContainer.mas_trailing).offset(numStarR);
            make.size.equalTo(sizeStar);
            make.centerY.equalTo(_lblRepeatPwd.mas_centerY);
        }];
        
        //邮箱
        [_lblEmail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
            make.top.equalTo(_lblRepeatPwd.mas_bottom).offset(fLabelTopPadding);
            make.size.equalTo(sizeLabel);
        }];
        
        [_txtEmail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_lblEmail.mas_trailing).offset(fTextLPadding);
            make.trailing.equalTo(_viewContainer.mas_trailing).offset(fTextRPadding);
            make.height.equalTo(fTextH);
            make.centerY.equalTo(_lblEmail.mas_centerY);
        }];
        
        [_lblEmailStar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_viewContainer.mas_trailing).offset(numStarR);
            make.size.equalTo(sizeStar);
            make.centerY.equalTo(_lblEmail.mas_centerY);
        }];
        
        //验证码
        [_lblCode mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
            make.top.equalTo(_lblEmail.mas_bottom).offset(fLabelTopPadding);
            make.size.equalTo(sizeLabel);
        }];
        
        [_txtCode mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_lblCode.mas_trailing).offset(fTextLPadding);
            make.height.equalTo(fTextH);
            make.centerY.equalTo(_lblCode.mas_centerY);
        }];
        
        [_btnCode mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_txtCode.mas_trailing).offset(fTextLPadding);
            make.trailing.equalTo(_viewContainer.mas_trailing).offset(fTextRPadding);
            make.size.equalTo(CGSizeMake(88, 30));
            make.centerY.equalTo(_lblCode.mas_centerY);
        }];
        senderVt.centerY = _lblCode.centerY - 8;
        senderVt.x = kScreenWidth - 30 - 88;
        senderVt.width = 88;
        senderVt.height = 30;
//        senderVt.frame = _btnCode.frame;
        senderVt.layer.masksToBounds = YES;
        senderVt.layer.cornerRadius = 5;
        senderVt.titleLabel.font = [UIFont systemFontOfSize:15];
        senderVt.backgroundColor = THEME_COLOR;
        [self.m_scrollView  addSubview:senderVt];
        
        [_lblCodeStar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_viewContainer.mas_trailing).offset(numStarR);
            make.size.equalTo(sizeStar);
            make.centerY.equalTo(_lblCode.mas_centerY);
        }];
        
        //呢称
        [_lblAliasName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
            make.top.equalTo(_lblCode.mas_bottom).offset(fLabelTopPadding);
            make.size.equalTo(sizeLabel);
        }];
        
        [_txtAliasName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_lblAliasName.mas_trailing).offset(fTextLPadding);
            make.trailing.equalTo(_viewContainer.mas_trailing).offset(fTextRPadding);
            make.height.equalTo(fTextH);
            make.centerY.equalTo(_lblAliasName.mas_centerY);
        }];
        
        [_lblAliasNameStar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_viewContainer.mas_trailing).offset(numStarR);
            make.size.equalTo(sizeStar);
            make.centerY.equalTo(_lblAliasName.mas_centerY);
        }];
    }
    else
    {
        //登录名
        self.lblLoginName.hidden = YES;
        self.txtLoginName.hidden = YES;
        self.lblLoginNameStar.hidden = YES;
        
        //密码
        self.lblPwd.hidden = YES;
        self.txtPwd.hidden = YES;
        self.lblPwdStar.hidden = YES;
        
        //重复密码
        _lblRepeatPwd.hidden = YES;
        _txtRepeatPwd.hidden = YES;
        self.lblRepeatPwdStar.hidden = YES;
        
        //邮箱
        [_lblEmail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
            make.top.equalTo(_viewContainer.mas_top).offset(fLabelTopPadding);
            make.size.equalTo(sizeLabel);
        }];
        
        [_txtEmail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_lblEmail.mas_trailing).offset(fTextLPadding);
            make.trailing.equalTo(_viewContainer.mas_trailing).offset(fTextRPadding);
            make.height.equalTo(fTextH);
            make.centerY.equalTo(_lblEmail.mas_centerY);
        }];
        
        [_lblEmailStar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_viewContainer.mas_trailing).offset(numStarR);
            make.size.equalTo(sizeStar);
            make.centerY.equalTo(_lblEmail.mas_centerY);
        }];
        
        //验证码
        _lblCode.hidden = YES;
        _txtCode.hidden = YES;
        _btnCode.hidden = YES;
        _lblCodeStar.hidden = YES;
        
        //呢称
        [_lblAliasName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
            make.top.equalTo(_lblEmail.mas_bottom).offset(fLabelTopPadding);
            make.size.equalTo(sizeLabel);
        }];
        
        [_txtAliasName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_lblAliasName.mas_trailing).offset(fTextLPadding);
            make.trailing.equalTo(_viewContainer.mas_trailing).offset(fTextRPadding);
            make.height.equalTo(fTextH);
            make.centerY.equalTo(_lblAliasName.mas_centerY);
        }];
        
        [_lblAliasNameStar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(_viewContainer.mas_trailing).offset(numStarR);
            make.size.equalTo(sizeStar);
            make.centerY.equalTo(_lblAliasName.mas_centerY);
        }];
    }
    
    //姓名
    [_lblRealName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
        make.top.equalTo(_lblAliasName.mas_bottom).offset(fLabelTopPadding);
        make.size.equalTo(sizeLabel);
    }];
    
    [_txtRealName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lblRealName.mas_trailing).offset(fTextLPadding);
        make.trailing.equalTo(_viewContainer.mas_trailing).offset(fTextRPadding);
        make.height.equalTo(fTextH);
        make.centerY.equalTo(_lblRealName.mas_centerY);
    }];
    
    [_lblRealNameStar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_viewContainer.mas_trailing).offset(numStarR);
        make.size.equalTo(sizeStar);
        make.centerY.equalTo(_lblRealName.mas_centerY);
    }];
    
    //手机
    [_lblPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
        make.top.equalTo(_lblRealName.mas_bottom).offset(fLabelTopPadding);
        make.size.equalTo(sizeLabel);
    }];
    
    [_txtPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lblPhone.mas_trailing).offset(fTextLPadding);
        make.trailing.equalTo(_viewContainer.mas_trailing).offset(fTextRPadding);
        make.height.equalTo(fTextH);
        make.centerY.equalTo(_lblPhone.mas_centerY);
    }];
    
    [_lblPhoneStar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_viewContainer.mas_trailing).offset(numStarR);
        make.size.equalTo(sizeStar);
        make.centerY.equalTo(_lblPhone.mas_centerY);
    }];
    
    //学历
    [_lblEducation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
        make.top.equalTo(_lblPhone.mas_bottom).offset(fLabelTopPadding);
        make.size.equalTo(sizeLabel);
    }];
    
    [_txtEduction mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lblEducation.mas_trailing).offset(fTextLPadding);
        make.trailing.equalTo(_viewContainer.mas_trailing).offset(fTextRPadding);
        make.height.equalTo(fTextH);
        make.centerY.equalTo(_lblEducation.mas_centerY);
    }];
    
    [_lblEducationStar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_viewContainer.mas_trailing).offset(numStarR);
        make.size.equalTo(sizeStar);
        make.centerY.equalTo(_lblEducation.mas_centerY);
    }];
    
    //所属公司
    [_lblCompany mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
        make.top.equalTo(_lblEducation.mas_bottom).offset(fLabelTopPadding);
        make.size.equalTo(sizeLabel);
    }];
    
    [_txtCompany mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lblCompany.mas_trailing).offset(fTextLPadding);
        make.trailing.equalTo(_viewContainer.mas_trailing).offset(fTextRPadding);
        make.height.equalTo(fTextH);
        make.centerY.equalTo(_lblCompany.mas_centerY);
    }];
    
    [_lblCompanyStar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_viewContainer.mas_trailing).offset(numStarR);
        make.size.equalTo(sizeStar);
        make.centerY.equalTo(_lblCompany.mas_centerY);
    }];
    
    //工作年数
    [_lblSeniority mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
        make.top.equalTo(_lblCompany.mas_bottom).offset(fLabelTopPadding);
        make.size.equalTo(sizeLabel);
    }];
    
    [_txtSeniority mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lblSeniority.mas_trailing).offset(fTextLPadding);
        make.trailing.equalTo(_viewContainer.mas_trailing).offset(fTextRPadding);
        make.height.equalTo(fTextH);
        make.centerY.equalTo(_lblSeniority.mas_centerY);
    }];
    
    [_lblSeniorityStar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_viewContainer.mas_trailing).offset(numStarR);
        make.size.equalTo(sizeStar);
        make.centerY.equalTo(_lblSeniority.mas_centerY);
    }];
    
    //自我介绍
    [_lblIntroduction mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
        make.top.equalTo(_lblSeniority.mas_bottom).offset(fLabelTopPadding);
        make.size.equalTo(sizeLabel);
    }];
    
    [_txtIntroduction mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_txtSeniority.mas_bottom).offset(8);
        make.leading.equalTo(_lblIntroduction.mas_trailing).offset(fTextLPadding);
        make.trailing.equalTo(_viewContainer.mas_trailing).offset(fTextRPadding);
        make.height.equalTo(60);
    }];
    
    [_lblIntroductionStar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(_viewContainer.mas_trailing).offset(numStarR);
        make.size.equalTo(sizeStar);
        make.centerY.equalTo(_lblIntroduction.mas_centerY);
    }];
    
    //seperate1
    [_viewSeperate1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.trailing.equalTo(_viewContainer).offset(@0);
        make.top.equalTo(_txtIntroduction.mas_bottom).offset(fLabelLPadding);
        make.height.equalTo(@15);
    }];
    
    //性别
    [_lblGender mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
        make.top.equalTo(_viewSeperate1.mas_bottom).offset(fLabelTopPadding);
        make.size.equalTo(sizeLabel);
    }];
    
    [_btnMale mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lblGender.mas_trailing).offset(fTextLPadding);
        make.size.equalTo(CGSizeMake(80, 35));
        make.centerY.equalTo(_lblGender.mas_centerY);
    }];
    [Common setButtonImageLeftTitleRight:_btnMale spacing:5];
    
    [_btnFemale mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_btnMale.mas_trailing).offset(fTextLPadding);
        make.size.equalTo(CGSizeMake(80, 35));
        make.centerY.equalTo(_lblGender.mas_centerY);
    }];
    [Common setButtonImageLeftTitleRight:_btnFemale spacing:5];
    
    //出生年月
    [_lblBirthday mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
        make.top.equalTo(_lblGender.mas_bottom).offset(fLabelTopPadding);
        make.size.equalTo(sizeLabel);
    }];
    
    [_txtBirthday mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lblBirthday.mas_trailing).offset(fTextLPadding);
        make.trailing.equalTo(_viewContainer.mas_trailing).offset(fTextRPadding);
        make.height.equalTo(fTextH);
        make.centerY.equalTo(_lblBirthday.mas_centerY);
    }];
    
    self.pickerDate = [[CustomDatePicker alloc] initWithFrame:CGRectZero andDelegate:self];
    [self.view addSubview:self.pickerDate];
    
    [_pickerDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.trailing.and.bottom.equalTo(@0);
        make.height.equalTo(@0);
    }];
    
    [_imgViewBirthdatyIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(18, 18));
        make.trailing.equalTo(_txtBirthday.mas_trailing).offset(@-5);
        make.centerY.equalTo(_lblBirthday.mas_centerY);
    }];
    
    //民族
    [_lblNation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
        make.top.equalTo(_lblBirthday.mas_bottom).offset(fLabelTopPadding);
        make.size.equalTo(sizeLabel);
    }];
    
    [_txtNation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lblNation.mas_trailing).offset(fTextLPadding);
        make.trailing.equalTo(_viewContainer.mas_trailing).offset(fTextRPadding);
        make.height.equalTo(fTextH);
        make.centerY.equalTo(_lblNation.mas_centerY);
    }];
    
    //户籍
    [_lblHouseHold mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
        make.top.equalTo(_lblNation.mas_bottom).offset(fLabelTopPadding);
        make.size.equalTo(sizeLabel);
    }];
    
    [_txtHouseHold mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lblHouseHold.mas_trailing).offset(fTextLPadding);
        make.trailing.equalTo(_viewContainer.mas_trailing).offset(fTextRPadding);
        make.height.equalTo(fTextH);
        make.centerY.equalTo(_lblHouseHold.mas_centerY);
    }];
    
    //毕业学校
    [_lblSchool mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
        make.top.equalTo(_lblHouseHold.mas_bottom).offset(fLabelTopPadding);
        make.size.equalTo(sizeLabel);
    }];
    
    [_txtSchool mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_lblSchool.mas_trailing).offset(fTextLPadding);
        make.trailing.equalTo(_viewContainer.mas_trailing).offset(fTextRPadding);
        make.height.equalTo(fTextH);
        make.centerY.equalTo(_lblSchool.mas_centerY);
    }];
    
    
    if (self.viewType == RegisterUserType)
    {
        _viewSeperate2.hidden = YES;
        _lblCertificate.hidden = YES;
        _viewCertContainer.hidden = YES;
        
        [_viewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.greaterThanOrEqualTo(_txtSchool.mas_bottom).offset(252).priorityHigh();
        }];
    }
    else
    {
        //seperate2
        [_viewSeperate2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.and.trailing.equalTo(_viewContainer).offset(@0);
            make.top.equalTo(_lblSchool.mas_bottom).offset(fLabelLPadding);
            make.height.equalTo(@15);
        }];
        
        //持有证书
        [_lblCertificate mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(_viewContainer.mas_leading).offset(fLabelLPadding);
            make.top.equalTo(_viewSeperate2.mas_bottom).offset(fLabelTopPadding);
            make.size.equalTo(sizeLabel);
        }];
        
        [_viewCertContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_viewSeperate2.mas_bottom).offset(@8);
            make.leading.equalTo(_lblCertificate.mas_trailing).offset(fTextLPadding);
            make.trailing.equalTo(_viewContainer).offset(@-20);
            make.height.equalTo(@80);
        }];
        
        [_viewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.greaterThanOrEqualTo(_viewCertContainer.mas_bottom).offset(252);
        }];
    }
}

- (void)initData
{
    fKeyboardH = 252;
    
    //获取个人信息，初始化显示
    if (self.viewType == EditUserType)
    {
        _txtEmail.text = _m_userVo.strEmail;
        _txtAliasName.text = _m_userVo.aliasName;
        _txtRealName.text = _m_userVo.name;
        _txtPhone.text = _m_userVo.strPhoneNumber;
        _txtEduction.text = _m_userVo.strEducation;
        
        _txtCompany.text = _m_userVo.strCompanyName;
        _txtSeniority.text = _m_userVo.strSeniority;
        [_txtIntroduction layoutIfNeeded];
        _txtIntroduction.text = _m_userVo.strSignature;
        [self updateTextViewHeight];
        [_txtIntroduction layoutIfNeeded];
        
        [_txtIntroduction updateConstraints];
        //[_txtIntroduction sizeToFit];
        //性别
        if ([_m_userVo.gender isEqualToString:@"男"])
        {
            [self buttonAction:_btnMale];
        }
        else if ([_m_userVo.gender isEqualToString:@"女"])
        {
            [self buttonAction:_btnFemale];
        }
        else
        {
            _btnMale.selected = NO;
            [_btnMale setImage:[UIImage imageNamed:@"option_unchk"] forState:UIControlStateNormal];
        }
        _txtBirthday.text = _m_userVo.strBirthday;
        
        _txtNation.text = _m_userVo.strNation;
        _txtHouseHold.text = _m_userVo.strHouseHold;
        _txtSchool.text = _m_userVo.strSchool;
        
        //持有证书
        aryCertPic = [NSMutableArray array];
        [aryCertPic addObjectsFromArray:_m_userVo.aryCertificate];
        [self updateCertPictureLayout];
    }
}

- (void)updateCertPictureLayout
{
    //移除之前约束，防止约束冲突
    [self.viewCertContainer removeConstraints:self.viewCertContainer.constraints];
    
    __block UIView *viewLast = nil;
    __block BOOL bNewLine = NO;
    
    //定义布局block
    void(^block)(MASConstraintMaker *) = ^(MASConstraintMaker *make) {
        if (viewLast)
        {
            if (!bNewLine && (viewLast.tag-1000+1)*70+10+60 > self.viewCertContainer.width)
            {
                //大于一行则换行
                make.leading.equalTo(@10);
                make.top.equalTo(@80);
                bNewLine = YES;
            }
            else
            {
                make.leading.equalTo(viewLast.mas_trailing).offset(@10);
                make.top.equalTo(viewLast.mas_top);
            }
        }
        else
        {
            //第一行
            make.leading.and.top.equalTo(@10);
        }
        
        make.width.and.height.equalTo(@60);
    };
    
    //照片按钮
    for (int i=0;i<aryCertPic.count;i++)
    {
        UserCertPictureVo *picVo = aryCertPic[i];
        
        if (picVo.btnCertPic == nil)
        {
            //新增
            UIButton *btnCertPic = [UIButton buttonWithType:UIButtonTypeCustom];
            if (picVo.bOld)
            {
                [btnCertPic sd_setImageWithURL:[NSURL URLWithString:picVo.strImageURL] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_album_bk"]];
            }
            else
            {
                [btnCertPic sd_setImageWithURL:[NSURL fileURLWithPath:picVo.strImagePath] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_album_bk"]];
            }
            btnCertPic.imageView.contentMode = UIViewContentModeScaleAspectFill;
            btnCertPic.tag = 1000+i;
            [btnCertPic addTarget:self action:@selector(certPictureTouch:) forControlEvents:UIControlEventTouchUpInside];
            [self.viewCertContainer addSubview:btnCertPic];
            picVo.btnCertPic = btnCertPic;
            [picVo.btnCertPic mas_makeConstraints:block];
            
            //minus button
            UIButton *btnMinus = [UIButton buttonWithType:UIButtonTypeCustom];
            btnMinus.tag = 2000+i;
            [btnMinus setImage:[UIImage imageNamed:@"remove_app"] forState:UIControlStateNormal];
            [btnMinus setImage:[UIImage imageNamed:@"remove_app_HL"] forState:UIControlStateHighlighted];
            [btnMinus addTarget:self action:@selector(certPictureTouch:) forControlEvents:UIControlEventTouchUpInside];
            [btnCertPic addSubview:btnMinus];
            [btnMinus mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.and.trailing.equalTo(btnCertPic).insets(UIEdgeInsetsMake(-5, 0, 0, -5));
                make.width.and.height.equalTo(@30);
            }];
        }
        else
        {
            //更新;
            UIButton *btnMinus = [picVo.btnCertPic viewWithTag:picVo.btnCertPic.tag+1000];
            btnMinus.tag = 2000+i;
            picVo.btnCertPic.tag = 1000+i;
            [picVo.btnCertPic mas_makeConstraints:block];
        }
        
        viewLast = picVo.btnCertPic;
    }
    
    //增加按钮
    if (aryCertPic.count >= 5)
    {
        self.btnAddCertPic.hidden = YES;
    }
    else
    {
        self.btnAddCertPic.hidden = NO;
        [self.btnAddCertPic mas_makeConstraints:block];
    }
    
    //更新容器布局
    if (bNewLine)
    {
        [self.viewCertContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@150);
        }];
    }
    else
    {
        [self.viewCertContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(80);
        }];
    }
}

- (IBAction)certPictureTouch:(UIButton *)sender
{
    if(sender == self.btnAddCertPic)
    {
        self.imageButton = sender;
        UIActionSheet *photoSheet = [[UIActionSheet alloc] initWithTitle:@"上传证件照片" delegate:self  cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"用户相册", nil];
        [photoSheet showInView:self.view];
    }
    else if(sender.tag >=2000)
    {
        //删除图像
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"您确定要删除该证件照片？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = sender.tag;
        [alertView show];
    }
    else if(sender.tag >=1000)
    {
        //预览图像
        NSInteger nIndex = sender.tag - 1000;
        NSMutableArray *aryPreviewPic = [NSMutableArray array];
        for (UserCertPictureVo *picVo in aryCertPic)
        {
            //取大图
            NSURL *urlMax,*urlMin;
            if (picVo.bOld)
            {
                urlMax = [NSURL URLWithString:picVo.strImageURL];
                urlMin = urlMax;
            }
            else
            {
                urlMax = [NSURL fileURLWithPath:picVo.strImagePath];
                urlMin = urlMax;
            }
            
            if (urlMax == nil || urlMin == nil)
            {
                continue;
            }
            
            NSArray *ary = @[urlMax,urlMin];
            [aryPreviewPic addObject:ary];
        }
        
        SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
        dataSource.images_ = aryPreviewPic;
        KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
                                                                  initWithDataSource:dataSource
                                                                  andStartWithPhotoAtIndex:nIndex];
        photoScrollViewController.bShowImageNumBarBtn = YES;
        [self.navigationController pushViewController:photoScrollViewController animated:YES];
    }
}

//选择日期
-(void)doSelectDate:(UITextField*)txtView
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    if (txtView == _txtBirthday)
    {
        //出生日期
        [self fieldOffset:_txtBirthday];
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

//注册
-(void)doCommit
{
    UserVo *userVo = [[UserVo alloc]init];
    
    if (self.viewType == RegisterUserType)
    {
        //1.登录名
        userVo.strLoginAccount = self.txtLoginName.text;
        if (userVo.strLoginAccount == nil || userVo.strLoginAccount.length==0)
        {
            [Common tipAlert:@"请输入登录名"];
            return;
        }
        
        //2.密码	明文
        userVo.strPassword = self.txtPwd.text;
        if (userVo.strPassword == nil || userVo.strPassword.length==0)
        {
            [Common tipAlert:@"请输入密码"];
            return;
        }
        NSString *strRepeatPwd = self.txtRepeatPwd.text;
        if (strRepeatPwd == nil || strRepeatPwd.length==0)
        {
            [Common tipAlert:@"请输入重复密码"];
            return;
        }
        if (![userVo.strPassword isEqualToString:strRepeatPwd])
        {
            [Common tipAlert:@"密码与重复密码不一致"];
            return;
        }
    }
    else
    {
        
        
    }
    
    //邮箱
    userVo.strEmail = _txtEmail.text;
    if (userVo.strEmail == nil || userVo.strEmail.length == 0)
    {
        [Common tipAlert:@"请输入邮箱"];
        return;
    }
    
    if (![RegexUtility validateEmail:userVo.strEmail])
    {
        [Common tipAlert:@"请输入正确的邮箱"];
        return;
    }
    if (self.viewType == RegisterUserType)
    {
  
    //验证码	发送到对应邮箱
    userVo.strIdentifyCode = self.txtCode.text;
    if (userVo.strIdentifyCode == nil || userVo.strIdentifyCode.length==0)
    {
        [Common tipAlert:@"请输入验证码"];
        return;
    }
    }
    
    //昵称
    userVo.nickName = self.txtAliasName.text;
    if (userVo.nickName == nil || userVo.nickName.length==0)
    {
        [Common tipAlert:@"请输入昵称"];
        return;
    }
    
    //姓名
    userVo.strRealName = self.txtRealName.text;
    if (userVo.strRealName == nil || userVo.strRealName.length==0)
    {
        [Common tipAlert:@"请输入姓名"];
        return;
    }
    
    //手机号	事先由管理员导入，需验证
    userVo.strPhoneNumber = self.txtPhone.text;
    if (userVo.strPhoneNumber == nil || userVo.strPhoneNumber.length == 0)
    {
        [Common tipAlert:@"请输入手机号"];
        return;
    }
    
    if (![RegexUtility validateMobile:userVo.strPhoneNumber])
    {
        [Common tipAlert:@"请输入正确的手机号"];
        return;
    }
    
    //学历
    userVo.strEducation = self.txtEduction.text;
    if (userVo.strEducation == nil || userVo.strEducation.length==0)
    {
        [Common tipAlert:@"请输入学历"];
        return;
    }
    
    //所属公司
    userVo.strCompanyName = self.txtCompany.text;
    if (userVo.strCompanyName == nil || userVo.strCompanyName.length==0)
    {
        [Common tipAlert:@"请输入所属公司"];
        return;
    }
    userVo.strCompanyID =companyDic[userVo.strCompanyName];
    //工作年数
    userVo.strSeniority = self.txtSeniority.text;
    if (userVo.strSeniority == nil || userVo.strSeniority.length==0)
    {
        [Common tipAlert:@"请输入工作年数"];
        return;
    }
    
    //自我介绍
    userVo.strSignature = self.txtIntroduction.text;
    if (userVo.strSignature == nil || userVo.strSignature.length==0)
    {
        [Common tipAlert:@"请输入自我介绍"];
        return;
    }
    
    //选填/////////////////////////////////////////////////////////////////////////////
    //性别
    userVo.gender = _btnMale.selected ? @"男":@"女";
    
    //生日
    userVo.strBirthday = self.txtBirthday.text;
    
    //民族
    userVo.strNation = self.txtNation.text;
    
    //户籍
    userVo.strHouseHold = self.txtHouseHold.text;
    
    //毕业学校
    userVo.strSchool = self.txtSchool.text;
    
    if (self.viewType == EditUserType)
    {
        //证书
        
    }
    
    if (self.viewType == RegisterUserType)
    {
        
        [self isHideActivity:NO];
        dispatch_async(dispatch_get_global_queue(0,0),^{
            //do thread work
            ServerReturnInfo *retInfo = [ServerProvider registerUserAction:userVo];
            if (retInfo.bSuccess)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self isHideActivity:YES];
                    [Common bubbleTip:@"注册成功" andView:self.view];
                    [self backButtonClicked];
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
    else
    {
        
        [self isHideActivity:NO];
        dispatch_async(dispatch_get_global_queue(0,0),^{
            //do thread work
            ServerReturnInfo *retInfo = [ServerProvider editUserInfo:userVo];
            if (retInfo.bSuccess)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]postNotificationName:NSNotificationCenterEditInformation object:nil];
                    [self isHideActivity:YES];
                    [self backButtonClicked];
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

//获取验证码
-(void)getIdentifyingCode
{
    NSString *strEmail = _txtEmail.text;
    if (strEmail == nil || strEmail.length == 0)
    {
        [Common tipAlert:[Common localStr:@"Login_PhoneTip" value:@"请输入邮箱"]];
        return;
    }
    
    if (![RegexUtility validateEmail:strEmail])
    {
        [Common tipAlert:@"请输入正确的邮箱"];
        return;
    }
    
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        //do thread work
    	ServerReturnInfo *retInfo = [ServerProvider sendIdentifyingCode:strEmail];
    	if (retInfo.bSuccess)
    	{
            if ([retInfo.data2 isEqualToString: @"10000"]) {
              
                dispatch_async(dispatch_get_main_queue(), ^{
                    senderVt.selected = YES;
                    _btnCode.enabled = NO;
                    [self isHideActivity:YES];
                });

            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self isHideActivity:YES];
                    [MBProgressHUD showSuccess:retInfo.data toView:nil];
                });

            }
            
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

- (IBAction)buttonAction:(id)sender
{
    if (sender == _btnMale)
    {
        _btnMale.selected = YES;
        _btnFemale.selected = !_btnMale.selected;
        
        [_btnMale setImage:[UIImage imageNamed:@"option_chk"] forState:UIControlStateNormal];
        [_btnFemale setImage:[UIImage imageNamed:@"option_unchk"] forState:UIControlStateNormal];
    }
    else if (sender == _btnFemale)
    {
        _btnMale.selected = NO;
        _btnFemale.selected = !_btnMale.selected;
        
        [_btnMale setImage:[UIImage imageNamed:@"option_unchk"] forState:UIControlStateNormal];
        [_btnFemale setImage:[UIImage imageNamed:@"option_chk"] forState:UIControlStateNormal];
    }
    else if (sender == _btnCode)
    {
        [self getIdentifyingCode];
    }
}

//调整键盘高度
-(void)fieldOffset:(UIView *)subView
{
    //获取特定subView相对于容器的布局height
	float fViewHeight = subView.top+subView.height;
    
    //当前scrollView 偏移量
	float fScrollOffset = self.m_scrollView.contentOffset.y;
    
    //可视界面的范围(0~fVisibleHeigh),假定容器从底部开始布局
    float fVisibleHeigh = self.m_scrollView.height-fKeyboardH;//中文键盘252
    
    //控件当前高度值（从屏幕顶部开始计算）
    float fCurrHeight = fViewHeight-fScrollOffset;
	
    //当subView超过了可见范围，则滚动scrollView
	if (fCurrHeight>fVisibleHeigh)
    {
		[self.m_scrollView setContentOffset:CGPointMake(0, fViewHeight-fVisibleHeigh+21+20) animated:YES];
    }
}

//隐藏键盘
-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch*touch =[touches anyObject];
	if(touch.phase==UITouchPhaseBegan)
    {
		//find first response view
		for(UIView*view in[self.viewContainer subviews])
        {
			if([view isFirstResponder])
            {
				[view resignFirstResponder];
				break;
			}
		}
	}
    
    [self setPickerHidden:self.pickerDate andHide:YES];
}

//显示隐藏时间控件
- (void)setPickerHidden:(UIView*)pickerViewCtrl andHide:(BOOL)hidden
{
    CGFloat fFirstH=0,fSecondH=260;
    if (hidden)
    {
        fFirstH = 260;
        fSecondH = 0;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        [_pickerDate mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(fSecondH);
        }];
        [self.view layoutIfNeeded];
    } completion:nil];
}

//动态更新UITextView的高度
- (void)updateTextViewHeight
{
    CGFloat fContentH = [_txtIntroduction sizeThatFits:CGSizeMake(_txtIntroduction.frame.size.width, CGFLOAT_MAX)].height;
    if (fContentH > 60 && fabs(fContentH-_txtIntroduction.frame.size.height) > 0.01)//进行优化，避免每次输入都更新height
    {
        [_txtIntroduction mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(fContentH);
        }];
        [_txtIntroduction layoutIfNeeded];
        [_viewContainer layoutIfNeeded];
        
        [self fieldOffset:self.txtIntroduction];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        UserCertPictureVo *picVo = aryCertPic[alertView.tag-2000];
        [picVo.btnCertPic removeFromSuperview];
        [aryCertPic removeObject:picVo];
        [self updateCertPictureLayout];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.viewType == RegisterUserType)
    {
        if (buttonIndex != comNameArr.count)
        {
            _txtCompany.text =comNameArr[buttonIndex];
            compId = comNumArr[buttonIndex];
        }
    }else
    {
        if (buttonIndex == 0)
        {
            //拍照
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
            {
                return;
            }
            UIImagePickerController *photoController = [[UIImagePickerController alloc] init];
            photoController.delegate = self;
            photoController.mediaTypes = @[(NSString*)kUTTypeImage];
            photoController.sourceType = UIImagePickerControllerSourceTypeCamera;
            photoController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            photoController.allowsEditing = NO;
            [photoController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            
            [self presentViewController:photoController animated:YES completion: nil];
        }
        else if (buttonIndex == 1)
        {
            //用户相册
            UIImagePickerController *photoAlbumController = [[UIImagePickerController alloc]init];
            photoAlbumController.delegate = self;
            photoAlbumController.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
            photoAlbumController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            photoAlbumController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            photoAlbumController.allowsEditing = NO;
            [photoAlbumController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            
            [self presentViewController:photoAlbumController animated:YES completion: nil];
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
        
        UIImage *imageToSave = originalImage;
        
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
        
        
        
        NSMutableDictionary *bodyDic1 = [[NSMutableDictionary alloc] init];
        //    [bodyDic1 setObject:@"ios" forKey:@"client_flag"];
        [bodyDic1 setObject:[Common getCurrentUserVo].strUserID forKey:@"malfunctionId"];
        [bodyDic1 setObject:@" " forKey:@"detailId"];
        [bodyDic1 setObject:@(1) forKey:@"no"];
        [bodyDic1 setObject:@"01" forKey:@"type"];
        [MBProgressHUD showMessage:@"图片上传中..." toView:self.imageButton];
        [TichetServise uploadImageToServer:bodyDic1 imageData:imageData result:^(ServerReturnInfo *retInfo) {
            if (retInfo.bSuccess) {
                [MBProgressHUD hideHUDForView:self.imageButton animated:YES];
                [MBProgressHUD showSuccess:@"图片上传成功" toView:nil];
//                [[NSNotificationCenter defaultCenter]postNotificationName:NSNotificationCenterName object:nil];
                
            }else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:retInfo.strErrorMsg toView:nil];
            }
            
        }];

        
        
        
        //增加证书照片到数组
        UserCertPictureVo *picVo = [[UserCertPictureVo alloc]init];
        picVo.bOld = NO;
        picVo.strImagePath = imagePath;
        [aryCertPic addObject:picVo];
        [self updateCertPictureLayout];
    }
    [picker dismissViewControllerAnimated:YES completion: nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self fieldOffset:textView];
    [self setPickerHidden:self.pickerDate andHide:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self updateTextViewHeight];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateTextViewHeight];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (isAppear==YES) {
        
        if (textField == _txtCompany) {
        //王文静
//            UIActionSheet *act = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:comNameArr[0],comNameArr[1],comNameArr[2],comNameArr[3],comNameArr[4], nil];
//            [act showInView:self.view];
            
            UIAlertController *controller =[UIAlertController alertControllerWithTitle:@"请选择所属公司" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
            
            for (NSString *titleStr in comNameArr) {
                UIAlertAction *action = [UIAlertAction actionWithTitle:titleStr style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                    _txtCompany.text = action.title;
                    compId = action.title;
                   
                    
                }];
                [controller addAction:action];

            }
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                [controller dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [controller addAction:action];
            [self presentViewController:controller animated:YES completion:nil];

            
            
            return NO;
        }
    }
    
    if (textField == _txtBirthday)
    {
        [self doSelectDate:textField];
        return NO;
    }
    else
    {
        [self setPickerHidden:self.pickerDate andHide:YES];
        return YES;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txtLoginName)
    {
        [_txtPwd becomeFirstResponder];
    }
    else if (textField == _txtPwd)
    {
        [_txtRepeatPwd becomeFirstResponder];
    }
    else if (textField == _txtRepeatPwd)
    {
        [_txtEmail becomeFirstResponder];
    }
    else if (textField == _txtEmail)
    {
        if (self.viewType == RegisterUserType)
        {
            [_txtCode becomeFirstResponder];
        }
        else
        {
            [_txtAliasName becomeFirstResponder];
        }
    }
    else if (textField == _txtCode)
    {
        [_txtAliasName becomeFirstResponder];
    }
    else if (textField == _txtAliasName)
    {
        [_txtRealName becomeFirstResponder];
    }
    else if (textField == _txtRealName)
    {
        [_txtPhone becomeFirstResponder];
    }
    else if (textField == _txtEduction)
    {
        [_txtCompany becomeFirstResponder];
    }
    else if (textField == _txtCompany)
    {
        [_txtSeniority becomeFirstResponder];
    }
    else if (textField == _txtSeniority)
    {
        [_txtIntroduction becomeFirstResponder];
        return NO;
    }
    else if (textField == _txtNation)
    {
        [_txtHouseHold becomeFirstResponder];
    }
    else if (textField == _txtHouseHold)
    {
        [_txtSchool becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self fieldOffset:textField];
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
