//
//  SearchItemVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchItemVo : NSObject

@property (nonatomic,strong) NSString *strType; //精华区:essence,热门搜索:hotSearch,hotTag

@property (nonatomic,strong) NSString *strSearchItem1;
@property (nonatomic,strong) NSString *strID1;

@property (nonatomic,strong) NSString *strSearchItem2;
@property (nonatomic,strong) NSString *strID2;

@end
