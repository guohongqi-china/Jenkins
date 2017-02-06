//
//  TBModel.m
//  FindestProj
//
//  Created by MacBook on 16/7/13.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "TBModel.h"

@implementation TBModel

- (void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"content"]) {
        _content = [NSMutableArray array];
        for (id mod in value) {
            Model *mo = [[Model alloc]init];
            [mo setValuesForKeysWithDictionary:mod];
            [_content addObject:mo];
        }
        return;
    }
    [super setValue:value forKey:key];
    
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
@end
