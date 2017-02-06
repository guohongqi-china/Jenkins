//
//  UserVo.h
//  Sloth
//
//  Created by Ann Yao on 12-9-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserVo : NSObject

@property(nonatomic,strong)NSString *strUserID;             //用户ID
@property(nonatomic,strong)NSString *strUserNodeID;         //Node ID
@property(nonatomic,strong)NSString *strLoginAccount;       //用户登录名(邮箱或电话号码)
@property(nonatomic,strong)NSString *strUserName;           //用户别名
@property(nonatomic,strong)NSString *strRealName;           //真实姓名
@property(nonatomic,strong)NSString *strPassword;           //密码
@property(nonatomic,strong)NSString *strHeadImageURL;       //用户头像地址
@property(nonatomic,strong)NSString *strMaxHeadImageURL;    //用户头像大图地址
@property(nonatomic,strong)NSString *strCoverImageURL;      //用户封面地址
@property(nonatomic,strong)UIImage *imgHeadBuffer;          //用户头像数据缓存
@property(nonatomic,strong)NSString *strPartImageURL;       //用户头像部分地址（不包含IP前缀）

@property(nonatomic,strong)NSString *strCompanyID;          //公司id
@property(nonatomic,strong)NSString *strCompanyName;        //公司名称
@property(nonatomic,strong)NSString *strDepartmentId;       //部门id
@property(nonatomic,strong)NSString *strDepartmentName;     //部门名称
@property(nonatomic,strong)NSString *strSignature;          //签名
@property(nonatomic,strong)NSString *strQQ;                 //QQ
@property(nonatomic,strong)NSString *strPhoneNumber;        //电话号码

@property(nonatomic)NSInteger gender;                             //性别	未知=2 0为女，1为男
@property(nonatomic,strong)NSString * strBirthday;          //出生日期
@property(nonatomic,strong)NSString * strPosition;          //职位
@property(nonatomic,strong)NSString * strEmail;             //邮件
@property(nonatomic,strong)NSString * strAddress;           //个人住址1
@property(nonatomic,strong)NSString * strRemark;           //备注

@property(nonatomic,strong)NSString * strFirstLetter;       //姓名首字母
@property(nonatomic)int nArticleCount;               //消息数量
@property(nonatomic)int nShareCount;               //分享数量
@property(nonatomic)int nQACount;               //问答数量
@property(nonatomic)NSInteger nAttentionCount;               //关注人数
@property(nonatomic)NSInteger nFansCount;               //粉丝人数

@property(nonatomic)double fIntegrationCount;                //自有积分
@property(nonatomic)double fBadgeIntegral;                   //勋章积分（版主）
@property(nonatomic)double fIntegralDaily;               //昨日积分
@property(nonatomic)NSInteger nBadge;               //勋章类别（0:普通用户; 1:版主; 2:跑鞋; 3:达人; 4:BOSS; 5:慈善）

@property(nonatomic)BOOL bViewPhone;            //是否显示手机号码
@property(nonatomic)BOOL bViewFavorite;         //是否显示收藏夹

////////////////////////////////////////////////////////////////////////
@property(nonatomic,strong)NSString *strJP;             //名称简拼
@property(nonatomic,strong)NSString *strQP;             //名称全拼
@property(nonatomic,strong)NSString *strReceiveMessage; //是否接收推送消息
@property(nonatomic,strong)NSString *strSecID;          //该用户的秘书或领导ID

//用于同步
@property(nonatomic)int nRecordStatus;           //是否逻辑删除（1:已删除，0:有效）

//用于选择用户
@property(nonatomic)BOOL bChecked;               //是否选择了
@property(nonatomic)BOOL bCanNotCheck;           //不能选择标识

@property(nonatomic)BOOL bTempChecked;           //YES:(点击完成前-更改的临时数据),NO:(点击完成前-没有任何更改)

@property(nonatomic)BOOL bAttentioned;              //本人是否关注该用户

//验证码
@property(nonatomic,strong)NSString *strIdentifyCode;

//modify personal info
@property(nonatomic)BOOL bHasHeadImg;
@property(nonatomic,strong)NSString *strHeadImgPath;

//讨论组创建者
@property(nonatomic)BOOL bGroupFounder;

@property(nonatomic,strong)NSString *strLastChat;           //最后一次聊天记录
@property(nonatomic,strong)NSString *strLastChatTime;       //最后一次聊天记录 时间

@property(nonatomic,strong)NSMutableArray *aryDepartmentList;   //部门列表

//合理化建议权限
@property(nonatomic,strong)NSMutableArray *arySuggestionRole;

//圈子列表
@property(nonatomic,strong)NSMutableArray *aryCommunity;

//会议ID
@property(nonatomic,strong)NSString *strMeetingID;
@property(nonatomic,strong)NSMutableArray *aryCustomField;//自定义字段

@property(nonatomic)BOOL bDaySign;       //当日是否签到

//积分排行
@property(nonatomic)NSInteger nIndex;
@property(nonatomic,strong)NSString *strRankingState;//昨天和前天相比；U：上升；D：下降；E：不变

//推荐关注//////////////////////////////////////////////////////////////////////
@property(nonatomic,strong)NSString *strRecommendDes;   //推荐说明

@end
