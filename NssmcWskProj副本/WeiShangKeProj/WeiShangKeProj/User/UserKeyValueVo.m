//
//  UserKeyValueVo.m
//  NssmcWskProj
//
//  Created by 焱 孙 on 15/12/9.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "UserKeyValueVo.h"

@implementation UserKeyValueVo

- (instancetype)initWithKey:(NSString*)strKey title:(NSString *)strTitle
{
    self  = [super init];
    if (self)
    {
        _strKey = strKey;
        _strTitle = strTitle;
    }
    return self;
}

@end
