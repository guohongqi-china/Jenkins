//
//  CustomerVo.m
//  WeiShangKeProj
//
//  Created by 焱 孙 on 4/29/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "CustomerVo.h"

@implementation CustomerVo
- (void)setValue:(id)value forKey:(NSString *)key{
    if (key == NULL) {
        return;
    }
    if ([key isEqualToString:@"id"]) {
        _ID = [value stringValue];
    }
    [super setValue:value forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
@end
