//
//  FaceModel.h
//  FindestProj
//
//  Created by MacBook on 16/7/20.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FaceModel : NSObject

@property (nonatomic, copy) NSString *chs;/** <#注释#> */

@property (nonatomic, copy) NSString *image;/** <#注释#> */

@property (nonatomic, copy) NSString *name;/** <#注释#> */

@property (nonatomic, assign) BOOL ISnO;/** <#注释#> */

@property (nonatomic, strong) NSMutableArray *modelArr;/** <#注释#> */
+ (FaceModel *)sharedManager;
@end
