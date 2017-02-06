//
//  AnimationView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 4/14/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "RewardAnimationOldView.h"
#import "UIViewExt.h"

@implementation RewardAnimationOldView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = COLOR(0, 0, 0, 0.3);
        
        CGFloat fWidth = 302/4;
        CGFloat fHeight = 64.5/4;
        
        self.imgViewTitle = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"integral_title"]];
        self.imgViewTitle.frame = CGRectMake((kScreenWidth-fWidth)/2, 150-(fHeight-64.5), fWidth, fHeight);
        [self addSubview:self.imgViewTitle];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.imgViewTitle.frame = CGRectMake((kScreenWidth-302)/2, 150, 302, 64.5);
            } completion:^(BOOL finished){
                self.viewIntegral = [[UIView alloc]initWithFrame:CGRectMake((kScreenWidth-320)/2, self.imgViewTitle.bottom+25, 320, 50)];
                [self addSubview:self.viewIntegral];
                
//                self.lblIntegral = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 50)];
//                self.lblIntegral.font = [UIFont boldSystemFontOfSize:50];
//                self.lblIntegral.textColor = [UIColor redColor];
//                self.lblIntegral.textAlignment = NSTextAlignmentCenter;
//                self.lblIntegral.backgroundColor = [UIColor clearColor];
//                self.lblIntegral.text = [NSString stringWithFormat:@"%i",self.nIntegral];
//                [self.viewIntegral addSubview:self.lblIntegral];
                
                //积分数量
                self.lblIntegral = [[StrokeLabel alloc]init];
                self.lblIntegral.textAlignment = NSTextAlignmentRight;
                self.lblIntegral.textColor = COLOR(255, 153, 54, 1.0);
                self.lblIntegral.font = [UIFont boldSystemFontOfSize:80];
                self.lblIntegral.backgroundColor = [UIColor clearColor];
                self.lblIntegral.lineBreakMode = NSLineBreakByWordWrapping;
                //描边效果
                self.lblIntegral.fStrokeLineWidth = 2.5;
                self.lblIntegral.colorStroke = [UIColor whiteColor];
                self.lblIntegral.text = [NSString stringWithFormat:@"%g",self.fIntegral];
                [self.viewIntegral addSubview:self.lblIntegral];
                CGSize size = [Common getStringSize:self.lblIntegral.text font:self.lblIntegral.font bound:CGSizeMake(MAXFLOAT, 80) lineBreakMode:NSLineBreakByWordWrapping];
                self.lblIntegral.frame = CGRectMake((self.viewIntegral.width-size.width)/2-30, 0, size.width, size.height);
                //self.lblIntegral.backgroundColor = [UIColor redColor];
                self.lblIntegral.rectStroke = CGRectMake(0, 0, self.lblIntegral.width, self.lblIntegral.height);
                
                //积分硬币图标
                self.imgViewIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"integral_icon"]];
                self.imgViewIcon.frame = CGRectMake(self.lblIntegral.right+10, 23.5+5, 50, 50);
                [self.viewIntegral addSubview:self.imgViewIcon];
                
                //设置缩放变化的动画
                self.viewIntegral.transform = CGAffineTransformMakeScale(4.0, 4.0);
                [UIView animateWithDuration:0.2 animations:^{
                    self.viewIntegral.transform = CGAffineTransformMakeScale(1.0, 1.0);
                } completion:^(BOOL finished){
                    
                    //设置抖动的动画效果
                    CGFloat t = 5;
                    CGAffineTransform translateRight  =CGAffineTransformTranslate(CGAffineTransformIdentity, 0,t);
                    CGAffineTransform translateLeft =CGAffineTransformTranslate(CGAffineTransformIdentity,0,-t);
                    
                    self.viewIntegral.transform = translateLeft;
                    
                    [UIView animateWithDuration:0.09 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
                        [UIView setAnimationRepeatCount:3];
                        self.viewIntegral.transform = translateRight;
                    } completion:nil];
                        
                }];
            }];
    }
    return self;
}

@end
