//
//  QuestionSurveyVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 11/28/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

//问卷调查VO
@interface QuestionSurveyVo : NSObject

@property(nonatomic,strong)NSString *strID;
@property(nonatomic,strong)NSString *strName;//问卷名称
@property(nonatomic,strong)NSString *strDesc;//问卷描述
@property(nonatomic)NSInteger nSelectLimited;//多选回答上限
@property(nonatomic,strong)NSString *strState;//问卷状态 A: 草稿；B:发布；C:结束
//@property(nonatomic,strong)NSMutableArray *aryQuestion;//问题列表

@end
