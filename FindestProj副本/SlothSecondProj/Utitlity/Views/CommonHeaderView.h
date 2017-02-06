//
//  CommonHeaderView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/23.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExt.h"
#import "UserVo.h"

@protocol CommonHeaderViewDelegate;

@interface CommonHeaderView : UIView

@property(nonatomic,weak)id<CommonHeaderViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame canTap:(BOOL)bTap parent:(UIViewController *)parentController;
- (void)refreshViewWithImage:(NSString*)strImageURL userID:(NSString *)strUserID;

@end

@protocol CommonHeaderViewDelegate<NSObject>

@optional
- (void)tapHeaderViewAction:(CommonHeaderView*)headerView;

@end