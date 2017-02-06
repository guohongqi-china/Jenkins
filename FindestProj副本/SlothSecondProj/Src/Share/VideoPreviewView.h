//
//  VideoPreviewView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/8/20.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPreviewView : UIView

- (instancetype)initWithFrame:(CGRect)frame previewBlock:(void(^)(void))preview deleteBlock:(void(^)(void))delete;
- (void)setVideoFileURL:(NSURL *)urlVideo;
- (void)hideCloseButton;

@end
