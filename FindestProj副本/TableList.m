//
//  TableList.m
//  FindestProj
//
//  Created by MacBook on 16/7/13.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "TableList.h"

@implementation TableList
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
}
-(void)setValue:(id)value forKey:(NSString *)key{

    if ([key isEqualToString:@"content"]) {
        _content = [NSMutableArray array];
        NSLog(@"%@",[value class]);
        for (NSDictionary *mod in value) {
            ManListModel *mo = [[ManListModel alloc]init];
            [mo setValuesForKeysWithDictionary:mod];
            [_content addObject:mo];
        }
        return;
    }
    if (![value isKindOfClass:[NSString class]]) {
        value = [NSString stringWithFormat:@"%@",value];
    }
    [super setValue:value forKey:key];
    
}

@end
