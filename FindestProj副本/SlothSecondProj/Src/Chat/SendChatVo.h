//
//  SendChatVo.h
//  Sloth
//
//  Created by 焱 孙 on 13-6-25.
//
//

#import <Foundation/Foundation.h>

@interface SendChatVo : NSObject

@property(nonatomic,retain)NSString *strTeamID;         //群聊的ID
@property(nonatomic,retain)NSString *strTeamNodeID;
@property(nonatomic,retain)NSString *strOtherVestID;    //私聊的对方VestID
@property(nonatomic,retain)NSString *strOtherVestNodeID;

@property(nonatomic,retain)NSString *strStreamContent;
@property(nonatomic,retain)NSString *strFilePath;

@property(nonatomic,assign)int nSendType;       //1:私聊 2:群聊

@property(nonatomic,assign)int nContentType;    //内容类型 0:普通文本 1:图片 2:文件

@end
