//
//  ServerURL.m
//  CorpKnowlGroup
//
//  Created by yuson on 11-8-12.
//  Copyright 2011 DNE. All rights reserved.
//

#import "ServerURL.h"

static NSString *g_domain           = SERVER_DOMAIN;
static NSString *g_chatDomain       = SERVER_CHAT_DOMAIN;
static NSString *g_nginxDomain      = SERVER_NGINX_DOMAIN;
static NSString *g_serverURL		= @"";
static NSString *g_chatServerURL	= @"";
static NSString *g_nginxServerURL	= @"";

static NSString *g_updateAppURL	= @"";
static NSString *g_loginToRESTServerURL = @"mobilelogin";
static NSString *g_logoutActionURL = @"mobilelogout";
static NSString *g_setLanguageURL = @"mobile/language";///{locale}
static NSString *g_getLoginInfoURL  = @"mobile/user/current";
static NSString *g_messageListMyAllURL = @"mobile/search/stream/toMe";
static NSString *g_getMessageListPersonalURL  = @"mobile/search/stream/toMyself";
static NSString *g_messageListMyGroupURL  = @"mobile/search/stream/myTeam";
static NSString *g_getMessageListFromMeURL  = @"mobile/search/stream/fromMe";
static NSString *g_messageListFromDraftURL = @"mobile/search/stream/draft";
static NSString *g_noticeListURL = @"mobile/notice/list";

static NSString *g_uploadFileURL	= @"mobile/attachment/fileUpload";
static NSString *g_sessionMsgListURL	= @"mobile/stream/returnList";//{titleId}
static NSString *g_editUserPasswordURL	= @"mobile/user/updateSelfPasswd";
static NSString *g_userDetailURL	= @"mobile/user";//{id}
static NSString *g_userDetailURLForMe	= @"mobile/user/current";//{id}

static NSString *g_syncAllMemberURL	= @"mobile/webUser/userContacts";
static NSString *g_editUserInfoURL	= @"mobile/webUser/update";
static NSString *g_allGroupListURL	= @"mobile/team/queryAllTeam";
static NSString *g_createGroupURL	= @"mobile/team/addteam";
static NSString *g_editGroupURL	= @"mobile/team/updateTeamInfo";
static NSString *g_dismissGroupURL	= @"mobile/team/deleteTeam";
static NSString *g_transferGroupURL	= @"mobile/team/updateTeamcreater";
static NSString *g_joinGroupURL	= @"mobile/team/addMember";
static NSString *g_exitGroupURL	= @"mobile/team/deleteMember";
static NSString *g_groupMemberListURL	= @"mobile/team/queryTeamMembers";
static NSString *g_publishMsgURL	= @"mobile/stream/new";
static NSString *g_deleteMessageURL	= @"mobile/stream/delete";//--/{id}
static NSString *g_shareBlog	= @"mobile/blog/blogs";
static NSString *g_shareDetailBlog	= @"mobile/blog";
static NSString *g_sharePaiserBlog	= @"mobile/blog/mentionBlog";
static NSString *g_commentListBlog	= @"mobile/blogComment/comments";
static NSString *g_createComment	= @"mobile/blogComment/create";
static NSString *g_deleteComment	= @"mobile/blogComment/delete";
static NSString *g_operateVote	= @"mobile/vote/reply";
static NSString *g_operateSchedule	= @"mobile/schedule/reply";
static NSString *g_addTagToMessageURL	= @"mobile/tag/add";//--/{streamId}/{tagIds}
static NSString *g_removeTagFromMessageURL	= @"mobile/tag/delete";//--/{streamId}/{tagId}

static NSString *g_createAlbumFolderURL         = @"mobile/imageFolder/addImageFolder";
static NSString *g_modifyAlbumFolderURL         = @"mobile/imageFolder/updateImageFolder";
static NSString *g_removeAlbumFolderURL         = @"mobile/imageFolder/deleteImageFolder";//--/id
static NSString *g_getMyFolderURL               = @"mobile/imageFolder/myfolder";
static NSString *g_getGroupFolderURL            = @"mobile/imageFolder/queryfolder";
static NSString *g_getPublicFolderURL           = @"mobile/imageFolder/queryfolder";
static NSString *g_getImageFolderURL            = @"mobile/imageFolder/findImageFolderById";//--/id
static NSString *g_addImageIntoFolderURL        = @"mobile/imageFolder/addImage";
static NSString *g_addImagesIntoFolderURL       = @"mobile/imageFolder/addImages";
static NSString *g_removeImageFromFolderURL     = @"mobile/imageFolder/deleteImage";
static NSString *g_removeImagesFromFolderURL    = @"mobile/imageFolder/deleteImages";
static NSString *g_copyImageToPublicURL         = @"mobile/imageFolder/addImageToSystem";
static NSString *g_addImageCommentURL         = @"mobile/imageFolder/addImageComment";
static NSString *g_queryImagePraiseURL        = @"mobile/imageFolder/queryPraise";//--/id
static NSString *g_queryImageDetailInfoURL    = @"mobile/imageFolder/imageById";//-/id
static NSString *g_praiseImageURL             = @"mobile/imageFolder/addImageMention";
static NSString *g_publishShare               = @"mobile/blog/create";
static NSString *g_ShareDraft                 = @"mobile/blog/drafts";
static NSString *g_searchMessageListURL    = @"mobile/search/stream/list";
static NSString *g_messageDetailURL        = @"mobile/stream";//-{id}
static NSString *g_questNewListURL         = @"mobile/question/question";
static NSString *g_questHotListURL         = @"mobile/question/hotQuestion";
static NSString *g_questUnAnswerListURL    = @"mobile/question/unAnswerQuestion";
static NSString *g_questDetailURL          = @"mobile/question/questionDetails";

static NSString *g_questDeleteURL          = @"mobile/question/delete";
static NSString *g_answerDeleteURL         = @"mobile/answer/delete";
static NSString *g_answerSolutionURL       = @"mobile/answer/solutionQuestion";
static NSString *g_answerPaiserURL         = @"mobile/answer/mentionAnswer";
static NSString *g_questPaiserURL          = @"mobile/question/mentionQuestion";
static NSString *g_askUserURL              = @"mobile/question/askUser";
static NSString *g_createAnswerURL         = @"mobile/answer/create";
static NSString *g_createQuestURL          = @"mobile/question/create";

static NSString *g_historyChatSessionURL = @"mobile/talks";
static NSString *g_sendSingleChatURL = @"api/smessage";
static NSString *g_historyChatUserURL = @"mobile/messages";
static NSString *g_singleChatConByCIdURL = @"api/smessage";//--/{id}
static NSString *g_sendGroupChatURL = @"api/gmessage";
static NSString *g_groupHistoryChatURL = @"api/findGMessage";
static NSString *g_groupChatConByCId = @"api/gmessage";//--/{id}
static NSString *g_createOrUpdateChatDiscussionURL = @"api/invite";
static NSString *g_chatGroupInfoURL = @"api/getGroup";
static NSString *g_setPushSwitchURL = @"api/pushBlackList";
static NSString *g_setTopChatURL           = @"api/stick";
static NSString *g_deleteChatGroupMemberURL = @"api/reject";
static NSString *g_selfExitChatGroupURL     = @"api/exitGroup";
static NSString *g_transferChatGroupAdminURL    = @"api/handOver";
static NSString *g_chatSingleInfoURL        = @"api/getWhisperSet";
static NSString *g_clearChatRecordURL       = @"api/clearChatRecord";
static NSString *g_deleteChatSessionByIDURL = @"api/removeHistorySession";
static NSString *g_renameChatDiscussionURL  = @"api/renameGroup";

static NSString *g_noticeNumURL = @"mobile/stream/unread";
static NSString *g_allNotifyTypeUnreadNumURL = @"mobile/remind/allRemindCount";
static NSString *g_myNotifyListURL = @"mobile/remind/getMyselfRemindList";//mobile/remind/myselfRemind";
static NSString *g_groupNotifyListURL = @"mobile/remind/getTeamRemindList";//mobile/remind/teamRemind";
static NSString *g_setAllNotifyToReadURL = @"mobile/remind/setAllMessagesWereRead";
static NSString *g_deleteSingleChatMsgURL = @"mobile/chat/deleteChatMessageHistory";//--/{toUserId}
static NSString *g_historyChatGroupURL = @"mobile/chat/team/chatTeamSession";
static NSString *g_myAttentionUserListURL = @"mobile/webUser/getAttentionListByPage";
static NSString *g_integrationSortURL = @"mobile/webUser/findUsersByIntegral";
static NSString *g_addAttentionURL = @"mobile/relation/addRelation";
static NSString *g_cancelAttentionURL = @"mobile/relation/cancelRelation";
static NSString *g_registerUserURL = @"register";
static NSString *g_sendIdentifyingCodeURL = @"business/email/sendEmail";
static NSString *g_setNotifyTypeToReadURL = @"mobile/remind/setOneMessageWasRead";
static NSString *g_sendChangePwdIdentifyingCodeURL = @"register/forgotpw?loginName=";
static NSString *g_changePasswordURL = @"/mobile/user/resetSelfPasswd";
static NSString *g_deleteShareArticleURL = @"mobile/blog/delete";//--/{id}
static NSString *g_setTheNoticeToReadURL = @"mobile/remind/setOneRemindHasReaded";//--/{id}
static NSString *g_searchShareListURL = @"mobile/blog/fuzzyBlogs";
static NSString *g_searchQAListURL = @"mobile/question/fuzzyQuestions";
static NSString *g_addCollectionURL = @"mobile/store/create";
static NSString *g_cancelCollectionURL = @"mobile/store/delete";
static NSString *g_collectionBlogURL = @"mobile/store/blogs";
static NSString *g_collectionQuestionURL = @"mobile/store/questions";
static NSString *g_folderListURL = @"mobile/document/folderList";
static NSString *g_createFolderURL = @"mobile/document/addFolder";
static NSString *g_modifyFolderURL = @"mobile/document/updateFolder";
static NSString *g_deleteFolderURL = @"mobile/document/delFolder";//--/{folderId}
static NSString *g_fileListByFolderIDURL = @"mobile/document/fileList";//--/{folderId}
static NSString *g_deleteFileURL = @"mobile/document/delFile";//--/{id}
static NSString *g_uploadFileToFolderURL = @"mobile/document/addFileToFolder";//--/{folderId}/{fileId}
static NSString *g_drawLotteryActionURL = @"mobile/lottery";
static NSString *g_hotShareBlogURL = @"mobile/blog/hotBlog";//-/{pageNumber}
static NSString *g_activityListURL = @"mobile/blog/blogs";
static NSString *g_activityProjectListURL = @"mobile/signup/findProject";//--/{blogId}
static NSString *g_signupActivityProjectURL = @"mobile/signup/signupProject";
static NSString *g_activityProjectUserListURL = @"mobile/signup/signupListForCreator";//--/{pid}
static NSString *g_activityProjectByIDURL = @"mobile/signup/projectDetail";//--/{pid}
static NSString *g_shareInfoURL = @"mobile/snapshot/snapshot";
static NSString *g_questionSurveyURL = @"mobile/survey/table";//--/{id}
static NSString *g_questionListURL = @"mobile/survey/field/list";//--/{id}
static NSString *g_commitSurveyURL = @"mobile/survey/values/submit";//--/{id}
static NSString *g_blogCommentListByPageURL = @"mobile/blogComment/commentList";
static NSString *g_praiseShareCommentURL = @"mobile/blogComment/mention";//--/{id}
static NSString *g_tagVoListByTypeURL = @"mobile/tag/search";//--/{id}
static NSString *g_toGetTheCompanyName = @"business/company/list";
//新版URL/////////////////////////////////////////////////////////////////////////////////////////
static NSString *g_customerList = @"mobile/customer";
static NSString *g_customerDetailURL = @"mobile/customer/talk";
static NSString *g_updateCustomerURL = @"mobile/customer/save";

static NSString *g_sessionDetailURL = @"mobile/messages";
static NSString *g_sendSessionMessageURL = @"mobile/messages/reply";
static NSString *g_transferSessionURL = @"mobile/talks/transfer";
static NSString *g_suspendSessionURL = @"mobile/talks/pending";
static NSString *g_closeSessionURL = @"mobile/talks/close";
static NSString *g_allOnLineKefuURL = @"mobile/user/online";
static NSString *g_FAQListURL = @"mobile/faq/search";
static NSString *g_sendRichFAQ = @"mobile/faq/material";
static NSString *g_sendScoreLinkURL = @"mobile/talks/giveMeScore";
static NSString *g_sessionStatusNumURL = @"mobile/talks/status";
static NSString *g_ticketListURL = @"mobile/ns/TMalfunctionDetailList?action=get";//LinkInfoservlet/TMalfunctionDetail
static NSString *g_ticketDetailURL = @"mobile/workOrder";
static NSString *g_ticketTypeListURL = @"mobile/workOrder/types";
static NSString *g_addTicketRecordURL = @"mobile/workOrder/track/create";
static NSString *g_transferTicketToEmailURL = @"mobile/workOrder/mail";
static NSString *g_closeTicketURL = @"mobile/workOrder/close";
static NSString *g_mergeTicketURL = @"mobile/workOrder/merge";
static NSString *g_saveTicketURL = @"mobile/workOrder/save";

//郭红旗
static NSString *g_ticketListDetailURL = @"/mobile/ns/TMalfunctionDetail?action=get";
static NSString *g_ticketListsetDetailURL = @"/mobile/ns/TMalfunctionDetail?action=set";

static NSString *g_ticketListImage = @"/mobile/ns/TAttatch?action=get";
static NSString *s_setTicketListImage = @"/mobile/ns/TAttatch?action=set";
static NSString *g_UserInformation = @"/mobile/user/current";
static NSString *g_detailArray = @"/mobile/ns/TDetailRecord?action=get";
static NSString *s_detailArray = @"/mobile/ns/TDetailRecord?action=set";
static NSString *s_upLoadUrl = @"/mobile/fileUpload";
static NSString *g_ticketQiangList = @"/mobile/ns/TOrderMalfunctionDetailList?action=get";
static NSString *s_ticketQiangListDetail = @"/mobile/ns/TCompetitionForOrders?action=set";
static NSString *locationUrl = @"http://api.map.baidu.com/geodata/v3/poi/list";


//ngnix url////////////////////////////////////////////////////////////////////////////////////////
static NSString *g_customTicketURL = @"crumbs/order.html#/?refId=";


//新日铁URL/////////////////////////////////////////////////////////////////////////////////////////
static NSString *g_uploadLocationURL = @"XXXX";

@implementation ServerURL

+(NSString *)LocationUrl{
    return locationUrl;
}
//设置与服务器端交互的ip&port
+ (void)initServerURL
{
    [ServerURL initRestServerURL];
    [ServerURL initChatServerURL];
    [ServerURL initNginxServerURL];
}

+ (void)initRestServerURL
{
    NSString *strUrlPrefix = nil;
    NSString *strIP = SERVER_IP;
    NSString *strPort = SERVER_PORT;
    if(![strIP hasPrefix:@"http://"])
    {
        strIP = [NSString stringWithFormat:@"http://%@",strIP];
    }
    
    if (strPort == nil || strPort.length == 0)
    {
        strUrlPrefix = [NSString stringWithFormat:@"%@",strIP];
    }
    else
    {
        strUrlPrefix = [NSString stringWithFormat:@"%@:%@",strIP,strPort];
    }
    
    //check the strUrlPrefix contain "/"
    NSString *serverURL = nil;
    if ([strUrlPrefix hasSuffix:@"/"])
    {
        serverURL = [NSString stringWithFormat:@"%@%@",strUrlPrefix,g_domain];
    }
    else
    {
        serverURL = [NSString stringWithFormat:@"%@/%@",strUrlPrefix,g_domain];
    }
    
    g_serverURL = [serverURL copy];
}

+ (void)initChatServerURL
{
    NSString *strUrlPrefix = nil;
    NSString *strIP = SERVER_CHAT_IP;
    NSString *strPort = SERVER_CHAT_PORT;
    if(![strIP hasPrefix:@"http://"])
    {
        strIP = [NSString stringWithFormat:@"http://%@",strIP];
    }
    
    if (strPort == nil || strPort.length == 0)
    {
        strUrlPrefix = [NSString stringWithFormat:@"%@",strIP];
    }
    else
    {
        strUrlPrefix = [NSString stringWithFormat:@"%@:%@",strIP,strPort];
    }
    
    //check the strUrlPrefix contain "/"
    NSString *serverURL = nil;
    if ([strUrlPrefix hasSuffix:@"/"])
    {
        serverURL = [NSString stringWithFormat:@"%@%@",strUrlPrefix,g_chatDomain];
    }
    else
    {
        serverURL = [NSString stringWithFormat:@"%@/%@",strUrlPrefix,g_chatDomain];
    }
    
    g_chatServerURL = [serverURL copy];
}

+ (void)initNginxServerURL
{
    NSString *strUrlPrefix = nil;
    NSString *strIP = SERVER_NGINX_IP;
    NSString *strPort = SERVER_NGINX_PORT;
    if(![strIP hasPrefix:@"http://"])
    {
        strIP = [NSString stringWithFormat:@"http://%@",strIP];
    }
    
    if (strPort == nil || strPort.length == 0)
    {
        strUrlPrefix = [NSString stringWithFormat:@"%@",strIP];
    }
    else
    {
        strUrlPrefix = [NSString stringWithFormat:@"%@:%@",strIP,strPort];
    }
    
    //check the strUrlPrefix contain "/"
    NSString *serverURL = nil;
    if ([strUrlPrefix hasSuffix:@"/"])
    {
        serverURL = [NSString stringWithFormat:@"%@%@",strUrlPrefix,g_nginxDomain];
    }
    else
    {
        serverURL = [NSString stringWithFormat:@"%@/%@",strUrlPrefix,g_nginxDomain];
    }
    
    g_nginxServerURL = [serverURL copy];
}

+ (NSString *)getWholeURL:(NSString *)strURL
{
    NSString *strRetURL = @"";
    if (strURL == nil || (id)strURL == [NSNull null])
    {
        strRetURL = @"";
    }
    else
    {
        strRetURL = [NSString stringWithFormat:@"%@%@",g_serverURL,strURL];
    }
    return strRetURL;
}

+ (NSString *)getUploadFileURL
{
	return [NSString stringWithFormat:@"%@%@", g_serverURL, g_uploadFileURL];
}

//+ (NSString *)getVersionUpdateURL
//{
//    //版本更新URL
//    return g_updateAppURL;
//}

+ (void)setVersionUpdateURL:(NSString*)strUpdateAppURL
{
    g_updateAppURL = strUpdateAppURL;
}

+ (NSString *)getFormatSessionID
{
	return [NSString stringWithFormat:@";jsessionid=%@",[Common getSessionID]];
}

+ (NSString *)getFormatChatSessionID
{
	return [NSString stringWithFormat:@";nsid=%@",[Common getChatSessionID]];
}

//ngnix url////////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)getCustomTicketURL
{
    return [NSString stringWithFormat:@"%@%@",g_nginxServerURL,g_customTicketURL];
}

+ (NSString *)getLoginToRESTServerURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_loginToRESTServerURL];
}

+ (NSString *)getSetLanguageURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_setLanguageURL];
}

+ (NSString *)getLoginInfoURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_getLoginInfoURL];
}

+ (NSString *)getMessageListPersonalURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_getMessageListPersonalURL];
}

+ (NSString *)getMessageListFromMeURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_getMessageListFromMeURL];
}

+ (NSString *)getSessionMsgListURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_sessionMsgListURL];
}

+ (NSString *)getEditUserPasswordURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_editUserPasswordURL];
}
+(NSString *)getUserDetailURLForMe{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_userDetailURLForMe];

}

+ (NSString *)getUserDetailURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_userDetailURL];
}

+ (NSString *)getSyncAllMemberURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_syncAllMemberURL];
}

+ (NSString *)getEditUserInfoURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, @"mobile/user/update"];

}

+ (NSString *)getAllGroupListURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_allGroupListURL];
}

+ (NSString *)getCreateGroupURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_createGroupURL];
}

+ (NSString *)getEditGroupURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_editGroupURL];
}

+ (NSString *)getDismissGroupURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_dismissGroupURL];
}

+ (NSString *)getTransferGroupURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_transferGroupURL];
}

+ (NSString *)getJoinGroupURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_joinGroupURL];
}

+ (NSString *)getExitGroupURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_exitGroupURL];
}

+ (NSString *)getGroupMemberListURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_groupMemberListURL];
}

+ (NSString *)getPublishMsgURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_publishMsgURL];
}

+ (NSString *)getDeleteMessageURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_deleteMessageURL];
}

+ (NSString *)getShareDetailBlog
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_shareDetailBlog];
}

+ (NSString *)getSharePaiserBlog
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_sharePaiserBlog];
}

+ (NSString *)getCommentListBlog
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_commentListBlog];
}

+ (NSString *)getCreateComment
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_createComment];
}

+ (NSString *)getDeleteComment
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_deleteComment];
}

+ (NSString *)getOperateVoteURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_operateVote];
}

+ (NSString *)getOperateScheduleURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_operateSchedule];
}

+ (NSString *)getAddTagToMessageURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_addTagToMessageURL];
}

+ (NSString *)getRemoveTagFromMessageURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_removeTagFromMessageURL];
}

+ (NSString *) getCreateAlbumFolderURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_createAlbumFolderURL];
}

+ (NSString *) getModifyAlbumFolderURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_modifyAlbumFolderURL];
}

+ (NSString *) getRemoveAlbumFolderURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_removeAlbumFolderURL];
}

+ (NSString *) getMyAlbumFolderInfoURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_getMyFolderURL];
}

+ (NSString *) getPublicAlbumFolderInfoURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_getPublicFolderURL];
}
+ (NSString *)getUserInformationURL{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_UserInformation];
}
+ (NSString *) getGroupAlbumFolderInfoURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_getGroupFolderURL];
}

+ (NSString *) getImageFolderFromIDURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_getImageFolderURL];
}

+ (NSString *) getAddImageIntoFolderURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_addImageIntoFolderURL];
}

+ (NSString *) getAddImagesIntoFolderURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_addImagesIntoFolderURL];
}

+ (NSString *) getRemoveImageFromFolderURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_removeImageFromFolderURL];
}

+ (NSString *) getRemoveImagesFromFolderURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_removeImagesFromFolderURL];
}

+ (NSString *) getCopyImageToPublicURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_copyImageToPublicURL];
}

+ (NSString *) getAddImageCommentURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_addImageCommentURL];
}

+ (NSString *)getQueryImagePraiseURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_queryImagePraiseURL];
}

+ (NSString *)getQueryImageDetailInfoURL;
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_queryImageDetailInfoURL];
}

+(NSString *)getPraiseImageURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_praiseImageURL];
}

+(NSString *)getSearchMessageListURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_searchMessageListURL];
}

+(NSString *)getPublishShare
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_publishShare];
}

+(NSString *)getShareDraft
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_ShareDraft];
}

+ (NSString *)getMessageListFromDraftURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_messageListFromDraftURL];
}

+ (NSString *)getMessageDetailURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_messageDetailURL];
}

+ (NSString *)getQuestListURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_questNewListURL];
}

+ (NSString *)getQuestHotListURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_questHotListURL];
}

+ (NSString *)getQuestUnAnswerListURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_questUnAnswerListURL];
}

+ (NSString *)getQuestDetailURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_questDetailURL];
}

+ (NSString *)getQuestDeleteURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_questDeleteURL];
}

+ (NSString *)getAnswerDeleteURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_answerDeleteURL];
}

+ (NSString *)getAnswerSolutionURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_answerSolutionURL];
}

+ (NSString *)getAnswerPaiserURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_answerPaiserURL];
}

+ (NSString *)getQuestPaiserURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_questPaiserURL];
}

+ (NSString *)getAllNotifyTypeUnreadNumURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_allNotifyTypeUnreadNumURL];
}

+ (NSString *)getMyNotifyListURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_myNotifyListURL];
}

+ (NSString *)getGroupNotifyListURL
{
     return [NSString stringWithFormat:@"%@%@",g_serverURL,g_groupNotifyListURL];
}

+ (NSString *)getSetAllNotifyToReadURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_setAllNotifyToReadURL];
}

+ (NSString *)getMessageListMyGroupURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_messageListMyGroupURL];
}

+ (NSString *)getMessageListMyAllURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_messageListMyAllURL];
}

+ (NSString *)getAskUserURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_askUserURL];
}

+ (NSString *)getNoticeListURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_noticeListURL];
}

+ (NSString *)getCreateAnswerURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_createAnswerURL];
}

+ (NSString *)getCreateQuestURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_createQuestURL];
}

+ (NSString *)getDeleteSingleChatMsgURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_deleteSingleChatMsgURL];
}

+ (NSString *)getHistoryChatGroupURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_historyChatGroupURL];
}

+ (NSString *)getMyAttentionUserListURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_myAttentionUserListURL];
}

+ (NSString *)getIntegrationSortURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_integrationSortURL];
}

+ (NSString *)getAddAttentionURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_addAttentionURL];
}

+ (NSString *)getCancelAttentionURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_cancelAttentionURL];
}

+ (NSString *)getRegisterUserURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_registerUserURL];
}

+ (NSString *)getSendIdentifyingCodeURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_sendIdentifyingCodeURL];
}

+ (NSString *)getToGetTheCompanyName
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_toGetTheCompanyName];
}

+ (NSString *)getSetNotifyTypeToReadURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_setNotifyTypeToReadURL];
}

+ (NSString *)getSendChangePwdIdentifyingCodeURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_sendChangePwdIdentifyingCodeURL];
}

+ (NSString *)getChangePasswordURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_changePasswordURL];
}

+ (NSString *)getDeleteShareArticleURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_deleteShareArticleURL];
}

+ (NSString *)getSetTheNoticeToReadURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_setTheNoticeToReadURL];
}

+ (NSString *)getSearchShareListURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_searchShareListURL];
}

+ (NSString *)getSearchQAListURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_searchQAListURL];
}

//聊天记录/////////////////////////////////////////////////////////////////////////////////
+ (NSString *)getHistoryChatSessionURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_historyChatSessionURL];
}

+ (NSString *)getSendSingleChatURL
{
    return [NSString stringWithFormat:@"%@%@",g_chatServerURL,g_sendSingleChatURL];
}

+ (NSString *)getSingleChatConByCIdURL
{
    return [NSString stringWithFormat:@"%@%@",g_chatServerURL,g_singleChatConByCIdURL];
}

+ (NSString *)getHistoryChatUserURL
{
    return [NSString stringWithFormat:@"%@%@",g_serverURL,g_historyChatUserURL];
}

+ (NSString *)getSendGroupChatURL
{
    return [NSString stringWithFormat:@"%@%@",g_chatServerURL,g_sendGroupChatURL];
}

+ (NSString *)getGroupChatConByCIdURL
{
    return [NSString stringWithFormat:@"%@%@", g_chatServerURL, g_groupChatConByCId];
}

+ (NSString *)getGroupHistoryChatURL
{
    return [NSString stringWithFormat:@"%@%@", g_chatServerURL, g_groupHistoryChatURL];
}

+ (NSString *)getCreateOrUpdateChatDiscussionURL
{
    return [NSString stringWithFormat:@"%@%@", g_chatServerURL, g_createOrUpdateChatDiscussionURL];
}

+ (NSString *)getChatGroupInfoURL
{
    return [NSString stringWithFormat:@"%@%@", g_chatServerURL, g_chatGroupInfoURL];
}

+ (NSString *)getSetPushSwitchURL
{
    return [NSString stringWithFormat:@"%@%@", g_chatServerURL, g_setPushSwitchURL];
}

+ (NSString *)getSetTopChatURL
{
    return [NSString stringWithFormat:@"%@%@", g_chatServerURL, g_setTopChatURL];
}

+ (NSString *)getDeleteChatGroupMemberURL
{
    return [NSString stringWithFormat:@"%@%@", g_chatServerURL, g_deleteChatGroupMemberURL];
}

+ (NSString *)getSelfExitChatGroupURL
{
    return [NSString stringWithFormat:@"%@%@", g_chatServerURL, g_selfExitChatGroupURL];
}

+ (NSString *)getTransferChatGroupAdminURL
{
    return [NSString stringWithFormat:@"%@%@", g_chatServerURL, g_transferChatGroupAdminURL];
}

+ (NSString *)getChatSingleInfoURL
{
    return [NSString stringWithFormat:@"%@%@", g_chatServerURL, g_chatSingleInfoURL];
}

+ (NSString *)getClearChatRecordURL
{
    return [NSString stringWithFormat:@"%@%@", g_chatServerURL, g_clearChatRecordURL];
}

+ (NSString *)getDeleteChatSessionByIDURL
{
    return [NSString stringWithFormat:@"%@%@", g_chatServerURL, g_deleteChatSessionByIDURL];
}

+ (NSString *)getRenameChatDiscussionURL
{
    return [NSString stringWithFormat:@"%@%@", g_chatServerURL, g_renameChatDiscussionURL];
}
///////////////////////////////////////////////////////////////////////////////////
+ (NSString *)getAddCollectionURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_addCollectionURL];
}

+ (NSString *)getCancelCollectionURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_cancelCollectionURL];
}

+ (NSString *)getCollectionBlogURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_collectionBlogURL];
}

+ (NSString *)getCollectionQuestionURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_collectionQuestionURL];
}

+ (NSString *)getNoticeNumURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_noticeNumURL];
}

+ (NSString *)getFolderListURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_folderListURL];
}

+ (NSString *)getCreateFolderURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_createFolderURL];
}

+ (NSString *)getModifyFolderURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_modifyFolderURL];
}

+ (NSString *)getDeleteFolderURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_deleteFolderURL];
}

+ (NSString *)getFileListByFolderIDURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_fileListByFolderIDURL];
}

+ (NSString *)getDeleteFileURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_deleteFileURL];
}

+ (NSString *)getUploadFileToFolderURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_uploadFileToFolderURL];
}

+ (NSString *)getLogoutActionURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_logoutActionURL];
}

+ (NSString *)getDrawLotteryActionURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_drawLotteryActionURL];
}

+ (NSString *)getHotShareBlogURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_hotShareBlogURL];
}

+ (NSString *)getActivityListURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_activityListURL];
}

+ (NSString *)getActivityProjectListURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_activityProjectListURL];
}

+ (NSString *)getSignupActivityProjectURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_signupActivityProjectURL];
}

+ (NSString *)getActivityProjectUserListURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_activityProjectUserListURL];
}

+ (NSString *)getActivityProjectByIDURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_activityProjectByIDURL];
}

+ (NSString *)getShareInfoURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_shareInfoURL];
}

+ (NSString *)getQuestionSurveyURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_questionSurveyURL];
}

+ (NSString *)getQuestionListURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_questionListURL];
}

+ (NSString *)getCommitSurveyURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_commitSurveyURL];
}

+ (NSString *)getBlogCommentListByPageURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_blogCommentListByPageURL];
}

+ (NSString *)getPraiseShareCommentURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_praiseShareCommentURL];
}

+ (NSString *)getTagVoListByTypeURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_tagVoListByTypeURL];
}

+ (NSString *)getShareBlog
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_shareBlog];
}

+ (NSString *)getCustomerList
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_customerList];
}

+ (NSString *)getCustomerDetailURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_customerDetailURL];
}

+ (NSString *)getUpdateCustomerURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_updateCustomerURL];
}

+ (NSString *)getSessionDetailURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_sessionDetailURL];
}

+ (NSString *)getSendSessionMessageURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_sendSessionMessageURL];
}

+ (NSString *)getTransferSessionURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_transferSessionURL];
}

+ (NSString *)getSuspendSessionURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_suspendSessionURL];
}

+ (NSString *)getCloseSessionURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_closeSessionURL];
}

+ (NSString *)getAllOnLineKefuURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_allOnLineKefuURL];
}

+ (NSString *)getFAQListURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_FAQListURL];
}

+ (NSString *)getSendRichFAQ
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_sendRichFAQ];
}

+ (NSString *)getSendScoreLinkURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_sendScoreLinkURL];
}

+ (NSString *)getSessionStatusNumURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_sessionStatusNumURL];
}
+ (NSString *)getWODEDetailUR{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_ticketListDetailURL];
}
+ (NSString *)setRecordImageURL{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, s_upLoadUrl];
    
}
//+ (NSString *)getUserDetailURL
+ (NSString *)setQiangUrl{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, s_ticketQiangListDetail];
//    return @"http://192.168.0.184:8081/wsk-ns/api//mobile/ns/TCompetitionForOrders?action=set";
}
+ (NSString *)getQiangTicketList{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_ticketQiangList];
    
}
+ (NSString *)setRecordURL{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, s_detailArray];
    
}
+ (NSString *)setWODetailURL{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_ticketListsetDetailURL];

}
+ (NSString *)commentWork{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, @"/mobile/ns/TMalfunctionDetail1?action=set"];
}

+ (NSString *)getWOImage{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_ticketListImage];
}
+ (NSString *)getWODeatilArray{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_detailArray];
}
+ (NSString *)getTicketListURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_ticketListURL];
}
//+ (NSString *)SetTicketDetailURL
//{
//    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_ticketDetailURL];
//}

+ (NSString *)getTicketDetailURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_ticketDetailURL];
}

+ (NSString *)getTicketTypeListURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_ticketTypeListURL];
}

+ (NSString *)getAddTicketRecordURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_addTicketRecordURL];
}

+ (NSString *)getTransferTicketToEmailURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_transferTicketToEmailURL];
}

+ (NSString *)getCloseTicketURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_closeTicketURL];
}

+ (NSString *)getMergeTicketURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_mergeTicketURL];
}

+ (NSString *)getSaveTicketURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_saveTicketURL];
}

+ (NSString *)getUploadLocationURL
{
    return [NSString stringWithFormat:@"%@%@", g_serverURL, g_uploadLocationURL];
}

@end
