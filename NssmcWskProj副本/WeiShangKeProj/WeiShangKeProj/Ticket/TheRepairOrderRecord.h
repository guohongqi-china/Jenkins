//
//  TheRepairOrderRecord.h
//  NssmcWskProj
//
//  Created by MacBook on 16/5/23.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "modelForViewFrame.h"
@interface TheRepairOrderRecord : UIView


@property (nonatomic, strong) modelForViewFrame *modelFrame;/** <#注释#> */
@property (nonatomic, strong) UIImageView *baseView;/** <#注释#> */

@property (nonatomic, strong) UILabel *timeLabel;/** <#注释#> */

@property (nonatomic, strong) UILabel *contentLabel;/** <#注释#> */
@end
