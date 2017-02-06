//
//  CustomerVo.h
//  WeiShangKeProj
//
//  Created by 焱 孙 on 4/29/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatObjectVo.h"

@interface CustomerVo : NSObject

@property(nonatomic,strong)NSString *strID;                 //用户ID
@property(nonatomic,strong)NSString *strNodeID;             //Node ID
@property(nonatomic,strong)NSString *strName;               //客户名
@property(nonatomic,strong)NSString *strHeadImageURL;       //用户头像地址
@property(nonatomic,strong)UIImage *imgHeadBuffer;          //用户头像数据缓存
@property(nonatomic,strong)NSString *strPartImageURL;       //用户头像部分地址（不包含IP前缀）

@property(nonatomic,strong)NSString *strEmail;             //邮件
@property(nonatomic,strong)NSString *strCode;               //客户编号
@property(nonatomic,strong)NSString *strPhone;              //电话号码
@property(nonatomic,strong)NSString *strRemark;             //备注
@property(nonatomic,strong)ChatObjectVo *chatObjectVo;

////////////////////////////////////////////////////////////////////////
@property(nonatomic,strong)NSString * strFirstLetter;       //姓名首字母
@property(nonatomic,strong)NSString *strJP;             //名称简拼
@property(nonatomic,strong)NSString *strQP;             //名称全拼

//用于选择用户
@property(nonatomic)BOOL bChecked;               //是否选择了
@property(nonatomic)BOOL bCanNotCheck;           //不能选择标识


//modify personal info
@property(nonatomic)BOOL bHasHeadImg;
@property(nonatomic,strong)NSString *strHeadImgPath;


@property(nonatomic,strong)NSString *strLastChat;           //最后一次聊天记录
@property(nonatomic,strong)NSString *strLastChatTime;       //最后一次聊天记录 时间
@property(nonatomic,strong)NSString *name;           //最后一次聊天记录
@property(nonatomic,strong)NSString *ID;           //最后一次聊天记录

@end
