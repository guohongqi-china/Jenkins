//
//  SuggestionDetailViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/3/18.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "SuggestionDetailViewController.h"
#import "InsetsTextField.h"
#import "Utils.h"
#import "AddSuggestionViewController.h"
#import "SuggestionRoleVo.h"
#import "UserVo.h"
#import "ChooseReviewerViewController.h"
#import "CommonNavigationController.h"

@interface SuggestionDetailViewController ()<UITextViewDelegate,UITextFieldDelegate>

@end

@implementation SuggestionDetailViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"RefreshSuggestionDetail" object:nil];
}

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
    self.nOptionSelected = -1;
    self.bReportAttention = NO;
    self.bReportToHeadOffice = NO;
    self.bRefreshList = NO;
    self.dicOffsetY = [[NSMutableDictionary alloc]init];
    
    if (self.suggestionBaseVo == nil)
    {
        [self getSuggestionBaseData];
    }
    
    [self refreshData];
}

//获取基础数据
-(void)getSuggestionBaseData
{
    [self isHideActivity:NO];
    [ServerProvider getSuggestionBaseDataList:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            self.suggestionBaseVo = retInfo.data;
        }
    }];
}

- (void)refreshData
{
    [self isHideActivity:NO];
    [ServerProvider getSuggestionDetail:self.m_suggestionVo.strID result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            self.m_suggestionVo = retInfo.data;
            [self refreshView];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)initView
{
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    [self setTopNavBarTitle:@"合理化建议"];
    //右边按钮
    self.btnEdit = [Utils buttonWithTitle:@"编辑" frame:[Utils getNavRightBtnFrame:CGSizeMake(100,76)] target:self action:@selector(doEdit)];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshDataAfterEdit) name:@"RefreshSuggestionDetail" object:nil];
    
    self.m_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT)];
    self.m_scrollView.backgroundColor = [UIColor clearColor];
    self.m_scrollView.autoresizingMask = NO;
    self.m_scrollView.clipsToBounds = YES;
    [self.view addSubview:self.m_scrollView];
    self.m_scrollView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    //合理化建议标题
    self.lblSuggestionTitle = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblSuggestionTitle.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    self.lblSuggestionTitle.backgroundColor = [UIColor clearColor];
    self.lblSuggestionTitle.textColor = COLOR(51, 51, 51, 1.0);
    self.lblSuggestionTitle.numberOfLines = 0;
    self.lblSuggestionTitle.lineBreakMode = NSLineBreakByWordWrapping;
    [self.m_scrollView addSubview:self.lblSuggestionTitle];
    self.lblSuggestionTitle.textColor = [SkinManage colorNamed:@"mySuggestion_title"];
    
    
    
    self.viewLine1 = [[UIView alloc]init];
    self.viewLine1.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:self.viewLine1];
    self.viewLine1.backgroundColor = [SkinManage colorNamed:@"mySuggestion_title_line"];
    //提议人
    self.lblName = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblName.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    self.lblName.backgroundColor = [UIColor clearColor];
    self.lblName.textColor = COLOR(153, 153, 153, 1.0);
    [self.m_scrollView addSubview:self.lblName];
    self.lblName.textColor = [SkinManage colorNamed:@"mySuggestion_context"];
    
    //分公司
    self.lblDepartment = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblDepartment.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    self.lblDepartment.backgroundColor = [UIColor clearColor];
    self.lblDepartment.textColor = COLOR(153, 153, 153, 1.0);
    self.lblDepartment.textAlignment = NSTextAlignmentRight;
    self.lblDepartment.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblDepartment.numberOfLines = 0;
    [self.m_scrollView addSubview:self.lblDepartment];
    self.lblDepartment.textColor = [SkinManage colorNamed:@"mySuggestion_context"];
    //编号
    self.lblSuggestionNo = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblSuggestionNo.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    self.lblSuggestionNo.backgroundColor = [UIColor clearColor];
    self.lblSuggestionNo.textColor = COLOR(153, 153, 153, 1.0);
    [self.m_scrollView addSubview:self.lblSuggestionNo];
    self.lblSuggestionNo.textColor = [SkinManage colorNamed:@"mySuggestion_context"];
    //日期
    self.lblDate = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblDate.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    self.lblDate.backgroundColor = [UIColor clearColor];
    self.lblDate.textColor = COLOR(153, 153, 153, 1.0);
    self.lblDate.textAlignment = NSTextAlignmentRight;
    [self.m_scrollView addSubview:self.lblDate];
    self.lblDate.textColor = [SkinManage colorNamed:@"mySuggestion_context"];
    
    self.viewLine2 = [[UIView alloc]init];
    self.viewLine2.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:self.viewLine2];
    self.viewLine2.backgroundColor = [SkinManage colorNamed:@"mySuggestion_title_line"];
    
    //目前存在的问题
    self.lblProblemTitle = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblProblemTitle.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    self.lblProblemTitle.backgroundColor = [UIColor clearColor];
    self.lblProblemTitle.textColor = COLOR(245, 98, 0, 1.0);
    self.lblProblemTitle.text = @"目前存在的问题";
    [self.m_scrollView addSubview:self.lblProblemTitle];
    
    self.lblProblem = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblProblem.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    self.lblProblem.backgroundColor = [UIColor clearColor];
    self.lblProblem.textColor = COLOR(102, 102, 102, 1.0);
    self.lblProblem.numberOfLines = 0;
    self.lblProblem.lineBreakMode = NSLineBreakByWordWrapping;
    [self.m_scrollView addSubview:self.lblProblem];
    self.lblProblem.textColor = [SkinManage colorNamed:@"mySuggestion_Problem"];
    self.viewLine3 = [[UIView alloc]init];
    self.viewLine3.backgroundColor = [UIColor colorWithPatternImage:[SkinManage imageNamed:@"dote_line"]];
    [self.m_scrollView addSubview:self.viewLine3];
    self.viewLine3.backgroundColor = [SkinManage colorNamed:@"mySuggestion_title_line"];
    //建议改进的措施
    self.lblImproveTitle = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblImproveTitle.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    self.lblImproveTitle.backgroundColor = [UIColor clearColor];
    self.lblImproveTitle.textColor = COLOR(0, 153, 68, 1.0);
    self.lblImproveTitle.text = @"建议改进的措施";
    [self.m_scrollView addSubview:self.lblImproveTitle];
    
    self.lblImprove = [[UILabel alloc]initWithFrame:CGRectZero];
    self.lblImprove.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    self.lblImprove.backgroundColor = [UIColor clearColor];
    self.lblImprove.textColor = COLOR(102, 102, 102, 1.0);
    self.lblImprove.numberOfLines = 0;
    self.lblImprove.lineBreakMode = NSLineBreakByWordWrapping;
    [self.m_scrollView addSubview:self.lblImprove];
    self.lblImprove.textColor = [SkinManage colorNamed:@"mySuggestion_Problem"];
    self.viewLine4 = [[UIView alloc]init];
    self.viewLine4.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:self.viewLine4];
    self.viewLine4.backgroundColor = [SkinManage colorNamed:@"mySuggestion_title_line"];
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    [self.m_scrollView addGestureRecognizer:tapGestureRecognizer1];
    
    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard)];
    [self.view addGestureRecognizer:tapGestureRecognizer2];
}

- (void)refreshView
{
    //编辑按钮的显示控制
    if ([self.m_suggestionVo.strApplyID isEqualToString:[Common getCurrentUserVo].strUserID])
    {
        //已提交或者不符合要求退回建议人 self.m_suggestionVo.nStatus == 1 ||
        if(self.m_suggestionVo.nStatus == 3)
        {
            [self setRightBarButton:self.btnEdit];
        }
        else
        {
            [self setRightBarButton:nil];
        }
    }
    else
    {
        [self setRightBarButton:nil];
    }
    
    //UI 布局定位
    CGFloat fHeight = 7.5;
    //合理化建议标题
    self.lblSuggestionTitle.text = self.m_suggestionVo.strSuggestionName;
    CGSize size = [Common getStringSize:self.lblSuggestionTitle.text font:self.lblSuggestionTitle.font bound:CGSizeMake(kScreenWidth-20, MAXFLOAT) lineBreakMode:self.lblSuggestionTitle.lineBreakMode];
    if(size.height<20)
    {
        size.height = 20;
    }
    self.lblSuggestionTitle.frame = CGRectMake(10, fHeight, size.width, size.height);
    fHeight += size.height+7.5;
    
    self.viewLine1.frame = CGRectMake(0, fHeight, kScreenWidth, 0.5);
    fHeight += 0.5;
    
    //提议人
    self.lblName.frame = CGRectMake(10, fHeight, kScreenWidth/2-10, 30);
    self.lblName.text = self.m_suggestionVo.strName;
    
    //分公司
    self.lblDepartment.text = self.m_suggestionVo.strDepartmentName;
    size = [Common getStringSize:self.lblDepartment.text font:self.lblDepartment.font bound:CGSizeMake(kScreenWidth/2-10, MAXFLOAT) lineBreakMode:self.lblDepartment.lineBreakMode];
    if(size.height<20)
    {
        size.height = 20;
    }
    //    else
    //    {
    //        self.lblDepartment.textAlignment = NSTextAlignmentCenter;
    //    }
    self.lblDepartment.frame = CGRectMake(kScreenWidth/2, fHeight, kScreenWidth/2-10, size.height+10);
    fHeight += size.height + 10;
    
    //编号
    self.lblSuggestionNo.frame = CGRectMake(10, fHeight, kScreenWidth/2-10, 30);
    self.lblSuggestionNo.text = self.m_suggestionVo.strSuggestionNo;
    
    //日期
    self.lblDate.frame = CGRectMake(kScreenWidth/2, fHeight, kScreenWidth/2-10, 30);
    self.lblDate.text = self.m_suggestionVo.strDate;
    fHeight += 30;
    
    self.viewLine2.frame = CGRectMake(10, fHeight, kScreenWidth-20, 0.5);
    fHeight += 0.5;
    
    //目前存在的问题
    self.lblProblemTitle.frame = CGRectMake(10, fHeight, kScreenWidth-20, 30);
    fHeight += 30;
    
    self.lblProblem.text = self.m_suggestionVo.strProblemDes;
    size = [Common getStringSize:self.lblProblem.text font:self.lblProblem.font bound:CGSizeMake(kScreenWidth-20, MAXFLOAT) lineBreakMode:self.lblProblem.lineBreakMode];
    self.lblProblem.frame = CGRectMake(10, fHeight, kScreenWidth-20, size.height);
    fHeight += size.height+10;
    
    self.viewLine3.frame = CGRectMake(10, fHeight, kScreenWidth-20, 0.5);
    fHeight += 0.5;
    
    //建议改进的措施
    self.lblImproveTitle.frame = CGRectMake(10, fHeight, kScreenWidth-20, 30);
    fHeight += 30;
    
    self.lblImprove.text = self.m_suggestionVo.strImproveDes;
    size = [Common getStringSize:self.lblImprove.text font:self.lblProblem.font bound:CGSizeMake(kScreenWidth-20, MAXFLOAT) lineBreakMode:self.lblProblem.lineBreakMode];
    self.lblImprove.frame = CGRectMake(10, fHeight, kScreenWidth-20, size.height);
    fHeight += size.height+15;
    
    self.viewLine4.frame = CGRectMake(0, fHeight, kScreenWidth, 0.5);
    
    //初始化结果视图
    fHeight += [self initResultContainerView:fHeight];
    
    //显示表单提交View
    fHeight += [self initFormView:fHeight];
    
    fHeight += 100;
    [self.m_scrollView setContentSize:CGSizeMake(kScreenWidth, fHeight)];
}

- (void)refreshDataAfterEdit
{
    self.bRefreshList = YES;
    
    [self isHideActivity:NO];
    [ServerProvider getSuggestionDetail:self.m_suggestionVo.strID result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            self.m_suggestionVo = retInfo.data;
            [self refreshView];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//返回是否刷新列表
- (void)backButtonClicked
{
    if (self.bRefreshList)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshSuggestionList" object:nil];
    }
    
    [super backButtonClicked];
}

//编辑建议
- (void)doEdit
{
    AddSuggestionViewController *addSuggestionViewController = [[AddSuggestionViewController alloc]init];
    addSuggestionViewController.suggestionViewType = SuggestionViewEditType;
    addSuggestionViewController.m_suggestionVo = self.m_suggestionVo;
    addSuggestionViewController.suggestionBaseVo = self.suggestionBaseVo;
    
    CommonNavigationController *navController = [[CommonNavigationController alloc] initWithRootViewController:addSuggestionViewController];
    navController.navigationBarHidden = YES;
    [self presentViewController:navController animated:YES completion:nil];
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

//检查角色
-(BOOL)checkCurrentRole:(NSString*)strRoleCode
{
    BOOL bRes = NO;
    UserVo *userVo = [Common getCurrentUserVo];
    for (SuggestionRoleVo *suggestionRoleVo in userVo.arySuggestionRole)
    {
        if ([suggestionRoleVo.strRoleCode isEqualToString:strRoleCode])
        {
            //初评人、验证人、子公司评奖人
            if ([strRoleCode isEqualToString:@"DB"]  || [strRoleCode isEqualToString:@"CB"] || [strRoleCode isEqualToString:@"DD"])
            {
                //如果角色是分公司成员得判断该建议是否属于该分公司,并且该用户权限是否属于该分公司
                NSString *strDeparmentID = [Common getCurrentUserVo].strDepartmentId;
                if ([strDeparmentID isEqualToString:self.m_suggestionVo.strDepartmentID] && [strDeparmentID isEqualToString:suggestionRoleVo.strDepartmentID])
                {
                    bRes = YES;
                    break;
                }
            }
            else
            {
                bRes = YES;
                break;
            }
        }
    }
    return bRes;
}

//初始化结果视图
- (CGFloat)initResultContainerView:(CGFloat)fTopHeight
{
    CGFloat fHeight = 0.0;
    
    if (self.viewResultContainer != nil)
    {
        [self.viewResultContainer removeFromSuperview];
    }
    
    self.viewResultContainer = [[UIView alloc]init];
    self.viewResultContainer.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    //1.显示已初评结果（状态大于已提交）
    if(self.m_suggestionVo.nStatus>1)
    {
        UIView *viewLine1 = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 0.5)];
        viewLine1.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
        //COLOR(204, 204, 204, 1.0);
        [self.viewResultContainer addSubview:viewLine1];
        fHeight += 0.5;
        
        //初评结果
        fHeight += 5;
        UIImageView *imgViewIcon1 = [[UIImageView alloc]initWithFrame:CGRectMake(15, fHeight+12.5, 5, 5)];
        imgViewIcon1.image = [UIImage imageNamed:@"text_head"];
        [self.viewResultContainer addSubview:imgViewIcon1];
        
        UILabel *lblEvaluationTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, fHeight, kScreenWidth-40, 30)];
        lblEvaluationTitle.text = @"初评结果";
        lblEvaluationTitle.textColor = [SkinManage colorNamed:@"mySuggestion_title"];
        //COLOR(51, 51, 51, 1.0);
        lblEvaluationTitle.font = [UIFont boldSystemFontOfSize:16.0];
        lblEvaluationTitle.textAlignment = NSTextAlignmentLeft;
        [self.viewResultContainer addSubview:lblEvaluationTitle];
        fHeight += 30;
        
        UILabel *lblEvaluationContent = [[UILabel alloc]init];
        lblEvaluationContent.text = self.m_suggestionVo.strEvaluationValue;
        lblEvaluationContent.textColor = [SkinManage colorNamed:@"mySuggestion_Problem"];
        //COLOR(102, 102, 102, 1.0);
        lblEvaluationContent.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        lblEvaluationContent.textAlignment = NSTextAlignmentLeft;
        lblEvaluationContent.lineBreakMode = NSLineBreakByWordWrapping;
        lblEvaluationContent.numberOfLines = 0;
        [self.viewResultContainer addSubview:lblEvaluationContent];
        CGSize size = [Common getStringSize:lblEvaluationContent.text font:lblEvaluationContent.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:lblEvaluationContent.lineBreakMode];
        lblEvaluationContent.frame = CGRectMake(30, fHeight, kScreenWidth-40, size.height);
        fHeight += size.height+15;
        
        UIView *viewLine2 = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 1)];
        viewLine2.backgroundColor = [UIColor colorWithPatternImage:[SkinManage imageNamed:@"dote_line"]];
        [self.viewResultContainer addSubview:viewLine2];
        fHeight += 1;
        
        //备注
        fHeight += 5;
        UIImageView *imgViewIcon2 = [[UIImageView alloc]initWithFrame:CGRectMake(15, fHeight+12.5, 5, 5)];
        imgViewIcon2.image = [UIImage imageNamed:@"text_head"];
        [self.viewResultContainer addSubview:imgViewIcon2];
        
        UILabel *lblSuggestionTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, fHeight, kScreenWidth-40, 30)];
        lblSuggestionTitle.text = @"初评备注";
        lblSuggestionTitle.textColor = [SkinManage colorNamed:@"mySuggestion_title"];
        //COLOR(51, 51, 51, 1.0);
        lblSuggestionTitle.font = [UIFont boldSystemFontOfSize:16.0];
        lblSuggestionTitle.textAlignment = NSTextAlignmentLeft;
        [self.viewResultContainer addSubview:lblSuggestionTitle];
        fHeight += 30;
        
        UILabel *lblSuggestionContent = [[UILabel alloc]init];
        lblSuggestionContent.text = self.m_suggestionVo.strEvaluationSuggestion;
        lblSuggestionContent.textColor = [SkinManage colorNamed:@"mySuggestion_Problem"];// COLOR(102, 102, 102, 1.0);
        lblSuggestionContent.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        lblSuggestionContent.textAlignment = NSTextAlignmentLeft;
        lblSuggestionContent.lineBreakMode = NSLineBreakByWordWrapping;
        lblSuggestionContent.numberOfLines = 0;
        [self.viewResultContainer addSubview:lblSuggestionContent];
        size = [Common getStringSize:lblSuggestionContent.text font:lblSuggestionContent.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:lblSuggestionContent.lineBreakMode];
        lblSuggestionContent.frame = CGRectMake(30, fHeight, kScreenWidth-40, size.height);
        fHeight += size.height+15;
        
        //审核人
        UIView *viewLine3 = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 1)];
        viewLine3.backgroundColor = [UIColor colorWithPatternImage:[SkinManage imageNamed:@"dote_line"]];
        [self.viewResultContainer addSubview:viewLine3];
        fHeight += 1;
        
        fHeight += 5;
        UIImageView *imgViewIcon3 = [[UIImageView alloc]initWithFrame:CGRectMake(15, fHeight+12.5, 5, 5)];
        imgViewIcon3.image = [UIImage imageNamed:@"text_head"];
        [self.viewResultContainer addSubview:imgViewIcon3];
        
        UILabel *lblReviewerTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, fHeight, kScreenWidth-40, 30)];
        lblReviewerTitle.text = @"审核人";
        lblReviewerTitle.textColor = [SkinManage colorNamed:@"mySuggestion_title"];//COLOR(51, 51, 51, 1.0);
        lblReviewerTitle.font = [UIFont boldSystemFontOfSize:16.0];
        lblReviewerTitle.textAlignment = NSTextAlignmentLeft;
        [self.viewResultContainer addSubview:lblReviewerTitle];
        fHeight += 30;
        
        UILabel *lblReviewerContent = [[UILabel alloc]init];
        lblReviewerContent.text = self.m_suggestionVo.strReviewName;
        lblReviewerContent.textColor = [SkinManage colorNamed:@"mySuggestion_Problem"]; // COLOR(102, 102, 102, 1.0);
        lblReviewerContent.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        lblReviewerContent.textAlignment = NSTextAlignmentLeft;
        lblReviewerContent.lineBreakMode = NSLineBreakByWordWrapping;
        lblReviewerContent.numberOfLines = 0;
        [self.viewResultContainer addSubview:lblReviewerContent];
        size = [Common getStringSize:lblReviewerContent.text font:lblReviewerContent.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:lblReviewerContent.lineBreakMode];
        lblReviewerContent.frame = CGRectMake(30, fHeight, kScreenWidth-40, size.height);
        fHeight += size.height+15;
        
        //是否上报总公司关注
        if (self.m_suggestionVo.nReportAttention == 1)
        {
            UIView *viewLine4 = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 1)];
            viewLine4.backgroundColor = [UIColor colorWithPatternImage:[SkinManage imageNamed:@"dote_line"]];
            [self.viewResultContainer addSubview:viewLine4];
            fHeight += 1;
            
            fHeight += 5;
            UIImageView *imgViewIcon4 = [[UIImageView alloc]initWithFrame:CGRectMake(15, fHeight+12.5, 5, 5)];
            imgViewIcon4.image = [UIImage imageNamed:@"text_head"];
            [self.viewResultContainer addSubview:imgViewIcon4];
            
            UILabel *lblReportAttention = [[UILabel alloc]initWithFrame:CGRectMake(30, fHeight, kScreenWidth-40, 30)];
            lblReportAttention.text = @"上报总公司关注";
            lblReportAttention.textColor = [SkinManage colorNamed:@"mySuggestion_title"];  //COLOR(51, 51, 51, 1.0);
            lblReportAttention.font = [UIFont boldSystemFontOfSize:16.0];
            lblReportAttention.textAlignment = NSTextAlignmentLeft;
            [self.viewResultContainer addSubview:lblReportAttention];
            fHeight += 30;
            fHeight += 5;
        }
        
        UIView *viewLine5 = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 0.5)];
        viewLine5.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];//COLOR(204, 204, 204, 1.0);
        [self.viewResultContainer addSubview:viewLine5];
        fHeight += 0.5;
        
        UIView *viewSeparate = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 10)];
        viewSeparate.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        [self.viewResultContainer addSubview:viewSeparate];
        fHeight += 10;
    }
    
    //2.显示审核结果，当前【13-不是合理化建议】【不是（暂不实施界面 并且 审核人权限）】
    if(self.m_suggestionVo.nStatus>=4 && self.m_suggestionVo.nStatus != 13 && !([self.m_suggestionVo.strReviewID isEqualToString:[Common getCurrentUserVo].strUserID] && self.m_suggestionVo.nStatus == 5))
    {
        //审核结果（显示实施、不实施）
        UIView *viewLine1 = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 0.5)];
        viewLine1.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];//COLOR(204, 204, 204, 1.0);
        [self.viewResultContainer addSubview:viewLine1];
        fHeight += 0.5;
        
        fHeight += 5;
        UIImageView *imgViewIcon1 = [[UIImageView alloc]initWithFrame:CGRectMake(15, fHeight+12.5, 5, 5)];
        imgViewIcon1.image = [UIImage imageNamed:@"text_head"];
        [self.viewResultContainer addSubview:imgViewIcon1];
        
        UILabel *lblReviewTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, fHeight, kScreenWidth-40, 30)];
        lblReviewTitle.text = @"审核结果";
        lblReviewTitle.textColor = [SkinManage colorNamed:@"mySuggestion_title"];  //COLOR(51, 51, 51, 1.0);
        lblReviewTitle.font = [UIFont boldSystemFontOfSize:16.0];
        lblReviewTitle.textAlignment = NSTextAlignmentLeft;
        [self.viewResultContainer addSubview:lblReviewTitle];
        fHeight += 30;
        
        UILabel *lblReview = [[UILabel alloc]initWithFrame:CGRectMake(30, fHeight, kScreenWidth-40, 20)];
        lblReview.text = self.m_suggestionVo.strReviewValue;
        lblReview.textColor = COLOR(0, 153, 51, 1.0);
        lblReview.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        lblReview.textAlignment = NSTextAlignmentLeft;
        lblReview.lineBreakMode = NSLineBreakByWordWrapping;
        [self.viewResultContainer addSubview:lblReview];
        fHeight += 30;
        
        UIView *viewLine2 = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 1)];
        viewLine2.backgroundColor = [UIColor colorWithPatternImage:[SkinManage imageNamed:@"dote_line"]];
        [self.viewResultContainer addSubview:viewLine2];
        fHeight += 1;
        
        //备注
        fHeight += 5;
        UIImageView *imgViewIcon2 = [[UIImageView alloc]initWithFrame:CGRectMake(15, fHeight+12.5, 5, 5)];
        imgViewIcon2.image = [UIImage imageNamed:@"text_head"];
        [self.viewResultContainer addSubview:imgViewIcon2];
        
        UILabel *lblRemarkTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, fHeight, kScreenWidth-40, 30)];
        lblRemarkTitle.text = @"审核备注";
        lblRemarkTitle.textColor = [SkinManage colorNamed:@"mySuggestion_title"];  //COLOR(51, 51, 51, 1.0);
        lblRemarkTitle.font = [UIFont boldSystemFontOfSize:16.0];
        lblRemarkTitle.textAlignment = NSTextAlignmentLeft;
        [self.viewResultContainer addSubview:lblRemarkTitle];
        fHeight += 30;
        
        UILabel *lblRemark = [[UILabel alloc]init];
        lblRemark.text = self.m_suggestionVo.strReviewRemark;
        lblRemark.textColor = [SkinManage colorNamed:@"mySuggestion_Problem"];
        lblRemark.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        lblRemark.textAlignment = NSTextAlignmentLeft;
        lblRemark.lineBreakMode = NSLineBreakByWordWrapping;
        lblRemark.numberOfLines = 0;
        [self.viewResultContainer addSubview:lblRemark];
        CGSize size = [Common getStringSize:lblRemark.text font:lblRemark.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:lblRemark.lineBreakMode];
        lblRemark.frame = CGRectMake(30, fHeight, kScreenWidth-40, size.height);
        fHeight += size.height+15;
        
        UIView *viewLine3 = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 0.5)];
        viewLine3.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];//COLOR(204, 204, 204, 1.0);
        [self.viewResultContainer addSubview:viewLine3];
        fHeight += 0.5;
        
        UIView *viewSeparate = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 10)];
        viewSeparate.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        [self.viewResultContainer addSubview:viewSeparate];
        fHeight += 10;
    }
    
    //3.显示实施结果 （7-子公司评奖结果，13-不是合理化建议）
    if(self.m_suggestionVo.nStatus>=7 && self.m_suggestionVo.nStatus != 13)//已经填写实施团队
    {
        UIView *viewLine1 = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 0.5)];
        viewLine1.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];//COLOR(204, 204, 204, 1.0);
        [self.viewResultContainer addSubview:viewLine1];
        fHeight += 0.5;
        
        //实施人/团队
        fHeight += 5;
        UIImageView *imgViewIcon1 = [[UIImageView alloc]initWithFrame:CGRectMake(15, fHeight+12.5, 5, 5)];
        imgViewIcon1.image = [UIImage imageNamed:@"text_head"];
        [self.viewResultContainer addSubview:imgViewIcon1];
        
        UILabel *lblImplementTeamTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, fHeight, kScreenWidth-40, 30)];
        lblImplementTeamTitle.text = @"实施人/团队";
        lblImplementTeamTitle.textColor = [SkinManage colorNamed:@"mySuggestion_title"];   //COLOR(51, 51, 51, 1.0);
        lblImplementTeamTitle.font = [UIFont boldSystemFontOfSize:16.0];
        lblImplementTeamTitle.textAlignment = NSTextAlignmentLeft;
        [self.viewResultContainer addSubview:lblImplementTeamTitle];
        fHeight += 30;
        
        UILabel *lblImplementTeam = [[UILabel alloc]init];
        lblImplementTeam.text = self.m_suggestionVo.strImplementTeam;
        lblImplementTeam.textColor = [SkinManage colorNamed:@"mySuggestion_Problem"];
        lblImplementTeam.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        lblImplementTeam.textAlignment = NSTextAlignmentLeft;
        lblImplementTeam.lineBreakMode = NSLineBreakByWordWrapping;
        lblImplementTeam.numberOfLines = 0;
        [self.viewResultContainer addSubview:lblImplementTeam];
        CGSize size = [Common getStringSize:lblImplementTeam.text font:lblImplementTeam.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:lblImplementTeam.lineBreakMode];
        lblImplementTeam.frame = CGRectMake(30, fHeight, kScreenWidth-40, size.height);
        fHeight += size.height+15;
        
        UIView *viewLine2 = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 1)];
        viewLine2.backgroundColor = [UIColor colorWithPatternImage:[SkinManage imageNamed:@"dote_line"]];
        [self.viewResultContainer addSubview:viewLine2];
        fHeight += 1;
        
        //实施情况描述
        fHeight += 5;
        UIImageView *imgViewIcon2 = [[UIImageView alloc]initWithFrame:CGRectMake(15, fHeight+12.5, 5, 5)];
        imgViewIcon2.image = [UIImage imageNamed:@"text_head"];
        [self.viewResultContainer addSubview:imgViewIcon2];
        
        UILabel *lblSituationTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, fHeight, kScreenWidth-40, 30)];
        lblSituationTitle.text = @"实施情况描述";
        lblSituationTitle.textColor = [SkinManage colorNamed:@"mySuggestion_title"];  //COLOR(51, 51, 51, 1.0);
        lblSituationTitle.font = [UIFont boldSystemFontOfSize:16.0];
        lblSituationTitle.textAlignment = NSTextAlignmentLeft;
        [self.viewResultContainer addSubview:lblSituationTitle];
        fHeight += 30;
        
        UILabel *lblSituation = [[UILabel alloc]init];
        lblSituation.text = self.m_suggestionVo.strImplementSituation;
        lblSituation.textColor = [SkinManage colorNamed:@"mySuggestion_Problem"];
        lblSituation.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        lblSituation.textAlignment = NSTextAlignmentLeft;
        lblSituation.lineBreakMode = NSLineBreakByWordWrapping;
        lblSituation.numberOfLines = 0;
        [self.viewResultContainer addSubview:lblSituation];
        size = [Common getStringSize:lblSituation.text font:lblSituation.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:lblSituation.lineBreakMode];
        lblSituation.frame = CGRectMake(30, fHeight, kScreenWidth-40, size.height);
        fHeight += size.height+15;
        
        UIView *viewLine3 = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 0.5)];
        viewLine3.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"]; //COLOR(204, 204, 204, 1.0);
        [self.viewResultContainer addSubview:viewLine3];
        fHeight += 0.5;
        
        UIView *viewSeparate = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 10)];
        viewSeparate.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        [self.viewResultContainer addSubview:viewSeparate];
        fHeight += 10;
    }
    
    //4.显示验证结果（7-子公司评奖结果，13-不是合理化建议）
    if((self.m_suggestionVo.nStatus>=9 || self.m_suggestionVo.nStatus==7) && self.m_suggestionVo.nStatus != 13)
    {
        //验证情况
        UIView *viewLine1 = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 0.5)];
        viewLine1.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"]; //COLOR(204, 204, 204, 1.0);
        [self.viewResultContainer addSubview:viewLine1];
        fHeight += 0.5;
        
        //验证情况描述
        fHeight += 5;
        UIImageView *imgViewIcon1 = [[UIImageView alloc]initWithFrame:CGRectMake(15, fHeight+12.5, 5, 5)];
        imgViewIcon1.image = [UIImage imageNamed:@"text_head"];
        [self.viewResultContainer addSubview:imgViewIcon1];
        
        UILabel *lblVerifySituationTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, fHeight, kScreenWidth-40, 30)];
        lblVerifySituationTitle.text = @"验证情况描述";
        lblVerifySituationTitle.textColor = [SkinManage colorNamed:@"mySuggestion_title"];  //COLOR(51, 51, 51, 1.0);
        lblVerifySituationTitle.font = [UIFont boldSystemFontOfSize:16.0];
        lblVerifySituationTitle.textAlignment = NSTextAlignmentLeft;
        [self.viewResultContainer addSubview:lblVerifySituationTitle];
        fHeight += 30;
        
        UILabel *lblVerifySituation = [[UILabel alloc]init];
        lblVerifySituation.text = self.m_suggestionVo.strVerifySituaion;
        lblVerifySituation.textColor = [SkinManage colorNamed:@"mySuggestion_Problem"];
        lblVerifySituation.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        lblVerifySituation.textAlignment = NSTextAlignmentLeft;
        lblVerifySituation.lineBreakMode = NSLineBreakByWordWrapping;
        lblVerifySituation.numberOfLines = 0;
        [self.viewResultContainer addSubview:lblVerifySituation];
        CGSize size = [Common getStringSize:lblVerifySituation.text font:lblVerifySituation.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:lblVerifySituation.lineBreakMode];
        lblVerifySituation.frame = CGRectMake(30, fHeight, kScreenWidth-40, size.height);
        fHeight += size.height+15;
        
        UIView *viewLine2 = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 1)];
        viewLine2.backgroundColor = [UIColor colorWithPatternImage:[SkinManage imageNamed:@"dote_line"]];
        [self.viewResultContainer addSubview:viewLine2];
        fHeight += 1;
        
        //推广或标准化情况描述
        fHeight += 5;
        UIImageView *imgViewIcon2 = [[UIImageView alloc]initWithFrame:CGRectMake(15, fHeight+12.5, 5, 5)];
        imgViewIcon2.image = [UIImage imageNamed:@"text_head"];
        [self.viewResultContainer addSubview:imgViewIcon2];
        
        UILabel *lblExtendSituationTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, fHeight, kScreenWidth-40, 30)];
        lblExtendSituationTitle.text = @"推广或标准化情况描述";
        lblExtendSituationTitle.textColor = [SkinManage colorNamed:@"mySuggestion_title"];  //COLOR(51, 51, 51, 1.0);
        lblExtendSituationTitle.font = [UIFont boldSystemFontOfSize:16.0];
        lblExtendSituationTitle.textAlignment = NSTextAlignmentLeft;
        [self.viewResultContainer addSubview:lblExtendSituationTitle];
        fHeight += 30;
        
        UILabel *lblExtendSituation = [[UILabel alloc]init];
        lblExtendSituation.text = self.m_suggestionVo.strExtendSituation;
        lblExtendSituation.textColor = [SkinManage colorNamed:@"mySuggestion_Problem"];
        lblExtendSituation.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        lblExtendSituation.textAlignment = NSTextAlignmentLeft;
        lblExtendSituation.lineBreakMode = NSLineBreakByWordWrapping;
        lblExtendSituation.numberOfLines = 0;
        [self.viewResultContainer addSubview:lblExtendSituation];
        size = [Common getStringSize:lblExtendSituation.text font:lblExtendSituation.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:lblExtendSituation.lineBreakMode];
        lblExtendSituation.frame = CGRectMake(30, fHeight, kScreenWidth-40, size.height);
        fHeight += size.height+15;
        
        UIView *viewLine3 = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 1)];
        viewLine3.backgroundColor = [UIColor colorWithPatternImage:[SkinManage imageNamed:@"dote_line"]];
        [self.viewResultContainer addSubview:viewLine3];
        fHeight += 1;
        
        //实施成本（元）
        fHeight += 5;
        UIImageView *imgViewIcon3 = [[UIImageView alloc]initWithFrame:CGRectMake(15, fHeight+12.5, 5, 5)];
        imgViewIcon3.image = [UIImage imageNamed:@"text_head"];
        [self.viewResultContainer addSubview:imgViewIcon3];
        
        UILabel *lblImplementCostTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, fHeight, kScreenWidth-40, 30)];
        lblImplementCostTitle.text = @"实施成本（元）";
        lblImplementCostTitle.textColor = [SkinManage colorNamed:@"mySuggestion_title"];  //COLOR(51, 51, 51, 1.0);
        lblImplementCostTitle.font = [UIFont boldSystemFontOfSize:16.0];
        lblImplementCostTitle.textAlignment = NSTextAlignmentLeft;
        [self.viewResultContainer addSubview:lblImplementCostTitle];
        fHeight += 30;
        
        UILabel *lblImplementCost = [[UILabel alloc]init];
        lblImplementCost.text = self.m_suggestionVo.strImplementCost;
        lblImplementCost.textColor = [SkinManage colorNamed:@"mySuggestion_Problem"];
        lblImplementCost.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        lblImplementCost.textAlignment = NSTextAlignmentLeft;
        lblImplementCost.lineBreakMode = NSLineBreakByWordWrapping;
        lblImplementCost.numberOfLines = 0;
        [self.viewResultContainer addSubview:lblImplementCost];
        size = [Common getStringSize:lblImplementCost.text font:lblImplementCost.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:lblImplementCost.lineBreakMode];
        lblImplementCost.frame = CGRectMake(30, fHeight, kScreenWidth-40, size.height);
        fHeight += size.height+15;
        
        UIView *viewLine4 = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 1)];
        viewLine4.backgroundColor = [UIColor colorWithPatternImage:[SkinManage imageNamed:@"dote_line"]];
        [self.viewResultContainer addSubview:viewLine4];
        fHeight += 1;
        
        //经济效益或节约金额（元）
        fHeight += 5;
        UIImageView *imgViewIcon4 = [[UIImageView alloc]initWithFrame:CGRectMake(15, fHeight+12.5, 5, 5)];
        imgViewIcon4.image = [UIImage imageNamed:@"text_head"];
        [self.viewResultContainer addSubview:imgViewIcon4];
        
        UILabel *lblSavingCostTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, fHeight, kScreenWidth-40, 30)];
        lblSavingCostTitle.text = @"经济效益或节约金额（元）";
        lblSavingCostTitle.textColor = [SkinManage colorNamed:@"mySuggestion_title"];  //COLOR(51, 51, 51, 1.0);
        lblSavingCostTitle.font = [UIFont boldSystemFontOfSize:16.0];
        lblSavingCostTitle.textAlignment = NSTextAlignmentLeft;
        [self.viewResultContainer addSubview:lblSavingCostTitle];
        fHeight += 30;
        
        UILabel *lblSavingCost = [[UILabel alloc]init];
        lblSavingCost.text = self.m_suggestionVo.strSavingCost;
        lblSavingCost.textColor = [SkinManage colorNamed:@"mySuggestion_Problem"];
        lblSavingCost.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        lblSavingCost.textAlignment = NSTextAlignmentLeft;
        lblSavingCost.lineBreakMode = NSLineBreakByWordWrapping;
        lblSavingCost.numberOfLines = 0;
        [self.viewResultContainer addSubview:lblSavingCost];
        size = [Common getStringSize:lblSavingCost.text font:lblSavingCost.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:lblSavingCost.lineBreakMode];
        lblSavingCost.frame = CGRectMake(30, fHeight, kScreenWidth-40, size.height);
        fHeight += size.height+15;
        
        UIView *viewLine5 = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 0.5)];
        viewLine5.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"]; //COLOR(204, 204, 204, 1.0);
        [self.viewResultContainer addSubview:viewLine5];
        fHeight += 0.5;
        
        UIView *viewSeparate = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 10)];
        viewSeparate.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        [self.viewResultContainer addSubview:viewSeparate];
        fHeight += 10;
    }
    
    //5.显示子公司评奖结果
    if(self.m_suggestionVo.nStatus==7 || self.m_suggestionVo.nStatus==10 || self.m_suggestionVo.nStatus == 12)
    {
        //子公司评奖
        UIView *viewLine1 = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 0.5)];
        viewLine1.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"]; //COLOR(204, 204, 204, 1.0);
        [self.viewResultContainer addSubview:viewLine1];
        fHeight += 0.5;
        
        //子公司评奖结果
        fHeight += 5;
        UIImageView *imgViewIcon1 = [[UIImageView alloc]initWithFrame:CGRectMake(15, fHeight+12.5, 5, 5)];
        imgViewIcon1.image = [UIImage imageNamed:@"text_head"];
        [self.viewResultContainer addSubview:imgViewIcon1];
        
        UILabel *lblSubRewardTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, fHeight, kScreenWidth-40, 30)];
        lblSubRewardTitle.text = @"子公司评奖结果";
        lblSubRewardTitle.textColor = [SkinManage colorNamed:@"mySuggestion_title"];    //COLOR(51, 51, 51, 1.0);
        lblSubRewardTitle.font = [UIFont boldSystemFontOfSize:16.0];
        lblSubRewardTitle.textAlignment = NSTextAlignmentLeft;
        [self.viewResultContainer addSubview:lblSubRewardTitle];
        fHeight += 30;
        
        UILabel *lblSubReward = [[UILabel alloc]init];
        lblSubReward.text = self.m_suggestionVo.strSubRewardValue;
        lblSubReward.textColor = [SkinManage colorNamed:@"mySuggestion_Problem"];
        lblSubReward.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        lblSubReward.textAlignment = NSTextAlignmentLeft;
        lblSubReward.lineBreakMode = NSLineBreakByWordWrapping;
        lblSubReward.numberOfLines = 0;
        [self.viewResultContainer addSubview:lblSubReward];
        CGSize size = [Common getStringSize:lblSubReward.text font:lblSubReward.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:lblSubReward.lineBreakMode];
        lblSubReward.frame = CGRectMake(30, fHeight, kScreenWidth-40, size.height);
        fHeight += size.height+15;
        
        UIView *viewLine3 = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 0.5)];
        viewLine3.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"]; //COLOR(204, 204, 204, 1.0);
        [self.viewResultContainer addSubview:viewLine3];
        fHeight += 0.5;
        
        UIView *viewSeparate = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 10)];
        viewSeparate.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        [self.viewResultContainer addSubview:viewSeparate];
        fHeight += 10;
    }
    
    //6.显示总公司评奖结果
    if(self.m_suggestionVo.nStatus == 11)
    {
        //总公司评奖
        UIView *viewLine1 = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 0.5)];
        viewLine1.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"]; //COLOR(204, 204, 204, 1.0);
        [self.viewResultContainer addSubview:viewLine1];
        fHeight += 0.5;
        
        //总公司评奖
        fHeight += 5;
        UIImageView *imgViewIcon1 = [[UIImageView alloc]initWithFrame:CGRectMake(15, fHeight+12.5, 5, 5)];
        imgViewIcon1.image = [UIImage imageNamed:@"text_head"];
        [self.viewResultContainer addSubview:imgViewIcon1];
        
        UILabel *lblHeadOfficeRewardTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, fHeight, kScreenWidth-40, 30)];
        lblHeadOfficeRewardTitle.text = @"总公司评奖";
        lblHeadOfficeRewardTitle.textColor = [SkinManage colorNamed:@"mySuggestion_title"];  //COLOR(51, 51, 51, 1.0);
        lblHeadOfficeRewardTitle.font = [UIFont boldSystemFontOfSize:16.0];
        lblHeadOfficeRewardTitle.textAlignment = NSTextAlignmentLeft;
        [self.viewResultContainer addSubview:lblHeadOfficeRewardTitle];
        fHeight += 30;
        
        UILabel *lblHeadOfficeReward = [[UILabel alloc]init];
        lblHeadOfficeReward.text = self.m_suggestionVo.strHeadRewardValue;
        lblHeadOfficeReward.textColor = [SkinManage colorNamed:@"mySuggestion_Problem"];
        lblHeadOfficeReward.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        lblHeadOfficeReward.textAlignment = NSTextAlignmentLeft;
        lblHeadOfficeReward.lineBreakMode = NSLineBreakByWordWrapping;
        lblHeadOfficeReward.numberOfLines = 0;
        [self.viewResultContainer addSubview:lblHeadOfficeReward];
        CGSize size = [Common getStringSize:lblHeadOfficeReward.text font:lblHeadOfficeReward.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:lblHeadOfficeReward.lineBreakMode];
        lblHeadOfficeReward.frame = CGRectMake(30, fHeight, kScreenWidth-40, size.height);
        fHeight += size.height+15;
        
        UIView *viewLine2 = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 1)];
        viewLine2.backgroundColor = [UIColor colorWithPatternImage:[SkinManage imageNamed:@"dote_line"]];
        [self.viewResultContainer addSubview:viewLine2];
        fHeight += 1;
        
        //奖励情况
        fHeight += 5;
        UIImageView *imgViewIcon2 = [[UIImageView alloc]initWithFrame:CGRectMake(15, fHeight+12.5, 5, 5)];
        imgViewIcon2.image = [UIImage imageNamed:@"text_head"];
        [self.viewResultContainer addSubview:imgViewIcon2];
        
        UILabel *lblRewardSituationTitle = [[UILabel alloc]initWithFrame:CGRectMake(30, fHeight, kScreenWidth-40, 30)];
        lblRewardSituationTitle.text = @"奖励情况";
        lblRewardSituationTitle.textColor = [SkinManage colorNamed:@"mySuggestion_title"];  //COLOR(51, 51, 51, 1.0);
        lblRewardSituationTitle.font = [UIFont boldSystemFontOfSize:16.0];
        lblRewardSituationTitle.textAlignment = NSTextAlignmentLeft;
        [self.viewResultContainer addSubview:lblRewardSituationTitle];
        fHeight += 30;
        
        UILabel *lblRewardSituation = [[UILabel alloc]init];
        lblRewardSituation.text = self.m_suggestionVo.strHeadRewardSituation;
        lblRewardSituation.textColor = [SkinManage colorNamed:@"mySuggestion_Problem"];
        lblRewardSituation.font = [UIFont fontWithName:@"Helvetica" size:15.0];
        lblRewardSituation.textAlignment = NSTextAlignmentLeft;
        lblRewardSituation.lineBreakMode = NSLineBreakByWordWrapping;
        lblRewardSituation.numberOfLines = 0;
        [self.viewResultContainer addSubview:lblRewardSituation];
        size = [Common getStringSize:lblRewardSituation.text font:lblRewardSituation.font bound:CGSizeMake(kScreenWidth-40, MAXFLOAT) lineBreakMode:lblRewardSituation.lineBreakMode];
        lblRewardSituation.frame = CGRectMake(30, fHeight, kScreenWidth-40, size.height);
        fHeight += size.height+15;
        
        UIView *viewLine3 = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 0.5)];
        viewLine3.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"]; //COLOR(204, 204, 204, 1.0);
        [self.viewResultContainer addSubview:viewLine3];
        fHeight += 0.5;
        
        UIView *viewSeparate = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 10)];
        viewSeparate.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        [self.viewResultContainer addSubview:viewSeparate];
        fHeight += 10;
    }
    
    self.viewResultContainer.frame = CGRectMake(0, fTopHeight, kScreenWidth, fHeight);
    [self.m_scrollView addSubview:self.viewResultContainer];
    return fHeight;
}

////////////////////////////////////////////////////////////////////////////////////////////
//根据状态 - 显示提交的表单
-(CGFloat)initFormView:(CGFloat)fTopHeight
{
    CGFloat fHeight = 0;
    
    //clear commit form
    if (self.viewFormContainer != nil)
    {
        [self.viewFormContainer removeFromSuperview];
    }
    
    if (self.m_suggestionVo.nStatus == 1)
    {
        //已提交【初始化初评视图】
        if ([self checkCurrentRole:@"DB"])
        {
            //拥有初评权限
            fHeight += [self initFirstEvaluationView:fTopHeight];
        }
    }
    else if (self.m_suggestionVo.nStatus == 3 || self.m_suggestionVo.nStatus == 13)
    {
        //【初评退回】或者【不是合理化建议】 - 只显示结果，除非重新修改建议
    }
    else if (self.m_suggestionVo.nStatus == 2 || self.m_suggestionVo.nStatus == 5)
    {
        //【审核中】或者【暂不实施】
        if ([self.m_suggestionVo.strReviewID isEqualToString:[Common getCurrentUserVo].strUserID])
        {
            //拥有审核权限(通过审核ID进行判断)
            fHeight += [self initReviewView:fTopHeight];
        }
    }
    else if (self.m_suggestionVo.nStatus == 4)
    {
        //【实施中】 【初始化实施团队】
        if ([self.m_suggestionVo.strReviewID isEqualToString:[Common getCurrentUserVo].strUserID])
        {
            //拥有实施权限(通过审核ID进行判断)
            fHeight += [self initImplementView:fTopHeight];
        }
    }
    else if (self.m_suggestionVo.nStatus == 6)
    {
        //【不实施】，暂不做处理
    }
    else if (self.m_suggestionVo.nStatus == 8)
    {
        //【验证中】（已经填写实施人/团队）
        if ([self checkCurrentRole:@"CB"])
        {
            fHeight += [self initVerifyView:fTopHeight];
        }
    }
    else if (self.m_suggestionVo.nStatus == 9)
    {
        //【子公司评奖中】（已经填写验证结果）
        if ([self checkCurrentRole:@"DD"])
        {
            fHeight += [self initSubcompanyRewardView:fTopHeight];
        }
    }
    else if (self.m_suggestionVo.nStatus == 7 || self.m_suggestionVo.nStatus == 12)
    {
        //【子公司评奖结果】或者【子公司不评奖】
    }
    else if (self.m_suggestionVo.nStatus == 10)
    {
        //【总公司评奖中】
        if ([self checkCurrentRole:@"CD"])
        {
            fHeight += [self initHeadOfficeRewardView:fTopHeight];
        }
    }
    else if (self.m_suggestionVo.nStatus == 11)
    {
        //【总公司评奖完毕】
    }
    return fHeight;
}

//初始化初评视图（1.符合要求，建议实施、2.符合要求，建议成立QC小组实施、3.不符合要求，退回建议人）
- (CGFloat)initFirstEvaluationView:(CGFloat)fTopHeight
{
    //如果是初评退回，显示上次的提交状态
    CGFloat fHeight = 0.0;
    
    if (self.viewFormContainer != nil)
    {
        [self.viewFormContainer removeFromSuperview];
    }
    
    self.viewFormContainer = [[UIView alloc]init];
    self.viewFormContainer.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    ;
    
    //top line
    UIView *viewTopLine = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 0.5)];
    viewTopLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];//COLOR(204, 204, 204, 1.0);
    [self.viewFormContainer addSubview:viewTopLine];
    fHeight = 5.0;
    
    //初评标题
    UILabel *lblEvaluationTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 30)];
    lblEvaluationTitle.text = @"初评";
    lblEvaluationTitle.textColor = COLOR(0, 153, 68, 1.0);
    lblEvaluationTitle.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    lblEvaluationTitle.textAlignment = NSTextAlignmentCenter;
    [self.viewFormContainer addSubview:lblEvaluationTitle];
    fHeight += 30;
    
    //view line
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 4)];
    viewLine.backgroundColor = COLOR(0, 153, 68, 1.0);
    [self.viewFormContainer addSubview:viewLine];
    fHeight += 10;
    
    //初评建议选项
    if (self.suggestionBaseVo != nil)
    {
        for (NSInteger i=0;i<self.suggestionBaseVo.aryAssessOpinion.count;i++)
        {
            fHeight += 1.25;
            KeyValueVo *optionVo = self.suggestionBaseVo.aryAssessOpinion[i];
            UIButton *btnOption = [UIButton buttonWithType:UIButtonTypeCustom];
            btnOption.tag = 1000+i;
            [btnOption setImage:[UIImage imageNamed:@"suggestion_uncheck"] forState:UIControlStateNormal];
            [btnOption setImage:[UIImage imageNamed:@"suggestion_check"] forState:UIControlStateSelected];
            [btnOption setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [btnOption setTitle:optionVo.strValue forState:UIControlStateNormal];
            [btnOption.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
            [btnOption setTitleColor:[SkinManage colorNamed:@"mySuggestion_title"] forState:UIControlStateNormal];
            [btnOption addTarget:self action:@selector(optionSelected:) forControlEvents:UIControlEventTouchUpInside];
            [btnOption setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            
            btnOption.titleLabel.numberOfLines = 0;
            
            CGSize sizeContent = [Common getStringSize:optionVo.strValue font:[UIFont systemFontOfSize:14.0] bound:CGSizeMake(kScreenWidth-80, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            btnOption.frame = CGRectMake(15, fHeight, kScreenWidth-30, sizeContent.height+20);
            [self.viewFormContainer addSubview:btnOption];
            fHeight += sizeContent.height+20;
            fHeight += 1.25;
            
            //line
            UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 1)];
            viewLine.backgroundColor = [UIColor colorWithPatternImage:[SkinManage imageNamed:@"dote_line"]];
            [self.viewFormContainer addSubview:viewLine];
            fHeight += 1;
        }
    }
    
    fHeight += 5;
    //其他部门支持或成立QC小组意见/退回意见 title
    UILabel *lblQCTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, fHeight, kScreenWidth-20, 30)];
    lblQCTitle.text = @"初评备注";
    lblQCTitle.textColor = [SkinManage colorNamed:@"mySuggestion_title"];//COLOR(51, 51, 51, 1.0);
    lblQCTitle.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    lblQCTitle.textAlignment = NSTextAlignmentLeft;
    [self.viewFormContainer addSubview:lblQCTitle];
    fHeight += 35;
    
    //意见 textView
    UITextView *txtSuggestion = [[UITextView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20,48)];
    txtSuggestion.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    txtSuggestion.delegate = self;
    txtSuggestion.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
    txtSuggestion.layer.borderWidth = 0.5;
    txtSuggestion.layer.cornerRadius = 5;
    txtSuggestion.layer.masksToBounds = YES;
    txtSuggestion.font = [UIFont fontWithName:APP_FONT_NAME size:16];
    txtSuggestion.textColor = [SkinManage colorNamed:@"mySuggestion_title"];  //COLOR(51, 51, 51, 1.0);
    txtSuggestion.tag = 2001;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fTopHeight+fHeight] forKey:@"2001"];
    [self.viewFormContainer addSubview:txtSuggestion];
    fHeight += 48+5;
    
    //选择审核人
    UILabel *lblReview = [[UILabel alloc]initWithFrame:CGRectMake(15, fHeight, kScreenWidth-20, 30)];
    lblReview.text = @"请选择审核人";
    lblReview.textColor = [SkinManage colorNamed:@"mySuggestion_title"];   //COLOR(51, 51, 51, 1.0);
    lblReview.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    lblReview.textAlignment = NSTextAlignmentLeft;
    [self.viewFormContainer addSubview:lblReview];
    fHeight += 30;
    
    InsetsTextField *txtReview = [[InsetsTextField alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20,35)];
    txtReview.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    txtReview.placeholder = @"审核人";
    //    txtReview.background = [[UIImage imageNamed:@"txt_bk"]stretchableImageWithLeftCapWidth:30 topCapHeight:10];
    txtReview.font = [UIFont fontWithName:APP_FONT_NAME size:15];
    txtReview.textColor = [SkinManage colorNamed:@"mySuggestion_title"];  //COLOR(51, 51, 51, 1.0);
    txtReview.delegate = self;
    txtReview.tag = 10001;
    [self.viewFormContainer addSubview:txtReview];
    
    //arrow
    UIImageView *imgViewArrow = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth-30, fHeight+11, 13, 13)];
    imgViewArrow.image = [UIImage imageNamed:@"arrow_gray_right"];
    [self.viewFormContainer addSubview:imgViewArrow];
    
    fHeight += 40;
    
    //上报总公司关注
    UIButton *btnReport = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnReport setImage:[UIImage imageNamed:@"reward_unreport"] forState:UIControlStateNormal];
    [btnReport setImage:[UIImage imageNamed:@"reward_report"] forState:UIControlStateSelected];
    [btnReport setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [btnReport setTitle:@"上报总公司关注" forState:UIControlStateNormal];
    [btnReport.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [btnReport setTitleColor:[SkinManage colorNamed:@""] forState:UIControlStateNormal];
    [btnReport addTarget:self action:@selector(reportToHeadAttention:) forControlEvents:UIControlEventTouchUpInside];
    [btnReport setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    btnReport.frame = CGRectMake(15, fHeight, kScreenWidth-30, 50);
    [self.viewFormContainer addSubview:btnReport];
    fHeight += 50;
    
    //提交 UIButton
    fHeight += 20;
    UIButton *btnCommit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCommit.frame = CGRectMake(10, fHeight, kScreenWidth-20, 40);
    [btnCommit setTitleColor:[SkinManage colorNamed:@"Menu_Title_Color"] forState:UIControlStateNormal];
    [btnCommit setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [btnCommit setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Function_BK_Color"]] forState:UIControlStateNormal];
    [btnCommit.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0]];
    [btnCommit setTitle:@"提交" forState:UIControlStateNormal];
    btnCommit.tag = 3001;
    [btnCommit addTarget:self action:@selector(doCommit:) forControlEvents:UIControlEventTouchUpInside];
    [btnCommit.layer setBorderWidth:1.0];
    [btnCommit.layer setCornerRadius:3];
    btnCommit.layer.borderColor = [[UIColor clearColor] CGColor];
    [btnCommit.layer setMasksToBounds:YES];
    [self.viewFormContainer addSubview:btnCommit];
    fHeight += 60;
    
    fHeight += 255;
    self.viewFormContainer.frame = CGRectMake(0, fTopHeight, kScreenWidth, fHeight);
    [self.m_scrollView addSubview:self.viewFormContainer];
    return fHeight;
}

//初始化审核视图（1.实施、2.暂不实施、3.不实施）
- (CGFloat)initReviewView:(CGFloat)fTopHeight
{
    CGFloat fHeight = 0.0;
    
    if (self.viewFormContainer != nil)
    {
        [self.viewFormContainer removeFromSuperview];
    }
    
    self.viewFormContainer = [[UIView alloc]init];
    self.viewFormContainer.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    //top line
    UIView *viewTopLine = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 0.5)];
    viewTopLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"]; //COLOR(204, 204, 204, 1.0);
    [self.viewFormContainer addSubview:viewTopLine];
    
    fHeight = 5.0;
    
    //标题
    UILabel *lblReviewTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 30)];
    lblReviewTitle.text = @"审核";
    lblReviewTitle.textColor = COLOR(0, 153, 68, 1.0);
    lblReviewTitle.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    lblReviewTitle.textAlignment = NSTextAlignmentCenter;
    [self.viewFormContainer addSubview:lblReviewTitle];
    fHeight += 30;
    
    //view line
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 4)];
    viewLine.backgroundColor = COLOR(0, 153, 68, 1.0);
    [self.viewFormContainer addSubview:viewLine];
    fHeight += 10;
    
    //选项
    if (self.suggestionBaseVo != nil)
    {
        for (NSInteger i=0;i<self.suggestionBaseVo.aryAssessImplementItem.count;i++)
        {
            fHeight += 1.25;
            KeyValueVo *optionVo = self.suggestionBaseVo.aryAssessImplementItem[i];
            UIButton *btnOption = [UIButton buttonWithType:UIButtonTypeCustom];
            btnOption.tag = 1000+i;
            [btnOption setImage:[UIImage imageNamed:@"suggestion_uncheck"] forState:UIControlStateNormal];
            [btnOption setImage:[UIImage imageNamed:@"suggestion_check"] forState:UIControlStateSelected];
            [btnOption setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [btnOption setTitle:optionVo.strValue forState:UIControlStateNormal];
            [btnOption.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
            [btnOption setTitleColor:[SkinManage colorNamed:@"mySuggestion_title"] forState:UIControlStateNormal];
            [btnOption addTarget:self action:@selector(optionSelected:) forControlEvents:UIControlEventTouchUpInside];
            [btnOption setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            
            btnOption.titleLabel.numberOfLines = 0;
            
            CGSize sizeContent = [Common getStringSize:optionVo.strValue font:[UIFont systemFontOfSize:14.0] bound:CGSizeMake(kScreenWidth-80, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            btnOption.frame = CGRectMake(15, fHeight, kScreenWidth-30, sizeContent.height+20);
            [self.viewFormContainer addSubview:btnOption];
            fHeight += sizeContent.height+20;
            fHeight += 1.25;
            
            //line
            UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 1)];
            viewLine.backgroundColor = [UIColor colorWithPatternImage:[SkinManage imageNamed:@"dote_line"]];
            [self.viewFormContainer addSubview:viewLine];
            fHeight += 1;
            
            if(self.m_suggestionVo.nStatus == 5)
            {
                //暂不实施，显示
                if([optionVo.strKey isEqualToString:self.m_suggestionVo.strReviewKey])
                {
                    btnOption.selected = YES;
                    self.nOptionSelected = btnOption.tag;
                }
            }
        }
    }
    
    fHeight += 5;
    
    //备注
    UILabel *lblQCTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, fHeight, kScreenWidth-20, 30)];
    lblQCTitle.text = @"审核备注";
    lblQCTitle.textColor = [SkinManage colorNamed:@"mySuggestion_title"];  //COLOR(51, 51, 51, 1.0);
    lblQCTitle.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    lblQCTitle.textAlignment = NSTextAlignmentLeft;
    [self.viewFormContainer addSubview:lblQCTitle];
    fHeight += 35;
    
    UITextView *txtRemark = [[UITextView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20,48)];
    txtRemark.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    txtRemark.delegate = self;
    txtRemark.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
    txtRemark.layer.borderWidth = 0.5;
    txtRemark.layer.cornerRadius = 5;
    txtRemark.layer.masksToBounds = YES;
    txtRemark.font = [UIFont fontWithName:APP_FONT_NAME size:16];
    txtRemark.textColor = [SkinManage colorNamed:@"mySuggestion_title"];
    txtRemark.tag = 2001;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fTopHeight+fHeight] forKey:@"2001"];
    [self.viewFormContainer addSubview:txtRemark];
    fHeight += 48;
    
    //暂不实施，显示上次填写的备注
    if (self.m_suggestionVo.nStatus == 5)
    {
        txtRemark.text = self.m_suggestionVo.strReviewRemark;
    }
    
    //提交 UIButton
    fHeight += 20;
    UIButton *btnCommit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCommit.frame = CGRectMake(10, fHeight, kScreenWidth-20, 40);
    [btnCommit setTitleColor:[SkinManage colorNamed:@"Menu_Title_Color"] forState:UIControlStateNormal];
    [btnCommit setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [btnCommit setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Function_BK_Color"]] forState:UIControlStateNormal];
    [btnCommit.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0]];
    [btnCommit setTitle:@"提交" forState:UIControlStateNormal];
    btnCommit.tag = 3002;
    [btnCommit addTarget:self action:@selector(doCommit:) forControlEvents:UIControlEventTouchUpInside];
    [btnCommit.layer setBorderWidth:1.0];
    [btnCommit.layer setCornerRadius:3];
    btnCommit.layer.borderColor = [[UIColor clearColor] CGColor];
    [btnCommit.layer setMasksToBounds:YES];
    [self.viewFormContainer addSubview:btnCommit];
    fHeight += 60;
    
    fHeight += 255;
    self.viewFormContainer.frame = CGRectMake(0, fTopHeight, kScreenWidth, fHeight);
    [self.m_scrollView addSubview:self.viewFormContainer];
    return fHeight;
}

//初始化实施团队（1.实施人/团队、2.实施情况描述）
- (CGFloat)initImplementView:(CGFloat)fTopHeight
{
    CGFloat fHeight = 0.0;
    
    if (self.viewFormContainer != nil)
    {
        [self.viewFormContainer removeFromSuperview];
    }
    
    self.viewFormContainer = [[UIView alloc]init];
    self.viewFormContainer.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    //top line
    UIView *viewTopLine = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 0.5)];
    viewTopLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.viewFormContainer addSubview:viewTopLine];
    
    fHeight = 5.0;
    
    //初评标题
    UILabel *lblWorkflowTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 30)];
    lblWorkflowTitle.text = @"实施";
    lblWorkflowTitle.textColor = COLOR(0, 153, 68, 1.0);
    lblWorkflowTitle.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    lblWorkflowTitle.textAlignment = NSTextAlignmentCenter;
    [self.viewFormContainer addSubview:lblWorkflowTitle];
    fHeight += 30;
    
    //view line
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 4)];
    viewLine.backgroundColor = COLOR(0, 153, 68, 1.0);
    [self.viewFormContainer addSubview:viewLine];
    fHeight += 10;
    
    //实施人/团队
    UILabel *lblImplementTeam = [[UILabel alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 30)];
    lblImplementTeam.text = @"实施人/团队";
    lblImplementTeam.textColor = [SkinManage colorNamed:@"mySuggestion_title"];  //COLOR(51, 51, 51, 1.0);
    lblImplementTeam.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    lblImplementTeam.textAlignment = NSTextAlignmentLeft;
    [self.viewFormContainer addSubview:lblImplementTeam];
    fHeight += 30;
    
    InsetsTextField *txtImplementTeam = [[InsetsTextField alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20,35)];
    //    txtImplementTeam.background = [[UIImage imageNamed:@"txt_bk"]stretchableImageWithLeftCapWidth:30 topCapHeight:10];
    txtImplementTeam.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    txtImplementTeam.font = [UIFont fontWithName:APP_FONT_NAME size:15];
    txtImplementTeam.textColor = [SkinManage colorNamed:@"mySuggestion_title"];
    txtImplementTeam.delegate = self;
    txtImplementTeam.tag = 2001;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fTopHeight+fHeight] forKey:@"2001"];
    [self.viewFormContainer addSubview:txtImplementTeam];
    fHeight += 45;
    
    //实施情况描述
    UILabel *lblImplementSituation = [[UILabel alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 30)];
    lblImplementSituation.text = @"实施情况描述";
    lblImplementSituation.textColor = [SkinManage colorNamed:@"mySuggestion_title"];   //COLOR(51, 51, 51, 1.0);
    lblImplementSituation.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    lblImplementSituation.textAlignment = NSTextAlignmentLeft;
    [self.viewFormContainer addSubview:lblImplementSituation];
    fHeight += 30;
    
    UITextView *txtImplementSituation = [[UITextView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20,72)];
    txtImplementTeam.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    txtImplementSituation.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
    txtImplementSituation.layer.borderWidth = 0.5;
    txtImplementSituation.layer.cornerRadius = 5;
    txtImplementSituation.layer.masksToBounds = YES;
    txtImplementSituation.font = [UIFont fontWithName:APP_FONT_NAME size:15];
    txtImplementSituation.textColor = [SkinManage colorNamed:@"mySuggestion_title"];  //COLOR(51, 51, 51, 1.0);
    txtImplementSituation.delegate = self;
    txtImplementSituation.tag = 2002;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fTopHeight+fHeight] forKey:@"2002"];
    [self.viewFormContainer addSubview:txtImplementSituation];
    fHeight += 82;
    
    //提交 UIButton
    fHeight += 15;
    UIButton *btnCommit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCommit.frame = CGRectMake(10, fHeight, kScreenWidth-20, 40);
    [btnCommit setTitleColor:[SkinManage colorNamed:@"Menu_Title_Color"] forState:UIControlStateNormal];
    [btnCommit setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [btnCommit setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Function_BK_Color"]] forState:UIControlStateNormal];
    [btnCommit.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0]];
    [btnCommit setTitle:@"提交" forState:UIControlStateNormal];
    btnCommit.tag = 3003;
    [btnCommit addTarget:self action:@selector(doCommit:) forControlEvents:UIControlEventTouchUpInside];
    [btnCommit.layer setBorderWidth:1.0];
    [btnCommit.layer setCornerRadius:3];
    btnCommit.layer.borderColor = [[UIColor clearColor] CGColor];
    [btnCommit.layer setMasksToBounds:YES];
    [self.viewFormContainer addSubview:btnCommit];
    fHeight += 60;
    
    fHeight += 255;
    self.viewFormContainer.frame = CGRectMake(0, fTopHeight, kScreenWidth, fHeight);
    [self.m_scrollView addSubview:self.viewFormContainer];
    return fHeight;
}

//初始化验证视图（1.验证情况描述、2....）
- (CGFloat)initVerifyView:(CGFloat)fTopHeight
{
    CGFloat fHeight = 0.0;
    
    if (self.viewFormContainer != nil)
    {
        [self.viewFormContainer removeFromSuperview];
    }
    
    self.viewFormContainer = [[UIView alloc]init];
    self.viewFormContainer.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    //top line
    UIView *viewTopLine = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 0.5)];
    viewTopLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];;
    [self.viewFormContainer addSubview:viewTopLine];
    
    fHeight = 5.0;
    
    //标题
    UILabel *lblWorkflowTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 30)];
    lblWorkflowTitle.text = @"验证";
    lblWorkflowTitle.textColor = COLOR(0, 153, 68, 1.0);
    lblWorkflowTitle.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    lblWorkflowTitle.textAlignment = NSTextAlignmentCenter;
    [self.viewFormContainer addSubview:lblWorkflowTitle];
    fHeight += 30;
    
    //view line
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 4)];
    viewLine.backgroundColor = COLOR(0, 153, 68, 1.0);
    [self.viewFormContainer addSubview:viewLine];
    fHeight += 10;
    
    //验证情况描述
    UILabel *lblVerifyDes = [[UILabel alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 30)];
    lblVerifyDes.text = @"验证情况描述";
    lblVerifyDes.textColor = [SkinManage colorNamed:@"mySuggestion_title"];
    lblVerifyDes.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    lblVerifyDes.textAlignment = NSTextAlignmentLeft;
    [self.viewFormContainer addSubview:lblVerifyDes];
    fHeight += 30;
    
    UITextView *txtVerifyDes = [[UITextView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20,72)];
    txtVerifyDes.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    txtVerifyDes.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
    txtVerifyDes.layer.borderWidth = 0.5;
    txtVerifyDes.layer.cornerRadius = 5;
    txtVerifyDes.layer.masksToBounds = YES;
    txtVerifyDes.font = [UIFont fontWithName:APP_FONT_NAME size:15];
    txtVerifyDes.textColor = [SkinManage colorNamed:@"mySuggestion_title"];
    txtVerifyDes.delegate = self;
    txtVerifyDes.tag = 2001;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fTopHeight+fHeight] forKey:@"2001"];
    [self.viewFormContainer addSubview:txtVerifyDes];
    fHeight += 82;
    
    //推广或标准化情况描述
    UILabel *lblStandardDes = [[UILabel alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 30)];
    lblStandardDes.text = @"推广或标准化情况描述";
    lblStandardDes.textColor = [SkinManage colorNamed:@"mySuggestion_title"];
    lblStandardDes.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    lblStandardDes.textAlignment = NSTextAlignmentLeft;
    [self.viewFormContainer addSubview:lblStandardDes];
    fHeight += 30;
    
    UITextView *txtStandardDes = [[UITextView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20,72)];
    txtStandardDes.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    txtStandardDes.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
    txtStandardDes.layer.borderWidth = 0.5;
    txtStandardDes.layer.cornerRadius = 5;
    txtStandardDes.layer.masksToBounds = YES;
    txtStandardDes.font = [UIFont fontWithName:APP_FONT_NAME size:15];
    txtStandardDes.textColor = [SkinManage colorNamed:@"mySuggestion_title"]; //COLOR(51, 51, 51, 1.0);
    txtStandardDes.delegate = self;
    txtStandardDes.tag = 2002;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fTopHeight+fHeight] forKey:@"2002"];
    [self.viewFormContainer addSubview:txtStandardDes];
    fHeight += 82;
    
    //实施成本（元）
    UILabel *lblImplementCost = [[UILabel alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 30)];
    lblImplementCost.text = @"实施成本（元）";
    lblImplementCost.textColor = [SkinManage colorNamed:@"mySuggestion_title"]; //COLOR(51, 51, 51, 1.0);
    lblImplementCost.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    lblImplementCost.textAlignment = NSTextAlignmentLeft;
    [self.viewFormContainer addSubview:lblImplementCost];
    fHeight += 30;
    
    InsetsTextField *txtImplementCost = [[InsetsTextField alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20,35)];
    //    txtImplementCost.background = [[UIImage imageNamed:@"txt_bk"]stretchableImageWithLeftCapWidth:30 topCapHeight:10];
    txtImplementCost.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    txtImplementCost.font = [UIFont fontWithName:APP_FONT_NAME size:15];
    txtImplementCost.textColor = [SkinManage colorNamed:@"mySuggestion_title"]; //COLOR(51, 51, 51, 1.0);
    txtImplementCost.delegate = self;
    txtImplementCost.tag = 2003;
    txtImplementCost.keyboardType = UIKeyboardTypeNumberPad;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fTopHeight+fHeight] forKey:@"2003"];
    [self.viewFormContainer addSubview:txtImplementCost];
    fHeight += 45;
    
    //经济效益或节约金额（元）
    UILabel *lblSavingCost = [[UILabel alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 30)];
    lblSavingCost.text = @"经济效益或节约金额（元）";
    lblSavingCost.textColor = [SkinManage colorNamed:@"mySuggestion_title"];
    lblSavingCost.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    lblSavingCost.textAlignment = NSTextAlignmentLeft;
    [self.viewFormContainer addSubview:lblSavingCost];
    fHeight += 30;
    
    InsetsTextField *txtSavingCost = [[InsetsTextField alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20,35)];
    //    txtSavingCost.background = [[UIImage imageNamed:@"txt_bk"]stretchableImageWithLeftCapWidth:30 topCapHeight:10];
    txtSavingCost.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    txtSavingCost.font = [UIFont fontWithName:APP_FONT_NAME size:15];
    txtSavingCost.textColor = [SkinManage colorNamed:@"mySuggestion_title"];  //COLOR(51, 51, 51, 1.0);
    txtSavingCost.delegate = self;
    txtSavingCost.tag = 2004;
    txtSavingCost.keyboardType = UIKeyboardTypeNumberPad;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fTopHeight+fHeight] forKey:@"2004"];
    [self.viewFormContainer addSubview:txtSavingCost];
    fHeight += 45;
    
    //提交 UIButton
    fHeight += 15;
    UIButton *btnCommit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCommit.frame = CGRectMake(10, fHeight, kScreenWidth-20, 40);
    [btnCommit setTitleColor:[SkinManage colorNamed:@"Menu_Title_Color"] forState:UIControlStateNormal];
    [btnCommit setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [btnCommit setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Function_BK_Color"]] forState:UIControlStateNormal];
    [btnCommit.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0]];
    [btnCommit setTitle:@"提交" forState:UIControlStateNormal];
    btnCommit.tag = 3004;
    [btnCommit addTarget:self action:@selector(doCommit:) forControlEvents:UIControlEventTouchUpInside];
    [btnCommit.layer setBorderWidth:1.0];
    [btnCommit.layer setCornerRadius:3];
    btnCommit.layer.borderColor = [[UIColor clearColor] CGColor];
    [btnCommit.layer setMasksToBounds:YES];
    [self.viewFormContainer addSubview:btnCommit];
    fHeight += 60;
    
    fHeight += 255;
    self.viewFormContainer.frame = CGRectMake(0, fTopHeight, kScreenWidth, fHeight);
    [self.m_scrollView addSubview:self.viewFormContainer];
    return fHeight;
}

//初始化子公司评奖视图（一等奖、二等奖、...）
- (CGFloat)initSubcompanyRewardView:(CGFloat)fTopHeight
{
    CGFloat fHeight = 0.0;
    
    if (self.viewFormContainer != nil)
    {
        [self.viewFormContainer removeFromSuperview];
    }
    
    self.viewFormContainer = [[UIView alloc]init];
    self.viewFormContainer.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    //top line
    UIView *viewTopLine = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 0.5)];
    viewTopLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [self.viewFormContainer addSubview:viewTopLine];
    
    fHeight = 5.0;
    
    //标题
    UILabel *lblReviewTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 30)];
    lblReviewTitle.text = @"子公司评奖";
    lblReviewTitle.textColor = COLOR(0, 153, 68, 1.0);
    lblReviewTitle.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    lblReviewTitle.textAlignment = NSTextAlignmentCenter;
    [self.viewFormContainer addSubview:lblReviewTitle];
    fHeight += 30;
    
    //view line
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 4)];
    viewLine.backgroundColor = COLOR(0, 153, 68, 1.0);
    [self.viewFormContainer addSubview:viewLine];
    fHeight += 10;
    
    //选项
    if (self.suggestionBaseVo != nil)
    {
        for (NSInteger i=0;i<self.suggestionBaseVo.aryEvaluationDepartmentOpinion.count;i++)
        {
            fHeight += 1.25;
            KeyValueVo *optionVo = self.suggestionBaseVo.aryEvaluationDepartmentOpinion[i];
            UIButton *btnOption = [UIButton buttonWithType:UIButtonTypeCustom];
            btnOption.tag = 1000+i;
            [btnOption setImage:[UIImage imageNamed:@"suggestion_uncheck"] forState:UIControlStateNormal];
            [btnOption setImage:[UIImage imageNamed:@"suggestion_check"] forState:UIControlStateSelected];
            [btnOption setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [btnOption setTitle:optionVo.strValue forState:UIControlStateNormal];
            [btnOption.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
            [btnOption setTitleColor:[SkinManage colorNamed:@"mySuggestion_title"] forState:UIControlStateNormal];
            [btnOption addTarget:self action:@selector(optionSelected:) forControlEvents:UIControlEventTouchUpInside];
            [btnOption setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            
            btnOption.titleLabel.numberOfLines = 0;
            
            CGSize sizeContent = [Common getStringSize:optionVo.strValue font:[UIFont systemFontOfSize:14.0] bound:CGSizeMake(kScreenWidth-80, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            btnOption.frame = CGRectMake(15, fHeight, kScreenWidth-30, sizeContent.height+20);
            [self.viewFormContainer addSubview:btnOption];
            fHeight += sizeContent.height+20;
            fHeight += 1.25;
            
            //line
            UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 1)];
            viewLine.backgroundColor = [UIColor colorWithPatternImage:[SkinManage imageNamed:@"dote_line"]];
            [self.viewFormContainer addSubview:viewLine];
            fHeight += 1;
        }
    }
    
    //    fHeight += 10;
    //    
    //    //上报总公司评奖
    //    UIButton *btnReport = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [btnReport setImage:[UIImage imageNamed:@"reward_unreport"] forState:UIControlStateNormal];
    //    [btnReport setImage:[UIImage imageNamed:@"reward_report"] forState:UIControlStateSelected];
    //    [btnReport setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    //    [btnReport setTitle:@"上报总公司评奖" forState:UIControlStateNormal];
    //    [btnReport.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    //    [btnReport setTitleColor:COLOR(51, 51, 51, 1.0) forState:UIControlStateNormal];
    //    [btnReport addTarget:self action:@selector(reportToHeadOffice:) forControlEvents:UIControlEventTouchUpInside];
    //    [btnReport setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    //    btnReport.frame = CGRectMake(15, fHeight, kScreenWidth-30, 50);
    //    [self.viewFormContainer addSubview:btnReport];
    //    fHeight += 50;
    
    //提交 UIButton
    fHeight += 10;
    UIButton *btnCommit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCommit.frame = CGRectMake(10, fHeight, kScreenWidth-20, 40);
    [btnCommit setTitleColor:[SkinManage colorNamed:@"Menu_Title_Color"] forState:UIControlStateNormal];
    [btnCommit setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [btnCommit setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Function_BK_Color"]] forState:UIControlStateNormal];
    [btnCommit.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0]];
    [btnCommit setTitle:@"提交" forState:UIControlStateNormal];
    btnCommit.tag = 3005;
    [btnCommit addTarget:self action:@selector(doCommit:) forControlEvents:UIControlEventTouchUpInside];
    [btnCommit.layer setBorderWidth:1.0];
    [btnCommit.layer setCornerRadius:3];
    btnCommit.layer.borderColor = [[UIColor clearColor] CGColor];
    [btnCommit.layer setMasksToBounds:YES];
    [self.viewFormContainer addSubview:btnCommit];
    fHeight += 60;
    
    fHeight += 255;
    self.viewFormContainer.frame = CGRectMake(0, fTopHeight, kScreenWidth, fHeight);
    [self.m_scrollView addSubview:self.viewFormContainer];
    return fHeight;
}

//初始化总公司评奖视图（一等奖、二等奖、...）
- (CGFloat)initHeadOfficeRewardView:(CGFloat)fTopHeight
{
    CGFloat fHeight = 0.0;
    
    if (self.viewFormContainer != nil)
    {
        [self.viewFormContainer removeFromSuperview];
    }
    
    self.viewFormContainer = [[UIView alloc]init];
    self.viewFormContainer.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    //top line
    UIView *viewTopLine = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 0.5)];
    viewTopLine.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.viewFormContainer addSubview:viewTopLine];
    
    fHeight = 5.0;
    
    //标题
    UILabel *lblReviewTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 30)];
    lblReviewTitle.text = @"总公司评奖";
    lblReviewTitle.textColor = COLOR(0, 153, 68, 1.0);
    lblReviewTitle.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    lblReviewTitle.textAlignment = NSTextAlignmentCenter;
    [self.viewFormContainer addSubview:lblReviewTitle];
    fHeight += 30;
    
    //view line
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 4)];
    viewLine.backgroundColor = COLOR(0, 153, 68, 1.0);
    [self.viewFormContainer addSubview:viewLine];
    fHeight += 10;
    
    //选项
    if (self.suggestionBaseVo != nil)
    {
        for (NSInteger i=0;i<self.suggestionBaseVo.aryEvaluationCommitteeOpinion.count;i++)
        {
            fHeight += 1.25;
            KeyValueVo *optionVo = self.suggestionBaseVo.aryEvaluationCommitteeOpinion[i];
            UIButton *btnOption = [UIButton buttonWithType:UIButtonTypeCustom];
            btnOption.tag = 1000+i;
            [btnOption setImage:[UIImage imageNamed:@"suggestion_uncheck"] forState:UIControlStateNormal];
            [btnOption setImage:[UIImage imageNamed:@"suggestion_check"] forState:UIControlStateSelected];
            [btnOption setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [btnOption setTitle:optionVo.strValue forState:UIControlStateNormal];
            [btnOption.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
            [btnOption setTitleColor:COLOR(51, 51, 51, 1.0) forState:UIControlStateNormal];
            [btnOption addTarget:self action:@selector(optionSelected:) forControlEvents:UIControlEventTouchUpInside];
            [btnOption setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            
            btnOption.titleLabel.numberOfLines = 0;
            
            CGSize sizeContent = [Common getStringSize:optionVo.strValue font:[UIFont systemFontOfSize:14.0] bound:CGSizeMake(kScreenWidth-80, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            btnOption.frame = CGRectMake(15, fHeight, kScreenWidth-30, sizeContent.height+20);
            [self.viewFormContainer addSubview:btnOption];
            fHeight += sizeContent.height+20;
            fHeight += 1.25;
            
            //line
            UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 1)];
            viewLine.backgroundColor = [UIColor colorWithPatternImage:[SkinManage imageNamed:@"dote_line"]];
            [self.viewFormContainer addSubview:viewLine];
            fHeight += 1;
        }
    }
    
    fHeight += 10;
    
    //奖励情况描述
    UILabel *lblVerifyDes = [[UILabel alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20, 30)];
    lblVerifyDes.text = @"奖励情况";
    lblVerifyDes.textColor = [SkinManage colorNamed:@"mySuggestion_title"]; //COLOR(51, 51, 51, 1.0);
    lblVerifyDes.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    lblVerifyDes.textAlignment = NSTextAlignmentLeft;
    [self.viewFormContainer addSubview:lblVerifyDes];
    fHeight += 30;
    
    UITextView *txtVerifyDes = [[UITextView alloc]initWithFrame:CGRectMake(10, fHeight, kScreenWidth-20,72)];
    txtVerifyDes.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    txtVerifyDes.layer.borderColor = COLOR(204, 204, 204, 1.0).CGColor;
    txtVerifyDes.layer.borderWidth = 0.5;
    txtVerifyDes.layer.cornerRadius = 5;
    txtVerifyDes.layer.masksToBounds = YES;
    txtVerifyDes.font = [UIFont fontWithName:APP_FONT_NAME size:15];
    txtVerifyDes.textColor = [SkinManage colorNamed:@"mySuggestion_title"];
    txtVerifyDes.delegate = self;
    txtVerifyDes.tag = 2001;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fTopHeight+fHeight] forKey:@"2001"];
    [self.viewFormContainer addSubview:txtVerifyDes];
    fHeight += 82;
    
    //提交 UIButton
    fHeight += 10;
    UIButton *btnCommit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCommit.frame = CGRectMake(10, fHeight, kScreenWidth-20, 40);
    [btnCommit setTitleColor:[SkinManage colorNamed:@"Menu_Title_Color"] forState:UIControlStateNormal];
    [btnCommit setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [btnCommit setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Function_BK_Color"]] forState:UIControlStateNormal];
    [btnCommit.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0]];
    [btnCommit setTitle:@"提交" forState:UIControlStateNormal];
    btnCommit.tag = 3006;
    [btnCommit addTarget:self action:@selector(doCommit:) forControlEvents:UIControlEventTouchUpInside];
    [btnCommit.layer setBorderWidth:1.0];
    [btnCommit.layer setCornerRadius:3];
    btnCommit.layer.borderColor = [[UIColor clearColor] CGColor];
    [btnCommit.layer setMasksToBounds:YES];
    [self.viewFormContainer addSubview:btnCommit];
    fHeight += 60;
    
    fHeight += 255;
    self.viewFormContainer.frame = CGRectMake(0, fTopHeight, kScreenWidth, fHeight);
    [self.m_scrollView addSubview:self.viewFormContainer];
    return fHeight;
}

//提交按钮
- (void)doCommit:(UIButton*)sender
{
    NSString *strSuccessTip = @"";
    SuggestionVo *suggestionVo = [[SuggestionVo alloc]init];
    suggestionVo.strID = self.m_suggestionVo.strID;
    suggestionVo.nDBVersion = self.m_suggestionVo.nDBVersion;
    
    if(sender.tag == 3001)
    {
        //提交初评
        suggestionVo.nCommitStatus = 1;//提交状态
        
        //初评选项
        if (self.nOptionSelected >=0)
        {
            KeyValueVo *optionVo = self.suggestionBaseVo.aryAssessOpinion[self.nOptionSelected-1000];
            suggestionVo.strEvaluationKey = optionVo.strKey;
        }
        else
        {
            [Common tipAlert:@"请选择初评选项"];
            return;
        }
        
        //备注
        UITextView *txtSuggestion = (UITextView *)[self.viewFormContainer viewWithTag:2001];
        if (txtSuggestion.text.length>0)
        {
            suggestionVo.strEvaluationSuggestion = txtSuggestion.text;
        }
        else
        {
            //            [Common tipAlert:@"请填写意见"];
            //            return;
        }
        
        //审核人用户ID
        if (self.userVoReview == nil)
        {
            //            [Common tipAlert:@"请选择审核人"];
            //            return;
        }
        else
        {
            suggestionVo.strReviewID = self.userVoReview.strUserID;
        }
        
        //是否上报总公司关注
        suggestionVo.nReportAttention = self.bReportAttention?1:0;
        
        strSuccessTip = @"提交初评成功";
    }
    else if(sender.tag == 3002)
    {
        //提交审核
        suggestionVo.nCommitStatus = 2;
        
        //审核选项
        if (self.nOptionSelected >=0)
        {
            KeyValueVo *optionVo = self.suggestionBaseVo.aryAssessImplementItem[self.nOptionSelected-1000];
            suggestionVo.strReviewKey = optionVo.strKey;
        }
        else
        {
            [Common tipAlert:@"请选择审核选项"];
            return;
        }
        
        //备注
        UITextView *txtViewRemark = (UITextView *)[self.viewFormContainer viewWithTag:2001];
        suggestionVo.strReviewRemark = txtViewRemark.text;
        
        strSuccessTip = @"提交审核成功";
    }
    else if(sender.tag == 3003)
    {
        //提交实施
        suggestionVo.nCommitStatus = 3;//提交状态
        
        //实施人/团队
        InsetsTextField *txtImplementTeam = (InsetsTextField *)[self.viewFormContainer viewWithTag:2001];
        if (txtImplementTeam.text.length>0)
        {
            suggestionVo.strImplementTeam = txtImplementTeam.text;
        }
        else
        {
            [Common tipAlert:@"请填写实施人/团队"];
            return;
        }
        
        //实施情况描述
        UITextView *txtImplementSituation = (UITextView *)[self.viewFormContainer viewWithTag:2002];
        if (txtImplementTeam.text.length>0)
        {
            suggestionVo.strImplementSituation = txtImplementSituation.text;
        }
        else
        {
            [Common tipAlert:@"请填写实施情况描述"];
            return;
        }
        strSuccessTip = @"提交实施成功";
    }
    else if(sender.tag == 3004)
    {
        //提交验证
        suggestionVo.nCommitStatus = 4;//提交状态
        
        //验证情况描述
        UITextView *txtVerifyDes = (UITextView *)[self.viewFormContainer viewWithTag:2001];
        if (txtVerifyDes.text.length>0)
        {
            suggestionVo.strVerifySituaion = txtVerifyDes.text;
        }
        else
        {
            [Common tipAlert:@"请填写验证情况描述"];
            return;
        }
        
        //推广或标准化情况描述
        UITextView *txtStandardDes = (UITextView *)[self.viewFormContainer viewWithTag:2002];
        if (txtStandardDes.text.length>0)
        {
            suggestionVo.strExtendSituation = txtStandardDes.text;
        }
        else
        {
            [Common tipAlert:@"请填写推广或标准化情况描述"];
            return;
        }
        
        //实施成本（元）
        InsetsTextField *txtImplementCost = (InsetsTextField *)[self.viewFormContainer viewWithTag:2003];
        if (txtImplementCost.text.length>0)
        {
            suggestionVo.strImplementCost = txtImplementCost.text;
        }
        else
        {
            [Common tipAlert:@"请填写实施成本"];
            return;
        }
        
        //经济效益或节约金额（元）
        InsetsTextField *txtSavingCost = (InsetsTextField *)[self.viewFormContainer viewWithTag:2004];
        if (txtSavingCost.text.length>0)
        {
            suggestionVo.strSavingCost = txtSavingCost.text;
        }
        else
        {
            [Common tipAlert:@"请填写经济效益或节约金额"];
            return;
        }
        strSuccessTip = @"提交验证成功";
    }
    else if(sender.tag == 3005)
    {
        //提交子公司评奖
        suggestionVo.nCommitStatus = 5;
        
        //子公司评奖选项
        if (self.nOptionSelected >=0)
        {
            KeyValueVo *optionVo = self.suggestionBaseVo.aryEvaluationDepartmentOpinion[self.nOptionSelected-1000];
            suggestionVo.strSubRewardKey = optionVo.strKey;
        }
        else
        {
            [Common tipAlert:@"请选择评奖选项"];
            return;
        }
        
        strSuccessTip = @"提交子公司评奖成功";
    }
    else if(sender.tag == 3006)
    {
        //提交总公司评奖
        suggestionVo.nCommitStatus = 6;//提交状态
        
        //总公司奖项
        if (self.nOptionSelected >=0)
        {
            KeyValueVo *optionVo = self.suggestionBaseVo.aryEvaluationCommitteeOpinion[self.nOptionSelected-1000];
            suggestionVo.strHeadRewardKey = optionVo.strKey;
        }
        else
        {
            [Common tipAlert:@"请选评奖选项"];
            return;
        }
        
        //奖励情况描述
        UITextView *txtVerifyDes = (UITextView *)[self.viewFormContainer viewWithTag:2001];
        if (txtVerifyDes.text.length>0)
        {
            suggestionVo.strHeadRewardSituation = txtVerifyDes.text;
        }
        else
        {
            [Common tipAlert:@"请填写奖励情况描述"];
            return;
        }
        
        strSuccessTip = @"提交总公司评奖成功";
    }
    
    [self isHideActivity:NO];
    [ServerProvider commitSuggestionReview:suggestionVo result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            [Common tipAlert:strSuccessTip];
            //刷新视图
            [self refreshData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//按钮单选
- (void)optionSelected:(UIButton*)sender
{
    if (self.nOptionSelected>=0)
    {
        //之前有选中,清空之前的选择
        UIButton *btnTemp = (UIButton*)[self.viewFormContainer viewWithTag:self.nOptionSelected];
        btnTemp.selected = NO;
    }
    
    self.nOptionSelected = sender.tag;
    sender.selected = YES;
}

//上报总公司评奖
-(void)reportToHeadOffice:(UIButton*)sender
{
    self.bReportToHeadOffice = !self.bReportToHeadOffice;
    sender.selected = self.bReportToHeadOffice;
}

//上报总公司关注
-(void)reportToHeadAttention:(UIButton*)sender
{
    self.bReportAttention = !self.bReportAttention;
    sender.selected = self.bReportAttention;
}

-(void)hideKeyBoard
{
    for(UIView*view in[self.viewFormContainer subviews])
    {
        if([view isFirstResponder])
        {
            [view resignFirstResponder];
            return;
        }
    }
}

//完成审核人的选择
- (void)finishedChooseReviewer:(UserVo*)userVo
{
    self.userVoReview = userVo;
    
    InsetsTextField *txtReview = (InsetsTextField *)[self.viewFormContainer viewWithTag:10001];
    txtReview.text = self.userVoReview.strRealName;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //编辑时调整view
    [self fieldOffset:textView.tag];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == 10001)
    {
        //选择审核人
        ChooseReviewerViewController *chooseReviewerViewController = [[ChooseReviewerViewController alloc]init];
        chooseReviewerViewController.suggestionDetailViewController = self;
        [self.navigationController pushViewController:chooseReviewerViewController animated:YES];
        
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //编辑时调整view
    [self fieldOffset:textField.tag];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
