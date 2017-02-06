//
//  topModelFrame.h
//  NssmcWskProj
//
//  Created by MacBook on 16/5/24.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "topModel.h"
@interface topModelFrame : NSObject

@property (nonatomic, strong) NSMutableArray *iamgeArray;/** <#注释#> */
@property (nonatomic, strong) topModel *topModel;/** <#注释#> */

@property (nonatomic, assign) CGRect progressRect;/** <#注释#> */

@property (nonatomic, assign) CGRect titleFrame;/** <#注释#> */

@property (nonatomic, assign) CGRect titleContentFrame;/** <#注释#> */

@property (nonatomic, assign) CGRect imageFrame;/** <#注释#> */

@property (nonatomic, assign) CGRect senderFrame;/** <#注释#> */

@property (nonatomic, assign) CGRect userNameFrame;/** <#注释#> */

@property (nonatomic, assign) CGRect userPhoneFrame;/** <#注释#> */

@property (nonatomic, assign) CGRect userAdressFrame;/** <#注释#> */

@property (nonatomic, assign) CGRect repairTimeFrame;/** <#注释#> */

@property (nonatomic, assign) CGRect classificationForDeafultFrame;/** <#注释#> */

@property (nonatomic, assign) CGRect priceFrame;/** <#注释#> */

@property (nonatomic, assign) CGRect difficultyFrame;/** <#注释#> */

@property (nonatomic, assign) CGRect statusFrame;/** <#注释#> */

/** PIN码验证frame */
@property (nonatomic, assign) CGRect pinFrame;
/** 客户区分frame */
@property (nonatomic, assign) CGRect distinguishUserFrame;
/** 约定上门时间 */
@property (nonatomic, assign) CGRect appointTimeFrame;

@property (nonatomic, assign) BOOL issssss;/** <#注释#> */

@end
