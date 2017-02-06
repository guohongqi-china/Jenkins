//
//  VersionControlVo.h
//  Sloth
//
//  Created by 焱 孙 on 13-6-26.
//
//

#import <Foundation/Foundation.h>

@interface VersionControlVo : NSObject

@property(nonatomic,retain)NSString *strCompanyID;
@property(nonatomic,retain)NSString *strGroupUpdateTime;                //群组表更新时间
@property(nonatomic,retain)NSString *strUserUpdateTime;               //成员表更新时间
@property(nonatomic,retain)NSString *strRelationshipUpdateTime;         //关系表更新时间

@end
