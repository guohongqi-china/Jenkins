//
//  shareModel.m
//  NssmcWskProj
//
//  Created by MacBook on 16/6/7.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "shareModel.h"
#import "MBProgressHUD+GHQ.h"
#import "ServerProvider.h"
@implementation shareModel

+ (shareModel *)sharedManager
{
    static shareModel *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}

- (void)shareModelStartToLocation{
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动LocationService
    //        116.403119,39.914935
    [_locService allowsBackgroundLocationUpdates];
    [_locService startUserLocationService];
    

}

- (instancetype)init{
    if (self  =  [super init]) {
        //初始化BMKLocationService

      
    }
    return self;
}

- (void)didFailToLocateUserWithError:(NSError *)error{
    self.isHe = YES;
}

//实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    NSLog(@"heading is %@",userLocation.heading);
}


//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    
    CLLocationCoordinate2D test = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    //将GCJ-02(火星坐标)转为百度坐标
    test = [TQLocationConverter transformFromGCJToBaidu:test];
    
    
    _latitude = userLocation.location.coordinate.latitude;
    _longitude = userLocation.location.coordinate.longitude;
    
    UserVo *y = [Common getCurrentUserVo];
    if (y != nil) {
        /**
         * 小明百度AK:nZ9WDfyOd30gGUgcyOaa9edQravgZdkh  表单id：141460
         * 菱信工单百度AK:SmBGCOYEhLVrINTAhvGjHN2BlnkWGf1u  表单id：149333
         */
        NSString *LBSAK = @"SmBGCOYEhLVrINTAhvGjHN2BlnkWGf1u";
        NSString *LBSID = @"149333";
        NSLog(@"%@",@{@"ak":LBSAK,@"geotable_id":LBSID,@"title":[Common getCurrentUserVo].strLoginAccount} );
        
        DNENetworkFramework *framework = [[DNENetworkFramework alloc] init];
        [framework setURL:[NSString stringWithFormat:@"http://api.map.baidu.com/geodata/v3/poi/list?ak=SmBGCOYEhLVrINTAhvGjHN2BlnkWGf1u&geotable_id=149333&title=%@",[Common getCurrentUserVo].strLoginAccount]];
        [framework startRequestToServerAndNoSesssion:@"GET" andParameter:nil];
        if ([framework dneError])
        {
            NSLog(@"错误");
        }
        else
        {
            NSDictionary *responseDic = [framework getResponseDic];
            if(responseDic == nil)
            {
                NSLog(@"错误");
                [MBProgressHUD showMessage:ERROR_TO_SERVER toView:nil];
            }
            else
            {
                //判断 HTTP 请求状态码
                if ([framework getResponseStatusCode] != HTTP_STATUS_OK)
                {
                    [MBProgressHUD showMessage:[DNENetworkFramework getErrorMsgBy:responseDic] toView:nil];
                    
                }
                else
                {
                    id dic = [framework getResponseDic];
                    
                    //当size为零的时候，表示在百度数据库中没有该目标（此时执行插入操作），否则执行跟新操作
                    if ([dic[@"size"] isEqual: @(0)]) {
     
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];//你的form表单参数，注意格式，尤其是数字类型的在一些model to dictionary 时会“多出”一些信息导致参数不对
                        dic[@"ak"] = LBSAK;
                        dic[@"coord_type"] = @"3";
                        dic[@"latitude"] = @(userLocation.location.coordinate.latitude);
                        dic[@"longitude"] = @(userLocation.location.coordinate.longitude);
                        dic[@"geotable_id"] = LBSID;
                        dic[@"user_name"] = [Common getCurrentUserVo].strRealName;
                        dic[@"user_id"] = [Common getCurrentUserVo].strUserID;
                        dic[@"tags"] = @"maintainer";
                        dic[@"title"] = [Common getCurrentUserVo].strLoginAccount;
                        
                        [ServerProvider startFormData:@"http://api.map.baidu.com/geodata/v3/poi/create" parms:dic result:^(ServerReturnInfo *retInfo) {
                            
                            if (retInfo.bSuccess) {
                                NSLog(@"%@---%@",retInfo.data,retInfo.data2);
                            }else{
                                NSLog(@"%@---%@",retInfo.data,retInfo.data2);
                                
                            }
                        }];
                        
                        
                    }else{//当size不为零的时候执行更新
                        
                        [ServerProvider startFormData:@"http://api.map.baidu.com/geodata/v3/poi/update" parms:@{@"ak":LBSAK,@"id":dic[@"pois"][0][@"id"],@"coord_type":@"3",@"latitude":@(userLocation.location.coordinate.latitude),@"longitude":@(userLocation.location.coordinate.longitude),@"geotable_id":LBSID,@"user_id":[Common getCurrentUserVo].strUserID,@"title":[Common getCurrentUserVo].strLoginAccount,@"user_name":[Common getCurrentUserVo].strRealName} result:^(ServerReturnInfo *retInfo) {
                            if (retInfo.bSuccess) {
                                NSLog(@"%@---%@",retInfo.data,retInfo.data2);
                            }else{
                                NSLog(@"%@---%@",retInfo.data,retInfo.data2);
                                
                            }
                            
                        }];
                    }
                }
            }
        }
        
        
    }
    
    [_locService stopUserLocationService];
    

}

//停止定位就会调用该方法
- (void)didStopLocatingUser{
    NSLog(@"hongqi");
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
           
}
- (void)timerAction{
    [_locService startUserLocationService];
   
}


@end
