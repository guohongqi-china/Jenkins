//
//  cengView.m
//  FindestProj
//
//  Created by MacBook on 16/7/22.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "cengView.h"

@implementation cengView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"cengViwe" object:nil];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
