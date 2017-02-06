//
//  ChatCountDao.h
//  Sloth
//
//  Created by 焱 孙 on 13-7-1.
//
//

#import <Foundation/Foundation.h>

//store data by NSUserDefault

@interface ChatCountDao : NSObject

+(void)initChatParaSetting;

//get unsee num by key
+(int)getUnseenChatNumByKey:(NSString*)strKey;

//set unsee num by key
+(void)addOneUnseenChatNumByKey:(NSString*)strKey;

//get sum unsee num by key
+(int)getUnseenChatSumNum;

+(void)clearUnseenChatNum;

+(void)removeObjectByKey:(NSString*)strKey;

+(void)clearUselessChatNum:(NSArray*)aryKeys;

@end
