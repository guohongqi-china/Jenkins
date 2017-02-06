//
//  NSString+Extension.h
//  NssmcWskProj
//
//  Created by MacBook on 16/12/5.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

/** 判断字符串是否为空 */
- (BOOL)isNullToString:(id)string;

//是否整形数
- (BOOL)isPureInt;

//浮点形判断：
- (BOOL)isPureFloat;
    
@end
