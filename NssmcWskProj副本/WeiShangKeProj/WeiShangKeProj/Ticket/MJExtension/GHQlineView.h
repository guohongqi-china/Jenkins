//
//  GHQlineView.h
//  Quartz2D
//
//  Created by MacBook on 16/4/10.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GHQlineView : UIView
{
    CGFloat mainW;
}

@property (nonatomic, strong) UILabel *label;/** <#注释#> */

@property (nonatomic, assign) CGFloat progress;/** <#注释#> */

@property (nonatomic, assign) NSInteger lineWidth;/** 线宽 */

- (void)setProgress:(CGFloat)progress;
@end
