//
//  timeModel.m
//  NssmcWskProj
//
//  Created by MacBook on 16/6/28.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "timeModel.h"

@implementation timeModel
- (void)setValue:(id)value forKey:(NSString *)key{
    [super setValue:value forKey:key];
    if ([key isEqualToString:@"typename"]) {
        _typename1 = value;
    }
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
@end
