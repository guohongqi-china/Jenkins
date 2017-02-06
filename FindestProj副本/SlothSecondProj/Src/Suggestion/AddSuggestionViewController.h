//
//  AddSuggestionViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/3/16.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "InsetsTextField.h"
#import "CustomPicker.h"
#import "SuggestionVo.h"
#import "SuggestionBaseVo.h"
#import "BRPlaceholderTextView.h"

typedef enum _SuggestionViewType{
    SuggestionViewAddType,
    SuggestionViewEditType
}SuggestionViewType;

@interface AddSuggestionViewController : QNavigationViewController<UIGestureRecognizerDelegate,UITextFieldDelegate,UITextViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,CustomPickerDelegate>

@property(nonatomic,strong)NSMutableDictionary *dicOffsetY; 
@property(nonatomic,strong)UIScrollView *m_scrollView;

@property(nonatomic,strong)NSString *strDepartmentID;       //缓存departmentID
@property(nonatomic,strong)NSString *strSuggestionTypeID;       //缓存suggestionTypeID
@property(nonatomic,strong)SuggestionBaseVo *suggestionBaseVo;
@property(nonatomic,strong)NSMutableArray *aryDepartment;

//用于修改建议
@property(nonatomic,strong)SuggestionVo *m_suggestionVo;
@property(nonatomic)SuggestionViewType suggestionViewType;

//提议人姓名
@property(nonatomic,strong)UITextField *txtName;

//所属分公司
@property(nonatomic,strong)UITextField *txtDepartment;
@property(nonatomic,strong)CustomPicker *pickerDepartment;
@property(nonatomic,strong)UIImageView *imgViewDepartmentIcon;

//建议名称
@property(nonatomic,strong)UITextField *txtSuggestionName;

//建议类别
@property(nonatomic,strong)UITextField *txtSuggestionType;
@property(nonatomic,strong)CustomPicker *pickerSuggestionType;
@property(nonatomic,strong)UIImageView *imgViewSuggestionIcon;

//目前存在的问题
@property(nonatomic,strong)BRPlaceholderTextView *txtProblemDes;

//建议改进的措施
@property(nonatomic,strong)BRPlaceholderTextView *txtImproveDes;

@end
