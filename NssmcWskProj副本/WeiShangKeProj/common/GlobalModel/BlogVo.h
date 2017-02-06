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

@interface BlogVo : NSObject

@property (nonatomic, retain) NSString *streamId;                 //博文Id
@property (nonatomic, retain) NSString *strTitle;                 //消息标题
@property (nonatomic, retain) NSString *strContent;               //消息内容html文本题
@property (nonatomic, retain) NSString *strText;                  //消息内容的纯文本
@property (nonatomic, assign) int nComefrom;                      //消息发布平台
@property (nonatomic) NSInteger nBlogType;                        //0-查分享 1-查活动；2－足球联赛 3-问卷调查
@property (nonatomic, retain) NSString *orgId;                    //公司ID
@property (nonatomic, retain) NSString *strCreateDate;            //创建时间
@property (nonatomic, retain) NSString *strUpdateDate;            //修改时间
@property (nonatomic, retain) NSString *strCreateBy;              //创建者ID
@property (nonatomic, retain) NSString *strUpdateBy;              //修改者ID
@property (nonatomic, retain) NSString *strCreateByName;          //创建者姓名
@property (nonatomic, retain) NSString *strUpdateByName;          //修改者姓名
@property (nonatomic, assign) int nPraiseCount;                   //赞数
@property (nonatomic, assign) NSInteger nCommentCount;                  //评论数 (如果是问答则代表回答总数)
@property (nonatomic, assign) int  nDelFlag;                      //删除标志
@property (nonatomic, retain) NSString * vestImg;                 //头像
@property (nonatomic, retain) NSString *strStartTime;             //查询开始时间
@property (nonatomic, retain) NSString *strEndTime;               //查询结束时间
@property (nonatomic, assign) int  isDraft;                       //是否是草稿(1-是，0-否)
@property (nonatomic, retain) NSString *strPictureUrl;
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

@property (nonatomic, retain) NSMutableArray * aryReceiverUser;   //接受用户列表
@property (nonatomic, retain) NSMutableArray * aryReceiverGroup;  //接受群组列表
@property (nonatomic, assign) BOOL bIsShow;
@property (nonatomic, retain) NSMutableArray *aryAttachmentList;  //附件列表
@property (nonatomic, retain) NSMutableArray *aryComment;  //评论列表（前三个评论）
@property (nonatomic, strong) NSMutableArray *aryTagList;  //标签VO列表

@property (nonatomic, retain) BlogVo *blogVoParent;               //源消息对象
@property (nonatomic, assign) int nTransferWorkCount;             //提交过秘书处理的次数
@property (nonatomic, retain) NSMutableArray *answearList;        //答案列表
@property (nonatomic, assign) int  isSolution;                    //是否解决 0:未解决,1:已解决

@property (nonatomic)BOOL bCollection;  //是否已经收藏

@property (nonatomic, strong) UIImage *imgContent;                //缓存需要在列表里面显示的图片（默认第一张图）

@property (nonatomic, strong) NSString *strMentionID;           //赞ID,id不为null则本人赞过，否则赞过
@property (nonatomic, strong) NSMutableArray *aryPraiseList;      //赞列表

//足球竞猜，包含的比赛场数
@property (nonatomic) NSInteger nContestNum;
@property (nonatomic) NSInteger nSurveyFlag;        //0：否；1：已提交
@property (nonatomic, strong) NSString *strRefID;   //引用ID

//会议报名
@property (nonatomic) NSInteger nSignupMemberNum;//已报名人数
@property (nonatomic) NSInteger nTotalMemberNum;//报名人数上限
@property (nonatomic) BOOL bOverDue;//会议是否过期(true：过期；false：有效)
@property (nonatomic, strong) NSMutableArray *aryMeetingField;//会议自定义提交字段

@end
