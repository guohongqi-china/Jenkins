//
//  ChatCountDao.h
//  Sloth
//
//  Created by 焱 孙 on 13-7-1.
//
//

#import <Foundation/Foundation.h>

#define SESSION_UNPROCESS_KEY @"SESSION_UNPROCESS_KEY"
#define SESSION_PROCESSING_KEY @"SESSION_PROCESSING_KEY"
#define SESSION_SUSPEND_KEY @"SESSION_SUSPEND_KEY"

//store data by NSUserDefault

@interface ChatCountDao : NSObject

+(void)initChatParaSetting;

//get unsee num by key
+(NSInteger)getUnseenChatNumByKey:(NSString*)strKey status:(NSString*)strStatus;

//set unsee num by key
+(void)addOneUnseenChatNumByKey:(NSString*)strKey status:(NSString*)strStatus;

//get sum unsee num by key
+(NSInteger)getNumBySessionStatus:(NSString*)strStatus;

//获取指定会话状态的会话数量（未提醒）
+(NSNumber*)getSessionNumByStatus:(NSString*)strStatus;

//获取所有会话数字总和
+(NSInteger)getAllSessionNum;

+(void)removeObjectByKey:(NSString*)strKey status:(NSString*)strStatus;

+(void)clearUnseenChatNum;

+(NSString*)getSessionKeyByStatus:(NSInteger)nStatus;

@end
