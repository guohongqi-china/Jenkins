//
//  TheCountdownButton.m
//  倒计时
//
//  Created by MacBook on 16/7/29.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "TheCountdownButton.h"
@interface TheCountdownButton ()
{
    UILabel *numberLabel;
    NSTimer *timer;
    NSInteger i ;
    NSString *titleString;
    NSInteger tag;
}
@end
@implementation TheCountdownButton

- (instancetype)initWithFrame:(CGRect)frame timeCount:(NSInteger)timeCount title:(NSString *)buttonTitle target:(id)target action:(SEL)action actionBlock:(TheCountdownButtonBlock)block{
    if (self = [super initWithFrame:frame]) {
        
        self.block = block;
        [self addTarget:target action:action forControlEvents:(UIControlEventTouchUpInside)];
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        timer.fireDate = [NSDate distantFuture];
        i = timeCount;
        tag = timeCount;
        [self setTitle:buttonTitle forState:(UIControlStateNormal)];
        titleString = buttonTitle;
    }
    return self;
}
/**
 * 定时器方法
 */
- (void)timerAction{
    i --;
    [self setTitle:[NSString stringWithFormat:@"%ld S",(long)i] forState:(UIControlStateNormal)];
    //当button的值为0的时候执行操作
    if (i == 0) {
        self.enabled = YES;
        timer.fireDate = [NSDate distantFuture];//计时器停止计时
        i = tag;
        [self setTitle:titleString forState:(UIControlStateNormal)];
        if (self.block != nil) {
            self.block();//计时器停止时执行的操作
        }

    }
}
/**
 *  判断button选中状态的方法
 */
- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        //计时器开始计时
        timer.fireDate = [NSDate distantPast];
        self.enabled = NO;

    }
}
- (void)dealloc{
    [timer invalidate];
    timer = nil;
}


@end
