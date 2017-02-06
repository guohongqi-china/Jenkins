//
//  RewardAnimationView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/23.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "RewardAnimationView.h"
#import "UIViewExt.h"

@interface RewardAnimationView ()
{
    double fIntegral;
    double fSumIntegral;
    
    UIView *viewContainer;
    UILabel *lblAddIntegral;
    UILabel *lblSumIntegral;
    UIProgressView *progressView;
    UIImageView *imgViewCurrLevel;
    UIImageView *imgViewNextLevel;
}

@end

@implementation RewardAnimationView

- (id)initWithFrame:(CGRect)frame integral:(double)fAddIntegral total:(double)fTotalIntegral
{
    self = [super initWithFrame:frame];
    if (self)
    {
        fIntegral = fAddIntegral;
        fSumIntegral = fTotalIntegral;
        
        viewContainer = [[UIView alloc]initWithFrame:CGRectMake((kScreenWidth-155)/2, (kScreenHeight-112)/2, 155, 112)];
        viewContainer.backgroundColor = COLOR(0, 0, 0, 0.8);
        viewContainer.layer.cornerRadius = 5;
        viewContainer.layer.masksToBounds = YES;
        [self addSubview:viewContainer];
        
        lblAddIntegral = [[UILabel alloc]initWithFrame:CGRectMake(0, 14, viewContainer.width, 20)];
        lblAddIntegral.font = [Common fontWithName:@"PingFangSC-Light" size:14];
        lblAddIntegral.textAlignment = NSTextAlignmentCenter;
        [viewContainer addSubview:lblAddIntegral];
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"积分  +%g",fIntegral]];
        [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, 2)];
        [attriString addAttribute:NSForegroundColorAttributeName value:COLOR(239, 111, 88, 1.0) range:NSMakeRange(2, attriString.length-2)];
        lblAddIntegral.attributedText = attriString;
        
        //当前积分图标 和 下一等级积分图标、进度条
        IntegralInfoVo *integralLast = [BusinessCommon getIntegralInfo:fSumIntegral];
        imgViewCurrLevel = [[UIImageView alloc]initWithFrame:CGRectMake(14, 41, 30, 30)];
        imgViewCurrLevel.contentMode = UIViewContentModeScaleAspectFit;
        imgViewCurrLevel.image = [UIImage imageNamed: integralLast.strLevelImage];
        imgViewCurrLevel.layer.cornerRadius = 15;
        imgViewCurrLevel.layer.masksToBounds = YES;
        imgViewCurrLevel.backgroundColor = COLOR(255, 255, 255, 0.7);
        [viewContainer addSubview:imgViewCurrLevel];
        
        progressView = [[UIProgressView alloc]initWithFrame:CGRectMake((viewContainer.width-61)/2, 54, 61, 4)];
        progressView.layer.cornerRadius = 2;
        progressView.layer.masksToBounds = YES;
        progressView.progressTintColor = COLOR(239, 111, 88, 1.0);      //进度条颜色
        progressView.trackTintColor = COLOR(221, 208, 204, 1.0);	//背景颜色
        progressView.transform = CGAffineTransformMakeScale(1, 2);
        progressView.progress = (fSumIntegral-integralLast.fMinIntegral)/(integralLast.fMaxIntegral-integralLast.fMinIntegral);
        [viewContainer addSubview:progressView];
        
        IntegralInfoVo *integralNext = [BusinessCommon getIntegralInfo:integralLast.fMaxIntegral];
        imgViewNextLevel = [[UIImageView alloc]initWithFrame:CGRectMake(viewContainer.width-44, 41, 30, 30)];
        imgViewNextLevel.contentMode = UIViewContentModeScaleAspectFit;
        imgViewNextLevel.image = [UIImage imageNamed: integralNext.strLevelImage];
        imgViewNextLevel.layer.cornerRadius = 15;
        imgViewNextLevel.layer.masksToBounds = YES;
        imgViewNextLevel.backgroundColor = COLOR(255, 255, 255, 0.7);
        [viewContainer addSubview:imgViewNextLevel];
        
        //共 积分
        lblSumIntegral = [[UILabel alloc]initWithFrame:CGRectMake(0, viewContainer.height-34, viewContainer.width, 20)];
        lblSumIntegral.font = [UIFont systemFontOfSize:14];
        lblSumIntegral.textAlignment = NSTextAlignmentCenter;
        [viewContainer addSubview:lblSumIntegral];
        NSMutableAttributedString *attriStringSum = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"共 %g 积分",fIntegral]];
        [attriStringSum addAttribute:NSForegroundColorAttributeName value:COLOR(221, 208, 204, 1.0) range:NSMakeRange(0, 1)];
        [attriStringSum addAttribute:NSForegroundColorAttributeName value:COLOR(239, 111, 88, 1.0) range:NSMakeRange(1, attriString.length-3)];
        [attriStringSum addAttribute:NSForegroundColorAttributeName value:COLOR(221, 208, 204, 1.0) range:NSMakeRange(attriString.length-2, 2)];
        lblSumIntegral.attributedText = attriStringSum;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackground)];
        [self addGestureRecognizer:tapGesture];
    }
    
    return self;
}

- (void)tapBackground
{
    [self closeRewardView];
}

- (void)closeRewardView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
