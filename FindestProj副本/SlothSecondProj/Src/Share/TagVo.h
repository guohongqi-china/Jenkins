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

//主页搜索相关
@property(nonatomic) NSInteger nFrequency;
@property(nonatomic,strong)NSString *strSearchType;     //精华区:essence,热门搜索:hotSearch,热门话题:hotTag,分享:blog,投票:vote,问答:qa

@end
