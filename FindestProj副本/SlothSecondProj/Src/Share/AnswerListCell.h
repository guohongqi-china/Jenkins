//
//  AnswerListCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/3.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlogVo.h"

@protocol AnswerCellDelegate <NSObject>
@optional
- (void)praiseAnswer:(BlogVo*)answerVo;
@end

@interface AnswerListCell : UITableViewCell

@property(nonatomic,weak)id<AnswerCellDelegate> delegate;

@property (nonatomic,strong) BlogVo *entity;

@end
