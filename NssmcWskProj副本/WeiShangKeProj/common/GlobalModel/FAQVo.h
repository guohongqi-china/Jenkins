//
//  FAQVo.h
//  WeiShangKeProj
//
//  Created by 焱 孙 on 5/20/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FAQVo : NSObject

@property(nonatomic,strong)NSString *strID;
@property(nonatomic,strong)NSString *strCompanyID;
@property(nonatomic,strong)NSString *strTitle;
@property(nonatomic,strong)NSString *strRichContent;    //内容 富文本
@property(nonatomic,strong)NSString *strTextContent;    //内容 纯文本
@property(nonatomic,strong)NSString *strPicUrl;
@property(nonatomic,strong)NSString *strJumpUrl;        //相关链接

@end
