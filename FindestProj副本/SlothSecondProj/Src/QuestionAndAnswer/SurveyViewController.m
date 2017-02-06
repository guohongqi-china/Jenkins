//
//  SurveyViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 11/28/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "SurveyViewController.h"
#import "Utils.h"
#import "SurveyCell.h"

@interface SurveyViewController ()

@end

@implementation SurveyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initSurveyData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self setTopNavBarTitle:@"问卷调查"];
    
    self.scrollViewSurvey = [[UIScrollView alloc]initWithFrame:CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT)];
    self.scrollViewSurvey.backgroundColor = [UIColor clearColor];
    self.scrollViewSurvey.autoresizingMask = NO;
    self.scrollViewSurvey.clipsToBounds = YES;
    [self.view addSubview:self.scrollViewSurvey];
    
    //介绍页////////////////////////////////////////////////////////////////////////////
    //问卷标题
    self.lblSurveyTitle = [[UILabel alloc]init];
    self.lblSurveyTitle.numberOfLines = 0;
    self.lblSurveyTitle.textColor = COLOR(0, 0, 0, 1.0);
    self.lblSurveyTitle.font = [UIFont systemFontOfSize:17];
    self.lblSurveyTitle.backgroundColor = [UIColor clearColor];
    self.lblSurveyTitle.textAlignment = NSTextAlignmentCenter;
    [self.scrollViewSurvey addSubview:self.lblSurveyTitle];
    
    //问卷描述
    self.lblSurveyDesc = [[UILabel alloc]init];
    self.lblSurveyDesc.numberOfLines = 0;
    self.lblSurveyDesc.textColor = COLOR(95, 95, 95, 1.0);
    self.lblSurveyDesc.font = [UIFont systemFontOfSize:15];
    self.lblSurveyDesc.backgroundColor = [UIColor clearColor];
    [self.scrollViewSurvey addSubview:self.lblSurveyDesc];
    
    //开始答题
    self.btnStart = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnStart setTitle:@"开始答题" forState:UIControlStateNormal];
    [self.btnStart setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnStart setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [self.btnStart.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
    [self.btnStart setBackgroundImage:[Common getImageWithColor:[SkinManage skinColor]] forState:UIControlStateNormal];
    [self.btnStart addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnStart.layer setBorderWidth:1.0];
    [self.btnStart.layer setCornerRadius:4];
    self.btnStart.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.btnStart.layer setMasksToBounds:YES];
    [self.scrollViewSurvey addSubview:self.btnStart];
    
    //答题页////////////////////////////////////////////////////////////////////////////
    //题号
    self.lblQNum = [[UILabel alloc]init];
    self.lblQNum.textColor = COLOR(95, 95, 95, 1.0);
    self.lblQNum.font = [UIFont systemFontOfSize:16];
    self.lblQNum.backgroundColor = [UIColor clearColor];
    [self.scrollViewSurvey addSubview:self.lblQNum];
    
    //题目简介
    self.lblQDesc = [[UILabel alloc]init];
    self.lblQDesc.numberOfLines = 0;
    self.lblQDesc.textColor = COLOR(95, 95, 95, 1.0);
    self.lblQDesc.font = [UIFont systemFontOfSize:16];
    self.lblQDesc.backgroundColor = [UIColor clearColor];
    [self.scrollViewSurvey addSubview:self.lblQDesc];
    
    //题目
    self.lblQName = [[UILabel alloc]init];
    self.lblQName.numberOfLines = 0;
    self.lblQName.textColor = COLOR(0, 0, 0, 1.0);
    self.lblQName.font = [UIFont systemFontOfSize:16];
    self.lblQName.backgroundColor = [UIColor clearColor];
    [self.scrollViewSurvey addSubview:self.lblQName];
    
    //选项
    self.tableViewOption = [[UITableView alloc]initWithFrame:CGRectZero];
    self.tableViewOption.dataSource = self;
    self.tableViewOption.delegate = self;
    self.tableViewOption.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.scrollViewSurvey addSubview:self.tableViewOption];
    
    //上一题
    self.btnPrevious = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnPrevious setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnPrevious setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [self.btnPrevious.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
    [self.btnPrevious setBackgroundImage:[Common getImageWithColor:[SkinManage skinColor]] forState:UIControlStateNormal];
    [self.btnPrevious addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPrevious.layer setBorderWidth:1.0];
    [self.btnPrevious.layer setCornerRadius:4];
    self.btnPrevious.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.btnPrevious.layer setMasksToBounds:YES];
    [self.scrollViewSurvey addSubview:self.btnPrevious];
    
    //下一题
    self.btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnNext setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [self.btnNext.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
    [self.btnNext setBackgroundImage:[Common getImageWithColor:[SkinManage skinColor]] forState:UIControlStateNormal];
    [self.btnNext addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnNext.layer setBorderWidth:1.0];
    [self.btnNext.layer setCornerRadius:4];
    self.btnNext.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.btnNext.layer setMasksToBounds:YES];
    [self.scrollViewSurvey addSubview:self.btnNext];
}

- (void)refreshView
{
    //更新当前选择项的数量
    [self updateCurrChooseNum];
    
    CGFloat fHeight = 15;
    if (self.nCurrIndex == -1)
    {
        //介绍页
        fHeight += 10;
        self.lblSurveyTitle.hidden = NO;
        self.lblSurveyTitle.text = self.m_surveyVo.strName;
        CGSize size = [Common getStringSize:self.m_surveyVo.strName andFont:self.lblSurveyTitle.font andBound:CGSizeMake(kScreenWidth-30, MAXFLOAT)];
        self.lblSurveyTitle.frame = CGRectMake(15, fHeight, kScreenWidth-30, size.height);
        fHeight += size.height + 20;
        
        self.lblSurveyDesc.hidden = NO;
        self.lblSurveyDesc.text = self.m_surveyVo.strDesc;
        size = [Common getStringSize:self.m_surveyVo.strDesc andFont:self.lblSurveyDesc.font andBound:CGSizeMake(kScreenWidth-30, MAXFLOAT)];
        self.lblSurveyDesc.frame = CGRectMake(15, fHeight, kScreenWidth-30, size.height);
        fHeight += size.height + 30;
        
        self.btnStart.hidden = NO;
        self.btnStart.frame = CGRectMake(60, fHeight, kScreenWidth-120, 40);
        
        //hide
        self.lblQNum.hidden = YES;
        self.lblQName.hidden = YES;
        self.tableViewOption.hidden = YES;
        self.btnPrevious.hidden = YES;
        self.btnNext.hidden = YES;
    }
    else
    {
        QuestionVo *questionVo = [self.aryQuestion objectAtIndex:self.nCurrIndex];
        //答题页
        //题号
        self.lblQNum.hidden = NO;
        self.lblQNum.text = [NSString stringWithFormat:@"【第%li题】",(long)self.nCurrIndex+1];
        self.lblQNum.frame = CGRectMake(8, fHeight, kScreenWidth-30, 20);
        fHeight += 25;
        
        //简介
        self.lblQDesc.hidden = NO;
        self.lblQDesc.text = questionVo.strDesc;
        CGSize size = [Common getStringSize:questionVo.strDesc andFont:self.lblQDesc.font andBound:CGSizeMake(kScreenWidth-30, MAXFLOAT)];
        self.lblQDesc.frame = CGRectMake(15, fHeight, kScreenWidth-30, size.height);
        if (size.height>5)
        {
            //存在题目描述
            fHeight += size.height + 10;
        }
        
        //题目
        self.lblQName.hidden = NO;
        self.lblQName.text = questionVo.strName;
        size = [Common getStringSize:questionVo.strName andFont:self.lblQName.font andBound:CGSizeMake(kScreenWidth-30, MAXFLOAT)];
        self.lblQName.frame = CGRectMake(15, fHeight, kScreenWidth-30, size.height);
        fHeight += size.height + 10;
        
        //为了获取UITableView 的高度
        self.tableViewOption.hidden = NO;
        [self.tableViewOption reloadData];
        self.tableViewOption.frame = CGRectMake(0, fHeight, kScreenWidth, self.tableViewOption.contentSize.height);
        fHeight += self.tableViewOption.contentSize.height + 20;
        
        //上一题
        self.btnPrevious.hidden = NO;
        self.btnPrevious.frame = CGRectMake(kScreenWidth/2-120-10, fHeight, 120, 40);
        if(self.nCurrIndex == 0)
        {
            [self.btnPrevious setTitle:@"返回说明" forState:UIControlStateNormal];
        }
        else
        {
            [self.btnPrevious setTitle:@"上一题" forState:UIControlStateNormal];
        }
        
        //下一题
        self.btnNext.hidden = NO;
        self.btnNext.frame = CGRectMake(kScreenWidth/2+10, fHeight, 120, 40);
        if(self.nCurrIndex == (self.aryQuestion.count-1))
        {
            [self.btnNext setTitle:@"提交问卷" forState:UIControlStateNormal];
        }
        else
        {
            [self.btnNext setTitle:@"下一题" forState:UIControlStateNormal];
        }
        fHeight += 60;
        //控制下页按钮的有效性
        if(self.nCurrChooseNum>0)
        {
            self.btnNext.enabled = YES;
        }
        else
        {
            self.btnNext.enabled = NO;
        }
        
        //hide
        self.lblSurveyTitle.hidden = YES;
        self.lblSurveyDesc.hidden = YES;
        self.btnStart.hidden = YES;
    }
    
    if (fHeight<kScreenHeight-NAV_BAR_HEIGHT)
    {
        fHeight = kScreenHeight-NAV_BAR_HEIGHT+0.5;
    }
    self.scrollViewSurvey.contentSize = CGSizeMake(kScreenWidth, fHeight);
}

- (void)initSurveyData
{
    self.nCurrIndex = -1;
    self.nCurrChooseNum = 0;
    [self isHideActivity:NO];
    [ServerProvider getQuestionSurvey:self.strSurveyID result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            self.m_surveyVo = retInfo.data;
            [self refreshView];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)initQuestionData
{
    [self isHideActivity:NO];
    [ServerProvider getQuestionList:self.strSurveyID result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            self.aryQuestion = retInfo.data;
            [self refreshView];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//提交问卷
- (void)commitSurvey
{
    [self isHideActivity:NO];
    [ServerProvider commitSurvey:self.strSurveyID andAnswer:self.aryQuestion result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            //刷新分享详情页面
            [[NSNotificationCenter defaultCenter]postNotificationName:@"CompletedSurvey" object:nil];
            //提交问卷成功，返回分享详情页面
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)buttonAction:(UIButton*)sender
{
    if (sender == self.btnStart)
    {
        //开始答题
        self.nCurrIndex = 0;
        if(self.aryQuestion == nil || self.aryQuestion.count == 0)
        {
            [self initQuestionData];
        }
        else
        {
            [self refreshView];
        }
    }
    else if (sender == self.btnPrevious)
    {
        //上一题
        self.nCurrIndex--;
        [self refreshView];
    }
    else if (sender == self.btnNext)
    {
        //下一题
        if(self.nCurrIndex == self.aryQuestion.count-1)
        {
            //提交问卷
            UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:nil message:@"你确认要提交问卷？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
            alertView.tag = 1002;
            [alertView show];
        }
        else
        {
            self.nCurrIndex++;
            [self refreshView];
        }
    }
}

- (void)backButtonClicked
{
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:nil message:@"你确认要退出问卷测试？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
    alertView.tag = 1001;
    [alertView show];
}

//更新当前页的选择的数量
- (void)updateCurrChooseNum
{
    if(self.nCurrIndex>=0)
    {
        self.nCurrChooseNum = 0;
        QuestionVo *questionVo = [self.aryQuestion objectAtIndex:self.nCurrIndex];
        for (QOptionVo *qOptionVoTemp in questionVo.aryOption)
        {
            if(qOptionVoTemp.bChecked)
            {
                self.nCurrChooseNum++;
            }
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1001)
    {
        
        if (buttonIndex == 1)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (alertView.tag == 1002)
    {
        
        if (buttonIndex == 1)
        {
            [self commitSurvey];
        }
    }
}

#pragma mark - UITableView
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger nCount = 0;
    if (self.nCurrIndex>=0)
    {
        QuestionVo *questionVo = [self.aryQuestion objectAtIndex:self.nCurrIndex];
        nCount = questionVo.aryOption.count;
    }
    return nCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SurveyCell";
    SurveyCell *cell = (SurveyCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[SurveyCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        //改变选中背景色
        UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
        viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
        cell.selectedBackgroundView = viewSelected;
    }
    
    QuestionVo *questionLast = nil;
    if (self.nCurrIndex>0)
    {
        questionLast = [self.aryQuestion objectAtIndex:self.nCurrIndex-1];
    }
    QuestionVo *questionVo = [self.aryQuestion objectAtIndex:self.nCurrIndex];
    QOptionVo *qOptionVo = [questionVo.aryOption objectAtIndex:[indexPath row]];
    [cell initWithData:qOptionVo andLastQ:questionLast andMultiple:questionVo.nMultiple];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestionVo *questionVo = [self.aryQuestion objectAtIndex:self.nCurrIndex];
    QOptionVo *qOptionVo = [questionVo.aryOption objectAtIndex:[indexPath row]];
    return [SurveyCell calculateCellHeight:qOptionVo];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QuestionVo *questionVo = [self.aryQuestion objectAtIndex:self.nCurrIndex];
    QOptionVo *qOptionVo = [questionVo.aryOption objectAtIndex:[indexPath row]];
    SurveyCell *cell = (SurveyCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    if(cell.bAssociation)
    {
        //答案关联
        [Common bubbleTip:@"该题与上一题关联，不能选择上一题的答案" andView:self.view];
    }
    else
    {
        //单选和多选的控制
        if (questionVo.nMultiple == 1)
        {
            //多选
            if(!qOptionVo.bChecked && self.nCurrChooseNum >= self.m_surveyVo.nSelectLimited)
            {
                [Common bubbleTip:[NSString stringWithFormat:@"多选题，限选%li项",(long)self.m_surveyVo.nSelectLimited] andView:self.view];
            }
            else
            {
                //更新UI 和 data
                qOptionVo.bChecked = !qOptionVo.bChecked;
                [cell updateCheckImage];
                
                if (qOptionVo.bChecked)
                {
                    self.nCurrChooseNum++;
                }
                else
                {
                    self.nCurrChooseNum--;
                }
            }
        }
        else
        {
            //单选
            self.nCurrChooseNum = 1;
            if (!qOptionVo.bChecked)
            {
                //将其他选项清除
                for (QOptionVo *qOptionVoTemp in questionVo.aryOption)
                {
                    qOptionVoTemp.bChecked = NO;
                }
                
                //将该项设置为YES
                qOptionVo.bChecked = YES;
                [self.tableViewOption reloadData];
            }
        }
        
        //控制下一页按钮的状态
        if (self.nCurrChooseNum>0)
        {
            self.btnNext.enabled = YES;
        }
        else
        {
            self.btnNext.enabled = NO;
        }
        
        //如果本题是关联题目，则将下一题的答案清除
        if (questionVo.nAssociation == 1 && self.nCurrIndex < self.aryQuestion.count-1)
        {
            QuestionVo *questionNext = [self.aryQuestion objectAtIndex:self.nCurrIndex+1];
            for (QOptionVo *qOptionVo in questionNext.aryOption)
            {
                qOptionVo.bChecked = NO;
            }
        }
    }
}

@end
