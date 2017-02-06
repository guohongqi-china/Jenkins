//
//  TichetServise.h
//  NssmcWskProj
//
//  Created by MacBook on 16/6/2.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TichetServise : NSObject
+ (void)uploadSound:(NSString *)fileName body:(NSDictionary *)bodyDic numberOfTimer:(NSInteger )timer  result:(ResultBlock)resultBlock;//发送语音到服务器

+ (void)uploadImageToServer:(NSDictionary *)bodyDic imageData:(NSData *)imageData result:(ResultBlock)resultBlock;//发送图片到服务器

+ (void)sendRequest:(NSDictionary *)bodyDicty result:(ResultBlock)resultBlock;//网络请求
+ (void)sendRequest:(NSDictionary *)bodyDicty urlString:(NSString *)urlString requestStyle:(NSString *)requestStyle result:(ResultBlock)resultBlock;//网络请求

@end
