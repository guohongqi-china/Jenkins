//
//  HistorySearchVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistorySearchVo : NSObject

@property (nonatomic) NSInteger nID;
@property (nonatomic) NSInteger nColType;              //删除列的标记，2：全部搜索记录，1：清除搜索记录，0：正常列
@property (nonatomic, strong) NSString *strText;


@end
