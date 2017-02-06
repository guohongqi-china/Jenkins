//
//  BlogVo.h
//  Sloth
//
//  Created by Ann Yao on 12-9-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoteVo.h"
#import "ScheduleVo.h"
#import "LotteryVo.h"
#import "RedPacketVo.h"
#import "VideoPlayView.h"

typedef enum {
    PraiseStateNomal = 0,
    PraiseStatePraise
}PraiseState;

@interface BlogVo : NSObject

@property (nonatomic, retain) NSString *streamId;                 //博文Id
@property (nonatomic, retain) NSString *strTitle;                 //消息标题(问答，表示问题标题)
@property (nonatomic, retain) NSString *strContent;               //消息内容html文本题
@property (nonatomic, retain) NSString *strText;                  //消息内容的纯文本
@property (nonatomic, assign) NSInteger nComefrom;                //消息发布平台(0-web ; 1-android ; 2-iphone版; 10-国际联赛；11-中超联赛；14:会议报名)
@property (nonatomic) NSInteger nBlogType;                        //0-查分享 1-查活动；2－足球联赛 3-问卷调查
@property (nonatomic, strong) NSString *strBlogType;              //"blog"：分享；"vote": 投票；"qa":问答；"answer":回答；"activity":活动
@property (nonatomic, retain) NSString *orgId;                    //公司ID
@property (nonatomic, retain) NSString *strCreateDate;            //创建时间
@property (nonatomic, retain) NSString *strUpdateDate;            //修改时间
@property (nonatomic, retain) NSString *strCreateBy;              //创建者ID
@property (nonatomic, retain) NSString *strUpdateBy;              //修改者ID
@property (nonatomic, retain) NSString *strCreateByName;          //创建者姓名
@property (nonatomic, retain) NSString *strUpdateByName;          //修改者姓名


@property (nonatomic, assign) NSInteger nCommentCount;                  //评论数 (如果是问答则代表回答总数)
@property (nonatomic) NSInteger nCollectCount;                      //收藏的数量
@property (nonatomic, assign) NSInteger  nDelFlag;                      //删除标志
@property (nonatomic, retain) NSString * vestImg;                 //头像
@property (nonatomic) NSInteger nBadge;                           //勋章（用于头像显示）
@property (nonatomic) double fIntegral;                        //积分（用于头像显示）
@property (nonatomic, retain) NSString *strStartTime;             //查询开始时间
@property (nonatomic, retain) NSString *strEndTime;               //查询结束时间
@property (nonatomic, assign) NSInteger  isDraft;                       //是否是草稿(1-是，0-否)
@property (nonatomic, retain) NSString *strPictureUrl;
@property (nonatomic, strong) NSMutableArray *aryPictureUrl;       //分享中的前3个图片地址
@property (nonatomic, strong) NSMutableArray *aryVideoUrl;       //分享中的视频文件
@property (nonatomic, strong) NSMutableArray *aryMaxPictureUrl;    //高清图片

@property (nonatomic, assign) int nTranspondCount;                //转发数
@property (nonatomic, retain) NSString *strAnnexation;            //附加内容（）
@property (nonatomic, retain) NSString *strAnnexationSpezies;     //区分附加内容的种类
@property (nonatomic, retain) NSString *strObText;                //是否有文档
@property (nonatomic, assign) int   nIsAdmin;                     //是否是管理员发布的
@property (nonatomic, retain) NSString *strAgencyId;
@property (nonatomic, retain) NSString *strToSource;              //收件人列表
@property (nonatomic, assign) int  nSecInvisible;                 //秘书不可见
@property (nonatomic, retain) NSString *strReceiveUser;           //接收人 （自己实现）
@property (nonatomic, retain) NSString *strReceiveGroup;          //接收群组 （自己实现
@property (nonatomic, retain) VoteVo *voteVo;
@property (nonatomic, retain) ScheduleVo *scheduleVo;
@property (nonatomic, assign) int  nUnreader;                     //未读标志
@property (nonatomic, strong) LotteryVo *lotteryVo;               //抽奖视图
@property (nonatomic, strong) RedPacketVo *redPacketVo;               //红包视图

@property (nonatomic, retain) NSMutableArray *aryReceiverUser;   //接受用户列表
@property (nonatomic, retain) NSMutableArray *aryReceiverGroup;  //接受群组列表
@property (nonatomic, assign) BOOL bIsShow;
@property (nonatomic, retain) NSMutableArray *aryAttachmentList;  //附件列表
@property (nonatomic, retain) NSMutableArray *aryComment;  //评论列表（前三个评论）
@property (nonatomic, strong) NSMutableArray *aryTagList;  //标签VO列表

@property (nonatomic, retain) BlogVo *blogVoParent;               //源消息对象
@property (nonatomic, assign) int nTransferWorkCount;             //提交过秘书处理的次数
@property (nonatomic, retain) NSMutableArray *answearList;        //答案列表

@property (nonatomic)BOOL bCollection;  //是否已经收藏

@property (nonatomic, strong) UIImage *imgContent;                //缓存需要在列表里面显示的图片（默认第一张图）

@property (nonatomic, assign) NSInteger nPraiseCount;             //赞数
@property (nonatomic, strong) NSString *strMentionID;             //赞ID,id不为null则本人赞过，否则赞过
@property (nonatomic, strong) NSMutableArray *aryPraiseList;      //赞列表

//足球竞猜，包含的比赛场数
@property (nonatomic) NSInteger nContestNum;
@property (nonatomic) NSInteger nSurveyFlag;        //0：否；1：已提交,【当前用户是否已提交报名】
@property (nonatomic, strong) NSString *strRefID;   //引用ID，【会议报名ID】

//会议报名
@property (nonatomic) NSInteger nSignupMemberNum;//已报名人数
@property (nonatomic) NSInteger nTotalMemberNum;//报名人数上限
@property (nonatomic) BOOL bOverDue;//会议是否过期(true：过期；false：有效)
@property (nonatomic, strong) NSMutableArray *aryMeetingField;//会议自定义提交字段

//分享链接
@property (nonatomic, strong) NSString *strShareLink;   //分享的超链接
@property (nonatomic, strong) NSString *strLinkTitle;  //分享的超链接指向页面的 title 简介

//活动相关 - [活动积分]
@property (nonatomic, strong) NSMutableArray *aryActivityUser;      //活动已报名用户 - 前15用户列表
@property (nonatomic, strong) NSMutableArray *aryActivityProject;   //活动的项目列表
@property (nonatomic, strong) NSString *strActivityAddress;         //整个活动地点
@property (nonatomic, strong) NSString *strActivityStartDateTime;   //活动开始时间(从项目中抽取一个最早时间)
@property (nonatomic)NSInteger nActivitySignupNum;                  //活动已经报名人数
@property (nonatomic)NSInteger nActivitySignupTimes;                //我的活动报名（该字段表示报名该活动下面项目的数量）
@property (nonatomic)NSInteger nUpIntegral;         //参加活动前N名积分
@property (nonatomic)NSInteger nDownIntegral;       //参加活动后N名积分
@property (nonatomic)NSInteger nActivityJoinRank;   //活动参加前多少名
@property (nonatomic)NSInteger nProjectJoinNum;      //该活动的子活动报名次数

//排名
@property (nonatomic) NSInteger nIndex;
@property (nonatomic) NSInteger nHotValue;//热度值

//小视频(为了保持下载过程)
@property(nonatomic,strong)VideoPlayView *videoPlayView;

//问答相关/////////////////////////////////////////////////////////////////////////
@property (nonatomic, strong) NSMutableArray *aryAnswer;
@property (nonatomic, strong) NSString *strQuestionID;
@property (nonatomic, assign) int  isSolution;                    //是否解决 0:未解决,1:已解决
@property (nonatomic, assign) NSInteger nAnswerCount;                  //回答数量

@property (assign, nonatomic) PraiseState praiseState; //点赞状态


@end
