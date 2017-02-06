//
//  UIImageView+clickLike.m
//  TaoZhiHuiProj
//
//  Created by fujunzhi on 16/4/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "UIImageView+clickLike.h"

@implementation UIImageView (clickLike)
- (void)animationOfClickLikeWithUp:(BOOL)upOrDown
{
    NSMutableArray *images = [@[] mutableCopy];
    for (int i = (upOrDown ? 1 : 20); (upOrDown ? i <= 20 : i >= 1); (upOrDown ? i++ : i--)) {
        NSString *fileName = [NSString stringWithFormat:@"like-%d.png",i];
        NSLog(@"%@",fileName);
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:nil]];
        [images addObject:image];
    }
    UIImage *lastImage = [UIImage imageNamed:upOrDown ? @"like-20" : @"like-1"];
    [images addObject:lastImage];
    
    self.animationImages = images;
    self.userInteractionEnabled = YES;
    self.animationRepeatCount = 1;
    self.animationDuration = images.count * 0.05;
    [self startAnimating];
    
    //清理内存
    CGFloat delay = self.animationDuration + 1.0;
    [self performSelector:@selector(setAnimationImages:) withObject:nil afterDelay:delay];
    
}
@end
