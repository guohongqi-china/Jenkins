//
//  RegisterCompanyViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/25.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "RegisterCompanyViewController.h"
#import "DepartmentVo.h"
#import "CommitButtonView.h"
#import "RegisterPhoneViewController.h"
#import "Constants+OC.h"

@interface RegisterCompanyViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    UIPickerView *pickerViewDepartment;
    NSMutableArray *aryDepartmentList;
    
    CommitButtonView *commitButtonView;
    DepartmentVo *departmentSelected;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgViewValidate;
@property (weak, nonatomic) IBOutlet UITextField *txtCompany;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintIconH;

@end

@implementation RegisterCompanyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(self.bFirstAppear)
    {
        [self.txtCompany becomeFirstResponder];
    }
}

- (void)initView
{
    self.isNeedBackItem = NO;
    [self setTitleImage:[UIImage imageNamed:@"nav_logo"]];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_normal"] style:UIBarButtonItemStylePlain target:self action:@selector(backForePage)];
    leftItem.tintColor = THEME_COLOR;
    self.navigationItem.leftBarButtonItem = leftItem;
    
    pickerViewDepartment = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 216)];
    pickerViewDepartment.delegate = self;
    pickerViewDepartment.dataSource = self;
    pickerViewDepartment.backgroundColor = [UIColor whiteColor];
    
    self.txtCompany.inputView = pickerViewDepartment;
    
    @weakify(self)
    commitButtonView = [[CommitButtonView alloc]initWithLeftTitle:nil right:@"下一步" action:^(UIButton *sender) {
        @strongify(self)
        [self.txtCompany resignFirstResponder];
        RegisterPhoneViewController *registerPhoneViewController = [[UIStoryboard storyboardWithName:@"LoginModule" bundle:nil]instantiateViewControllerWithIdentifier:@"RegisterPhoneViewController"];
        DepartmentVo *departmentVo = aryDepartmentList[[pickerViewDepartment selectedRowInComponent:0]];
        self.registerVo.strDepartmentId = departmentVo.strDepartmentID;
        registerPhoneViewController.registerVo = self.registerVo;
        [self.navigationController pushViewController:registerPhoneViewController animated:YES];
    }];
    [self.view addSubview:commitButtonView];
    
    [commitButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(0);
        make.height.equalTo(44.5);
    }];
}

- (void)initData
{
    aryDepartmentList = [NSMutableArray array];
    DepartmentVo *department = [[DepartmentVo alloc]init];
    department.strDepartmentID = @"0";
    department.strDepartmentName = @"";
    [aryDepartmentList addObject:department];
    
    [ServerProvider getAllCompanyList:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess)
        {
            //刷新视图
            [aryDepartmentList addObjectsFromArray:retInfo.data];
            [pickerViewDepartment reloadAllComponents];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)validateCompanySelected
{
    if (self.txtCompany.text.length > 0)
    {
        [commitButtonView setRightButtonEnable:YES];
        
        if (self.imgViewValidate.alpha < 0.0001)//浮点数
        {
            [UIView animateWithDuration:0.5 animations:^{
                self.imgViewValidate.alpha = 1.0;
                self.constraintIconH.constant = 20;
                [self.view layoutIfNeeded];
            }];
        }
    }
    else
    {
        [commitButtonView setRightButtonEnable:NO];
        
        if (self.imgViewValidate.alpha > 0.0001)//浮点数
        {
            [UIView animateWithDuration:0.5 animations:^{
                self.imgViewValidate.alpha = 0;
                self.constraintIconH.constant = 10;
                [self.view layoutIfNeeded];
            }];
        }
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
    if (pickerView == pickerViewDepartment)
    {
        nRowNum = aryDepartmentList.count;
    }
    return nRowNum;
}

//3 绑定选取器上面的数据，主要是文本
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *strText = @"";
    if (pickerView == pickerViewDepartment)
    {
        DepartmentVo *departmentVo = [aryDepartmentList objectAtIndex:row];
        strText = departmentVo.strDepartmentName;
    }
    return strText;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    DepartmentVo *departmentVo = [aryDepartmentList objectAtIndex:row];
    if ([departmentVo.strDepartmentID isEqualToString:@"0"])
    {
        self.txtCompany.text = nil;
    }
    else
    {
        self.txtCompany.text = departmentVo.strDepartmentName;
        departmentSelected = departmentVo;
    }
    
    [self validateCompanySelected];
}

@end
