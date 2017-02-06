//
//  UserEditViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/6.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "UserEditViewController.h"
#import "UserVo.h"
#import "CustomDatePicker.h"
#import "CustomPicker.h"
#import "DepartmentVo.h"
#import "BRPlaceholderTextView.h"
@interface UserEditViewController ()<CustomDatePickerDelegate,CustomPickerDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    UIBarButtonItem *btnNavRight;
    NSInteger nMaxLength;
    
    CustomDatePicker *pickerDate;
    CustomPicker *pickerDepartment;
    
    NSMutableArray *aryDepartment;
    
    UserVo *userVo;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewUserEdit;

@property (weak, nonatomic) IBOutlet UIView *viewTextContainer;     //基本文字输入容器
@property (weak, nonatomic) IBOutlet BRPlaceholderTextView *textViewInput;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextH;
@property (weak, nonatomic) IBOutlet UILabel *lblTextNum;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintEqualH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextBottom;
@property (weak, nonatomic) IBOutlet UILabel *maleLabel;
@property (weak, nonatomic) IBOutlet UILabel *manLabel;
//gender
@property (weak, nonatomic) IBOutlet UIView *viewGenderContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnGenderMale;
@property (weak, nonatomic) IBOutlet UIButton *btnGenderFemale;
@property (weak, nonatomic) IBOutlet UIView *viewGenderSep;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintGenderSelected;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewGenderSelected;


@end

@implementation UserEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    
    //    [self.textViewInput becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //    [self.textViewInput resignFirstResponder];
}

- (void)initView
{
    self.title = self.menuVo.strTitle;
    
    self.fd_interactivePopDisabled = YES;
    self.isNeedBackItem = NO;
    self.navigationItem.leftBarButtonItem = [self leftBtnItemWithTitle:@"取消"];
    
    //right button
    btnNavRight = [self rightBtnItemWithTitle:@"完成"];
    btnNavRight.enabled = NO;
    self.navigationItem.rightBarButtonItem = btnNavRight;
    
    
    
    if([self.menuVo.strKey isEqualToString:@"gender"])
    {
        
        
        _scrollViewUserEdit.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        self.viewGenderContainer.hidden = NO;
        self.viewTextContainer.hidden = YES;
        self.navigationItem.rightBarButtonItem = nil;
        
        
        _viewGenderContainer.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        _manLabel.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
        _maleLabel.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
        _viewGenderSep.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
        _viewGenderContainer.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
        [_btnGenderMale setBackgroundImage:[Common getImageWithColor:COLOR(246, 246, 246, 1.0)] forState:UIControlStateHighlighted];
        [_btnGenderFemale setBackgroundImage:[Common getImageWithColor:COLOR(246, 246, 246, 1.0)] forState:UIControlStateHighlighted];
        
        if([self.menuVo.strValueID isEqualToString:@"0"])
        {
            self.constraintGenderSelected.constant = 61;
        }
        else if([self.menuVo.strValueID isEqualToString:@"1"])
        {
            self.constraintGenderSelected.constant = 17;
        }
        else
        {
            self.imgViewGenderSelected.hidden = YES;
        }
    }
    else
    {
        
        _scrollViewUserEdit.backgroundColor = [SkinManage colorNamed:@"All_textField_bg_color"];
        self.viewGenderContainer.hidden = YES;
        self.viewTextContainer.hidden = NO;
        
        
        _viewTextContainer.backgroundColor = [SkinManage colorNamed:@"All_textField_bg_color"];
        _textViewInput.backgroundColor = [SkinManage colorNamed:@"All_textField_bg_color"];
        _lblTextNum.textColor = [SkinManage colorNamed:@"date_title"];
        _textViewInput.textColor = [SkinManage colorNamed:@"metting_Tite_color"];
        [_textViewInput setPlaceholderColor:[SkinManage colorNamed:@"Tab_Item_Color"]];
        _constraintEqualH.constant = 0.5;
        
        if(self.menuVo.nMaxLength <= 0)
        {
            _constraintTextBottom.constant = 10;
            _lblTextNum.hidden = YES;
        }
        
        if([self.menuVo.strKey isEqualToString:@"birthday"])
        {
            //生日
            self.textViewInput.userInteractionEnabled = NO;
            self.navigationItem.rightBarButtonItem = nil;
            
            pickerDate = [[CustomDatePicker alloc] initWithFrame:CGRectMake(0, kScreenHeight-324, kScreenWidth, 260) andDelegate:self];
            pickerDate.delegate = self;
            [pickerDate hideCancelButton];
            [self.view addSubview:pickerDate];
            pickerDate.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
            [self doSelectPickerView];
        }
        else if ([self.menuVo.strKey isEqualToString:@"departmentId"])
        {
            //子公司
            self.textViewInput.userInteractionEnabled = NO;
            self.navigationItem.rightBarButtonItem = nil;
            
            pickerDepartment = [[CustomPicker alloc] initWithFrame:CGRectMake(0, kScreenHeight-324, kScreenWidth, 260) andDelegate:self];
            pickerDepartment.delegate = self;
            [pickerDepartment hideCancelButton];
            [self.view addSubview:pickerDepartment];
            
            [self doSelectPickerView];
        }
        else
        {
            [self.textViewInput becomeFirstResponder];
        }
    }
    
    [self setText:self.menuVo.strValue];
    [self configView];
}

- (void)initData
{
    nMaxLength = self.menuVo.nMaxLength;
    userVo = [Common getCurrentUserVo];
    
    aryDepartment = [NSMutableArray array];
    [aryDepartment addObjectsFromArray:userVo.aryDepartmentList];
}

- (void)righBarClick
{
    [self commitUserInfo:nil];
}

- (void)commitUserInfo:(UserEditVo*)menuVoNew
{
    NSString *strValue = self.textViewInput.text;
    
    if (self.menuVo.bRequired && strValue.length == 0)
    {
        [Common tipAlert:[NSString stringWithFormat:@"%@不能为空",self.menuVo.strTitle]];
        return;
    }
    
    if ([self.menuVo.strKey isEqualToString:@"phoneNumber"])
    {
        if (strValue.length<8 || strValue.length>11)
        {
            [Common tipAlert:@"手机号码格式不正确"];
            return;
        }
    }
    
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc]init];
    [dicBody setObject:[Common getCurrentUserVo].strUserID forKey:@"id"];
    if ([self.menuVo.strKey isEqualToString:@"gender"] || [self.menuVo.strKey isEqualToString:@"departmentId"])
    {
        //性别&公司
        [dicBody setObject:menuVoNew.strValueID forKey:self.menuVo.strKey];
    }
    else
    {
        [dicBody setObject:strValue forKey:self.menuVo.strKey];
    }
    
    [Common showProgressView:nil view:self.view modal:NO];
    [ServerProvider updateUserInfoByDictionary:dicBody result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            //刷新视图
            if ([self.menuVo.strKey isEqualToString:@"gender"] || [self.menuVo.strKey isEqualToString:@"departmentId"])
            {
                self.menuVo.strValue = menuVoNew.strValue;
                self.menuVo.strValueID = menuVoNew.strValueID;
            }
            else
            {
                self.menuVo.strValue = strValue;
            }
            
            //update user info
            [self updateCurrentUserVo];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshUserDetail" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)setText:(NSString *)strText
{
    self.textViewInput.text = strText;
    [self updateTextViewHeight];
    [self textViewDidChange:self.textViewInput];
}

//选中当前PickerView
-(void)doSelectPickerView
{
    if ([self.menuVo.strKey isEqualToString:@"birthday"])
    {
        //出生日期
        NSString *strDate = self.menuVo.strValue;
        if (strDate.length>0)
        {
            NSDate *date = [Common getDateFromDateStr:strDate];
            if (date != nil)
            {
                [pickerDate.pickerView setDate:date animated:YES];
            }
        }
    }
    else if ([self.menuVo.strKey isEqualToString:@"departmentId"])
    {
        //部门
        if (self.menuVo.strValueID != nil && self.menuVo.strValueID.length>0)
        {
            for (int i=0; i<aryDepartment.count; i++)
            {
                DepartmentVo *deparmentVo = [aryDepartment objectAtIndex:i];
                if ([deparmentVo.strDepartmentID isEqualToString:self.menuVo.strValueID])
                {
                    [pickerDepartment.pickerView selectRow:i inComponent:0 animated:YES];
                    break;
                }
            }
        }
    }
}

//动态更新UITextView的高度
- (void)updateTextViewHeight
{
    CGFloat fContentH = [self.textViewInput sizeThatFits:CGSizeMake(_textViewInput.frame.size.width, CGFLOAT_MAX)].height;
    if (fContentH > 26 && fabs(fContentH-_textViewInput.frame.size.height) > 0.01)//进行优化，避免每次输入都更新height
    {
        self.constraintTextH.constant = fContentH;
        [self.view layoutIfNeeded];
    }
}

- (void)configView
{
    if([self.menuVo.strKey isEqualToString:@"userName"])
    {
        
    }
    else if ([self.menuVo.strKey isEqualToString:@"trueName"])
    {
        
    }
    else if ([self.menuVo.strKey isEqualToString:@"phoneNumber"])
    {
        self.textViewInput.keyboardType = UIKeyboardTypePhonePad;
    }
    else if ([self.menuVo.strKey isEqualToString:@"departmentId"])
    {
        
    }
    else if ([self.menuVo.strKey isEqualToString:@"title"])
    {
    }
    else if ([self.menuVo.strKey isEqualToString:@"signature"])
    {
    }
    else if ([self.menuVo.strKey isEqualToString:@"gender"])
    {
    }
    else if ([self.menuVo.strKey isEqualToString:@"birthday"])
    {
    }
    else if ([self.menuVo.strKey isEqualToString:@"qq"])
    {
        self.textViewInput.keyboardType = UIKeyboardTypeNumberPad;
    }
    else if ([self.menuVo.strKey isEqualToString:@"email"])
    {
        self.textViewInput.keyboardType = UIKeyboardTypeEmailAddress;
    }
}

- (void)updateCurrentUserVo
{
    if([self.menuVo.strKey isEqualToString:@"userName"])
    {
        userVo.strUserName = self.menuVo.strValue;
    }
    else if ([self.menuVo.strKey isEqualToString:@"trueName"])
    {
        userVo.strRealName = self.menuVo.strValue;
    }
    else if ([self.menuVo.strKey isEqualToString:@"phoneNumber"])
    {
        userVo.strPhoneNumber = self.menuVo.strValue;
    }
    else if ([self.menuVo.strKey isEqualToString:@"departmentId"])
    {
        userVo.strDepartmentName = self.menuVo.strValue;
        userVo.strDepartmentId = self.menuVo.strValueID;
    }
    else if ([self.menuVo.strKey isEqualToString:@"title"])
    {
        userVo.strPosition = self.menuVo.strValue;
    }
    else if ([self.menuVo.strKey isEqualToString:@"signature"])
    {
        userVo.strSignature = self.menuVo.strValue;
    }
    else if ([self.menuVo.strKey isEqualToString:@"gender"])
    {
        userVo.gender = self.menuVo.strValue.integerValue;
    }
    else if ([self.menuVo.strKey isEqualToString:@"birthday"])
    {
        userVo.strBirthday = self.menuVo.strValue;
    }
    else if ([self.menuVo.strKey isEqualToString:@"qq"])
    {
        userVo.strQQ = self.menuVo.strValue;
    }
    else if ([self.menuVo.strKey isEqualToString:@"email"])
    {
        userVo.strEmail = self.menuVo.strValue;
    }
    
}

- (IBAction)selectGenderAction:(UIButton *)sender
{
    UserEditVo *userEditVo = [[UserEditVo alloc]init];
    if (sender == self.btnGenderMale)
    {
        userEditVo.strValue = @"男";
        userEditVo.strValueID = @"1";
    }
    else
    {
        userEditVo.strValue = @"女";
        userEditVo.strValueID = @"0";
    }
    
    if ([self.menuVo.strValueID isEqualToString:userEditVo.strValueID])
    {
        //没有改变,则不提交
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self commitUserInfo:userEditVo];
    }
}

#pragma mark - CustomDatePickerDelegate
- (void)doneDatePickerButtonClick:(CustomDatePicker*)pickerViewCtrl
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    if (pickerViewCtrl == pickerDate)
    {
        NSDate *date = pickerViewCtrl.pickerView.date;
        self.textViewInput.text = [dateFormatter stringFromDate:date];
        [self commitUserInfo:nil];
    }
}

#pragma mark - CustomPickerDelegate
- (void)donePickerButtonClick:(CustomPicker*)pickerViewCtrl
{
    if (pickerViewCtrl == pickerDepartment && aryDepartment.count>0)
    {
        DepartmentVo *departmentVo = [aryDepartment objectAtIndex:[pickerViewCtrl getSelectedRowNum]];
        
        UserEditVo *userEditVo = [[UserEditVo alloc]init];
        userEditVo.strValue = departmentVo.strDepartmentName;
        userEditVo.strValueID = departmentVo.strDepartmentID;
        
        [self commitUserInfo:userEditVo];
    }
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
    if (pickerView == pickerDepartment.pickerView)
    {
        nRowNum = aryDepartment.count;
    }
    return nRowNum;
}

//3 绑定选取器上面的数据，主要是文本
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *strText = @"";
    if (pickerView == pickerDepartment.pickerView)
    {
        DepartmentVo *departmentVo = [aryDepartment objectAtIndex:row];
        strText = departmentVo.strDepartmentName;
    }
    return strText;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        return NO;
    }
    
    NSString *string = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if (nMaxLength > 0 && [string length] > nMaxLength)
    {
        //防止输入或粘帖字数超过 nMaxLength
        string = [string substringToIndex:nMaxLength];
        textView.text = string;
        [self updateTextViewHeight];
        return NO;
    }
    else
    {
        [self updateTextViewHeight];
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *strValue = textView.text;
    
    //限制字数
    if(nMaxLength > 0 )
    {
        if(strValue.length > nMaxLength)
        {
            textView.text = [strValue substringToIndex:nMaxLength];
            strValue = textView.text;
        }
        
        self.lblTextNum.text = [NSString stringWithFormat:@"%li/%li",(unsigned long)strValue.length,(unsigned long)nMaxLength];
    }
    
    [self updateTextViewHeight];
    if (strValue.length > 0 && ![strValue isEqualToString:self.menuVo.strValue])
    {
        btnNavRight.enabled = YES;
    }
    else
    {
        btnNavRight.enabled = NO;
    }
}

@end
