//
//  UserEditVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/6.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserEditVo : NSObject

@property (nonatomic, strong) NSString *strTitle;
@property (nonatomic, strong) NSString *strKey;
@property (nonatomic, strong) NSString *strValueID;
@property (nonatomic, strong) NSString *strValue;

@property (nonatomic) NSInteger nMaxLength; //最多字数
@property (nonatomic) BOOL bRequired;//

@end
