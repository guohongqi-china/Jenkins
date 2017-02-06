//
//  ShareInfoVo.h
//  MaternalChildProj
//
//  Created by 焱 孙 on 7/11/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareInfoVo : NSObject

@property(nonatomic,strong)NSString *strResID;  //资源ID
@property(nonatomic,strong)NSString *strTitle;//标题
@property(nonatomic,strong)NSString *strImageURL;//图片URL
@property(nonatomic,strong)NSString *strContent;//简介
@property(nonatomic,strong)NSString *strLinkURL;//分享连接

@end
