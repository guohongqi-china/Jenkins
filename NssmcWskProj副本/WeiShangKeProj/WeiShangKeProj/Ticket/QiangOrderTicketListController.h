//
//  QiangOrderTicketListController.h
//  NssmcWskProj
//
//  Created by MacBook on 16/6/3.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TicketVo.h"
@interface QiangOrderTicketListController : UIViewController

@property (nonatomic, copy) NSString *malfunctionId;/** <#注释#> */

@property (nonatomic, copy) NSString *detailId;/** <#注释#> */
@property (nonatomic, strong) TicketVo *model;/** <#注释#> */

@property (nonatomic, strong) NSMutableArray *modelArray;/** <#注释#> */







@end
