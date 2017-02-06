//
//  ChatObjectVo.h
//  Sloth
//
//  Created by 焱 孙 on 13-6-24.
//
//

#import <Foundation/Foundation.h>

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

@property(nonatomic,retain)NSString *strLastChatCon;         //最后一次聊天内容
@property(nonatomic,retain)NSString *strLastChatTime;        //最后一次聊天时间
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
@property(nonatomic,assign)BOOL bReject;                    //是否被讨论组管理员踢出讨论组

//common
@property(nonatomic,assign)int nRecordStatus;               //记录状态 1：已删除，0：有效
@property(nonatomic,assign)BOOL bTopMsg;                    //置顶消息
@property(nonatomic,assign)BOOL bEnablePush;                //是否启用推送

@end
