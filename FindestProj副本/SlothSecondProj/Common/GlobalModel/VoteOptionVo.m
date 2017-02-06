//
//  VoteOptionVo.m
//  Sloth
//
//  Created by 焱 孙 on 12-12-27.
//
//

#import "VoteOptionVo.h"

@implementation VoteOptionVo

-(id)init
{
    self = [super init];
    if (self) 
    {
        _strOptionName = @"";
        _nCount = 0;
        _nOptionId = 0;
        _nSelected = 0;
        _bExpansion = NO;
    }
    return self;
}

@end
