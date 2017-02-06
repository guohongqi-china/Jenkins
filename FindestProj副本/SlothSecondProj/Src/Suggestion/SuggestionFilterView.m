//
//  SuggestionFilterView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/2/29.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "SuggestionFilterView.h"
#import "UIViewExt.h"

@interface SuggestionFilterView ()
{
    NSMutableArray *aryState;
    NSMutableArray *aryDepartment;
    
    BOOL bExpandState;
    BOOL bExpandDepartment;
    
    DropDownDataVo *dataState;
    DropDownDataVo *dataDepartment;
    
    CGFloat fBtnWidth;
    CGFloat fBtnHeight;
}

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *stateView;
@property (weak, nonatomic) IBOutlet UIView *stateBottomView;
@property (weak, nonatomic) IBOutlet UIView *stateSepView;

@property (weak, nonatomic) IBOutlet UIView *departmentView;
@property (weak, nonatomic) IBOutlet UIView *departmentBottomView;
@property (weak, nonatomic) IBOutlet UIView *departmentSepView;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIView *buttonConfirmView;

@property (weak, nonatomic) IBOutlet UILabel *chooseStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lblChoosedState;
@property (weak, nonatomic) IBOutlet UIView *viewStateContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintStateH;

@property (weak, nonatomic) IBOutlet UILabel *chooseDepartmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *lblChoosedDepartment;
@property (weak, nonatomic) IBOutlet UIView *viewDepartmentContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDepartmentH;

@property (weak, nonatomic) IBOutlet UIButton *btnExpandState;
@property (weak, nonatomic) IBOutlet UIButton *btnExpandDepartment;

@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTopOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintResetBtnW;

@end

@implementation SuggestionFilterView

- (instancetype)initWithFrame:(CGRect)frame state:(NSArray*)aryStateData department:(NSArray*)aryDepartmentData
{
    self = [super init];
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:@"SuggestionFilterView" owner:self options:nil];
        self.view.frame = frame;
        self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        aryState = [NSMutableArray array];
        [aryState addObjectsFromArray:aryStateData];
        
        aryDepartment = [NSMutableArray array];
        [aryDepartment addObjectsFromArray:aryDepartmentData];
        
        bExpandState = NO;
        bExpandDepartment = NO;
        
        fBtnWidth = (kScreenWidth-24-40)/3;
        fBtnHeight = 44;
        
        _constraintTopOffset.constant = -1*self.view.height;
        _constraintBottomOffset.constant = self.view.height;
        _constraintResetBtnW.constant = fBtnWidth;
        [self.view layoutIfNeeded];
        
        [self initView];
    }
    return self;
}

- (void)initView
{
    [_btnConfirm setBackgroundImage:[Common getImageWithColor:COLOR(239, 111, 88, 1.0)] forState:UIControlStateNormal];
    
    //init state list
    if (aryState.count > 0)
    {
        dataState = aryState[0];
        dataState.nIndex = 1000;
    }
    for (int i=1; i<aryState.count; i++)
    {
        DropDownDataVo *dataVo = aryState[i];
        dataVo.nIndex = 1000+i;
        UIButton *btnState = [UIButton buttonWithType:UIButtonTypeCustom];
        btnState.layer.cornerRadius = 5;
        btnState.layer.masksToBounds = YES;
        btnState.frame = CGRectMake(12+((i-1)%3)*(fBtnWidth+20), 10+((i-1)/3)*(fBtnHeight+10), fBtnWidth, fBtnHeight);
        [btnState setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"deveice_btnColor"]] forState:UIControlStateNormal];
        [btnState setBackgroundImage:[Common getImageWithColor:COLOR(239, 111, 88, 1.0)] forState:UIControlStateSelected];
        btnState.tag = dataVo.nIndex;
        [btnState setTitle:dataVo.strName forState:UIControlStateNormal];
        [btnState setTitleColor:COLOR(51, 43, 41, 1.0) forState:UIControlStateNormal];
        [btnState setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        btnState.titleLabel.font = [UIFont systemFontOfSize:13];
        [btnState addTarget:self action:@selector(chooseCondition:) forControlEvents:UIControlEventTouchUpInside];
        [_viewStateContainer addSubview:btnState];
    }
    
    //init department list
    if (aryDepartment.count > 0)
    {
        dataDepartment = aryDepartment[0];
        dataDepartment.nIndex = 2000;
    }
    for (int i=1; i<aryDepartment.count; i++)
    {
        DropDownDataVo *dataVo = aryDepartment[i];
        dataVo.nIndex = 2000+i;
        UIButton *btnState = [UIButton buttonWithType:UIButtonTypeCustom];
        btnState.layer.cornerRadius = 5;
        btnState.layer.masksToBounds = YES;
        btnState.frame = CGRectMake(12+((i-1)%3)*(fBtnWidth+20), 10+((i-1)/3)*(fBtnHeight+10), fBtnWidth, fBtnHeight);
        [btnState setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"deveice_btnColor"]] forState:UIControlStateNormal];
        [btnState setBackgroundImage:[Common getImageWithColor:COLOR(239, 111, 88, 1.0)] forState:UIControlStateSelected];
        btnState.tag = dataVo.nIndex;
        [btnState setTitle:dataVo.strName forState:UIControlStateNormal];
        [btnState setTitleColor:COLOR(51, 43, 41, 1.0) forState:UIControlStateNormal];
        [btnState setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        btnState.titleLabel.font = [UIFont systemFontOfSize:13];
        [btnState addTarget:self action:@selector(chooseCondition:) forControlEvents:UIControlEventTouchUpInside];
        [_viewDepartmentContainer addSubview:btnState];
    }
    self.topView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.buttonConfirmView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.viewContainer.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.stateView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.stateBottomView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.stateSepView.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.departmentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.departmentBottomView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.departmentSepView.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.chooseStateLabel.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    self.chooseDepartmentLabel.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
}

- (void)refreshViewState:(DropDownDataVo *)stateData department:(DropDownDataVo *)departmentData
{
    //重置
    [self resetChooseAction:nil];
    
    //state
    if (stateData.nIndex > 1000 && stateData.nIndex < 2000)
    {
        UIButton *btnState = [_viewStateContainer viewWithTag:stateData.nIndex];
        [self chooseCondition:btnState];
    }
    
    //department
    if (departmentData.nIndex > 2000)
    {
        UIButton *btnDepartment = [_viewDepartmentContainer viewWithTag:departmentData.nIndex];
        [self chooseCondition:btnDepartment];
    }
}

- (void)showWithAnimation
{
    [UIView animateWithDuration:0.35 animations:^{
        _constraintTopOffset.constant = 0;
        _constraintBottomOffset.constant = 0;
        self.bShow = YES;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

//取消选择
- (void)cancelChooseAnimated:(BOOL)animated;
{
    [self dismissWithAnimation:animated];
    
    if ([self.delegate respondsToSelector:@selector(cancelChooseFilter)])
    {
        [self.delegate cancelChooseFilter];
    }
}

- (void)dismissWithAnimation:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.35 animations:^{
            _constraintTopOffset.constant = -1*self.view.height;
            _constraintBottomOffset.constant = self.view.height;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            self.bShow = NO;
        }];
    }
    else
    {
        _constraintTopOffset.constant = -1*self.view.height;
        _constraintBottomOffset.constant = self.view.height;
        [self.view removeFromSuperview];
        self.bShow = NO;
    }
}

- (void)chooseCondition:(UIButton *)sender
{
    if(sender.tag >= 2000)
    {
        //公司筛选
        DropDownDataVo *newDataVo = aryDepartment[sender.tag-2000];
        if (newDataVo.nIndex == dataDepartment.nIndex)
        {
            //取消选择
            UIButton *btnState = [_viewDepartmentContainer viewWithTag:newDataVo.nIndex];
            btnState.selected = NO;
            
            dataDepartment = aryDepartment[0];
        }
        else
        {
            //清除之前的状态
            if (dataDepartment.nIndex != 2000)
            {
                UIButton *btnState = [_viewDepartmentContainer viewWithTag:dataDepartment.nIndex];
                btnState.selected = NO;
            }
            
            //设置新状态
            dataDepartment = newDataVo;
            UIButton *btnState = [_viewDepartmentContainer viewWithTag:newDataVo.nIndex];
            btnState.selected = YES;
        }
        
        self.lblChoosedDepartment.text = dataDepartment.strName;
    }
    else
    {
        //状态筛选
        DropDownDataVo *newDataVo = aryState[sender.tag-1000];
        if (newDataVo.nIndex == dataState.nIndex)
        {
            //取消选择
            UIButton *btnState = [_viewStateContainer viewWithTag:newDataVo.nIndex];
            btnState.selected = NO;
            
            dataState = aryState[0];
        }
        else
        {
            //清除之前的状态
            if (dataState.nIndex != 1000)
            {
                UIButton *btnState = [_viewStateContainer viewWithTag:dataState.nIndex];
                btnState.selected = NO;
            }
            
            //设置新状态
            dataState = newDataVo;
            UIButton *btnState = [_viewStateContainer viewWithTag:newDataVo.nIndex];
            btnState.selected = YES;
        }
        
        self.lblChoosedState.text = dataState.strName;
    }
}

//提交选择
- (IBAction)completeFilter:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(completedChooseState: department:)])
    {
        [self.delegate completedChooseState:dataState department:dataDepartment];
        [self dismissWithAnimation:YES];
    }
}

//展开和隐藏
- (IBAction)expandViewAction:(UIButton *)sender
{
    [UIView animateWithDuration:0.35 animations:^{
        if(sender == _btnExpandState)
        {
            bExpandState = !bExpandState;
            if(bExpandState)
            {
                //展开
                _constraintStateH.constant = ceil(aryState.count*1.0/3)*(44+10);
                [_btnExpandState setImage:[UIImage imageNamed:@"filter_arrow_up"] forState:UIControlStateNormal];
            }
            else
            {
                //隐藏
                _constraintStateH.constant = 44+10;
                [_btnExpandState setImage:[UIImage imageNamed:@"filter_arrow_down"] forState:UIControlStateNormal];
            }
        }
        else
        {
            bExpandDepartment = !bExpandDepartment;
            if(bExpandDepartment)
            {
                //展开
                _constraintDepartmentH.constant = ceil(aryDepartment.count*1.0/3)*(44+10);
                [_btnExpandDepartment setImage:[UIImage imageNamed:@"filter_arrow_up"] forState:UIControlStateNormal];
            }
            else
            {
                //隐藏
                _constraintDepartmentH.constant = 44+10;
                [_btnExpandDepartment setImage:[UIImage imageNamed:@"filter_arrow_down"] forState:UIControlStateNormal];
            }
        }
        
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (IBAction)resetChooseAction:(id)sender
{
    //state
    if (dataState.nIndex > 1000 && dataState.nIndex < 2000)
    {
        UIButton *btnState = [_viewStateContainer viewWithTag:dataState.nIndex];
        [self chooseCondition:btnState];
        dataState = aryState[0];
    }
    
    //department
    if (dataDepartment.nIndex > 2000)
    {
        UIButton *btnDepartment = [_viewDepartmentContainer viewWithTag:dataDepartment.nIndex];
        [self chooseCondition:btnDepartment];
        dataDepartment = aryDepartment[0];
    }
}

@end
