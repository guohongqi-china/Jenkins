//
//  ChineseToPinyin.h
//  LianPu
//
//  Created by shawnlee on 10-12-16.
//  Copyright 2010 lianpu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ChineseToPinyin : NSObject

+ (NSString *) pinyinFromChiniseString:(NSString *)string;
+ (char) sortSectionTitle:(NSString *)string; 
//获取全拼和简拼（0：全拼，1：简拼）
+ (NSArray *)getQPAndJPFromChiniseString:(NSString *)string;

@end
