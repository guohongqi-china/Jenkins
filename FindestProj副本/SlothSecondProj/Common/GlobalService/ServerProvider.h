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
#import "GroupVo.h"
#import "SendChatVo.h"
#import "PublishVo.h"
#import "MessageVo.h"
#import "ChatObjectVo.h"
#import "LeagueVo.h"
#import "SuggestionVo.h"

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

//发表消息界面的来源界面枚举
typedef enum _PublishMessageFromType{
    PublishMessageDirectlyType = 0,         //直接发表
    PublishMessageReplyType,                //回复发表
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
    MessageListWorkOrderType,                  //我的工单消息
    MessageListSearchType                      //搜索
}MessageListType;

////分享类型
//typedef enum _ShareListType{
//    ShareListAllType=0,                       //全部分享
//    ShareListHotType                          //热门分享
//}ShareListType;

//分享资源类型
typedef enum _ShareResType{
    ShareResShareType=0,                        //分享
    ShareResMsgType,                            //消息
    ShareResActivityType,                       //活动
    ShareResQAType,                              //问答
    ShareResAnswerType                              //回答 - 问答
}ShareResType;

//问答类型
typedef enum _QuestListType{
    QuestListAllType=0,                      //全部问答
    QuestListMyType,                         //我的问答
    QuestListHotType,                        //热点问答
    QuestListUnAnswerType                    //未解决问答
}QuestListType;

//用户类型
typedef enum _UserListType{
    UserListMyAttention=0,                        //我关注的人
    UserListAllType,                            //全部用户
    UserListIntegration                        //按积分排序
}UserListType;

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

//提醒子类别
typedef NS_ENUM(NSInteger,NotifySubType){
    NOTIFY_SUB_RECEIVE_MESSAGE = 1,          //给你发了条消息
    NOTIFY_SUB_REPLY_MESSAGE = 2,           //回复了你的消息
    NOTIFY_SUB_FORWARD_MESSAGE = 4,         //转发了你的消息
    NOTIFY_SUB_VOTE_MESSAGE = 9,           //回应了你发起的投票
    NOTIFY_SUB_SCHEDULE_MESSAGE = 10,        //回应了你发起的约会
    
    NOTIFY_SUB_JOIN_YOUR_GROUP = 12,       //加入了你的群组
    NOTIFY_SUB_EXIT_YOUR_GROUP = 13,          //退出了你的群组
    NOTIFY_SUB_GROUP_MANAGER = 14,         //将您设为群组管理员
    NOTIFY_SUB_INVITE_JOINE_GROUP = 15,          //请你加入了群组
    NOTIFY_SUB_ASK_EXIT_GROUP = 16,           //将你请出了群组
    
    NOTIFY_SUB_COMMENT_SHARE = 30,             //评论了你的分享
    NOTIFY_SUB_COMMENT_COMMENT = 31,         //评论了你的评论
    NOTIFY_SUB_PRAISE_SHARE = 32,          //赞了你的分享
    
    NOTIFY_SUB_ANSWER = 33,                //回答了你的问答
    NOTIFY_SUB_FINISHED_QUESTION = 34,     //答案被原作者标识为已经解决
    NOTIFY_SUB_ADD_ANSWER = 35,          //追加了你的问题答案
    NOTIFY_SUB_PRAISE_QUESTION = 36,          //赞了你的问题
    NOTIFY_SUB_PRAISE_ANSWER = 37,          //赞了你的答案
    NOTIFY_SUB_INVITE_ANSWER_QUESTION = 38,    //邀请你回答问题
    
    NOTIFY_SUB_ATTENTION_ME = 39,             //别人关注我（跳转对方个人中心）
    
    NOTIFY_SUB_ACTIVITY_ATTENTION = 40,             //合理化建议待办
    
    NOTIFY_SUB_MODERATOR_INTEGRAL = 41,            //积分个人打赏
    
    NOTIFY_SUB_AT_SHARE = 42,                   //分享的@功能
    NOTIFY_SUB_AT_COMMENT = 43,                  //评论的@功能
    
    NOTIFY_DRINK_MACHINE_REFUND = 44,          //饮料机退款提醒
    NOTIFY_FOOTBALL_WIN = 45                  //足球竞猜中奖
    
} ;

typedef enum _TableUpdateType{
    UserTableType=1,                        //用户表
    GroupTableType,                         //群组表
    RelationshipTableType                   //关系表
}TableUpdateType;

typedef enum _CurrentPageName{
    ChatListPage=0,                     //聊天人列表界面
    ChatContentPage,                    //聊天界面
    PublishPage,                        //发表界面
    TopRankingPage,                    //排行榜界面
    OtherPage                           //其他界面
}CurrentPageName;

typedef enum _PublishMsgType{
    PublishMessageType = 0,                 //发送消息
    PublishMsgVoteType,                     //发送投票
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
typedef enum _HomeListType{
    shareType,                        //分享
    VoteType,                         //投票
    QuestionandanswerType                  //关系表
}HomeListType;
@interface ServerProvider : NSObject

@property (nonatomic, assign) HomeListType type;/** <#注释#> */
/////////////////////////////////////////////////////////
+ (NSMutableArray*)getUserListByJSONArray:(NSArray*)aryUserList;
+ (NSMutableArray*)getBlogListByJSONArray:(NSArray*)aryBlogJSONList;

/////////////////////////////////////////////////////////
+ (void)loginToRestServer:(NSString*)strLoginPhone andPwd:(NSString*)strPwd result:(ResultBlock)resultBlock;
+ (void)logoutAction:(ResultBlock)resultBlock;
+ (void)getAllCompanyList:(ResultBlock)resultBlock;
+ (void)getMessageDetailByID:(NSString *)strArticledID result:(ResultBlock)resultBlock;
+ (void)getSessionMsgList:(NSString*)strMessageID andTitleID:(NSString*)strTitleID result:(ResultBlock)resultBlock;
+ (void)getMessageListByType:(MessageListType)messageListType andFilterType:(NSString*)strFilterType andPageNum:(int)nPage result:(ResultBlock)resultBlock;

+ (void)searchMessageList:(NSString*)strSearchText type:(MessageListType)messageListType andPageNum:(int)nPage result:(ResultBlock)resultBlock;
+ (void)dismissGroup:(NSString *)strTeamId result:(ResultBlock)resultBlock;
+ (void)createGroup:(GroupVo *)groupVo result:(ResultBlock)resultBlock;
+ (void)joinGroup:(NSString *)strTeamId andUserID:(NSString*)strUserID result:(ResultBlock)resultBlock;
+ (void)exitGroup:(NSString *)strTeamId andUserID:(NSString*)strUserID result:(ResultBlock)resultBlock;
+ (void)transferGroup:(NSString *)strTeamId andUserID:(NSString*)strUserID result:(ResultBlock)resultBlock;
+ (void)editGroup:(GroupVo*)groupVo result:(ResultBlock)resultBlock;
+ (void)getAllGroupList:(ResultBlock)resultBlock;
+ (void)getUserDetail:(NSString*)strUserID result:(ResultBlock)resultBlock;
+ (void)getUserHeaderImage:(NSString*)strUserID result:(ResultBlock)resultBlock;
+ (void)editUserPassword:(NSString*)strUserID andNewPwd:(NSString*)strNewPwd andOldPwd:(NSString*)strOldPwd result:(ResultBlock)resultBlock;
+ (void)editUserInfo:(UserVo*)userVo result:(ResultBlock)resultBlock;
+ (void)updateUserInfoByDictionary:(NSMutableDictionary*)dicBody result:(ResultBlock)resultBlock;
+ (void)getCompanyUserByTrueName:(NSString*)strTrueName result:(ResultBlock)resultBlock;
+ (void)getRecommendAttentionUserList:(NSInteger)nPage result:(ResultBlock)resultBlock;

//上传附件
+ (void)uploadAttachment:(NSString *)path result:(ResultBlock)resultBlock;

//发表消息
+ (void)publishMsg:(MessageVo *)messageVo andPublishType:(PublishMessageFromType)publishMessageFromType result:(ResultBlock)resultBlock;
+ (void)addComment:(NSString *)strSourceID blogId:(NSString *)strBlogID content:(NSString*)strContent type:(NSString *)strType result:(ResultBlock)resultBlock;

+ (void)operateSchedule:(NSString *)strScheduleID andType:(int)nType result:(ResultBlock)resultBlock;
+ (void)operateVote:(NSString *)strVoteID andVoteOption:(NSMutableArray*)aryVoteOption andType:(int)nVoteType result:(ResultBlock)resultBlock;
+ (void)deleteMessage:(NSString *)strMessageID result:(ResultBlock)resultBlock;
+ (void)getShareDetailBlog:(NSString*)strBlogID type:(NSString *)strType result:(ResultBlock)resultBlock;
+ (void)praiseBlog:(NSString *)strTeamId type:(NSString *)strType result:(ResultBlock)resultBlock;
+ (void)deleteComment:(NSString *)strSourceID type:(NSString *)strType result:(ResultBlock)resultBlock;
+ (void)addTagToMessage:(NSString *)strMessageID andTagsID:(NSString*)strTagsID result:(ResultBlock)resultBlock;
+ (void)removeTagFromMessage:(NSString *)strMessageID andTagsID:(NSString*)strTagsID result:(ResultBlock)resultBlock;
+ (void)publishShare:(PublishVo *)publishVo result:(ResultBlock)resultBlock;

+ (void)createAlbumFolder:(NSString *)name andType:(int)nType andTeamID:(NSString *)teamID andRemark:(NSString *)remark result:(ResultBlock)resultBlock;
+ (void)removeAlbumFolder:(NSString*)strFolderID result:(ResultBlock)resultBlock;
+ (void)getMyAlbumInfo:(ResultBlock)resultBlock;
+ (void)getAlbumInfoByID:(NSString*)strUserID result:(ResultBlock)resultBlock;
+ (void)getPublicAlbumInfo:(ResultBlock)resultBlock;
+ (void)getImageFolderFromID:(NSString*)strFolderID result:(ResultBlock)resultBlock;
+ (void)addImagesIntoFolder:(NSMutableArray *)aryImagePath forFolder:(NSString*)strFolderID result:(ResultBlock)resultBlock;

//问答接口//////////////////////////////////////////////////////////////////////////////////////////
+ (void)getQuestList:(NSString*)strBlogID createBy:(NSString*)strUserID content:(NSString*)strContent result:(ResultBlock)resultBlock;
+ (void)deleteQusetion:(NSString *)strSourceID result:(ResultBlock)resultBlock;
+ (void)deleteAnswer:(NSString *)strSourceID result:(ResultBlock)resultBlock;
//+ (void)solutionAnswer:(NSString *)strSourceID result:(ResultBlock)resultBlock;
+ (void)paiserAnswer:(NSString *)strTeamId result:(ResultBlock)resultBlock;
+ (void)askUser:(NSString *)strTeamId andUser:(NSMutableArray *)userArr result:(ResultBlock)resultBlock;
+ (void)getAnnouncementList:(ResultBlock)resultBlock;
+ (void)addAnswer:(PublishVo*)publishVo result:(ResultBlock)resultBlock;
+ (void)addQuest:(PublishVo *)publishVo result:(ResultBlock)resultBlock;
+ (void)getAnswerList:(NSString*)strQuestionID nPage:(NSInteger)nPage result:(ResultBlock)resultBlock;
+ (void)getPraiseList:(NSString*)strRefID type:(NSString *)strType page:(NSInteger)nPage result:(ResultBlock)resultBlock;

//聊天记录//////////////////////////////////////////////////////////////////////////////////////////
+ (void)getHistoryChatSessionList:(ResultBlock)resultBlock;
+ (void)sendSingleChat:(SendChatVo *)sendChatVo result:(ResultBlock)resultBlock;
+ (void)getChatContentByCId:(NSString*)strChatContentID result:(ResultBlock)resultBlock;
+ (void)getSingleHistoryChatList:(NSString*)strOtherVestId andStartDateTime:(long long)nStartDateTime andPageNum:(NSInteger)nPageNum result:(ResultBlock)resultBlock;
+ (void)sendGroupChat:(SendChatVo *)sendChatVo result:(ResultBlock)resultBlock;
+ (void)getGroupChatContentByCId:(NSString*)strChatContentID result:(ResultBlock)resultBlock;
+ (void)getGroupHistoryChatList:(ChatObjectVo*)chatObjectVo andStartDateTime:(long long)nStartDateTime andPageNum:(NSInteger)nPageNum result:(ResultBlock)resultBlock;
+ (void)createOrUpdateChatDiscussion:(NSMutableArray*)aryMemberList andChatObject:(ChatObjectVo*)chatObjectVo result:(ResultBlock)resultBlock;
+ (void)getChatSingleInfo:(ChatObjectVo*)chatObject result:(ResultBlock)resultBlock;
+ (void)getChatGroupInfo:(ChatObjectVo*)chatObject result:(ResultBlock)resultBlock;
+ (void)clearChatHistory:(ChatObjectVo*)chatObject result:(ResultBlock)resultBlock;
+ (void)setPushSwitch:(ChatObjectVo*)chatObject result:(ResultBlock)resultBlock;
+ (void)setTopChat:(ChatObjectVo*)chatObject result:(ResultBlock)resultBlock;
+ (void)deleteChatGroupMember:(NSString*)strMemberID andGroupNodeID:(NSString*)strGroupNodeID result:(ResultBlock)resultBlock;
+ (void)selfExitChatGroup:(NSString*)strGroupNodeID result:(ResultBlock)resultBlock;
+ (void)deleteChatSingleSession:(ChatObjectVo*)chatObject result:(ResultBlock)resultBlock;
+ (void)renameChatDiscussion:(ChatObjectVo*)chatObject andNewName:(NSString*)strNewName result:(ResultBlock)resultBlock;
+ (void)getJoinedChatGroupList:(ResultBlock)resultBlock;
////////////////////////////////////////////////////////////////////////////////////////////

+ (void)getAllMyAttentionUserList:(ResultBlock)resultBlock;
+ (void)attentionUserAction:(BOOL)bAttention andOtherUserID:(NSString*)strUserID result:(ResultBlock)resultBlock;
+ (void)sendIdentifyingCode:(NSString *)strPhoneNum result:(ResultBlock)resultBlock;
+ (void)registerUserAction:(UserVo*)userVo result:(ResultBlock)resultBlock;
+ (void)getShareBlog:(NSString*)strBlogID andType:(int)nType content:(NSString*)strContent create:(NSString *)createBy result:(ResultBlock)resultBlock;
+ (void)getPraiseShareBlog:(NSInteger)nPage create:(NSString *)createBy result:(ResultBlock)resultBlock;

+ (void)sendChangePwdIdentifyingCode:(NSString *)strPhoneNum result:(ResultBlock)resultBlock;
+ (void)resetLoginPwd:(NSString*)strLoginName andPwd:(NSString*)strPwd andIdentifyingCode:(NSString*)strCode result:(ResultBlock)resultBlock;
+ (void)deleteShareArticle:(NSString *)strShareID result:(ResultBlock)resultBlock;
+ (void)addCollection:(NSString *)strResourceID andType:(NSString*)strBlogType result:(ResultBlock)resultBlock;
+ (void)cancelCollection:(NSString *)strResourceID andType:(NSString*)strBlogType result:(ResultBlock)resultBlock;
+ (void)getCollectionBlog:(NSInteger)nPageNum create:(NSString *)strCreateBy result:(ResultBlock)resultBlock;
+ (void)getCollectionQuestion:(NSInteger)nPageNum result:(ResultBlock)resultBlock;
+ (void)signInConferenceWithQRCode:(NSString *)strURLSuffix result:(ResultBlock)resultBlock;
+ (void)drawLotteryAction:(NSString*)strLotteryID result:(ResultBlock)resultBlock;
+ (void)getAllUserListByPage:(NSInteger)nPage andSearchText:(NSString*)strSearchText andPageSize:(NSInteger)nPageSize result:(ResultBlock)resultBlock;
+ (void)getCommentList:(NSString*)strArticleID andPageNum:(int)nPage result:(ResultBlock)resultBlock;
+ (void)getCommentList:(NSString*)strArticleID type:(NSString *)strType endCommentId:(NSString *)strEndCommentID midData:(BOOL)bMidData pageNumber:(NSInteger)page result:(ResultBlock)resultBlock;
+ (void)getShareInformation:(NSString*)strResID andResType:(ShareResType)resType andAnswerID:(NSString*)strAnswerID result:(ResultBlock)resultBlock;

+ (void)getShareListByType:(NSString *)strType search:(NSString *)strSearchText tag:(NSArray*)aryTag page:(NSInteger)nPage modelId:(NSString *)modelId result:(ResultBlock)resultBlock;
+ (void)getTopShareList:(ResultBlock)resultBlock;
+ (void)getAttentionShareList:(NSInteger)nPage result:(ResultBlock)resultBlock;

+ (void)checkPhone:(NSString *)strPhoneNum result:(ResultBlock)resultBlock;
+ (void)validatePhoneAndCode:(NSString*)mobile code:(NSString *)strCode result:(ResultBlock)resultBlock;
+ (void)praiseComment:(NSString *)strID type:(NSString *)strType result:(ResultBlock)resultBlock;
+ (void)getQuestionSurvey:(NSString*)strSurveyID result:(ResultBlock)resultBlock;
+ (void)getQuestionList:(NSString*)strSurveyID result:(ResultBlock)resultBlock;
+ (void)commitSurvey:(NSString*)strSurveyID andAnswer:(NSMutableArray*)aryQuestion result:(ResultBlock)resultBlock;
+ (void)getTagVoListByType:(NSString*)strType result:(ResultBlock)resultBlock;
+ (void)signupMeeting:(UserVo*)userVo result:(ResultBlock)resultBlock;
+ (void)commitSuggestion:(SuggestionVo*)suggestionVo result:(ResultBlock)resultBlock;
+ (void)getSuggestionList:(NSString*)strSearchText deparment:(NSString*)strDeparmentID
                   status:(NSString*)strStatus relate:(NSString*)strRelate page:(NSInteger)nPage
                 pageSize:(NSInteger)nSize result:(ResultBlock)resultBlock;
+ (void)getSuggestionBaseDataList:(ResultBlock)resultBlock;
+ (void)getSuggestionDetail:(NSString*)strSuggestionID result:(ResultBlock)resultBlock;
+ (void)commitSuggestionReview:(SuggestionVo*)suggestionVo result:(ResultBlock)resultBlock;
+ (void)getIntegrationList:(NSInteger)nPage type:(NSInteger)nType result:(ResultBlock)resultBlock;
+ (void)signInByDay:(ResultBlock)resultBlock;
+ (void)integrationOperation:(NSString*)strReceiverID intergral:(NSString*)strNum
                      blogId:(NSString*)strRefID remark:(NSString*)strDesc result:(ResultBlock)resultBlock;
+ (void)getIntegralByShareToThird:(NSString*)strShareID result:(ResultBlock)resultBlock;

+ (void)getHotUserList:(ResultBlock)resultBlock;
+ (void)getSelfRankUserList:(ResultBlock)resultBlock;
+ (void)getIntegrationSort:(ResultBlock)resultBlock;
+ (void)getCompanyRankingList:(ResultBlock)resultBlock;
+ (void)getHotShareList:(ResultBlock)resultBlock;
+ (void)getAttentionOrFansList:(NSString*)strUserID search:(NSString*)strSearchText type:(NSInteger)nType page:(NSInteger)nPage size:(NSInteger)nSize result:(ResultBlock)resultBlock;
+ (void)updateUserCoverImage:(NSString*)strImagePath result:(ResultBlock)resultBlock;

+ (void)testQRCode:(NSString *)strURLSuffix result:(ResultBlock)resultBlock;
+ (void)getDictionaryConfigData:(NSString *)strType result:(ResultBlock)resultBlock;

@end
