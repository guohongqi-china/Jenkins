//
//  PraiseModel.m
//  FindestProj
//
//  Created by MacBook on 16/7/18.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "PraiseModel.h"

@implementation PraiseModel
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
}
-(void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"ID"]) {
        _ID = value;
        return;
    }
    [super setValue:value forKey:key];
    
}

@end
