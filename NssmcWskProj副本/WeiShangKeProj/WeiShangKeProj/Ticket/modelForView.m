//
//  modelForView.m
//  NssmcWskProj
//
//  Created by MacBook on 16/5/23.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "modelForView.h"

@implementation modelForView
- (void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"timeString"]) {
        _timeString = value;
        return;
    }
    if ([key isEqualToString:@"contentString"]) {
        _contentString = value;
        return;
    }

}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
@end
