//
//  TicketVo.h
//  WeiShangKeProj
//
//  Created by 焱 孙 on 15/5/29.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "timeModel.h"
@interface TicketVo : NSObject

@property(nonatomic,strong)NSString *strID;
@property(nonatomic,strong)NSString *strKefuID;     //最后与该客户聊天的客服

@property (nonatomic, strong) NSString *orderstatuscontent;/** <#注释#> */

@property(nonatomic,strong)NSString *strTypeID;         //工单类型ID
@property(nonatomic,strong)NSString *strTypeName;       //工单类型名称
@property(nonatomic) NSInteger nStatus;

@property (nonatomic, assign) BOOL isQiang;/** <#注释#> */
@property(nonatomic,strong)NSString *strTitle;      //工单标题

@property(nonatomic,strong)NSString *strSessionID;    //会话ID

@property(nonatomic,strong)NSMutableArray *aryTag;
@property(nonatomic,strong)NSMutableArray *aryTrace;    //工单跟踪记录列表

@property(nonatomic,strong)NSString *strUpdateField;    //操作类型	create - 创建工单 modify - 修改（标题或正文） priorityId - 优先级调整

///////////////////////////////////////////////////////////
@property(nonatomic,strong)NSString *strCustomerID;
@property(nonatomic,strong)NSString *strCustomerName;   //客户
@property(nonatomic,strong)NSString *strTicketNum;      //工单号
@property(nonatomic,strong)NSString *strContent;    //工单描述
//@property(nonatomic,strong)NSString *strFaultClass;         //故障分类
@property(nonatomic,strong)NSString *strEvaluatePrice;      //价格估算
@property(nonatomic,strong)NSString *strDifficultyLevel;    //难度
@property(nonatomic,strong)NSString *strStatus;                  //0:未解决；1:已解决
@property(nonatomic) BOOL bRead;    //是否已读
@property(nonatomic) BOOL bGrabTicket;    //是否为可抢工单
@property(nonatomic,strong)NSString *strDateTime;


@property (nonatomic, copy) NSString *malfunctionId;/** 保障单号 */

@property (nonatomic, copy) NSString *classificationContent;/** 保障内容 */
@property (nonatomic, copy) NSString *difficulty;/** 保障内容 */
@property (nonatomic, copy) NSString *detailStatus;/** 保障内容 */
@property (nonatomic, copy) NSString *guestName;/** 客户名称 */
                
@property (nonatomic, copy) NSString *guestId;/** <#注释#> */
@property (nonatomic, copy) NSString *priceEstimation;/** 价格估算 */
@property (nonatomic, copy) NSString *productName;/** 制品名称 */
@property (nonatomic, copy) NSString *malfunctionDetail;/** 保障内容 */
@property (nonatomic, copy) NSString *detailId;/** 明细ID */
@property (nonatomic, copy) NSString *content;/** 保障内容 */

@property (nonatomic, copy) NSString *orderTime;/** <#注释#> */

@property (nonatomic, copy) NSString *classification;/** <#注释#> */


@property (nonatomic, assign) NSString *orderType;/** <#注释#> */

@property (nonatomic, copy) NSString *applyTime;/** <#注释#> */
@property (nonatomic, copy) NSString *engId;/** <#注释#> */
@property (nonatomic, copy) NSString *guestAddress;/** <#注释#> */
@property (nonatomic, copy) NSString *guestAddressName;/** <#注释#> */
@property (nonatomic, copy) NSString *guestAddressNo;/** <#注释#> */
@property (nonatomic, copy) NSString *distance;/** <#注释#> */
@property (nonatomic, copy) NSString *guest_Mobile;/** <#注释#> */
@property (nonatomic, copy) NSString *guestTel;/** <#注释#> */

@property (nonatomic, copy) NSString *orderstatus;/** <#注释#> */
@property (nonatomic, copy) NSString *percentage;/** <#注释#> */

@property (nonatomic, copy) NSString *guestArea;/** <#注释#> */

@property (nonatomic, strong) NSMutableArray *hopeTime;/** <#注释#> */


@property (nonatomic, copy) NSString *guestCompanyName;/** <#注释#> */
/** 客户区分 */
@property (nonatomic, copy) NSString *customType;
/** 约定上门时间 */
@property (nonatomic, copy) NSString *confirmTime;





@end
