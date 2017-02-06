//
//  ServerProvider.h
//  Sloth
//
//  Created by Ann Yao on 12-9-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerReturnInfo.h"
#import "VoteVo.h"
#import "VoteOptionVo.h"
#import "ScheduleVo.h"
#import "BlogVo.h"
#import "SendBlogVo.h"
#import "GroupVo.h"
#import "SendChatVo.h"
#import "PublishVo.h"
#import "MessageVo.h"
#import "ChatObjectVo.h"
#import "FolderVo.h"
#import "FileVo.h"
#import "AlbumInfoVO.h"
#import "AlbumImageVO.h"
#import "CustomerVo.h"
#import "TicketVo.h"
#import "TijiaoModel.h"
#import "InformPicVo.h"
#import "VNetworkFramework.h"

typedef void (^ResultBlock)(ServerReturnInfo *retInfo);

@class UserVo;

//角色类型
typedef enum _RoleType{
    RoleTypeAdmin=0,                        //管理员
    RoleTypeLeader,                         //领导
    RoleTypeAssistant,                      //秘书
    RoleTypeAgency,                         //代理（秘书代领导）
    RoleTypeOther                           //其他
}RoleType;

//文档来自类型
typedef enum _DocFromType{
    DOC_MINE_TYPE = 0,              //我的相册
    DOC_PUBLIC_TYPE                 //公共相册
}DocFromType;

//发表消息界面的来源界面枚举
typedef enum _PublishMessageFromType{
    PublishMessageDirectlyType = 0,         //直接发表
    PublishMessageReplyType,                //回复发表
    PublishMessageReplyAllType,             //回复全部发表
    PublishMessageForwardType,              //转发发表
    PublishMessageDraftType                 //草稿发表
}PublishMessageFromType;

//消息类型
typedef enum _MessageListType{
    MessageListAllType=0,                      //我的所有信息
    MessageListPersonalType,                   //我的私人信息
    MessageListMyGroupType,                    //我的群组消息
    MessageListFromMeType,                     //我发送的消息
    MessageListMyDraftType,                    //我保存的草稿
    MessageListStarType,                       //我的星标消息
    MessageListSearchType                      //搜索
}MessageListType;

//分享类型
typedef enum _ShareListType{
    ShareListAllType=0,                       //全部
    ShareListInnerType,                       //分享
    ShareListOutType,                         //信息流入
    ShareListHotType                          //热门分享
}ShareListType;

//分享资源类型
typedef enum _ShareResType{
    ShareResShareType=0,                        //分享
    ShareResMsgType,                            //消息
    ShareResQAType                              //问答
}ShareResType;

//问答类型
typedef enum _QuestListType{
    QuestListAllType=0,                      //全部问答
    QuestListMyType,                         //我的问答
    QuestListHotType,                        //热点问答
    QuestListUnAnswerType                    //未解决问答
}QuestListType;

//群组类型
typedef enum _GroupListType{
    GroupListAllType=0,                        //全部群组
    GroupListCreatedType,                      //我创建的群组
    GroupListJoinedType,                       //我参与的群组
    GroupListCouldSendType,                    //可发表的群组
    GroupListOtherType                         //其它群组
}GroupListType;

typedef enum _BlogType {
    BlogNewType = 0,            //群组下最新博文
    BlogExponentType,           //群组下精彩博文
    BlogMentionType,            //提到我的博文
    BlogPersonalType,           //个人博文
    SearchBlogType,             //搜索博文
    BlogCollectType,            //收藏
    BlogGoodCommentType,        //好评博文
    BlogTopicType,              //主题下博文
    BlogJoinScheduleType,       //join schedule
    BlogCreateScheduleType,     //create schedule
    BlogPageType                //my page type
} BlogType;

typedef enum _NotifyType {
    MESSAGE_TYPE_MENTION = 0,       //@提到我的
    MESSAGE_TYPE_COMMENT,           //别人评论我的
    MESSAGE_TYPE_COMMENT_AT,        //评论时@到我
    MESSAGE_TYPE_PRAISE,            //赞
    MESSAGE_TYPE_FANS,              //粉丝
    MESSAGE_TYPE_INVITE,            //邀请
    MESSAGE_TYPE_GROUP,             //群组
    MESSAGE_TYPE_DYNAMIC,           //动态
    MESSAGE_TYPE_ACTIVITY           //日程
} NotifyType;

//提醒主类别
typedef enum _NotifyMainType {
    TYPE_CHAT = 0,                  //聊天
    TYPE_MYSELF,                    //我的提醒
    TYPE_TEAM,                      //群组提醒
    TYPE_MANAGER                    //管理员的提醒
} NotifyMainType;

//提醒子类别
typedef enum _NotifySubType {
    NOTIFY_SUB_RECEIVE_MESSAGE = 1,          //给你发了条消息
    NOTIFY_SUB_REPLY_MESSAGE = 2,           //回复了你的消息
    NOTIFY_SUB_FORWARD_MESSAGE = 4,         //转发了你的消息
    
    NOTIFY_SUB_PRAISE_COMMENT = 6,          //赞了下你的评论
    NOTIFY_SUB_COMMENT_PHOTO = 7,           //评论了你的相片
    NOTIFY_SUB_PRAISE_PHOTO = 8,            //赞了下你的相片
    
    NOTIFY_SUB_JOIN_YOUR_GROUP = 12,       //加入了你的群组
    NOTIFY_SUB_EXIT_YOUR_GROUP = 13,          //退出了你的群组
    NOTIFY_SUB_GROUP_MANAGER = 14,         //将您设为群组管理员
    NOTIFY_SUB_INVITE_JOINE_GROUP = 15,          //请你加入了群组
    NOTIFY_SUB_ASK_EXIT_GROUP = 16,           //将你请出了群组
    
    NOTIFY_SUB_COMMENT_SHARE = 30,             //评论了你的分享
    NOTIFY_SUB_COMMENT_COMMENT = 31,         //评论了你的评论
    NOTIFY_SUB_PRAISE_SHARE = 32,          //赞了你的分享
    
    NOTIFY_SUB_ANSWER = 33,                //回答了你的问题
    NOTIFY_SUB_FINISHED_QUESTION = 34,     //答案被原作者标识为已经解决
    NOTIFY_SUB_ADD_ANSWER = 35,          //追加了你的问题答案
    NOTIFY_SUB_PRAISE_QUESTION = 36,          //赞了你的问题
    NOTIFY_SUB_PRAISE_ANSWER = 37,          //赞了你的答案
    NOTIFY_SUB_INVITE_ANSWER_QUESTION = 38             //邀请你回答问题
} NotifySubType;

typedef enum _TableUpdateType{
    UserTableType=1,                        //用户表
    GroupTableType,                         //群组表
    RelationshipTableType                   //关系表
}TableUpdateType;

typedef enum _CurrentPageName{
    ChatListPage=0,                     //聊天人列表界面
    ChatContentPage,                    //聊天界面
    ChatInfoPage,                       //聊天设置界面
    SessionListPage,                    //会话列表界面
    SessionContentPage,                 //会话详情界面
    FAQPage,                            //知识库界面
    OtherPage                           //其他界面
}CurrentPageName;

typedef enum _PublishMsgType{
    PublishMessageType = 0,                 //发送消息
    PublishVoteType,                        //发送投票
    PublishScheduleType                     //发送日程
}PublishMsgType;

//群组增加和编辑
typedef enum _GroupPageName{
    GroupAddPage=0,                     //群组增加界面
    GroupEditPage                       //群组编辑界面
}GroupPageName;

//来自的页面类型
typedef enum _FromViewToChooseType{
    FromContactListViewType = 1,        //从联系人列表界面进来
    FromChatListViewType,               //从即时聊天列表界面进来
    FromOtherViewType                   //从发表页面选择收件人
}FromViewToChooseType;

@interface ServerProvider : NSObject

/////////////////////////////////////////////////////////
+ (ServerReturnInfo*)loginToRestServer:(NSString*)strLoginPhone andPwd:(NSString*)strPwd;
+ (ServerReturnInfo*)logoutAction;
+ (void)editUserPassword:(NSString*)strNewPwd andOldPwd:(NSString*)strOldPwd result:(ResultBlock)resultBlock;
+ (ServerReturnInfo*)setLanguage:(NSString*)strLanguage;

+ (ServerReturnInfo*)dismissGroup:(NSString *)strTeamId;
+ (ServerReturnInfo*)createGroup:(GroupVo *)groupVo;
+ (ServerReturnInfo*)joinGroup:(NSString *)strTeamId andUserID:(NSString*)strUserID;
+ (ServerReturnInfo*)exitGroup:(NSString *)strTeamId andUserID:(NSString*)strUserID;
+ (ServerReturnInfo*)transferGroup:(NSString *)strTeamId andUserID:(NSString*)strUserID;
+ (ServerReturnInfo*)editGroup:(GroupVo*)groupVo;
+ (ServerReturnInfo*)getAllGroupList;
+ (ServerReturnInfo*)getGroupMemberList:(NSString*)strGroupID;
+ (ServerReturnInfo*)getUserDetail:(NSString*)strUserID;
+ (ServerReturnInfo*)editUserPassword:(NSString*)strUserID andNewPwd:(NSString*)strNewPwd andOldPwd:(NSString*)strOldPwd;
+ (ServerReturnInfo*)editUserInfo:(UserVo*)userVo;
+ (ServerReturnInfo*)syncAllMember:(NSString*)strLastUpdateDateTime;
+ (ServerReturnInfo*)getAllMyAttentionUserList;

+ (ServerReturnInfo*)getAllNotifyTypeUnreadNum;
+ (ServerReturnInfo*)getMyNotifyList:(int)nPageNum;
+ (ServerReturnInfo*)getGroupNotifyList:(int)nPageNum;
+ (ServerReturnInfo*)setNotifyTypeToRead:(int)nType;
+ (ServerReturnInfo*)setAllNotifyToRead;
//上传附件
+ (ServerReturnInfo*)uploadAttachment:(NSString *)path;

////////////////////////////////////////////////////////////////////////////////////////////
+ (ServerReturnInfo*)getSingleChatImageList:(NSString*)strOtherVestId;
+ (ServerReturnInfo*)getGroupChatImageList:(ChatObjectVo*)chatObjectVo;
+ (ServerReturnInfo *)getTagVoListByType:(NSString*)strType;

//会话模块
+ (NSMutableArray*)getSessionDetailByJSONArray:(NSArray*)aryChatJSONList;
+ (NSMutableArray*)getSessionListByJSONArray:(NSArray*)arySessionJSONList;

+(ServerReturnInfo*)getSessionList:(NSInteger)nStatus page:(NSInteger)nPage from:(NSInteger)nFrom;
+(ServerReturnInfo*)getSessionDetail:(NSString*)strCustomerID endMessageID:(NSString*)strEndMessageID;
+(ServerReturnInfo*)sendSessionMessage:(SendChatVo *)sendChatVo;
+(ServerReturnInfo*)closeSession:(NSString *)strSessionID;
+(ServerReturnInfo*)suspendSession:(NSString *)strSessionID;
+(ServerReturnInfo*)transferSession:(NSString *)strSessionID kefu:(NSString*)strKefuID;
+(ServerReturnInfo*)sendScoreLink:(NSString *)strSessionID;
+(ServerReturnInfo*)getSessionStatusNum;

+(ServerReturnInfo*)getCustomerList:(NSString*)strSearchText page:(NSInteger)nPage pageSize:(NSInteger)nSize;
+(ServerReturnInfo*)getCustomerDetail:(NSString*)strID;
+(ServerReturnInfo*)updateCustomer:(CustomerVo*)customerVo;

//客服
+(ServerReturnInfo*)getAllOnLineKefu;

//知识库
+(ServerReturnInfo*)getFAQList:(NSString*)strSearchText page:(NSInteger)nPage pageSize:(NSInteger)nPageSize;
+(ServerReturnInfo*)sendRichFAQ:(NSString *)strFAQID customerID:(NSString*)strCustomerID sessionID:(NSString*)strSessionID orign:(NSString*)strChatFrom;

+(ServerReturnInfo*)getTicketList:(NSString*)strSearch page:(NSInteger)nPage pageSize:(NSInteger)nSize
                           status:(NSString*)strStatus type:(NSString*)strType difficulty:(NSString *)strDifficulty title:(NSString *)title;
+(ServerReturnInfo*)getTicketDetail:(NSString*)strTicketID;
+(ServerReturnInfo*)getTicketTypeList;
+(ServerReturnInfo*)addTicketRecord:(NSString*)strTicketID record:(NSString*)strContent;
+(ServerReturnInfo*)transferTicketToEmail:(NSString*)strTicketID session:(NSString*)strSessionID email:(NSMutableArray*)aryEmail;
+(ServerReturnInfo*)closeTicket:(NSString*)strTicketID;
+(ServerReturnInfo*)mergeTicket:(NSString*)strTicketID toTicket:(NSString*)strToTicketId;
+(ServerReturnInfo*)saveTicket:(TicketVo*)ticketVo;

////////////////////////////////////////////////////////////////////////////////////////////
+ (ServerReturnInfo*)sendIdentifyingCode:(NSString *)strPhoneNum;
+ (ServerReturnInfo*)sendChangePwdIdentifyingCode:(NSString *)strPhoneNum;
+ (ServerReturnInfo*)registerUserAction:(UserVo*)userVo;
+ (ServerReturnInfo*)resetLoginPwd:(NSString*)strLoginName andPwd:(NSString*)strPwd andIdentifyingCode:(NSString*)strCode;


#pragma  =======================================我的工单详情接口调用方法=====================================
+ (ServerReturnInfo *)getTicketTypeListDetail:(NSString *)malfunctionId detailId:(NSString *)detailId boolIS:(BOOL)isAttachment;
+ (ServerReturnInfo *)getTicketTypeGetArray:(NSString *)malfunctionId detailId:(NSString *)detailId;
+ (ServerReturnInfo *)setTicketTypeListDetail:(NSString *)malfunctionId detailId:(NSString *)detailId detailStatus:(NSString *)detailStatus percentage:(NSString *)percentage judgement:(NSString *)judgement boolJudge:(BOOL)isHe guestId:(NSString *)guestId model:(TijiaoModel *)model PINCD:(NSString *)pinCd;
+ (ServerReturnInfo *)setTicketTypeListRecord:(NSString *)malfunctionId detailId:(NSString *)detailId  percentage:(NSString *)percentage detailContent:(NSString *)detailContent no:(NSString *)no  updateUserCd:(NSString *)updateUserCd guestId:(NSString *)guestId;



+ (ServerReturnInfo *)uploadPicData:(NSData *)picdata params:(NSDictionary *)dictionary;//上传图片到服务器
+ (void)uploadPicData:(NSData *)picdata result:(void (^)(ServerReturnInfo *retInfo))result;//上传图片到服务器
+ (ServerReturnInfo*)toGetTheCompanyName;
+ (NSString *)JudgeStrIsEmpty:(NSString *)string;
+ (void)startFormData:(NSString *)urlString parms:(NSDictionary *)bodDic result:(void (^)(ServerReturnInfo *retInfo))result;
@end
