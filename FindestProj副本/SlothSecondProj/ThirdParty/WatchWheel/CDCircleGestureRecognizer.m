
//注：
//1.该属性的设置仅仅被子类设置
//self.state = UIGestureRecognizerStateBegan
// readonly for users of a gesture recognizer. may only be changed by direct subclasses of UIGestureRecognizer

#define deceleration_multiplier 30.0f   //减速度(等同于加速度的相反)

#import "CDCircleGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "CDCircle.h"
#import "CDCircleThumb.h"
#import "CDCircleOverlayView.h"
#import "MeetingDialView.h"

@implementation CDCircleGestureRecognizer

//touch开始时
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CDCircle *viewCircle = (CDCircle *)(self.view);
    UITouch *touch = [touches anyObject];   //该方法将返回一个集合方便的值，不担保是随机的
    CGPoint point = [touch locationInView:viewCircle];
    
    //1.当超过一个手指滑动表盘，则无效
    //2.当在内圆path(UIBezierPath)滑动表盘，则无效
    if ([event touchesForGestureRecognizer:self].count > 1 || [viewCircle.path containsPoint:point])
    {
        self.state = UIGestureRecognizerStateFailed;
    }
    self.ended = NO;
}

//touch进行时(如果手指一直在滑动，则该方法一直响应，不会执行touchesEnded，直到结束)
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //UIGestureRecognizerStatePossible：the recognizer(识别器) has not yet(尚未) recognized its gesture,
    //but may be evaluating touch events. this is the default state
    if(self.state == UIGestureRecognizerStatePossible)
    {
        self.state = UIGestureRecognizerStateBegan;
    }
    else
    {
        self.state = UIGestureRecognizerStateChanged;
    }
    
    //We can look at any touch object since we know we have only 1.
    //If there were more than 1 then touchesBegan:withEvent: would have failed the recognizer.
    UITouch *touch = [touches anyObject];
    
    //To rotate with one finger, we simulate a second finger.
    //The second finger is on the opposite side of the virtual circle that represents the rotation gesture.
    CDCircle *viewCircle = (CDCircle *)(self.view);
    
    CGPoint center = CGPointMake(CGRectGetMidX(viewCircle.bounds), CGRectGetMidY(viewCircle.bounds));   //中心点
    CGPoint currentTouchPoint = [touch locationInView:viewCircle];              //当前触摸点
    CGPoint previousTouchPoint = [touch previousLocationInView:viewCircle];     //之前的触摸点(该方法记录了前一个坐标值)
    
    //设置触摸时间
    previousTouchDate = [NSDate date];
    
    //求得当前触摸与之前触摸之间的夹角
    //atan2f:反正切函数，根据斜率求得角度（根据当前点与中心点形成的角度），通过当前的角度减去之前的角度获得旋转的角度
    self.rotation = atan2f(currentTouchPoint.y-center.y, currentTouchPoint.x-center.x)-atan2f(previousTouchPoint.y-center.y, previousTouchPoint.x-center.x);
    
    //当前放射变换的角度
    currentTransformAngle = atan2f(viewCircle.transform.b, viewCircle.transform.a);
}

//touch结束时（一次touch事件，只执行一次touchesEnded）
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Perform final check to make sure a tap was not misinterpreted(误解、误判断).
    if(self.state == UIGestureRecognizerStateChanged)
    {
        self.state = UIGestureRecognizerStateEnded;
        self.ended = YES;   //设置为YES后，CDCircle的后面减速滚动由touchesEnded接管，不再被MeetingDialView的didRotateAngle控制
        
        CDCircle *viewCircle = (CDCircle *)(self.view);
        MeetingDialView *dialView = (MeetingDialView *)viewCircle.delegate;
        CGFloat flipintime = 0;     //减速的时间（速度从V0到0的时间）
        CGFloat angle = 0;          //整个减速到0过程中 - 旋转的角度
        
        //检查CDCircle是否需要惯性效果
        if (viewCircle.inertiaeffect)
        {
            //计算触摸后的最后一次角速度【然后根据此时的角速度，计算当速度通过加速度(-a),减速到0所经过的时间(flipintime)和角度(angle)】
            CGFloat angleInRaians = atan2f(viewCircle.transform.b, viewCircle.transform.a) - currentTransformAngle;
            double time = [[NSDate date] timeIntervalSinceDate:previousTouchDate];  //计算时间差
            double velocity = angleInRaians/time;   //[və'lɒsəti]角速度(角度差除以时间)
            CGFloat a = deceleration_multiplier;    //加速度（不过a<0）
            
            //加速度公式 V1=V0+at,s=V0*t+1/2*(a*t²)
            //由于是加速度是负的，V0:初始化速度，V1:终止速度（V1==0），a:加速度（a<0），所以两个公式转换如下(下面公式a转换为正值)：
            //0=V0-at,t=V0/a;s=V0*t-1/2*(a*t²);
            flipintime = fabs(velocity)/a;  //1.求得时间
            angle = velocity*flipintime - (a*flipintime*flipintime/2);  //2.求得旋转角度
            
            //当通过加速度计算angle角度范围在 大于π/2，小于-π/2时，给定一个极限值【M_PI/2.1=1.496】
            if (angle>M_PI/2 || angle<-1*M_PI/2)
            {
                if(angle < 0)
                {
                    angle = -1 * M_PI/2.1f;
                }
                else
                {
                    angle = M_PI/2.1f;
                }
                
                //根据新的路程angle,速度velocity,加速度a,由公式0=V0-at;s=V0*t-1/2*(a*t²);推导t=2s/V0
                flipintime = 2*fabs(angle)/velocity;
            }
            
            //把滚动角度angle限定在有效范围内（不能进行会议预订的区域禁止滚动）
            if(angle > 0)
            {
                //表盘顺时针转动
                CGFloat fMaxAngle = [viewCircle getCouldRotateMaxAngle:YES];
                
                //TODO:惯性angle
//                CGFloat fInertiaAngle = angle;
                
                if (angle > fMaxAngle)
                {
                    angle = fMaxAngle-degreesToRadians(5);  //5°，为了下面滚动到指定0°
                    flipintime = 2*fabs(angle)/velocity;
                }
//                NSLog(@"惯性:%g, 允许最大滚动:%g, 实际滚动:%g",fInertiaAngle*180/M_PI,fMaxAngle*180/M_PI,angle*180/M_PI);
            }
            else
            {
                //表盘逆时针转动
                CGFloat fMaxAngle = [viewCircle getCouldRotateMaxAngle:NO];
                
                //TODO:惯性angle
                //CGFloat fInertiaAngle = angle;
                
                if (angle < fMaxAngle)
                {
                    angle = fMaxAngle+degreesToRadians(5);
                    flipintime = 2*fabs(angle)/velocity;
                }
//                NSLog(@"惯性:%g, 允许最大滚动:%g, 实际滚动:%g",fInertiaAngle*180/M_PI,fMaxAngle*180/M_PI,angle*180/M_PI);
            }
        }
        
        [UIView animateWithDuration:flipintime delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            //使用动画把CDCircle旋转angle角度
            [viewCircle setTransform:CGAffineTransformRotate(viewCircle.transform, angle)];
            [dialView drawOutCircle];
            
        } completion:^(BOOL finished) {
            //循环所有的segment,如果哪个segment停留在overlayView的CDCircleThumb上面，则让表盘最终停止时滚动到这个segment的中心
            for (CDCircleThumb *thumb in viewCircle.thumbs)
            {
                CGPoint point = [thumb convertPoint:thumb.centerPoint toView:nil];  //转为相对于窗口的坐标
                CDCircleThumb *shadow = viewCircle.overlayView.overlayThumb;
                CGRect showRect = [shadow.superview convertRect:shadow.frame toView:nil];   //转为相对于窗口的Rect
                
                //判断两次,1.CGRectContainsPoint,2.CGPathContainsPoint
                if (CGRectContainsPoint(showRect, point))
                {
                    CGPoint pointInShadowRect = [thumb convertPoint:thumb.centerPoint toView:shadow];
                    if (CGPathContainsPoint(shadow.arc.CGPath, NULL, pointInShadowRect, NULL))
                    {
                        CGFloat deltaAngle = -M_PI + atan2(viewCircle.transform.a, viewCircle.transform.b) + atan2(thumb.transform.a, thumb.transform.b);
                        [UIView animateWithDuration:0.2f animations:^{
                            
//                            CGFloat fCurrAngle = [viewCircle getCircleCurrentAngle:viewCircle.transformInitValue];
//                            NSLog(@"deltaAngleTemp:%g deltaAngle:%g 吸附前角度:%g",deltaAngle*180/M_PI,deltaAngle*180/M_PI,fCurrAngle*180/M_PI);
                            [viewCircle setTransform:CGAffineTransformRotate(viewCircle.transform, deltaAngle)];
                            [dialView drawOutCircle];
                            
                        } completion:^(BOOL finished) {
                            //TODO:
//                            CGFloat fCurrAngle = [viewCircle getCircleCurrentAngle:viewCircle.transformInitValue];
//                            NSLog(@"deltaAngleTemp:%g deltaAngle:%g 吸附后角度:%g",deltaAngle*180/M_PI,deltaAngle*180/M_PI,fCurrAngle*180/M_PI);
                            
                            //选中新的thumbView
                            [self.currentThumb.iconView setIsSelected:NO];
                            [thumb.iconView setIsSelected:YES];
                            self.currentThumb = thumb;
                            
                            //delegate method
                            [viewCircle.delegate circle:viewCircle didMoveToSegment:thumb.tag thumb:thumb];
                        } ];
                        
                        break;
                    }
                }
            }
        }];
        
        currentTransformAngle = 0;
    }
}

//touch取消时
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setState:UIGestureRecognizerStateFailed];
}

@end