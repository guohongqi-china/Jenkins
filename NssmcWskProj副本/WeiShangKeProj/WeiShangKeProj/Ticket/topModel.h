//
//  topModel.h
//  NssmcWskProj
//
//  Created by MacBook on 16/5/24.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface topModel : NSObject

@property (nonatomic, assign) CGFloat CGprogress;/** <#注释#> */

@property (nonatomic, strong) NSString *title;/** <#注释#> */

@property (nonatomic, strong) NSString *titleContent;/** <#注释#> */

@property (nonatomic, copy) NSString *guestId;/** <#注释#> */

@property (nonatomic, assign) NSInteger count;/** <#注释#> */

@property (nonatomic, strong) NSString *userName;/** <#注释#> */

@property (nonatomic, strong) NSString *userPhone;/** <#注释#> */

@property (nonatomic, strong) NSString *userAddress;/** <#注释#> */

@property (nonatomic, strong) NSString *repairTime;/** <#注释#> */

@property (nonatomic, strong) NSString *classificationForDeafult;/** <#注释#> */

@property (nonatomic, strong) NSString *price;/** <#注释#> */


@property (nonatomic, strong) NSString *status;/** <#注释#> */
@property (nonatomic, copy) NSString *malfunctionId;/** 保障单号 */

@property (nonatomic, copy) NSString *classificationContent;/** 保障内容 */
@property (nonatomic, copy) NSString *difficulty;/** 保障内容 */
@property (nonatomic, copy) NSString *detailStatus;/** 保障内容 */
@property (nonatomic, copy) NSString *guestName;/** 客户名称 */

@property (nonatomic, copy) NSString *priceEstimation;/** 价格估算 */
@property (nonatomic, copy) NSString *productName;/** 制品名称 */
@property (nonatomic, copy) NSString *malfunctionDetail;/** 保障内容 */
@property (nonatomic, copy) NSString *detailId;/** 明细ID */
@property (nonatomic, copy) NSString *content;/** 保障内容 */

@property (nonatomic, copy) NSString *result;/** <#注释#> */
@property (nonatomic, copy) NSString *orderTime;/** <#注释#> */

@property (nonatomic, copy) NSString *classification;/** <#注释#> */


@property (nonatomic, copy) NSString *orderType;/** <#注释#> */

@property (nonatomic, copy) NSString *applyTime;/** <#注释#> */
@property (nonatomic, copy) NSString *engId;/** <#注释#> */
@property (nonatomic, copy) NSString *guestAddress;/** <#注释#> */
@property (nonatomic, copy) NSString *guestAddressName;/** <#注释#> */
@property (nonatomic, copy) NSString *guestAddressNo;/** <#注释#> */
@property (nonatomic, copy) NSString *distance;/** <#注释#> */
@property (nonatomic, copy) NSString *guestMobile;/** <#注释#> */
@property (nonatomic, copy) NSString *guestTel;/** <#注释#> */

@property (nonatomic, copy) NSString *detailContent;/** <#注释#> */
@property (nonatomic, copy) NSString *percentage;/** <#注释#> */

@property (nonatomic, copy) NSString *memo;/** <#注释#> */

@property (nonatomic, copy) NSString *updateUserCd;/** <#注释#> */

@property (nonatomic, copy) NSString   *updateTime;/** <#注释#> */

@property (nonatomic, copy) NSString *no;/** <#注释#> */

@property (nonatomic, copy) NSString *type;/** <#注释#> */

@property (nonatomic, copy) NSString *fileName;/** <#注释#> */

@property (nonatomic, copy) NSString *path;/** <#注释#> */


@property (nonatomic, copy) NSString *guestArea;/** <#注释#> */

/**
 * 追加字段
 */

/** pin码 */
@property (nonatomic, copy) NSString *pinCd;
/** pin码状态 */
@property (nonatomic, copy) NSString *pincdConfirmStatus;
/** 客户区分 */
@property (nonatomic, copy) NSString *customType;
/** 预定上门时间 */
@property (nonatomic, copy) NSString *confirmTime;
/** 网络 */
@property (nonatomic, copy) NSString *commonLevel;
/** 服务器 */
@property (nonatomic, copy) NSString *commonLeve2;
/** PC */
@property (nonatomic, copy) NSString *commonLeve3;
/** 综合布线 */
@property (nonatomic, copy) NSString *commonLeve4;
/** 其他 */
@property (nonatomic, copy) NSString *commonLeve5;

@end
