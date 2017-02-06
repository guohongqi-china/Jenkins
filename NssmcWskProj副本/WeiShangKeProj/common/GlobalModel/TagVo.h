//
//  TagVo.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-18.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagVo : NSObject

@property(nonatomic,strong)NSString *strID;
@property(nonatomic,strong)NSString *strTagName;
@property(nonatomic,strong)NSString *strTagDesc;
@property(nonatomic,strong)NSString *strTagType;        //P:个人标签; O:公司标签，默认P
@property(nonatomic)BOOL bChecked;

@property(nonatomic,strong)NSString *strJP;             //名称简拼
@property(nonatomic,strong)NSString *strQP;             //名称全拼

@end
