//
//  SQLiteDBOperator.m
//  AmwayMCommerce
//
//  Created by Stanley on 11-4-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SQLiteDBOperator.h"
#import "sqlite3.h"

//数据库 version:2,主要增加了积分和勋章字段
//数据库 version:3,主要更改了积分数据类型(INTEGER->Double)

//数据库最新版本号(用于数据库升级)
#define DB_VERSION @"3"
#define DBName @"sloth.sqlite"

@implementation SQLiteDBOperator

static sqlite3 *mySqliteDB = nil;
static SQLiteDBOperator *dbInstance = nil;

+ (id) getDBInstance
{
    @synchronized (self)
    {
        if( dbInstance == nil)
        {
            dbInstance = [[SQLiteDBOperator alloc] initWithFile:nil];
        }
    }
	return dbInstance;
}

//初始化戴入一个文件
- (id) initWithFile:(NSString *)dbFile
{
	self = [super init];
    
    //设置为 SQLITE_CONFIG_SERIALIZED 串行执行，【数据库连接】和【prepared statement】都已加锁,解决多线程访问bug
    if (sqlite3_config(SQLITE_CONFIG_SERIALIZED) == SQLITE_ERROR)
    {
        NSLog(@"couldn't set serialized mode");
    }
    
	if (dbFile == nil || [dbFile compare:@""] == NSOrderedSame) 
	{
		dbFile = DBName;
	}
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:dbFile];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL find = [fileManager fileExistsAtPath:path];
	BOOL bIsFind = find;
    
	//将根目录移动到 document 目录下面
	if(!find)
	{
		find = [SQLiteDBOperator moveDataBaseBud:dbFile ToDocFile:dbFile];
	}
	
	if(find) 
	{
		//Database file has already existed
		if(sqlite3_open([path UTF8String], &sqliteDB) != SQLITE_OK)
		{
			//Error:open database file.
			sqlite3_close(sqliteDB);
		}
		else
        {
            //save the instances
            mySqliteDB = sqliteDB;
            dbInstance = self;
        }
	}
    
    //check db version
    if (bIsFind)
    {
        [self checkDBVersion];
    }
	
	return self;
}

-(void) close
{
	if( sqlite3_close(sqliteDB) != SQLITE_OK)
	{
		NSLog(@"Failed to close database, normally error handling here.");
	}
}

-(sqlite3 *) sqliteDB
{
	return sqliteDB;
}

-(sqlite3 *)getSqliteDB
{
	return sqliteDB;
}

-(sqlite3_stmt *) prepare:(NSString *)sql
{
	const char *utfsql = [sql UTF8String];
	//const char *utfsql = [@"select * from t_test" UTF8String];
	sqlite3_stmt *statement;
	int sqlStatus = sqlite3_prepare_v2([self sqliteDB],utfsql,-1,&statement,NULL);
	if(sqlStatus == SQLITE_OK)
	{
		return statement;
	}
	else 
	{
		return nil;
	}	
}

//get count by sql
-(int) QueryItemsCountSQL:(NSString *)sql
{
	sqlite3_stmt *statement;
	int count = 0;
	
    statement = [self prepare:sql];
	if(statement != NULL)
	{
		while (sqlite3_step(statement) == SQLITE_ROW) 
		{			
			count ++;
		}		
	}
	
	sqlite3_finalize(statement);
	
	return count;
}

+(BOOL) moveDataBaseBud:(NSString *)budleStr ToDocFile:(NSString *)file
{
	NSFileManager * fileManager = [NSFileManager defaultManager];
	NSString * dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:budleStr];
	
	NSError * error;
	BOOL success;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * docsdir = [paths objectAtIndex:0];
	NSString *newPath = [docsdir stringByAppendingPathComponent:file];
	
	//如果已经存在一个path 
	if([fileManager  fileExistsAtPath:newPath])
	{
        [fileManager removeItemAtPath:newPath error:&error];
    }
	success = [fileManager copyItemAtPath:dbPath toPath:newPath error:&error];
	
	if( !success)
	{
		NSLog(@"Failed to copy database...error handling here %@.", [error localizedDescription]);
	}
	
	return success;
}

- (NSMutableArray *) QueryImageFromSQL:(NSString *)sql
{
	sqlite3_stmt *statement;
	NSData *nsData;
	
	NSMutableArray *arrayList = [NSMutableArray array];//[[NSMutableArray alloc] init];
	
	statement = [self prepare:sql];
	if(statement != NULL)
	{
		while(sqlite3_step(statement) == SQLITE_ROW) 
		{
			nsData = (__bridge NSData *) sqlite3_column_value(statement, 0);
			[arrayList addObject:nsData];
		}		
	}
	
	sqlite3_finalize(statement);
	return arrayList;
}

-(NSMutableArray *) QueryInfoFromSQL:(NSString *)sql
{
	sqlite3_stmt *statement;
    NSString *nsName;
	NSString *nsData;
	char *pchData;
	
	NSMutableArray *arrayList = [NSMutableArray array];//[[NSMutableArray alloc] init];
	
	statement = [self prepare:sql];
	if(statement != NULL)
	{
		while(sqlite3_step(statement) == SQLITE_ROW) 
		{
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
			int count = sqlite3_column_count(statement);
			for (int i = 0; i < count; i ++) 
			{
				pchData = (char *)sqlite3_column_text(statement, i);
				if (pchData == nil)
				{
                    pchData = "";
                }
                
				nsData = [NSString stringWithUTF8String:pchData];
                if(nsData == nil)
                {
                    nsData = @"";
                }
                pchData = (char *)sqlite3_column_name(statement, i);
                nsName = [NSString stringWithUTF8String:pchData];
                [dic setObject:nsData forKey:nsName];
			}
            
			[arrayList addObject:dic];
		}		
	}
	
	sqlite3_finalize(statement);
	return arrayList;
}

-(BOOL)executeSql:(NSString *)sql
{
	sqlite3_stmt *statement;
	BOOL bSuccess = NO;
	
    statement = [self prepare:sql];
	if(statement != NULL) 
    {  	
        bSuccess = sqlite3_step(statement);
    }
	else
	{
        NSLog(@"Error: failed to execute:%@",sql);
    }

	sqlite3_finalize(statement);
	
	return bSuccess;
}

//check db version add by sunyan 2012-05-30
-(void)checkDBVersion
{
    BOOL bRes;
    NSString *dbFile = DBName;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:dbFile];
    
	NSString *strSQL = [NSString stringWithFormat:@"select DV_VERSION from DB_VERSION where DV_ID = 1"];
    NSArray *array = [self QueryInfoFromSQL:strSQL];
    
    //1.select db_version data
    if(array.count > 0)
    {
        NSDictionary *dicData = [array objectAtIndex:0];
        NSString* strOldVer = [dicData objectForKey:@"DV_VERSION"];
        if ([strOldVer isEqualToString:DB_VERSION])
        {
            bRes = TRUE;
        }
        else
        {
            bRes = FALSE;
        }
       
    }
    else
    {
        bRes = FALSE;
    }
    
    //2.delete old db and copy new db 
    if (!bRes) 
    {
        //a:    close old db
        sqlite3_close(sqliteDB);
        
        //b:    delete old db and copy new db 
        [SQLiteDBOperator moveDataBaseBud:dbFile ToDocFile:dbFile];
        
        //c:    open new db
        if(sqlite3_open([path UTF8String],&sqliteDB)!=SQLITE_OK)
        {
            sqlite3_close(sqliteDB);
            NSLog(@"Error:open database file.");
        }
        else
        {
            //save the instances
            mySqliteDB = sqliteDB;
            dbInstance = self;
        }
    }
}

@end
