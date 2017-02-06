//
//  NotifyListCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/22.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotifyVo.h"
#import "MGSwipeTableCell.h"

@interface NotifyListCell : MGSwipeTableCell

@property (nonatomic) NSInteger nNotifyMainType;
@property (nonatomic,strong) NotifyVo *notifyVo;

- (void)setEntity:(NotifyVo *)entity;

@end
