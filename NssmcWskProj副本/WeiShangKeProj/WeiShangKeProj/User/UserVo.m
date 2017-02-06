//
//  UserVo.m
//  Sloth
//
//  Created by Ann Yao on 12-9-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserVo.h"

@implementation UserCertPictureVo

@end

@implementation UserVo


- (void)setValue:(id)value forKey:(NSString *)key{
    if (![value isKindOfClass:[NSString class]]) {
        NSString *STR = [value stringValue];
        value = STR;
    }
    [super setValue:value forKey:key];
    
    if ([key isEqualToString:@"id"]) {
        _ID = value;
    }
    
    
    
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end
