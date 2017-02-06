//
//  CommentListCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/6.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentVo.h"
@class CommentListCell;

@protocol CommentCellDelegate <NSObject>
@optional
- (void)praiseComment:(CommentVo*)commentVo;
- (void)commentCell:(CommentListCell *)commentListCell iconClick:(CommentVo *)commentVo;
@end

@interface CommentListCell : UITableViewCell

@property(nonatomic,weak)id<CommentCellDelegate> delegate;

@property (nonatomic, strong) CommentVo *entity;

@end
