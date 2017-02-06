//
//  HistorySearchDao.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/8.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "HistorySearchDao.h"
#import "SQLiteDBOperator.h"

@interface HistorySearchDao ()
{
    SQLiteDBOperator *dbOperator;
}

@end

@implementation HistorySearchDao

-(id)init
{
    self = [super init];
    if(self)
    {
        dbOperator = [SQLiteDBOperator getDBInstance];
    }
    return self;
}


//是否查询全部
- (NSMutableArray *)getTopSearchRecord:(BOOL)bAllRecord
{
    NSMutableArray *aryList = [NSMutableArray array];
    NSArray *aryData = [dbOperator QueryInfoFromSQL:@"select * from T_SEARCH_RECORD order by RECORD_ID desc;"];
    if (aryData.count>0)
    {
        for (int i=0; i<aryData.count; i++)
        {
            if (!bAllRecord && i >=2 )
            {
                break;
            }
            
            NSDictionary *dicData = [aryData objectAtIndex:i];
            HistorySearchVo *model = [[HistorySearchVo alloc] init];
            model.nID = [[dicData objectForKey:@"RECORD_ID"] integerValue];
            model.nColType = 0;
            model.strText = [dicData objectForKey:@"SEARCH_TEXT"];
            [aryList addObject:model];
        }
    }
    
    //添加最后一列
    if (aryList.count > 2)
    {
        HistorySearchVo *model = [[HistorySearchVo alloc] init];
        model.nColType = 1;
        model.strText = @"清除搜索记录";
        [aryList addObject:model];
    }
    else if (aryData.count > 2)
    {
        HistorySearchVo *model = [[HistorySearchVo alloc] init];
        model.nColType = 2;
        model.strText = @"全部搜索记录";
        [aryList addObject:model];
    }
    
    return aryList;
}

- (void)deleteSearchRecordByID:(NSInteger)nID
{
    NSString *strSql = [NSString stringWithFormat:@"delete from T_SEARCH_RECORD where RECORD_ID=%li",(long)nID];
    [dbOperator executeSql:strSql];
}

- (void)deleteAllSearchRecord
{
    NSString *strSql = @"delete from T_SEARCH_RECORD";
    [dbOperator executeSql:strSql];
}

- (void)addSearchRecord:(HistorySearchVo *)searchVo
{
    //查询是否有相同关键字的记录
    NSArray *aryData = [dbOperator QueryInfoFromSQL:[NSString stringWithFormat:@"select * from T_SEARCH_RECORD where SEARCH_TEXT = '%@';",searchVo.strText]];
    if (aryData.count>0)
    {
        //删除原记录
        NSDictionary *dicData = [aryData objectAtIndex:0];
        [self deleteSearchRecordByID:[dicData[@"RECORD_ID"] integerValue]];
    }
    
    //添加新记录
    NSString *strInsertSql = [NSString stringWithFormat:@"insert into T_SEARCH_RECORD (SEARCH_TEXT) VALUES ('%@')",searchVo.strText];
    [dbOperator executeSql:strInsertSql];
}

@end
