//
//  topModel.m
//  NssmcWskProj
//
//  Created by MacBook on 16/5/24.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "topModel.h"

@implementation topModel
- (void)setValue:(id)value forKey:(NSString *)key{
    if (value == nil) {
        return;
    }
    [super setValue:value forKey:key];
    if ([key isEqualToString:@"classification"]) {
        _classification = value;
        NSLog(@"%@",_classification);
    }
    if ([key isEqualToString:@"titleContent"]) {
        _titleContent = value;
    }
    if ([key isEqualToString:@"orderTime"]) {
        _orderTime = [NSString stringWithFormat:@"%@",value];
    }
    if ([key isEqualToString:@"updateTime"]) {
        _updateTime = [NSString stringWithFormat:@"%@",value];
    }
    if ([key isEqualToString:@"confirmTime"]) {
        _confirmTime = [NSString stringWithFormat:@"%@",value];
    }
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
- (BOOL)isEqual:(id)object{
    if (self == object) {
        return YES;
    }
        return NO;
}

@end
