//
//  ActivityProjectViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/18.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ActivityProjectViewController.h"
#import "UserVo.h"
#import "ActivityService.h"
#import "UIViewExt.h"
#import "ActivitySuccessViewController.h"
#import "FindestProj-Swift.h"

@interface ActivityProjectViewController ()<UIGestureRecognizerDelegate,UIAlertViewDelegate,UITextFieldDelegate>
{
    UserVo *userVo;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewProject;
@property (weak, nonatomic) IBOutlet UIView *viewTopContainer;

@property (weak, nonatomic) IBOutlet UIView *viewTopCircle;
@property (weak, nonatomic) IBOutlet UIView *viewBottomCircle;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDeadline;
@property (weak, nonatomic) IBOutlet UILabel *lblActivityDate;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;

@property (weak, nonatomic) IBOutlet UIView *viewMiddleSep;

@property (weak, nonatomic) IBOutlet UILabel *lblEnrollTip;

@property (weak, nonatomic) IBOutlet UIView *viewEnrollContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblNameTip;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UILabel *lblPhoneTip;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblCompanyTip;
@property (weak, nonatomic) IBOutlet UITextField *txtCompany;
@property (weak, nonatomic) IBOutlet UIView *viewSep1;
@property (weak, nonatomic) IBOutlet UIView *viewSep2;

@property (weak, nonatomic) IBOutlet UIButton *btnCommit;


@end

@implementation ActivityProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    
    [MobAnalytics beginLogPageView:@"stagePage"];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear: animated];
    
    [MobAnalytics endLogPageView:@"stagePage"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.title = @"活动报名";
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    if ([SkinManage getCurrentSkin] == SkinDefaultType) {
        self.viewTopContainer.layer.borderColor = COLOR(239, 232, 230, 1.0).CGColor;
    }else{
        self.viewTopContainer.layer.borderColor = [UIColor clearColor].CGColor;
    }
    self.viewTopContainer.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.viewTopCircle.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.viewMiddleSep.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    self.viewBottomCircle.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.viewEnrollContainer.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.viewSep1.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.viewSep2.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.lblNameTip.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    self.lblPhoneTip.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    self.lblCompanyTip.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    self.lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    
    self.txtName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.txtPhone.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.txtCompany.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    
    
    self.lblEnrollTip.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblDeadline.textColor = [SkinManage colorNamed:@"meeting_place_color"];
    self.lblActivityDate.textColor = [SkinManage colorNamed:@"meeting_place_color"];
    self.lblAddress.textColor = [SkinManage colorNamed:@"meeting_place_color"];
    
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundTap)];
    tapGestureRecognizer1.delegate = self;
    [self.scrollViewProject addGestureRecognizer:tapGestureRecognizer1];
    
    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundTap)];
    tapGestureRecognizer2.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer2];
    
    userVo = [Common getCurrentUserVo];
    
    //穿孔图片
    CGFloat fWidth = kScreenWidth-20-6;
    CGFloat fActualW = ((int)fWidth/21)*21;
    
    UIView *viewTop = [[UIView alloc]initWithFrame:CGRectMake(6+(fWidth-fActualW)/2, 0, fActualW, 15)];
    viewTop.backgroundColor = [UIColor colorWithPatternImage:[SkinManage imageNamed:@"activity_circle"]];
    [self.viewTopCircle addSubview:viewTop];
    
    UIView *viewBottom = [[UIView alloc]initWithFrame:CGRectMake(6+(fWidth-fActualW)/2, 0, fActualW, 15)];
    viewBottom.backgroundColor = [UIColor colorWithPatternImage:[SkinManage imageNamed:@"activity_circle"]];
    [self.viewBottomCircle addSubview:viewBottom];
    
    //项目信息
    self.lblTitle.font = [Common fontWithName:@"PingFangSC-Medium" size:16];
    self.lblTitle.text = self.m_activityProjectVo.strProjectName;
    
    self.lblDeadline.text = [NSString stringWithFormat:@"报名截止：%@",[Common getDateTimeStringFromString:self.m_activityProjectVo.strEndDateTime format:@"yyyy年MM月dd日 a hh:mm"]];
    self.lblActivityDate.text = [NSString stringWithFormat:@"活动时间：%@ - %@",[Common getDateTimeStringFromString:self.m_activityProjectVo.strActivityStartTime format:@"MM月dd日 a hh:mm"],
                                 [Common getDateTimeStringFromString:self.m_activityProjectVo.strActivityEndTime format:@"MM月dd日 a hh:mm"]];
    self.lblAddress.text = [NSString stringWithFormat:@"活动地点：%@",self.m_activityProjectVo.strAddress];
    
    //报名信息
    self.lblEnrollTip.font = [Common fontWithName:@"PingFangSC-Medium" size:16];
    
    self.viewSep1.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"user_detail_sep"]];
    self.viewSep2.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"user_detail_sep"]];
    
    if (self.m_activityProjectVo.nSelfSignup == 1)
    {
        //已报名
        self.txtName.text = self.m_activityProjectVo.strRealName;
        self.txtPhone.text = self.m_activityProjectVo.strPhoneNumber;
        self.txtCompany.text = self.m_activityProjectVo.strDepartmentName;
        [self.btnCommit setTitle:@"已报名" forState:UIControlStateNormal];
        self.txtName.enabled = NO;
        self.txtPhone.enabled = NO;
        self.txtCompany.enabled = NO;
        self.btnCommit.enabled = NO;
    }
    else
    {
        if (self.m_activityProjectVo.nStatus == 1)
        {
            //报名已结束
            [self.btnCommit setTitle:@"报名已结束" forState:UIControlStateNormal];
            self.txtName.enabled = NO;
            self.txtPhone.enabled = NO;
            self.txtCompany.enabled = NO;
            self.btnCommit.enabled = NO;
        }
        else
        {
            self.txtName.text = userVo.strRealName;
            self.txtPhone.text = userVo.strPhoneNumber;
            self.txtCompany.text = userVo.strDepartmentName;
            [self.btnCommit setTitle:@"报名" forState:UIControlStateNormal];
        }
    }
    
    //报名按钮
    [self.btnCommit setBackgroundImage:[Common getImageWithColor:Constants.colorTheme] forState:UIControlStateNormal];
    [self.btnCommit setTitleColor:COLOR(255, 255, 255, 0.35) forState:UIControlStateHighlighted];
}

- (IBAction)signupActivity
{
    NSString *strRealName = self.txtName.text;
    if (strRealName.length == 0)
    {
        [Common tipAlert:@"真实姓名不能为空"];
        return;
    }
    
    NSString *strPhoneNum = self.txtPhone.text;
    if (strPhoneNum.length == 0)
    {
        [Common tipAlert:@"联系电话不能为空"];
        return;
    }
    
    NSString *strWorkUnit = self.txtCompany.text;
    if (strWorkUnit.length == 0)
    {
        [Common tipAlert:@"所属公司不能为空"];
        return;
    }
    
    [self.txtName resignFirstResponder];
    [self.txtPhone resignFirstResponder];
    [self.txtCompany resignFirstResponder];
    
    [MobAnalytics event:@"applyButton"];
    
    UserVo *userVoCommit = [[UserVo alloc]init];
    userVoCommit.strUserName = strRealName;
    userVoCommit.strPhoneNumber = strPhoneNum;
    userVoCommit.strCompanyName = strWorkUnit;
    
    [Common showProgressView:nil view:self.view modal:NO];
    [ActivityService signupActivityProject:self.m_activityProjectVo.strID andUserVO:userVoCommit result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            ActivitySuccessViewController *activitySuccessViewController = [[UIStoryboard storyboardWithName:@"ActivityModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ActivitySuccessViewController"];
            activitySuccessViewController.m_activityProjectVo = self.m_activityProjectVo;
            activitySuccessViewController.m_blogVo = self.m_blogVo;
            [self.navigationController pushViewController:activitySuccessViewController animated:YES];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//调整键盘高度
-(void)fieldOffset:(UIView *)subView
{
    //获取特定subView相对于容器的布局height
    float fViewHeight = 10 + self.viewEnrollContainer.top + subView.top+subView.height;
    
    //当前scrollView 偏移量
    float fScrollOffset = self.scrollViewProject.contentOffset.y;
    
    //可视界面的范围(0~fVisibleHeigh),假定容器从底部开始布局
    float fVisibleHeigh = self.scrollViewProject.height-252;//中文键盘252
    
    //控件当前高度值（从屏幕顶部开始计算）
    float fCurrHeight = fViewHeight-fScrollOffset;
    
    //当subView超过了可见范围，则滚动scrollView
    if (fCurrHeight>fVisibleHeigh)
    {
        [self.scrollViewProject setContentOffset:CGPointMake(0, fViewHeight-fVisibleHeigh+21+20) animated:YES];
    }
}

-(void)backgroundTap
{
    [self.txtName resignFirstResponder];
    [self.txtPhone resignFirstResponder];
    [self.txtCompany resignFirstResponder];
}

#pragma mark - UITextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.txtName)
    {
        [self.txtPhone becomeFirstResponder];
    }
    else if(textField == self.txtPhone)
    {
        [self.txtCompany becomeFirstResponder];
    }
    else if(textField == self.txtCompany)
    {
        [self.txtCompany resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self fieldOffset:textField];
}


@end
