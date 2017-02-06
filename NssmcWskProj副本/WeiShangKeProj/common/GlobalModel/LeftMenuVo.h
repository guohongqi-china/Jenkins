//
//  LeftMenuVo.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-14.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeftMenuVo : NSObject

@property(nonatomic,strong) NSString *strMenuID;
@property(nonatomic,strong) NSString *strName;
@property(nonatomic,strong) NSString *strImageName;
@property(nonatomic,strong) NSString *strKey;//国际化存储的Key
@property(nonatomic,strong) NSNumber *numNotice;
@property(nonatomic) BOOL bNotice;//是否为通知（通知则显示提醒数量）

@end
