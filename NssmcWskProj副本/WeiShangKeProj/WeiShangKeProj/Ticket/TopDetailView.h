//
//  TopDetailView.h
//  郭红旗
//
//  Created by MacBook on 16/6/5.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageCollectionView.h"
#import "RepairView.h"
@class viewToShowInformation;
@class TicketVo;
@interface TopDetailView : UIView

@property (nonatomic, strong) viewToShowInformation *view1;/**  */

@property (nonatomic, strong) viewToShowInformation *view2;/** <#注释#> */
@property (nonatomic, strong) viewToShowInformation *view3;/** <#注释#> */
@property (nonatomic, strong) viewToShowInformation *view4;/** <#注释#> */
@property (nonatomic, strong) RepairView *view5;/** <#注释#> */
@property (nonatomic, strong) ImageCollectionView *describeImage;/** <#注释#> */
@property (nonatomic, strong) NSMutableArray *timeArray;/** <#注释#> */

@property (nonatomic, strong) viewToShowInformation *view6;/** <#注释#> */

@property (nonatomic, strong) viewToShowInformation *view7;/** <#注释#> */

@property (nonatomic, strong) viewToShowInformation *view8;/** <#注释#> */

@property (nonatomic, strong) viewToShowInformation *view9;/** <#注释#> */
@property (nonatomic, strong) viewToShowInformation *view0;/** <#注释#> */
@property (nonatomic, strong) viewToShowInformation *view10;/** <#注释#> */
@property (nonatomic, strong) viewToShowInformation *view11;/** <#注释#> */

@property (nonatomic, strong) UILabel *titlLabel;/** <#注释#> */

@property (nonatomic, strong) UILabel *contentLabel;/** <#注释#> */



@property (nonatomic, strong) NSMutableArray *itemArray;/** <#注释#> */
@property (nonatomic, strong) TicketVo *Model;/** <#注释#> */


@end
