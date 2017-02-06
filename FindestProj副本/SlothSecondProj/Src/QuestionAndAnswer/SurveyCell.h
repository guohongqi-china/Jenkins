//
//  SurveyCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 11/28/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionVo.h"

@interface SurveyCell : UITableViewCell

@property(nonatomic,strong)UIImageView *imgViewCheck;
@property(nonatomic,strong)UILabel *lblOptionDesc;

@property(nonatomic,strong)QOptionVo *m_qOptionVo;
@property(nonatomic)NSInteger m_nMultiple;
@property(nonatomic)BOOL bAssociation;//是否与上一题答案关联（上一题是关联题目并且上一题选择的答案ID与本答案一样）

- (void)initWithData:(QOptionVo*)qOptionVo andLastQ:(QuestionVo*)questionLast andMultiple:(NSInteger)nMultiple;
+ (CGFloat)calculateCellHeight:(QOptionVo*)qOptionVo;
-(void)updateCheckImage;

@end
