//
//  SuggestionBaseVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/3/16.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SuggestionBaseVo : NSObject

@property(nonatomic,strong)NSString *strDepartmentID;//子公司id
@property(nonatomic,strong)NSString *strDepartmentName;//子公司名称

@property(nonatomic,strong)NSMutableArray *arySuggestionType; //建议项目类别
@property(nonatomic,strong)NSMutableArray *aryAssessOpinion; //初评建议选项
@property(nonatomic,strong)NSMutableArray *aryAssessImplementItem; //建议实施部门

@property(nonatomic,strong)NSMutableArray *aryAssessReviewerOpinion; //本公司审核人意见 ？？？？？

@property(nonatomic,strong)NSMutableArray *aryEvaluationDepartmentOpinion; //子公司评奖
@property(nonatomic,strong)NSMutableArray *aryEvaluationDepartmentReport; //本公司推荐上报总公司评奖意见（暂时写死Y/N,是否）
@property(nonatomic,strong)NSMutableArray *aryEvaluationGroupOpinion; //工作小组评审意见（转到线下）
@property(nonatomic,strong)NSMutableArray *aryEvaluationCommitteeOpinion; //评审委员会意见

@end
