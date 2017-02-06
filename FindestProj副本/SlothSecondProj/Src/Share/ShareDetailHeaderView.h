//
//  ShareDetailHeaderView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/6.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareDetailViewController;
@interface ShareDetailHeaderView : UIView

@property (nonatomic, weak)ShareDetailViewController *parentController;

- (instancetype)initWithFrame:(CGRect)frame parent:(ShareDetailViewController*)controller;
- (void)refreshView:(BlogVo *)blogVo;

@end
