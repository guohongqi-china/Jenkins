//
//  BufferVideoFirstImage.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/8/22.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BufferVideoFirstImage : NSObject

//获取网络视频第一帧
+(void)getFirstFrameImageFromURL:(NSString*)strURL finished:(void(^)(UIImage *))blockFinished;

@end
