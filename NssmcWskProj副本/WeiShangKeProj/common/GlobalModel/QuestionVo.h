//
//  QuestionVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 11/28/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

//问卷调查的问题VO
@interface QuestionVo : NSObject

@property(nonatomic,strong)NSString *strID;
@property(nonatomic,strong)NSString *strName;//题目名
@property(nonatomic,strong)NSString *strDesc;//题目说明
@property(nonatomic,strong)NSMutableArray *aryOption;//选项列表
@property(nonatomic)NSInteger nMultiple;//单选多选 (0:单选；1:多选)
@property(nonatomic)NSInteger nAssociation;//与下一题答案不可出现重复	0:否；1:是

@end

//答题项
@interface QOptionVo : NSObject

@property(nonatomic,strong)NSString *strID;     //选项ID
@property(nonatomic,strong)NSString *strName;   //选项名字
@property(nonatomic)BOOL bChecked;//是否选择该项了

@end