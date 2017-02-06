//
//  HopeModel.m
//  NssmcWskProj
//
//  Created by MacBook on 16/6/28.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "HopeModel.h"

@implementation HopeModel
- (void)setValue:(id)value forKey:(NSString *)key{
//    if (value == nil) {
//        return;
//    }
//    if (![value isKindOfClass:[NSString class]]) {
//        value = [NSString stringWithFormat:@"%@",value];
//    }
    if ([@"typename" isEqualToString:value]) {
        _typename1 = value;
    }
    [super setValue:value forKeyPath:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
   
}
@end
