//
//  QiangOrderTicketListController.m
//  NssmcWskProj
//
//  Created by MacBook on 16/6/3.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "QiangOrderTicketListController.h"
#import "TopDetailView.h"
#import "SNUIBarButtonItem.h"
#import "TichetServise.h"
#import "ServerURL.h"
#import "GHQTimeToCalculate.h"
#import "MBProgressHUD+GHQ.h"
#import <CoreLocation/CoreLocation.h>
#import "shareModel.h"
#import "ServerProvider.h"
#import "topModel.h"
@interface QiangOrderTicketListController  ()<UIScrollViewDelegate,CLLocationManagerDelegate>
{
    CLLocationManager *_locationManager;
    UIButton *ActionButtton;
}
@property (nonatomic, strong) UIScrollView *baseScrollView;/** <#注释#> */

@property (nonatomic, strong) TopDetailView *TopView;/** <#注释#> */
@end

@implementation QiangOrderTicketListController



- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self updateUI];
    
}

- (void)showSideMenu{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateUI{
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"可抢工单详情";
    self.view.backgroundColor = [UIColor whiteColor];
    
    SNUIBarButtonItem *leftItem = [SNUIBarButtonItem backItemWithImage:@"nav_setting" target:self action:@selector(showSideMenu)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.baseScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 105)];
    self.baseScrollView.showsVerticalScrollIndicator = NO;
    self.baseScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_baseScrollView];

    _TopView = [[TopDetailView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
    [self.baseScrollView addSubview:_TopView];
    ServerReturnInfo *retInfo;
    retInfo = [ServerProvider getTicketTypeListDetail:_model.malfunctionId detailId:_model.detailId boolIS:YES];
    if (retInfo.bSuccess)
    {
        
        NSMutableArray *arr = [NSMutableArray array];
        for (NSDictionary *dic in retInfo.data) {
            topModel *model = [[topModel alloc]init];
            [model setValuesForKeysWithDictionary:dic];
            [arr addObject:model];
            
        }
        _TopView.itemArray = arr;
        _TopView.timeArray = _modelArray;
        _TopView.Model = _model;

        self.baseScrollView.contentSize = CGSizeMake(kScreenWidth, _TopView.height + 10);

    }
    
    
    
    ActionButtton = [[UIButton alloc]initWithFrame:CGRectMake(10, kScreenHeight - 104, kScreenWidth - 20, 39)];
    if ([_model.orderstatus isEqualToString:@"20"]) {
        [ActionButtton setTitleColor:COLOR(239, 148, 144, 1) forState:(UIControlStateNormal)];
        ActionButtton.layer.borderColor = [COLOR(239, 148, 144, 1) CGColor];
    }else{
    [ActionButtton setTitleColor:COLOR(192, 192, 192, 1) forState:(UIControlStateNormal)];
        ActionButtton.enabled = NO;
    ActionButtton.layer.borderColor = [COLOR(192, 192, 192, 1) CGColor];
    }
    [ActionButtton setTitle:@"抢工单" forState:(UIControlStateNormal)];
    ActionButtton.layer.borderWidth  = 2;
    ActionButtton.layer.cornerRadius = 7;
    ActionButtton.layer.masksToBounds = YES;
    [ActionButtton addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:ActionButtton];
    
}
//- (void)getButtonStatue{
//    dispatch_async(dispatch_get_global_queue(0,0), ^{
//        ServerReturnInfo *retInfo;
//        retInfo = [ServerProvider getTicketTypeListDetail:_malfunctionId detailId:_detailId boolIS:NO];
//        if (retInfo.bSuccess) {
//            
//            
//            
//        }else{
//            [MBProgressHUD showMessage:@"失败" toView:nil];
//        }
//    });
//
//}
- (void)buttonAction:(UIButton *)sender{
    
    NSDate *date = [NSDate date];
    NSString *timstring = [NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]*1000];
    shareModel *model = [shareModel sharedManager];
    NSString *longitudeString = [[NSString stringWithFormat:@"%f",model.longitude] stringByAppendingString:[NSString stringWithFormat:@",%f",model.latitude]];
    NSDictionary *bodyDic = @{@"engId":[GHQTimeToCalculate checkStrValue:_model.engId],@"malfunctionId":_model.malfunctionId,@"detailId":_model.detailId,@"action":@"1",@"user_coordinate":longitudeString,@"duration":@"2",@"distance":@"10",@"updateUserCd":[Common getCurrentUserVo].strUserID,@"updateTime":timstring};
    
    [TichetServise sendRequest:bodyDic urlString:[ServerURL setQiangUrl] requestStyle:@"POST" result:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess) {
            [MBProgressHUD showSuccess:@"抢单申请已受理" toView:nil];
            [ActionButtton setTitleColor:COLOR(192, 192, 192, 1) forState:(UIControlStateNormal)];
             ActionButtton.layer.borderColor = [COLOR(192, 192, 192, 1) CGColor];
            ActionButtton.enabled = NO;
   

        }else{
            [MBProgressHUD showSuccess:retInfo.data[@"message"] toView:nil];
            

        }
        
    }];

    
    
//    // 初始化定位管理器
//    _locationManager = [[CLLocationManager alloc] init];
//    // 设置代理
//    _locationManager.delegate = self;
//    // 设置定位精确度到米
//    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    // 设置过滤器为无
//    _locationManager.distanceFilter = kCLDistanceFilterNone;
//    [_locationManager startUpdatingLocation];
    
    
    
//    NSDictionary *dic = @{@"key":_locationManager};
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timerAction:) userInfo:dic repeats:YES];
//    [[NSRunLoop mainRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
//    [[NSRunLoop mainRunLoop]run];
    
  
    
   
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
}
//- (void)timerAction:(NSTimer *)userInfo{
//  CLLocationManager *locationManager = userInfo.userInfo[@"key"];
//    
//    
//}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSDate *date = [NSDate date];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//    [formatter setDateFormat:@"yyyy-MM-dd HH:ss:mm"];
//    NSString *dateString = [formatter stringFromDate:date];
    
  NSString *timstring = [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]*1000];

    NSLog(@"%@",timstring);
    
    NSString *longitudeString = [[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude] stringByAppendingString:[NSString stringWithFormat:@",%f",newLocation.coordinate.latitude]];
    NSDictionary *bodyDic = @{@"engId":[GHQTimeToCalculate checkStrValue:_model.engId],@"malfunctionId":_model.malfunctionId,@"detailId":_model.detailId,@"action":@"1",@"user_coordinate":longitudeString,@"duration":@"50",@"distance":@"60",@"updateUserCd":[Common getCurrentUserVo].strUserID,@"updateTime":timstring};
    
    [TichetServise sendRequest:bodyDic urlString:[ServerURL setQiangUrl] requestStyle:@"POST" result:^(ServerReturnInfo *retInfo) {
        if (retInfo.bSuccess) {
            [MBProgressHUD showSuccess:retInfo.data[@"message"] toView:nil];
        }else{
            NSLog(@"%@",retInfo.strErrorMsg);
            [MBProgressHUD showSuccess:retInfo.strErrorMsg toView:nil];
        }
        
    }];
    

}

@end
