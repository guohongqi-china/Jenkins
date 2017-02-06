//
//  SuggestionDetailViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/3/18.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "SuggestionVo.h"
#import "SuggestionBaseVo.h"
#import "KeyValueVo.h"
#import "UserVo.h"

@interface SuggestionDetailViewController : QNavigationViewController<UITextFieldDelegate>

@property(nonatomic,strong)SuggestionVo *m_suggestionVo;
@property(nonatomic,strong)SuggestionBaseVo *suggestionBaseVo;
@property(nonatomic)NSInteger nOptionSelected;//选择项
@property(nonatomic,strong)NSMutableDictionary *dicOffsetY;
@property(nonatomic)BOOL bReportAttention;//是否选择了上报总公司评奖
@property(nonatomic)BOOL bReportToHeadOffice;//是否选择了上报总公司评奖
@property(nonatomic)BOOL bRefreshList;//是否返回刷新建议列表

@property(nonatomic,strong)UserVo *userVoReview;

@property(nonatomic,strong)UIScrollView *m_scrollView;
@property(nonatomic,strong)UILabel *lblSuggestionTitle;
@property(nonatomic,strong)UIView *viewLine1;

@property(nonatomic,strong)UILabel *lblName;
@property(nonatomic,strong)UILabel *lblDepartment;
@property(nonatomic,strong)UILabel *lblSuggestionNo;
@property(nonatomic,strong)UILabel *lblDate;
@property(nonatomic,strong)UIView *viewLine2;

@property(nonatomic,strong)UILabel *lblProblemTitle;
@property(nonatomic,strong)UILabel *lblProblem;
@property(nonatomic,strong)UIView *viewLine3;

@property(nonatomic,strong)UILabel *lblImproveTitle;
@property(nonatomic,strong)UILabel *lblImprove;
@property(nonatomic,strong)UIView *viewLine4;

//审核结果视图容器
@property(nonatomic,strong)UIView *viewResultContainer;

//提交表单视图容器
@property(nonatomic,strong)UIView *viewFormContainer;

@property(nonatomic,strong)UIButton *btnEdit;//导航右边编辑按钮

- (void)finishedChooseReviewer:(UserVo*)userVo;

@end
