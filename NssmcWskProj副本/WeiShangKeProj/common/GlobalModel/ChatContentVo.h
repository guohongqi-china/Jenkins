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

@property(nonatomic,strong)NSString *strID;         //消息 ID
@property(nonatomic,strong)NSString *strGroupId;
@property(nonatomic,strong)NSString *strGroupNodeId;
@property(nonatomic,strong)NSString *strVestId;         //消息发送者ID
@property(nonatomic,strong)NSString *strVestNodeId;
@property(nonatomic,strong)NSString *strName;           //消息发送者名字
@property(nonatomic,strong)NSString *strHeadImg;        //消息发送者头像
@property(nonatomic,strong)NSString *strContent;
@property(nonatomic,strong)NSString *strChatTime;
@property(nonatomic)unsigned long long nChatTime;       //时间的int类型
@property(nonatomic,strong)NSString *strFileURL;        //附件URL
@property(nonatomic,strong)NSString *strFilePath;       //附件本地路径
@property(nonatomic,strong)NSString *strFileName;       //文件名称（图片+附件）
@property(nonatomic,strong)NSString *strFileID;         //文件ID
@property(nonatomic)unsigned long long lFileSize;       //文件大小

@property(nonatomic,strong)NSString *strSmallImgURL;    //中图
@property(nonatomic,strong)NSString *strImgURL;         //原始图
@property(nonatomic,strong)NSString *strCId;            //记录ID

@property(nonatomic)NSInteger nChatType;                      //1.私聊 2.群聊

@property(nonatomic)int nContentType;                   //0:文本(text)  1:图片(image)  2:语音(voice)  3:视频(video) 4:音频(audio) 5:位置(location) 6:链接(link)

@property(nonatomic)int nImgSource;                     //0:网络图片  1:本地图片

@property(nonatomic,strong)UIImage *imgChatTemp;        //缓存Image
@property(nonatomic)CGFloat fImageHeight;                //缓存图片宽度
@property (nonatomic) BOOL bAudioPlaying;   //是否正在播放音频
@property(nonatomic)NSInteger nImageIndex;  //如果聊天内容是图片，则图片所在的图片数组索引

/////////////////////////////////////////////////////////////////////////////////////
@property(nonatomic)NSInteger nChatFrom;                //消息来源 【1:微信 2:新浪微博 3:腾讯微博 4:易信 5:邮件 6:短信 7:新浪@我的 8:知新 9:系统内web聊天】
@property(nonatomic,strong)NSString *strChatType;       //消息类型(文本/图片)	text image document video audio location
@property(nonatomic)NSInteger nSenderType;              //发送人类型 1: 客户发布 2: 客服回复 3: 客服转交 4: 系统提示
@property(nonatomic,strong)NSString *strSessionID;       //会话ID
@property(nonatomic,strong)NSString *strChatURL;        //消息链接

@property(nonatomic)double fLongitude;                  //经度
@property(nonatomic)double fLatitude;                   //纬度

@property(nonatomic,strong)NSString *strCurrKefuID;         //当前客服ID
@property(nonatomic,strong)NSString *strCurrKefuName;       //当前客服名称
@property(nonatomic,strong)NSString *strCustomerID;         //客户ID
@property(nonatomic,strong)NSString *strCustomerNickName;   //客户昵称
@property(nonatomic,strong)NSString *strCustomerAccount;    //客户账户	微信号、邮箱等

@property(nonatomic,retain)NSString *strCompanyID;

@end
