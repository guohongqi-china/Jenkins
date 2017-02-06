/*
 Copyright (C) <2012> <Wojciech Czelalski/CzekalskiDev>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>
#import "CDCircle.h"
#import "CDCircleThumb.h"

//该View的主要功能是确定滚动停止后，停留在最近的Segment
//该View是放在MeetingDialView，始终不动,不能放在CDCircle，否则会随它一起滚动,该视图关联CDCircle view,包含了一个CDCircleThumb
@interface CDCircleOverlayView : UIView

@property (nonatomic, weak) CDCircle *circle;       //弱引用，否则循环引用
@property (nonatomic, assign) CGPoint controlPoint;
@property (nonatomic, assign) CGPoint buttonCenter;
@property (nonatomic, strong) CDCircleThumb *overlayThumb;

-(id) initWithCircle:(CDCircle *)cicle;

@end
