

#import <UIKit/UIKit.h>

@class CDCircleThumb;
@interface CDCircleGestureRecognizer : UIGestureRecognizer
{
    NSDate *previousTouchDate;      //touchesMoved的开始时间，用于计算速度变化的动画（用于内部计算动画）
    double currentTransformAngle;   //touchesMoved设置开始值，touchesEnded减去该值，得到差值
}

@property (nonatomic) BOOL ended;   //滚动是否结束，touchesBegan设置为NO,touchesEnded设置为YES
@property (nonatomic) CGFloat rotation; //touchesMoved:时的旋转角度
@property (nonatomic, strong) CDCircleThumb *currentThumb;  //保存当前选择的格子

@end