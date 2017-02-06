//
//  TicketVo.m
//  WeiShangKeProj
//
//  Created by 焱 孙 on 15/5/29.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "TicketVo.h"

@implementation TicketVo

- (void)setValue:(id)value forKey:(NSString *)key{
    if (value == nil) {
        return;
    }
    [super setValue:value forKey:key];
//    if ([key isEqualToString:@"classification"]) {
////        if ([value isEqualToString:@"HardWare"]) {
////            _classification = @"硬件";
////        }
////        if ([value isEqualToString:@"SoftWare"]) {
////            _classification = @"软件";
////        }
//        _classification = value;
//        
//    }
    if ([key isEqualToString:@"confirmTime"]) {
        _confirmTime = [NSString stringWithFormat:@"%@",value];
    }
    if ([key isEqualToString:@"applyTime"]) {
        _applyTime = [NSString stringWithFormat:@"%@",value];
    }
    if ([key isEqualToString:@"orderTime"]) {
        _orderTime = [NSString stringWithFormat:@"%@",value];
    }
    if ([key isEqualToString:@"hopeTime"]) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSDictionary *dic in value) {
            timeModel *model = [[timeModel alloc]init];
            [model setValuesForKeysWithDictionary:dic];
            [arr addObject:model];
        }
        _hopeTime = arr;
    }
}

//- (void)setHopeTime:(NSMutableArray *)hopeTime{
//    if (_hopeTime != hopeTime) {
//        NSMutableArray *arr = [NSMutableArray array];
//        for (NSDictionary *dic in hopeTime) {
//            HopeModel *model = [[HopeModel alloc]init];
//            [model setValuesForKeysWithDictionary:dic];
//            [arr addObject:model];
//        }
//        _hopeTime = arr;
//    }
//}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
@end
