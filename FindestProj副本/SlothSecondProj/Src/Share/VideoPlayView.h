//
//  VideoPlayView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/24.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayView : UIView

@property(nonatomic,strong) NSURL * urlVideo;

+ (NSString *)getVideoPathByURL:(NSString *)strURL;

@end
