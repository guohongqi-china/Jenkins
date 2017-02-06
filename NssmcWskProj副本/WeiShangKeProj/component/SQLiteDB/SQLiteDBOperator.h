//
//  SQLiteDBOperator.h
//  AmwayMCommerce
//
//  Created by Stanley on 11-4-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface SQLiteDBOperator : NSObject 
{
	sqlite3 *sqliteDB;
}

-(sqlite3 *)getSqliteDB;

+ (id) getDBInstance;
+ (BOOL) moveDataBaseBud:(NSString *)budleStr ToDocFile:(NSString *)file;

- (id) initWithFile:(NSString *)dbFile;
- (void) close;
- (sqlite3_stmt *) prepare:(NSString *)sql;

- (int) QueryItemsCountSQL:(NSString *)sql;
- (NSMutableArray *) QueryImageFromSQL:(NSString *)sql;
- (NSMutableArray *) QueryInfoFromSQL:(NSString *)sql;
- (BOOL) executeSql:(NSString *)sql;

@end
