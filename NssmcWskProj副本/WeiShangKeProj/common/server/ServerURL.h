//
//  ServerURL.h
//  CorpKnowlGroup
//
//  Created by yuson on 11-8-12.
//  Copyright 2011 DNE. All rights reserved.
//

#import <Foundation/Foundation.h>
//vn-functional.chinacloudapp.cn
//新日铁临时测试
//#define SERVER_IP           @"vn-functional.chinacloudapp.cn"           //Restful API 服务器
////#define SERVER_IP           @"192.168.0.184"           //Restful API 服务器
//
//#define SERVER_PORT         @""
//#define SERVER_DOMAIN       @"wsk-ns/api/"

#define SERVER_IP           @"weixin.link-infor.com.cn"           //Restful API 服务器
//#define SERVER_IP           @"192.168.0.184"           //Restful API 服务器

#define SERVER_PORT         @""
#define SERVER_DOMAIN       @"wsk-ns/api/"




#define SERVER_CHAT_IP           @"vn-functional.chinacloudapp.cn"      //Node 聊天服务器
#define SERVER_CHAT_PORT         @"2081"
#define SERVER_CHAT_DOMAIN       @""//无服务名

#define SERVER_NGINX_IP           @"vn-functional.chinacloudapp.cn"     //Ngnix 服务器
#define SERVER_NGINX_PORT         @""
#define SERVER_NGINX_DOMAIN       @"wsk/"

/////////////////////////////////////////////////////////////////////////////////////////////////
////生产环境(域名)
//#define SERVER_IP           @"www.wshangke.cn"          //Restful API 服务器
//#define SERVER_PORT         @""
//#define SERVER_DOMAIN       @"wsk/"
//
//#define SERVER_CHAT_IP           @"wshangke.cn"         //Node 聊天服务器
//#define SERVER_CHAT_PORT         @"10008"
//#define SERVER_CHAT_DOMAIN       @""//无服务名
//
//#define SERVER_NGINX_IP           @"www.wshangke.cn"     //Ngnix 服务器
//#define SERVER_NGINX_PORT         @""
//#define SERVER_NGINX_DOMAIN       @"wsk/"


@interface ServerURL : NSObject

//设置与服务器端交互的ip&port
+ (void)initServerURL;

+ (NSString *)getWholeURL:(NSString *)strURL;
+ (NSString *)getUploadFileURL;
+ (NSString *)getVersionUpdateURL;
+ (void)setVersionUpdateURL:(NSString*)strUpdateAppURL;

+ (NSString *)getFormatSessionID;
+ (NSString *)getFormatChatSessionID;

//ngnix url////////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)getCustomTicketURL;

+ (NSString *)getLoginToRESTServerURL;
+ (NSString *)getLogoutActionURL;
+ (NSString *)getSetLanguageURL;
+ (NSString *)getLoginInfoURL;
+ (NSString *)getMessageListPersonalURL;
+ (NSString *)getMessageListFromMeURL;
+ (NSString *)getSessionMsgListURL;
+ (NSString *)getEditUserPasswordURL;
+ (NSString *)getUserDetailURL;
+ (NSString *)getSyncAllMemberURL;
+ (NSString *)getEditUserInfoURL;
+ (NSString *)getAllGroupListURL;
+ (NSString *)getCreateGroupURL;
+ (NSString *)getEditGroupURL;
+ (NSString *)getDismissGroupURL;
+ (NSString *)getTransferGroupURL;
+ (NSString *)getJoinGroupURL;
+ (NSString *)getExitGroupURL;
+ (NSString *)getGroupMemberListURL;
+ (NSString *)getPublishMsgURL;
+ (NSString *)getDeleteMessageURL;
+ (NSString *)getShareDetailBlog;
+ (NSString *)getSharePaiserBlog;
+ (NSString *)getCommentListBlog;
+ (NSString *)getCreateComment;
+ (NSString *)getDeleteComment;
+ (NSString *)getOperateVoteURL;
+ (NSString *)getOperateScheduleURL;
+ (NSString *)getAddTagToMessageURL;
+ (NSString *)getRemoveTagFromMessageURL;
+ (NSString *)getCreateAlbumFolderURL;
+ (NSString *)getModifyAlbumFolderURL;
+ (NSString *)getRemoveAlbumFolderURL;
+ (NSString *)getMyAlbumFolderInfoURL;
+ (NSString *)getPublicAlbumFolderInfoURL;
+ (NSString *)getGroupAlbumFolderInfoURL;
+ (NSString *)getImageFolderFromIDURL;
+ (NSString *)getAddImageIntoFolderURL;
+ (NSString *)getAddImagesIntoFolderURL;
+ (NSString *)getRemoveImageFromFolderURL;
+ (NSString *)getRemoveImagesFromFolderURL;
+ (NSString *)getCopyImageToPublicURL;
+ (NSString *)getAddImageCommentURL;
+ (NSString *)getQueryImagePraiseURL;
+ (NSString *)getQueryImageDetailInfoURL;
+ (NSString *)getPraiseImageURL;
+ (NSString *)getSearchMessageListURL;
+ (NSString *)getPublishShare;
+ (NSString *)getShareDraft;
+ (NSString *)getMessageListFromDraftURL;
+ (NSString *)getMessageDetailURL;
+ (NSString *)getQuestListURL;
+ (NSString *)getQuestHotListURL;
+ (NSString *)getQuestUnAnswerListURL;
+ (NSString *)getQuestDetailURL;
+ (NSString *)getQuestDeleteURL;
+ (NSString *)getAnswerDeleteURL;
+ (NSString *)getAnswerSolutionURL;
+ (NSString *)getAnswerPaiserURL;
+ (NSString *)getAllNotifyTypeUnreadNumURL;
+ (NSString *)getMyNotifyListURL;
+ (NSString *)getGroupNotifyListURL;
+ (NSString *)getSetAllNotifyToReadURL;
+ (NSString *)getMessageListMyGroupURL;
+ (NSString *)getMessageListMyAllURL;
+ (NSString *)getQuestPaiserURL;
+ (NSString *)getAskUserURL;
+ (NSString *)getNoticeListURL;
+ (NSString *)getCreateAnswerURL;
+ (NSString *)getCreateQuestURL;
+ (NSString *)getDeleteSingleChatMsgURL;
+ (NSString *)getHistoryChatGroupURL;
+ (NSString *)getMyAttentionUserListURL;
+ (NSString *)getIntegrationSortURL;
+ (NSString *)getAddAttentionURL;
+ (NSString *)getCancelAttentionURL;
+ (NSString *)getSendIdentifyingCodeURL;
+ (NSString *)getRegisterUserURL;
+ (NSString *)getSetNotifyTypeToReadURL;
+ (NSString *)getSendChangePwdIdentifyingCodeURL;
+ (NSString *)getChangePasswordURL;
+ (NSString *)getDeleteShareArticleURL;
+ (NSString *)getSetTheNoticeToReadURL;
+ (NSString *)getSearchShareListURL;
+ (NSString *)getSearchQAListURL;

//聊天记录/////////////////////////////////////////////////////////////////////////////////
+ (NSString *)getHistoryChatSessionURL;
+ (NSString *)getSendSingleChatURL;
+ (NSString *)getSingleChatConByCIdURL;
+ (NSString *)getHistoryChatUserURL;
+ (NSString *)getSendGroupChatURL;
+ (NSString *)getGroupChatConByCIdURL;
+ (NSString *)getGroupHistoryChatURL;
+ (NSString *)getCreateOrUpdateChatDiscussionURL;
+ (NSString *)getChatGroupInfoURL;
+ (NSString *)getSetPushSwitchURL;
+ (NSString *)getSetTopChatURL;
+ (NSString *)getDeleteChatGroupMemberURL;
+ (NSString *)getSelfExitChatGroupURL;
+ (NSString *)getTransferChatGroupAdminURL;
+ (NSString *)getChatSingleInfoURL;
+ (NSString *)getClearChatRecordURL;
+ (NSString *)getDeleteChatSessionByIDURL;
+ (NSString *)getRenameChatDiscussionURL;
///////////////////////////////////////////////////////////////////////////////////
+ (NSString *)getAddCollectionURL;
+ (NSString *)getCancelCollectionURL;
+ (NSString *)getCollectionBlogURL;
+ (NSString *)getCollectionQuestionURL;
+ (NSString *)getNoticeNumURL;
+ (NSString *)getFolderListURL;
+ (NSString *)getCreateFolderURL;
+ (NSString *)getModifyFolderURL;
+ (NSString *)getDeleteFolderURL;
+ (NSString *)getFileListByFolderIDURL;
+ (NSString *)getDeleteFileURL;
+ (NSString *)getUploadFileToFolderURL;
+ (NSString *)getDrawLotteryActionURL;
+ (NSString *)getHotShareBlogURL;
+ (NSString *)getActivityListURL;
+ (NSString *)getActivityProjectListURL;
+ (NSString *)getSignupActivityProjectURL;
+ (NSString *)getActivityProjectUserListURL;
+ (NSString *)getActivityProjectByIDURL;
+ (NSString *)getShareInfoURL;
+ (NSString *)getQuestionSurveyURL;
+ (NSString *)getQuestionListURL;
+ (NSString *)getCommitSurveyURL;
+ (NSString *)getBlogCommentListByPageURL;
+ (NSString *)getPraiseShareCommentURL;
+ (NSString *)getTagVoListByTypeURL;
+ (NSString *)getShareBlog;
////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)getCustomerList;
+ (NSString *)getCustomerDetailURL;
+ (NSString *)getUpdateCustomerURL;
+ (NSString *)getSendScoreLinkURL;

+ (NSString *)getSessionDetailURL;
+ (NSString *)getSendSessionMessageURL;
+ (NSString *)getTransferSessionURL;
+ (NSString *)getSuspendSessionURL;
+ (NSString *)getCloseSessionURL;
+ (NSString *)getAllOnLineKefuURL;
+ (NSString *)getFAQListURL;
+ (NSString *)getSendRichFAQ;
+ (NSString *)getSessionStatusNumURL;
+ (NSString *)getTicketListURL;
+ (NSString *)getTicketDetailURL;
+ (NSString *)getTicketTypeListURL;
+ (NSString *)getAddTicketRecordURL;
+ (NSString *)getTransferTicketToEmailURL;
+ (NSString *)getCloseTicketURL;
+ (NSString *)getMergeTicketURL;
+ (NSString *)getSaveTicketURL;
+ (NSString *)getUploadLocationURL;

+ (NSString *)getWODEDetailUR;
+ (NSString *)getWOImage;
+ (NSString *)setWODetailURL;
+ (NSString *)getUserInformationURL;//获取个人信息接口
+ (NSString *)getWODeatilArray;//获取详情
+ (NSString *)setRecordURL;//添加记录接口
#pragma =================我的工单详情===================================

+ (NSString *)setRecordImageURL;
+ (NSString *)getToGetTheCompanyName;
+ (NSString *)getQiangTicketList;
+ (NSString *)setQiangUrl;
+ (NSString *)getUserDetailURLForMe;
+ (NSString *)LocationUrl;
+ (NSString *)commentWork;

@end
