//
//  UserVo.h
//  Sloth
//
//  Created by Ann Yao on 12-9-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCertPictureVo : NSObject

@property (nonatomic) BOOL bOld;    //是否为之前的照片
@property (nonatomic,strong) NSString *strImageURL;
@property (nonatomic,strong) NSString *strImagePath;    //本地路径
@property (nonatomic,weak) UIButton *btnCertPic;    //照片控件

@end

@interface UserVo : NSObject

@property(nonatomic,strong)NSString *strUserID;             //用户ID
@property(nonatomic,strong)NSString *strUserNodeID;         //Node ID
@property(nonatomic,strong)NSString *strLoginAccount;       //用户登录名(邮箱或电话号码)
@property(nonatomic,strong)NSString *strRealName;           //用户真实姓名
@property(nonatomic,strong)NSString *strAliasName;          //用户别名
@property(nonatomic,strong)NSString *strPassword;           //密码
@property(nonatomic,strong)NSString *strHeadImageURL;       //用户头像地址
@property(nonatomic,strong)UIImage *imgHeadBuffer;          //用户头像数据缓存
@property(nonatomic,strong)NSString *strPartImageURL;       //用户头像部分地址（不包含IP前缀）

@property (nonatomic, copy) NSString *birthday;/** <#注释#> */
@property (nonatomic, copy) NSString *householdRegister;/** <#注释#> */
@property (nonatomic, copy) NSString *graduationSchool;/** <#注释#> */
@property (nonatomic, copy) NSString *nation;/** <#注释#> */

//@property (nonatomic, copy) NSString <#属性#>;/** <#注释#> */
//@property (nonatomic, copy) NSString *nation;/** <#注释#> */


@property(nonatomic,strong)NSString *strCompanyID;          //公司id
@property(nonatomic,strong)NSString *strCompanyName;        //公司名称
@property(nonatomic,strong)NSString *strSignature;          //签名 - 自我介绍
@property(nonatomic,strong)NSString *strQQ;                 //QQ
@property(nonatomic,strong)NSString *strPhoneNumber;        //电话号码
/** 昵称 */
@property (nonatomic, copy) NSString *nickName;
@property(nonatomic ,copy)NSString *gender;                             //性别	未知=2 0为女，1为男
@property(nonatomic,strong)NSString * strBirthday;          //出生日期
@property(nonatomic,strong)NSString * strPosition;          //职位
@property(nonatomic,strong)NSString * strEmail;             //邮件
@property(nonatomic,strong)NSString * strAddress;           //个人住址1

@property(nonatomic,strong)NSString * strFirstLetter;       //姓名首字母
@property(nonatomic)int nArticleCount;               //消息数量
@property(nonatomic)int nShareCount;               //分享数量
@property(nonatomic)int nQACount;               //问答数量
@property(nonatomic)int nIntegrationCount;               //积分数量

@property(nonatomic)BOOL bViewPhone;       //是否显示手机号码

//新日铁增加部分
@property(nonatomic,strong)NSString * strNation;         //民族
@property(nonatomic,strong)NSString * strHouseHold;         //户籍
@property(nonatomic,strong)NSString * strEducation;         //学历
@property(nonatomic,strong)NSString * strSchool;         //毕业学校
@property(nonatomic,strong)NSString * strSeniority;         //工作年数
@property(nonatomic,strong)NSMutableArray * aryCertificate;         //持有证书
@property(nonatomic,strong)NSString * strGrade;         //综合等级
@property(nonatomic,strong)NSString * strSoftGrade;         //软件等级
@property(nonatomic,strong)NSString * strHardGrade;         //硬件等级

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

////////////////////////////////////////////////////////////////////////
@property(nonatomic,strong)NSString *strEmployeeNum;        //工号



@property (nonatomic, copy) NSString *aliasName;/** <#注释#> */
@property (nonatomic, copy) NSString *companyId;/** <#注释#> */
@property (nonatomic, copy) NSString *ID;/** <#注释#> */
@property (nonatomic, copy) NSString *name;/** <#注释#> */
@property (nonatomic, copy) NSString *phoneNumber;/** <#注释#> */
@property (nonatomic, copy) NSString *updateDate;/** <#注释#> */
@property (nonatomic, copy) NSString *updateTime;/** <#注释#> */
@property (nonatomic, copy) NSString *userLoginName;/** <#注释#> */
@property (nonatomic, copy) NSString *workingYears;/** <#注释#> */
@property (nonatomic, copy) NSString *education;/** <#注释#> */
@property (nonatomic, copy) NSString *certificate;/** <#注释#> */
@property (nonatomic, copy) NSString *headimgurl;/** <#注释#> */
@property (nonatomic, copy) NSString *selfIntroduction;/** <#注释#> */
@property (nonatomic, copy) NSString *lastCoordinate;/** <#注释#> */

@property (nonatomic, copy) NSString *email;/** <#注释#> */
@property (nonatomic, copy) NSString *emailCode;/** <#注释#> */
@property (nonatomic, copy) NSString *emailType;/** <#注释#> */
@property (nonatomic, copy) NSString *employeeNum;/** <#注释#> */
@property (nonatomic, copy) NSString *firstLetter;/** <#注释#> */
@property (nonatomic, copy) NSString *isLock;/** <#注释#> */

@property (nonatomic, copy) NSString *sex;/** <#注释#> */
@property (nonatomic, copy) NSString *updateUserCd;/** <#注释#> */
@property (nonatomic, copy) NSString *userLevel;/** <#注释#> */
@property (nonatomic, copy) NSString *plainPassword;/** <#注释#> */
@property (nonatomic, copy) NSString *attachmentList;/** <#注释#> */

@property (nonatomic, copy) NSString *company;/** <#注释#> */

/** 网络维修等级 */
@property (nonatomic, copy) NSString *commonLevel1;
/** 服务区维修等级 */
@property (nonatomic, copy) NSString *commonLevel2;
/** PC机维修等级 */
@property (nonatomic, copy) NSString *commonLevel3;
/** 综合布线维修等级 */
@property (nonatomic, copy) NSString *commonLevel4;
/** 其他维修等级 */
@property (nonatomic, copy) NSString *commonLevel5;



@end
