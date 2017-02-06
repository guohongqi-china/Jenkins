//
//  SuggestionVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/3/16.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SuggestionVo : NSObject

@property(nonatomic)NSInteger nDBVersion;//数据库锁版本号，用于流程控制

@property(nonatomic,strong)NSString *strID;//建议ID
@property(nonatomic,strong)NSString *strSuggestionNo;//建议编号
@property(nonatomic,strong)NSString *strApplyID;//申请人ID
@property(nonatomic,strong)NSString *strName;//申请人姓名

@property(nonatomic,strong)NSString *strReviewID;//审核人ID
@property(nonatomic,strong)NSString *strReviewName;//审核人姓名

@property(nonatomic,strong)NSString *strTypeKey;//合理化建议项目类别 key
@property(nonatomic,strong)NSString *strTypeValue;//合理化建议项目类别 value
@property(nonatomic,strong)NSString *strSuggestionName;//建议名称
@property(nonatomic,strong)NSString *strProblemDes;//存在问题（缺陷）描述
@property(nonatomic,strong)NSString *strImproveDes;//建议改进的措施
@property(nonatomic,strong)NSString *strDepartmentID;//子公司id
@property(nonatomic,strong)NSString *strDepartmentName;//子公司名称

@property(nonatomic)NSInteger nCommitStatus;  //提交审核状态（用于程序判断）0-修改合理化建议; 1-提交初评; 2-提交审核; 3-提交实施; 4-提交验证; 5-提交子公司评奖; 6-提交总公司评奖;
@property(nonatomic)NSInteger nReportAttention; //上报总公司关注

@property(nonatomic,strong)NSString *strDate;//申请日期

//状态值:	1-初评中（已提交）; 2-审核中; 3-初评退回; 4-实施中; 5-暂不实施; 6-不实施; 7-子公司评奖结果; 8-评审中; 9-子公司评奖中(已验证);
//10-子公司已上报;11-总公司评奖完毕;12-子公司不评奖;13-不是合理化建议;
@property(nonatomic)NSInteger nStatus;  //状态值
@property(nonatomic,strong)NSString *strStatusName;//状态名

//获奖状态
@property(nonatomic)NSInteger nRewardStatus;  //状态值
@property(nonatomic,strong)NSString *strRewardStatusName;//状态名	7-未通过; 8-评审中; 9-已评审;

//初评结果
@property(nonatomic,strong)NSString *strEvaluationKey;//初评结果 key
@property(nonatomic,strong)NSString *strEvaluationValue;//初评结果 value
@property(nonatomic,strong)NSString *strEvaluationSuggestion;//其他部门支持或成立QC小组意见/退回意见

//审核结果
@property(nonatomic,strong)NSString *strReviewKey;//审核结果 key
@property(nonatomic,strong)NSString *strReviewValue;//审核结果 value
@property(nonatomic,strong)NSString *strReviewRemark;//审核备注

//实施结果
@property(nonatomic,strong)NSString *strImplementTeam;//实施人/团队
@property(nonatomic,strong)NSString *strImplementSituation;//实施情况描述

//验证结果
@property(nonatomic,strong)NSString *strVerifySituaion;//验证情况描述
@property(nonatomic,strong)NSString *strExtendSituation;//推广或标准化情况描述
@property(nonatomic,strong)NSString *strImplementCost;//实施成本（元）
@property(nonatomic,strong)NSString *strSavingCost;//经济效益或节约金额（元）

//子公司评奖
@property(nonatomic,strong)NSString *strSubRewardKey;//奖项 key
@property(nonatomic,strong)NSString *strSubRewardValue;//奖项 value
@property(nonatomic,strong)NSString *strReportHeadOfficeKey;//是否上报总公司评奖，Y/N
@property(nonatomic,strong)NSString *strReportHeadOfficeValue;//是否上报总公司评奖，

//总公司评奖
@property(nonatomic,strong)NSString *strHeadRewardKey;//奖项 key
@property(nonatomic,strong)NSString *strHeadRewardValue;//奖项 value
@property(nonatomic,strong)NSString *strHeadRewardSituation;//奖励情况描述

@end
