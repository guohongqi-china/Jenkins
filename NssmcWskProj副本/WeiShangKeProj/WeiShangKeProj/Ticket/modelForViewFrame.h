//
//  modelForViewFrame.h
//  NssmcWskProj
//
//  Created by MacBook on 16/5/23.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "modelForView.h"

@interface modelForViewFrame : NSObject


@property (nonatomic, strong) modelForView *modelForView;/** <#注释#> */
@property (nonatomic, assign) CGRect timeRect;/** <#注释#> */

@property (nonatomic, assign) CGRect contentRect;/** <#注释#> */

@property (nonatomic, assign) CGRect imageFrame;/** <#注释#> */
@end
