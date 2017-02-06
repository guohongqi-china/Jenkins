//
//  HotSearchCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagVo.h"

@class MainSearchViewController;
@interface HotSearchCell : UITableViewCell

@property (nonatomic,weak) MainSearchViewController *parentController;

- (void)setFirstData:(TagVo *)firstData second:(TagVo *)secondData;

@end
