//
//  IntegralInfoVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IntegralInfoVo : NSObject

@property (nonatomic) double fMinIntegral;
@property (nonatomic) double fMaxIntegral;
@property (nonatomic,strong) NSString *strLevelName;
@property (nonatomic,strong) NSString *strLevelImage;
@property (nonatomic) BOOL bTopLevel;       //是否为最大等级了

@end
