//
//  VersionControlDao.h
//  Sloth
//
//  Created by 焱 孙 on 13-6-26.
//
//

#import <Foundation/Foundation.h>
#import "SQLiteDBOperator.h"
#import "VersionControlVo.h"
#import "ServerProvider.h"
#import "UserVo.h"

@interface VersionControlDao : NSObject
{
    SQLiteDBOperator *dbOperator;
}

-(VersionControlVo *)getSelfVersionControlInfo;
-(BOOL)updateVersionCtrlLastTime:(NSString*)strLastUpdateTime andType:(TableUpdateType)tableUpdateType;
-(BOOL)checkBufferOtherCompanyData;

@end
