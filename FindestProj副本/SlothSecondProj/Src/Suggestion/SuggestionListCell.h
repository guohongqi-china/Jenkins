//
//  SuggestionListCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/3/16.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuggestionVo.h"

@interface SuggestionListCell : UITableViewCell

@property(nonatomic,strong)UIView *viewBK;
@property(nonatomic,strong)UILabel *lblTitle;
@property(nonatomic,strong)UILabel *lblName;
@property(nonatomic,strong)UILabel *lblDepartment;
@property(nonatomic,strong)UILabel *lblContent;
@property(nonatomic,strong)UIView *viewLine;

@property(nonatomic,strong)UILabel *lblStatus;
@property(nonatomic,strong)UILabel *lblDate;




@property(nonatomic , strong)UIView *viewSelected;



- (void)initWithDataVo:(SuggestionVo*)suggestionVo;
+ (CGFloat)calculateCellHeight:(SuggestionVo*)suggestionVo;

@end
