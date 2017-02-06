//
//  AddSuggestionViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/3/16.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "AddSuggestionViewController.h"
#import "DepartmentVo.h"
#import "KeyValueVo.h"
#import "Utils.h"
#import "UserVo.h"
#import "UIViewExt.h"

@interface AddSuggestionViewController ()

@end

@implementation AddSuggestionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData
{
    //检查基础数据
    if (self.suggestionBaseVo == nil)
    {
        self.suggestionBaseVo = [Common getSuggestionBaseVo];
        if (self.suggestionBaseVo == nil)
        {
            
            [self isHideActivity:NO];
            [ServerProvider getSuggestionBaseDataList:^(ServerReturnInfo *retInfo) {
                [self isHideActivity:YES];
                if (retInfo.bSuccess)
                {
                    self.suggestionBaseVo = retInfo.data;
                    [Common setSuggestionBaseVo:self.suggestionBaseVo];
                }
                
                [self.pickerSuggestionType.pickerView reloadAllComponents];
            }];
        }
    }
    
    //检查分公司数据
    [self isHideActivity:NO];
    [ServerProvider getAllCompanyList:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            self.aryDepartment = retInfo.data;
        }
        
        [self.pickerDepartment.pickerView reloadAllComponents];
        if(self.suggestionViewType == SuggestionViewEditType)
        {
            [self refreshView];
        }
    }];
}

- (void)initView
{
    UserVo *userVoCurrent = [Common getCurrentUserVo];
    self.view.backgroundColor = [UIColor whiteColor];//COLOR(239, 239, 244, 1.0);
    
    [self setTopNavBarTitle:@"写建议"];
    
    //左边按钮
    UIButton *btnCancel = [Utils buttonWithTitle:@"取消" frame:[Utils getNavLeftBtnFrame:CGSizeMake(100,76)] target:self action:@selector(backButtonClicked)];
    [self setLeftBarButton:btnCancel];
    
    //右边按钮
    UIButton *btnEdit = [Utils buttonWithTitle:@"提交" frame:[Utils getNavRightBtnFrame:CGSizeMake(100,76)] target:self action:@selector(doCommit)];
    [self setRightBarButton:btnEdit];
    
    self.m_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT)];
    self.m_scrollView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.m_scrollView.autoresizingMask = NO;
    self.m_scrollView.clipsToBounds = YES;
    self.m_scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:self.m_scrollView];
    
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundTap)];
    tapGestureRecognizer1.delegate = self;
    [self.m_scrollView addGestureRecognizer:tapGestureRecognizer1];
    
    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundTap)];
    tapGestureRecognizer2.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer2];
    
    CGFloat fHeight = 10.0;
    self.dicOffsetY = [[NSMutableDictionary alloc]init];
    
    //提议人姓名
    self.txtName = [[UITextField alloc]initWithFrame:CGRectMake(12, fHeight, kScreenWidth-24,44)];
    
    
    self.txtName.font = [UIFont systemFontOfSize:16];
    self.txtName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.txtName.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"姓名" attributes:@{NSForegroundColorAttributeName:[SkinManage colorNamed:@"Tab_Item_Color"]}];
    self.txtName.text = userVoCurrent.strRealName;
    self.txtName.delegate = self;
    self.txtName.tag = 501;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"501"];
    [self.m_scrollView addSubview:self.txtName];
    
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(12, self.txtName.bottom, kScreenWidth-12, 0.5)];
    viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.m_scrollView addSubview:viewLine];
    fHeight += 45;
    
    //所属分公司
    self.txtDepartment = [[UITextField alloc]initWithFrame:CGRectMake(12, fHeight, kScreenWidth-24,44)];
    self.txtDepartment.font = [UIFont systemFontOfSize:16];
    self.txtDepartment.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.txtDepartment.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"公司" attributes:@{NSForegroundColorAttributeName:[SkinManage colorNamed:@"Tab_Item_Color"]}];
    self.txtDepartment.delegate = self;
    self.txtDepartment.tag = 502;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"502"];
    [self.m_scrollView addSubview:self.txtDepartment];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(12, self.txtDepartment.bottom, kScreenWidth-12, 0.5)];
    viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.m_scrollView addSubview:viewLine];
    fHeight += 45;
    
    //获取当前登录用户的所属分公司
    if(userVoCurrent.strDepartmentId.length>0)
    {
        self.txtDepartment.text = userVoCurrent.strDepartmentName;
        self.strDepartmentID = userVoCurrent.strDepartmentId;
    }
    
    self.pickerDepartment = [[CustomPicker alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 260) andDelegate:self];
    [self.view addSubview:self.pickerDepartment];
    
    //建议名称
    self.txtSuggestionName = [[UITextField alloc]initWithFrame:CGRectMake(12, fHeight, kScreenWidth-24,44)];;
    self.txtSuggestionName.font = [UIFont systemFontOfSize:16];
    self.txtSuggestionName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.txtSuggestionName.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"建议名称" attributes:@{NSForegroundColorAttributeName:[SkinManage colorNamed:@"Tab_Item_Color"]}];
    self.txtSuggestionName.delegate = self;
    self.txtSuggestionName.tag = 503;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"503"];
    [self.m_scrollView addSubview:self.txtSuggestionName];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(12, self.txtSuggestionName.bottom, kScreenWidth-12, 0.5)];
    viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.m_scrollView addSubview:viewLine];
    fHeight += 45;
    
    //建议类别
    self.txtSuggestionType = [[UITextField alloc]initWithFrame:CGRectMake(12, fHeight, kScreenWidth-24,44)];;
    self.txtSuggestionType.font = [UIFont systemFontOfSize:16];
    self.txtSuggestionType.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.txtSuggestionType.attributedPlaceholder = [[NSAttributedString alloc]initWithString:@"建议类别" attributes:@{NSForegroundColorAttributeName:[SkinManage colorNamed:@"Tab_Item_Color"]}];
    self.txtSuggestionType.delegate = self;
    self.txtSuggestionType.tag = 504;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"504"];
    [self.m_scrollView addSubview:self.txtSuggestionType];
    
    self.imgViewSuggestionIcon = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth-36, fHeight+14, 14, 8)];
    self.imgViewSuggestionIcon.image = [UIImage imageNamed:@"filter_arrow_down"];
    [self.m_scrollView addSubview:self.imgViewSuggestionIcon];
    
    self.pickerSuggestionType = [[CustomPicker alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 260) andDelegate:self];
    [self.view addSubview:self.pickerSuggestionType];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(12, self.txtSuggestionType.bottom, kScreenWidth-12, 0.5)];
    viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.m_scrollView addSubview:viewLine];
    fHeight += 45;
    
    //目前存在的问题
    self.txtProblemDes = [[BRPlaceholderTextView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20,72)];
    self.txtProblemDes.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.txtProblemDes.placeholder = @"建议内容";
    [self.txtProblemDes setPlaceholderColor:[SkinManage colorNamed:@"Tab_Item_Color"]];
    [self.txtProblemDes setPlaceholderFont:[UIFont systemFontOfSize:16]];
    self.txtProblemDes.font = [UIFont systemFontOfSize:16];
    self.txtProblemDes.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.txtProblemDes.delegate = self;
    self.txtProblemDes.tag = 505;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"505"];
    [self.m_scrollView addSubview:self.txtProblemDes];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(12, self.txtProblemDes.bottom, kScreenWidth-12, 0.5)];
    viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.m_scrollView addSubview:viewLine];
    fHeight += 75;
    
    //建议改进的措施
    self.txtImproveDes = [[BRPlaceholderTextView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20,72)];
    self.txtImproveDes.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.txtImproveDes.placeholder = @"改进措施";
    [self.txtImproveDes setPlaceholderColor:[SkinManage colorNamed:@"Tab_Item_Color"]];
    [self.txtImproveDes setPlaceholderFont:[UIFont systemFontOfSize:16]];
    self.txtImproveDes.font = [UIFont systemFontOfSize:16];
    self.txtImproveDes.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.txtImproveDes.delegate = self;
    self.txtImproveDes.tag = 506;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"506"];
    [self.m_scrollView addSubview:self.txtImproveDes];
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(12, self.txtImproveDes.bottom, kScreenWidth-12, 0.5)];
    viewLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.m_scrollView addSubview:viewLine];
    fHeight += 75;
    
    fHeight += 255;
    if(fHeight+NAV_BAR_HEIGHT < kScreenHeight)
    {
        fHeight = kScreenHeight-NAV_BAR_HEIGHT+0.5;
    }
    
    [self.m_scrollView setContentSize:CGSizeMake(kScreenWidth, fHeight)];
}

- (void)refreshView
{
    if(self.suggestionViewType == SuggestionViewEditType)
    {
        self.txtName.text = self.m_suggestionVo.strName;
        
        //所属分公司
        self.txtDepartment.text = self.m_suggestionVo.strDepartmentName;
        self.strDepartmentID = self.m_suggestionVo.strDepartmentID;
        
        //建议名称
        self.txtSuggestionName.text = self.m_suggestionVo.strSuggestionName;
        
        //建议类别
        self.txtSuggestionType.text = self.m_suggestionVo.strTypeValue;
        self.strSuggestionTypeID = self.m_suggestionVo.strTypeKey;
        
        //目前存在的问题
        self.txtProblemDes.text = self.m_suggestionVo.strProblemDes;
        
        //建议改进的措施
        self.txtImproveDes.text = self.m_suggestionVo.strImproveDes;
    }
}

-(void)doCommit
{
    SuggestionVo *suggestionVo = [[SuggestionVo alloc]init];
    
    suggestionVo.strName = self.txtName.text;
    if (suggestionVo.strName.length == 0)
    {
        [Common bubbleTip:@"姓名不能为空" andView:self.view];
        return;
    }
    
    suggestionVo.strDepartmentID = self.strDepartmentID;
    if (suggestionVo.strDepartmentID.length == 0)
    {
        [Common bubbleTip:@"请选择所属分公司" andView:self.view];
        return;
    }
    
    suggestionVo.strSuggestionName = self.txtSuggestionName.text;
    if (suggestionVo.strSuggestionName.length == 0)
    {
        [Common bubbleTip:@"建议名称不能为空" andView:self.view];
        return;
    }
    
    suggestionVo.strTypeKey = self.strSuggestionTypeID;
    if (suggestionVo.strTypeKey.length == 0)
    {
        [Common bubbleTip:@"请选择建议类别" andView:self.view];
        return;
    }
    
    suggestionVo.strProblemDes = self.txtProblemDes.text;
    if (suggestionVo.strProblemDes.length == 0)
    {
        [Common bubbleTip:@"请填写建议内容" andView:self.view];
        return;
    }
    
    suggestionVo.strImproveDes = self.txtImproveDes.text;
    if (suggestionVo.strImproveDes.length == 0)
    {
        [Common bubbleTip:@"请填写改进措施" andView:self.view];
        return;
    }
    
    if (self.suggestionViewType == SuggestionViewEditType)
    {
        //修改建议
        suggestionVo.strID = self.m_suggestionVo.strID;
        suggestionVo.nDBVersion = self.m_suggestionVo.nDBVersion;
        
        [self isHideActivity:NO];
        [ServerProvider commitSuggestionReview:suggestionVo result:^(ServerReturnInfo *retInfo) {
            [self isHideActivity:YES];
            if (retInfo.bSuccess)
            {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshSuggestionDetail" object:nil];
                [self backButtonClicked];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
    else
    {
        //添加建议
        [self isHideActivity:NO];
        [ServerProvider commitSuggestion:suggestionVo result:^(ServerReturnInfo *retInfo) {
            [self isHideActivity:YES];
            if (retInfo.bSuccess)
            {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshSuggestionList" object:nil];
                [self backButtonClicked];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
}

- (void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//选择建议分类或者部门
-(void)doSelectPickerView:(UITextField*)txtField
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    if (txtField == self.txtDepartment)
    {
        //所属公司
        [self fieldOffset:self.txtDepartment.tag];
        [self setPickerHidden:self.pickerDepartment andHide:NO];
        
        //初始选中
        if (self.strDepartmentID != nil && self.strDepartmentID.length>0)
        {
            for (int i=0; i<self.aryDepartment.count; i++)
            {
                DepartmentVo *deparmentVo = [self.aryDepartment objectAtIndex:i];
                if ([deparmentVo.strDepartmentID isEqualToString:self.strDepartmentID])
                {
                    [self.pickerDepartment.pickerView selectRow:i inComponent:0 animated:YES];
                    break;
                }
            }
        }
    }
    else if (txtField == self.txtSuggestionType)
    {
        //建议类别
        [self fieldOffset:self.txtSuggestionType.tag];
        [self setPickerHidden:self.pickerSuggestionType andHide:NO];
        
        //初始选中
        if (self.strSuggestionTypeID != nil && self.strSuggestionTypeID.length>0)
        {
            for (int i=0; i<self.suggestionBaseVo.arySuggestionType.count; i++)
            {
                KeyValueVo *keyValueVo = [self.suggestionBaseVo.arySuggestionType objectAtIndex:i];
                if ([keyValueVo.strKey isEqualToString:self.strSuggestionTypeID])
                {
                    [self.pickerSuggestionType.pickerView selectRow:i inComponent:0 animated:YES];
                    break;
                }
            }
        }
    }
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

-(void)backgroundTap
{
    for(UIView*view in[self.m_scrollView subviews])
    {
        if([view isFirstResponder])
        {
            [view resignFirstResponder];
            return;
        }
    }
    
    [self setPickerHidden:self.pickerDepartment andHide:YES];
    [self setPickerHidden:self.pickerSuggestionType andHide:YES];
}

//显示隐藏PickerView控件
- (void)setPickerHidden:(UIView*)pickerViewCtrl andHide:(BOOL)hidden
{
    int nHeight = pickerViewCtrl.frame.size.height * (-1);
    CGAffineTransform transform = hidden ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, nHeight);
    pickerViewCtrl.transform = transform;
    if (!hidden)
    {
        [self.view bringSubviewToFront:self.pickerSuggestionType];
        self.view.backgroundColor = [UIColor whiteColor];
        self.m_scrollView.frame = CGRectMake(0, NAV_BAR_HEIGHT, self.view.bounds.size.width, (kScreenHeight-NAV_BAR_HEIGHT-260+44));
    }
    else
    {
        self.m_scrollView.frame = CGRectMake(0, NAV_BAR_HEIGHT, self.view.bounds.size.width, kScreenHeight-NAV_BAR_HEIGHT);
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //ignore any touches from a UIToolbar
    if ([touch.view.superview isKindOfClass:[UIToolbar class]])
    {
        return NO;
    }
    return YES;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == 502)
    {
        //        [self doSelectPickerView:textField];
        //        [self setPickerHidden:self.pickerDepartment andHide:NO];
        return NO;
    }
    else if(textField.tag == 504)
    {
        [self doSelectPickerView:textField];
        [self setPickerHidden:self.pickerSuggestionType andHide:NO];
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self setPickerHidden:self.pickerDepartment andHide:YES];
    [self setPickerHidden:self.pickerSuggestionType andHide:YES];
    //编辑时调整view
    [self fieldOffset:textField.tag];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self setPickerHidden:self.pickerDepartment andHide:YES];
    [self setPickerHidden:self.pickerSuggestionType andHide:YES];
    //编辑时调整view
    [self fieldOffset:textView.tag];
}

#pragma mark - CustomPickerDelegate
- (void)donePickerButtonClick:(CustomPicker*)pickerViewCtrl
{
    [self setPickerHidden:pickerViewCtrl andHide:YES];
    if (pickerViewCtrl == self.pickerDepartment)
    {
        if (self.aryDepartment.count>0)
        {
            DepartmentVo *departmentVo = [self.aryDepartment objectAtIndex:[pickerViewCtrl getSelectedRowNum]];
            self.strDepartmentID = departmentVo.strDepartmentID;
            self.txtDepartment.text = departmentVo.strDepartmentName;
            [self.pickerDepartment.pickerView reloadComponent:0];
        }
    }
    else if (pickerViewCtrl == self.pickerSuggestionType)
    {
        if (self.suggestionBaseVo.arySuggestionType.count>0)
        {
            KeyValueVo *keyValueVo = [self.suggestionBaseVo.arySuggestionType objectAtIndex:[pickerViewCtrl getSelectedRowNum]];
            self.strSuggestionTypeID = keyValueVo.strKey;
            self.txtSuggestionType.text = keyValueVo.strValue;
            [self.pickerSuggestionType.pickerView reloadComponent:0];
        }
    }
}

- (void)cancelPickerButtonClick:(CustomPicker*)pickerViewCtrl
{
    [self setPickerHidden:pickerViewCtrl andHide:YES];
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
        nRowNum = self.aryDepartment.count;
    }
    else if (pickerView == self.pickerSuggestionType.pickerView)
    {
        nRowNum = self.suggestionBaseVo.arySuggestionType.count;
    }
    return nRowNum;
}

//3 绑定选取器上面的数据，主要是文本
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *strText = @"";
    if (pickerView == self.pickerDepartment.pickerView)
    {
        DepartmentVo *departmentVo = [self.aryDepartment objectAtIndex:row];
        strText = departmentVo.strDepartmentName;
    }
    else if(pickerView == self.pickerSuggestionType.pickerView)
    {
        KeyValueVo *keyValueVo = [self.suggestionBaseVo.arySuggestionType objectAtIndex:row];
        strText = keyValueVo.strValue;
    }
    return strText;
}

@end
