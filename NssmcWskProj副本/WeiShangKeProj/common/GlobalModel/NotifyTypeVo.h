//
//  NotifyTypeVo.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-25.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotifyTypeVo : NSObject

@property (nonatomic) NotifyMainType notifyMainType;    //提醒分类ID
@property (nonatomic, strong) NSString *strNotifyTypeName;      //提醒分类名称
@property (nonatomic, strong) NSString *strNotifyNum;           //提醒的数量

@end
