//
//  AnimationView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 4/14/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrokeLabel.h"

@interface RewardAnimationOldView : UIView

@property(nonatomic)double fIntegral;

@property(nonatomic,strong)UIImageView *imgViewTitle;

@property(nonatomic,strong)UIView *viewIntegral;
@property(nonatomic,strong)StrokeLabel *lblIntegral;
@property(nonatomic,strong)UIImageView *imgViewIcon;

@end
