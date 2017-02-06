//
//  FaceModel.m
//  FindestProj
//
//  Created by MacBook on 16/7/20.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "FaceModel.h"

@implementation FaceModel
+ (FaceModel *)sharedManager
{
    static FaceModel *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}
- (void)setValue:(id)value forKey:(NSString *)key{
    [super setValue:value forKey:key];
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end
