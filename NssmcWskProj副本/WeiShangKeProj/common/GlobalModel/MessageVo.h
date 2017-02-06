//
//  MessageVo.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-18.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LotteryVo.h"

@interface MessageVo : NSObject

@property (nonatomic, strong) NSString *strID;                  //消息Id
@property (nonatomic, strong) NSString *strTitle;               //消息标题
@property (nonatomic, strong) NSString *strTitleID;             //标题id,类似会话ID
@property (nonatomic, strong) NSString *strHtmlContent;         //消息内容html文本题
@property (nonatomic, strong) NSString *strTextContent;         //消息内容的纯文本
@property (nonatomic, strong) NSString *strMsgType;             //M-正文;D-草稿;A-提交审批;N-通知

@property (nonatomic) int nComeFromType;                            //0-web ;1-ios,2-android; 3-RSS; 4-Email; 5-微博 ; 6-微信;
@property (nonatomic, strong) NSMutableArray * aryReceiverList;     //收件人list
@property (nonatomic, strong) NSMutableArray * aryCCList;           //抄送人list
@property (nonatomic, strong) NSMutableArray * aryBCCList;          //密送人list
@property (nonatomic, strong) NSString *strParentID;                  //转发博文id

@property (nonatomic, strong) NSString *strParentText;                  //转发博文内容
@property (nonatomic, strong) NSString *strParentAuthorID;               //转发博文作者id
@property (nonatomic, strong) NSString *strContentType;         //关联类型	A-附件，B-约会，C-投票
@property (nonatomic, strong) NSString *strCreateDate;          //创建日期
@property (nonatomic, strong) NSString *strAuthorID;            //作者ID

@property (nonatomic, strong) NSString *strAuthorName;            //作者姓名
@property (nonatomic, strong) NSString *strAuthorHeadImg;            //作者头像
@property (nonatomic) int nDeleteFlag;              //删除标识
@property (nonatomic, strong) VoteVo *voteVo;
@property (nonatomic, strong) ScheduleVo *scheduleVo;
@property (nonatomic, strong) LotteryVo *lotteryVo;

@property (nonatomic, strong) NSString *strReturnID;            //回复自父消息id
@property (nonatomic, strong) NSMutableArray *aryAttachmentList;  //附件列表
@property (nonatomic, strong) NSMutableArray *aryImageList;  //图片列表
@property (nonatomic, strong) NSMutableArray *aryTagList;  //标签ID列表
@property (nonatomic) int  nUnreader;                     //未读标志（0:已读邮件,1:未读邮件,2:再次编辑后未读邮件,3:已转发或已回复的邮件）

@property (nonatomic) NSInteger  nSendAllPeople;      //是否发给所有人 (1:是,0:否)
//外部邮箱
@property (nonatomic, strong) NSMutableArray *aryReceiveEmail;  //外部邮箱收件人
@property (nonatomic, strong) NSMutableArray *aryCCEmail;       //外部邮箱抄送人
@property (nonatomic, strong) NSMutableArray *aryBCEmail;       //外部邮箱密送人

@property (nonatomic) BOOL  bHasStarTag;        //是否有星标



@end
