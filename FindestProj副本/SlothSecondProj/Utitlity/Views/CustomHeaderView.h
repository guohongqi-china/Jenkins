//
//  CustomHeaderView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 4/15/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewExt.h"
#import "UserVo.h"

//头像边框
#define HEADER_RATE_BIG 10        //大边框比例
#define HEADER_RATE_MID 18      //中边框比例

@protocol CustomHeaderViewDelegate;

@interface CustomHeaderView : UIView

@property(nonatomic,strong) UserVo *m_userVo;
@property(nonatomic) CGFloat fRate;
@property(nonatomic,strong) NSString *strSuffix;
@property(nonatomic,weak)id<CustomHeaderViewDelegate> delegate;

@property(nonatomic,strong) UIImageView *imgViewHeadBK;
@property(nonatomic,strong) UIImageView *imgViewHead;
@property(nonatomic,strong) UIImageView *imgViewBadge;

@property(nonatomic) NSInteger nSizeType;//1：大，2：小

- (id)initWithRate:(CGFloat)fRate andSuffix:(NSString*)strSuffix;
- (void)refreshView:(UserVo*)userVo andFrame:(CGRect)rect;

@end

@protocol CustomHeaderViewDelegate<NSObject>
@optional
- (void)tapHeaderViewAction:(CustomHeaderView*)headerView;

@end