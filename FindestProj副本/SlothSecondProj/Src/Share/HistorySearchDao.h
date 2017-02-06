//
//  HistorySearchDao.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistorySearchVo.h"

@interface HistorySearchDao : NSObject

- (NSMutableArray *)getTopSearchRecord:(BOOL)bAllRecord;

- (void)deleteSearchRecordByID:(NSInteger)nID;
- (void)deleteAllSearchRecord;

- (void)addSearchRecord:(HistorySearchVo *)searchVo;

@end
