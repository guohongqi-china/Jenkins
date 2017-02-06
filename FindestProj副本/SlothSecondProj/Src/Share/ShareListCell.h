//
//  ShareListCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/4.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlogVo.h"
@class CommonHeaderView;

@protocol ShareListCellDelegate <NSObject>

- (void)shareListCellAction:(NSInteger)nType data:(BlogVo *)blogVo;

@end

@interface ShareListCell : UITableViewCell

@property (nonatomic, weak) id<ShareListCellDelegate> delegate;

- (void)setEntity:(BlogVo *)blogVo;
- (void)setEntity:(BlogVo *)blogVo controller:(UIViewController *)controller;
@property (strong, nonatomic) CommonHeaderView *headerView;

@end
