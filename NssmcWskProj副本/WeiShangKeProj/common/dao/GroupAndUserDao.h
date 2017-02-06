//
//  GroupDao.h
//  Sloth
//
//  Created by 焱 孙 on 13-6-24.
//
//

#import <Foundation/Foundation.h>
#import "SQLiteDBOperator.h"
#import "ChatObjectVo.h"
#import "ServerProvider.h"

@interface GroupAndUserDao : NSObject
{
    SQLiteDBOperator *dbOperator;
}

- (NSMutableArray*)getChatUserList;
- (ChatObjectVo*)getUserInfoByUserID:(NSString*)strUserID;
- (void)clearAllBufferDBData;
- (UserVo*)getUserVoByVestID:(NSString*)strVestID andName:(NSString*)strName;
- (BOOL)checkBufferUserAndGroup;
- (void)updateUserTable;
- (void)updateGroupTable;
- (NSMutableArray*)getDBUserList:(BOOL)bIsIncludeSelf;
- (NSMutableArray*)getGroupListByType:(GroupListType)groupListType;
- (GroupVo*)getGroupVoByID:(NSString*)strID;
- (NSMutableArray*)getGroupChatUserList:(NSMutableArray*)aryUser;

@end
