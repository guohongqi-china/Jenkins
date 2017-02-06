//
//  DrawLotteryView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-5-6.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "DrawLotteryView.h"

@implementation DrawLotteryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
    }
    return self;
}

-(void)initView
{
    self.backgroundColor = [UIColor clearColor];
    
    //添加转盘
    self.imgViewLotteryBK = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lottery_disk"]];
    self.imgViewLotteryBK.frame = CGRectMake(0.0, 0.0, 320.0, 320.0);
    [self addSubview:self.imgViewLotteryBK];
    
    //添加转针
    self.imgViewLotteryPoint = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"start"]];
    self.imgViewLotteryPoint.frame = CGRectMake(185/2+2, 185/2, 135, 135);
    [self addSubview:self.imgViewLotteryPoint];
}

- (void)drawLotteryAction
{
    //设置动画
    CABasicAnimation *spin = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [spin setFromValue:[NSNumber numberWithFloat:M_PI * 0.0]];
    [spin setToValue:[NSNumber numberWithFloat:M_PI * 450.0]];
    [spin setDuration:100.0];
    [spin setDelegate:self];//设置代理，可以相应animationDidStop:finished:函数，用以弹出提醒框
    //动画过渡策略
    [spin setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];//线形匀速
    //添加动画
    [[self.imgViewLotteryPoint layer] addAnimation:spin forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
//    //判断抽奖结果
}

@end
