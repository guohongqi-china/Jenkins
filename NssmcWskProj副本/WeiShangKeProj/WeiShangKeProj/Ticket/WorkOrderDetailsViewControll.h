//
//  WorkOrderDetailsViewControll.h
//  NssmcWskProj
//
//  Created by MacBook on 16/5/23.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum _TitleForController{
    isok,//可抢
    noIsOk//其他
    
}itleForController;

@interface WorkOrderDetailsViewControll : UIViewController



@property (nonatomic, assign) itleForController judgeController;/** <#注释#> */
@property (nonatomic, copy) NSString *malfunctionId;/** <#注释#> */

@property (nonatomic, copy) NSString *detailId;/** <#注释#> */

@property (nonatomic, copy) NSString *ENDid;/** <#注释#> */


@property (nonatomic, strong) NSMutableArray *modelArray;/** <#注释#> */


+ (void)cancelLocalNotificationWithKey:(NSString *)key ;
+ (void)registerLocalNotification:(NSInteger)alertTime ;



@end
