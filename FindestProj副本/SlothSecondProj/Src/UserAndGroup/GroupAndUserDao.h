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
- (void)updateUserAfterAttentionAction:(UserVo*)userVo andAttention:(BOOL)bAttention;
- (ChatObjectVo*)getUserInfoByUserID:(NSString*)strUserID;
- (void)clearAllBufferDBData;
- (UserVo*)getUserVoByVestID:(NSString*)strVestID andName:(NSString*)strName;
- (BOOL)checkBufferUserAndGroup;
- (void)updateUserTable:(void(^)(void))finished;
- (void)updateGroupTable:(void(^)(void))finished;
- (NSMutableArray*)getDBUserList:(BOOL)bIsIncludeSelf;
- (NSMutableArray*)getGroupListByType:(GroupListType)groupListType;
- (GroupVo*)getGroupVoByID:(NSString*)strID;

@end
