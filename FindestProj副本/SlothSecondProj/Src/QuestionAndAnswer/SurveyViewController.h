//
//  SurveyViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 11/28/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "QuestionSurveyVo.h"
#import "QuestionVo.h"

@interface SurveyViewController : QNavigationViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property(nonatomic,strong)UIScrollView *scrollViewSurvey;
@property(nonatomic,strong)UILabel *lblQNum;//第n题
@property(nonatomic,strong)UILabel *lblQDesc;//题目简介
@property(nonatomic,strong)UILabel *lblQName;//题目
@property(nonatomic,strong)UITableView *tableViewOption;

@property(nonatomic,strong)UILabel *lblSurveyTitle;
@property(nonatomic,strong)UILabel *lblSurveyDesc;

@property(nonatomic,strong)UIButton *btnStart;//开始答题
@property(nonatomic,strong)UIButton *btnPrevious;//上一题
@property(nonatomic,strong)UIButton *btnNext;//下一题

@property(nonatomic,strong)NSString *strSurveyID;//问卷ID
@property(nonatomic,strong)QuestionSurveyVo *m_surveyVo;
@property(nonatomic,strong)NSMutableArray *aryQuestion;//问题列表


@property(nonatomic,strong)NSMutableArray *m_aryOption;//问题列表

@property(nonatomic)NSInteger nCurrIndex;//当前问题的序号
@property(nonatomic)NSInteger nCurrChooseNum;//当前选择的数量

@end
