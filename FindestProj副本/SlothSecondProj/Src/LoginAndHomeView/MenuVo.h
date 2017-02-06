//
//  MenuVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/30.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuVo : NSObject

@property (nonatomic, strong) NSString *strID;
@property (nonatomic, strong) NSString *strName;
@property (nonatomic, strong) NSString *strImageName;
@property (nonatomic, strong) NSString *strLinkClass;

@property (nonatomic, strong) NSString *strRemark;

@property (nonatomic) BOOL bSelected;//


@property (nonatomic) BOOL bBoolValue;

@end
