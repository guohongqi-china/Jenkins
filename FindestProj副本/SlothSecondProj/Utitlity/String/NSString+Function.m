//
//  NSString+Function.m
//  QunBao
//
//  Created by fujunzhi on 16/1/13.
//  Copyright © 2016年 QunBao. All rights reserved.
//

#import "NSString+Function.h"

@implementation NSString (Function)


- (NSString *)trimLeftAndRightSpace
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
