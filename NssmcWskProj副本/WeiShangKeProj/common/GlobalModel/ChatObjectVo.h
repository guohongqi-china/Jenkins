//
//  ChatObjectVo.h
//  Sloth
//
//  Created by 焱 孙 on 13-6-24.
//
//

#import <Foundation/Foundation.h>
#import "BaseData.h"
#import "ChatContentVo.h"

//聊天对象model，包含群组和用户
@interface ChatObjectVo : NSObject

@property(nonatomic,retain)NSString *strID;         //session id
@property(nonatomic,retain)NSString *strGroupID;        //群组ID
@property(nonatomic,retain)NSString *strGroupNodeID;    //群组NodeID
@property(nonatomic,retain)NSString *strGroupName;      //群组名字
@property(nonatomic,retain)NSString *strVestID;         //用户ID,若是群组则为创建者
@property(nonatomic,retain)NSString *strVestNodeID;
@property(nonatomic,retain)NSString *strNAME;       //名字
@property(nonatomic,retain)NSString *strDESC;       //描述
@property(nonatomic,retain)NSString *strIMGURL;     //头像
@property(nonatomic,retain)NSString *strJP;         //简拼
@property(nonatomic,retain)NSString *strQP;         //全拼

@property(nonatomic,retain)NSString *strLastChatID;          //最后一次聊天内容 最新消息的ID
@property(nonatomic,retain)NSString *strLastChatCon;         //最后一次聊天内容 最新消息的内容
@property(nonatomic,retain)NSString *strLastChatTime;        //最后一次聊天时间 最新消息的时间
@property(nonatomic)NSInteger nLastChatFrom;        //最后一次聊天时间 来源 【1:微信 2:新浪微博 3:腾讯微博 4:易信 5:邮件 6:短信 7:新浪@我的 8:知新 9:系统内web聊天】
@property(nonatomic,assign)int nType;                        //1:私聊,2:群聊

//user
@property(nonatomic,retain)NSString *strCompanyID;
@property(nonatomic,assign)int nUserStatus;        //是否已删除，1：已删除，0：有效
@property(nonatomic,retain)NSString *strQQ;
@property(nonatomic,retain)NSString *strPhoneNum;
@property(nonatomic,assign)int nGender;   
@property(nonatomic,retain)NSString *strPosition;   
@property(nonatomic,retain)NSString *strEmail;
@property(nonatomic,retain)NSString *strAddress;

@property(nonatomic,retain)UIImage *imgGroupHead;
@property(nonatomic,retain)NSMutableArray *aryMember;       //聊天组成员
@property(nonatomic,assign)BOOL bDiscussion;                //是否为讨论组还是内部群
@property(nonatomic,assign)BOOL bUnnaming;                  //是否未命名
@property(nonatomic,assign)BOOL bReject;                    //是否被讨论组管理员提出讨论组

//common
@property(nonatomic,assign)int nRecordStatus;               //记录状态 1：已删除，0：有效
@property(nonatomic,assign)BOOL bTopMsg;                    //置顶消息
@property(nonatomic,assign)BOOL bEnablePush;                //是否启用推送

////////////////////////////////////////////////////////////////////////////////////////
@property(nonatomic)NSInteger nSessionStatus;       //会话状态 -1: 未分配 1: 未处理 2: 处理中 3: 已暂停 4: 已结束
@property(nonatomic)NSInteger nSessionType;         //会话分类 1: 咨询 2: 投诉 3: 保修 4: 其他
@property(nonatomic)NSInteger nPriorityID;          //优先级
@property(nonatomic,strong)NSString *strPriorityDesc;          //优先级描述
@property(nonatomic,strong)NSString *strCustomerID;         //客户ID
@property(nonatomic,strong)NSString *strCustomerCode;         //客户编号
@property(nonatomic,strong)NSString *strCustomerNickName;   //客户昵称
@property(nonatomic)BOOL bCustomerVip;                      //该客户信息是否完善过
@property(nonatomic,strong)ChatContentVo *chatContentVo;    //携带的一条消息

@property(nonatomic)double fLongitude;                  //经度
@property(nonatomic)double fLatitude;                   //纬度

@property(nonatomic,strong)NSString *strCurrKefuID;         //当前客服ID
@property(nonatomic,strong)NSString *strCurrKefuName;       //当前客服名称
@property(nonatomic,strong)NSString *strTransferFromID;     //来自转交客服ID

@property(nonatomic,strong)NSString *strFirstReplyDate;     //第一次回复时间，即当客服人员第一次回复消息的时间
@property(nonatomic,strong)NSString *strLastResponseDate;   //最后回复时间
@property(nonatomic,strong)NSString *strCloseDate;          //关闭会话时间

@property(nonatomic)NSInteger nReplyTotalNum;               //到会话暂停/结束为止，客服回复总数量

@property(nonatomic,strong)NSString *strLastReadMessageID;  //上次读过最后的消息ID
@property(nonatomic,strong)NSString *strTagNames;           //消息标签名

@end
