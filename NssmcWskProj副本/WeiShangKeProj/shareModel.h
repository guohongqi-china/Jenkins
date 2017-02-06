//
//  shareModel.h
//  NssmcWskProj
//
//  Created by MacBook on 16/6/7.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Base/BMKMapManager.h>
#import "TQLocationConverter-master/TQLocationConverter.h"
#import "DNENetworkFramework.h"
#import "ServerURL.h"
typedef enum _shareModelType{
    shareModelLocationYes,
    shareModelLocationNo
}shareModelType;


@interface shareModel : NSObject<BMKLocationServiceDelegate>

@property (nonatomic) shareModelType locationBool;/** <#注释#> */
@property (nonatomic, strong) NSMutableArray *itemsArray;/** <#注释#> */


@property (nonatomic, copy) NSString *remindtick;/** <#注释#> */

@property (nonatomic, strong) NSTimer *timer;/** <#注释#> */



@property (nonatomic, assign) CGFloat longitude;/** <#注释#> */

@property (nonatomic, assign) CGFloat latitude;/** <#注释#> */

@property (nonatomic, assign) BOOL isHe;/** <#注释#> */

+ (shareModel *)sharedManager;
- (void)shareModelStartToLocation;
@property (nonatomic, strong) BMKLocationService *locService;/** <#注释#> */

@end
