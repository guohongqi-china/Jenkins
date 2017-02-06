//
//  Model.m
//  FindestProj
//
//  Created by MacBook on 16/7/13.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "Model.h"

@implementation Model
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
}
-(void)setValue:(id)value forKey:(NSString *)key{
    if (![value isKindOfClass:[NSString class]]) {
        value = [NSString stringWithFormat:@"%@",value];
    }
    if ([key isEqualToString:@"id"]) {
        _ID = value;
        return;
    }
    [super setValue:value forKey:key];
    
}
@end
