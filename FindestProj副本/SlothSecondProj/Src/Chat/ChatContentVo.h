//
//  ChatContentVo.h
//  Sloth
//
//  Created by 焱 孙 on 13-6-19.
//
//

#import <Foundation/Foundation.h>
#import "UserVo.h"
#import "ServerProvider.h"

//聊天内容model
@interface ChatContentVo : NSObject

@property(nonatomic,strong)NSString *strGroupId;
@property(nonatomic,strong)NSString *strGroupNodeId;
@property(nonatomic,strong)NSString *strVestId;         //消息发送者ID
@property(nonatomic,strong)NSString *strVestNodeId;
@property(nonatomic,strong)NSString *strName;           //消息发送者名字
@property(nonatomic,strong)NSString *strHeadImg;        //消息发送者头像
@property(nonatomic,strong)NSString *strContent;
@property(nonatomic,strong)NSString *strChatTime;
@property(nonatomic)unsigned long long nChatTime;       //时间的int类型
@property(nonatomic,strong)NSString *strFileURL;        //附件路径
@property(nonatomic,strong)NSString *strFilePath;       //附件本地路径
@property(nonatomic,strong)NSString *strFileName;       //文件名称（图片+附件）
@property(nonatomic,strong)NSString *strFileID;         //文件ID
@property(nonatomic)unsigned long long lFileSize;       //文件大小

@property(nonatomic,strong)NSString *strSmallImgURL;
@property(nonatomic,strong)NSString *strImgURL;         //原始图
@property(nonatomic,strong)NSString *strCId;            //记录ID

@property(nonatomic)NSInteger nChatType;                      //1.私聊 2.群聊

@property(nonatomic)NSInteger nContentType;                   //0:文本  1:图片  2:文件  3:音频

@property(nonatomic)NSInteger nImgSource;                     //0:网络图片  1:本地图片

@property(nonatomic,strong)UIImage *imgChatTemp;        //缓存Image
@property (nonatomic) BOOL bAudioPlaying;   //是否正在播放音频

@end
