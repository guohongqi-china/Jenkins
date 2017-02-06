//
//  TableList.h
//  FindestProj
//
//  Created by MacBook on 16/7/13.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManListModel.h"
@interface TableList : NSObject

@property (nonatomic, strong) NSMutableArray *content;/** <#注释#> */
@property (nonatomic, copy) NSString *totalElements;/** <#注释#> */
@property (nonatomic, copy) NSString *numberOfElements;/** <#注释#> */
@property (nonatomic, copy) NSString *totalPages;/** <#注释#> */
@property (nonatomic, copy) NSString *firstPage;/** <#注释#> */
@property (nonatomic, copy) NSString *size;/** <#注释#> */
@property (nonatomic, copy) NSString *number;/** <#注释#> */
@property (nonatomic, copy) NSString *sort;/** <#注释#> */

@end
