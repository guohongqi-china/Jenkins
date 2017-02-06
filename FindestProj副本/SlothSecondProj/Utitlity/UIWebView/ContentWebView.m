//
//  ContentWebView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/6/17.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "ContentWebView.h"

@implementation ContentWebView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.bScrolling = YES;
    [super scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
    __block ContentWebView* bself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        bself.bScrolling = NO;
    });
}

@end
