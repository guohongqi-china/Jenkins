//
//  GrayView.m
//  NssmcWskProj
//
//  Created by MacBook on 16/5/27.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "GrayView.h"
#import "addAlertView.h"
@implementation GrayView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = COLOR(40, 40, 40, 0.5);
    }
    return self;
}
+ (instancetype )Stutedent{
    return [[self alloc]init];
}
/**
 *  显示
 */
- (void)showFrom:(UIView *)from
{
    NSArray *VIEWarray = [[NSBundle mainBundle]loadNibNamed:@"addAlertView" owner:nil options:nil];
    addAlertView *alertViewll = [VIEWarray lastObject];
    
    // 1.获得最上面的窗口
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    
    // 2.添加自己到窗口上
    [window addSubview:self];
    [window addSubview:alertViewll];
    _addLERT = alertViewll;
    _baseWindow = window;
    // 3.设置尺寸
    self.frame = window.bounds;
    
    // 4.调整灰色图片的位置
    // 默认情况下，frame是以父控件左上角为坐标原点
    // 转换坐标系
    CGRect newFrame = [from convertRect:from.frame toView:window];

    alertViewll.y = CGRectGetMaxY(newFrame);
    alertViewll.width = kScreenWidth;

    [UIView animateWithDuration:0.5 animations:^{
            alertViewll.y = kScreenHeight - alertViewll.height;
            
    } completion:nil];
    
    // 通知外界，自己显示了
    if ([self.delegate respondsToSelector:@selector(dropdownMenuDidShow:)]) {
        [self.delegate dropdownMenuDidShow:self];
    }
}
/**
 *  销毁
 */
- (void)dismiss
{
    [_addLERT removeFromSuperview];
    [self removeFromSuperview];
    [_baseWindow removeFromSuperview];
    
    // 通知外界，自己被销毁了
    if ([self.delegate respondsToSelector:@selector(dropdownMenuDidDismiss:)]) {
        [self.delegate dropdownMenuDidDismiss:self];
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dismiss];
}

@end
