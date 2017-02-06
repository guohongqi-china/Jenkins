//
//  ReceiverVo.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-18.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReceiverVo : NSObject

@property(nonatomic,strong)NSString *strID;
@property(nonatomic,strong)NSString *strName;
@property(nonatomic,strong)NSString *strType;       //S:群组；U:用户
@property(nonatomic,strong)NSString *strCCType;     //T:发送,C:抄送,B:秘送

@end
