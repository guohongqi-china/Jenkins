//
//  SettingViewCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/25.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuVo.h"

@protocol SettingViewDelegate <NSObject>

@optional
- (void)switchControlChanged:(MenuVo *)entity state:(BOOL)bOn;

@end

@interface SettingViewCell : UITableViewCell

@property (nonatomic, weak) id<SettingViewDelegate> delegate;
@property (nonatomic, strong) MenuVo *entity;

@end
