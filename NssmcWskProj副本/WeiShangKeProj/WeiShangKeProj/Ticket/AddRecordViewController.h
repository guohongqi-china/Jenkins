//
//  AddRecordViewController.h
//  NssmcWskProj
//
//  Created by MacBook on 16/5/27.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddRecordViewController : UIViewController
@property (nonatomic, assign) BOOL isEnd;/** <#注释#> */
@property (nonatomic, copy) NSString *malfunctionId;/** <#注释#> */

@property (nonatomic, copy) NSString *detailId;/** <#注释#> */

@property (nonatomic, assign) NSInteger no;/** <#注释#> */
@property (nonatomic, copy) NSString *pacNumber;/** <#注释#> */

@property (nonatomic, copy) NSString *guestId;/** <#注释#> */
@property (nonatomic, assign) BOOL isNormalEnd;/** <#注释#> */
/** pin码 */
@property (nonatomic, copy) NSString *pinCd;
@end
