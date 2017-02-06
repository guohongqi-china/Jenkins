//
//  DrawLotteryView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-5-6.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawLotteryView : UIView

@property(nonatomic,strong)UIImageView *imgViewLotteryBK;
@property(nonatomic,strong)UIImageView *imgViewLotteryPoint;

@property(nonatomic)CGFloat fRandom;
@property(nonatomic)CGFloat fOrign;

- (void)drawLotteryAction;

@end
