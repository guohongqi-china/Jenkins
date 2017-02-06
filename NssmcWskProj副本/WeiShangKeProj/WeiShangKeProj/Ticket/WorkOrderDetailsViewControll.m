//
//  WorkOrderDetailsViewControll.m
//  NssmcWskProj
//
//  Created by MacBook on 16/5/23.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "WorkOrderDetailsViewControll.h"
#import "SNUIBarButtonItem.h"
#import "UIView+Extension.h"
#import "NSString+NSString_Category.h"
#import "viewToShowInformation.h"
#import "TheRepairOrderRecord.h"
#import "TopView.h"
#import "buttonView.h"
#import "addAlertView.h"
#import "GrayView.h"
#import "HopeModel.h"
#import "ServerURL.h"
#import "AddRecordViewController.h"
#import "AddRecordeView.h"
#import "shareModel.h"
#import "MBProgressHUD+GHQ.h"
#import "timeModel.h"
#import "AVAudioRecorderModel.h"
#import "LXGDPinCodeVerification.h"

//#define NSNotificationCenterName @"NSNotificationCenterName"
@interface WorkOrderDetailsViewControll ()<UIAlertViewDelegate,TopViewDelegate>
{
    UILabel *label2;
    topModelFrame *ticketModel;
    UIButton *ACButton;
    NSString *guestId;
    NSTimer *timer;
    BOOL isTag;
    LXGDPinCodeVerification *pinView;
}
@property (nonatomic, strong ) shareModel            * modell;/** <#注释#> */
@property (nonatomic, strong ) AVAudioRecorderModel  *RecordModel           ;/** <#注释#> */
@property (nonatomic, strong ) NSRunLoop             *timerRunloop;/** <#注释#> */
@property (nonatomic, strong ) NSMutableArray        *modelDataArray;/** <#注释#> */
@property (nonatomic, strong ) addAlertView          *addView;/** <#注释#> */
@property (nonatomic, strong ) TopView               *TOPvIEW;/** <#注释#> */
@property (nonatomic, strong ) TopView               *TOPVIEW;/** <#注释#> */
@property (nonatomic,  strong) UIScrollView          *baseScrollView;/** <#注释#> */

@property (nonatomic, strong ) UILabel               *contentLabel;/** <#注释#> */

@property (nonatomic, strong ) viewToShowInformation *view1;/** <#注释#> */

@property (nonatomic, strong ) viewToShowInformation *view2;/** <#注释#> */
@property (nonatomic, strong ) viewToShowInformation *view3;/** <#注释#> */
@property (nonatomic, strong ) viewToShowInformation *view4;/** <#注释#> */

@property (nonatomic, strong ) buttonView            *but;/** <#注释#> */

@property (nonatomic, strong ) TheRepairOrderRecord  *orderRecord1;/** <#注释#> */

@property (nonatomic, strong ) NSMutableArray        *recordArray;/** <#注释#> */

@property (nonatomic, strong ) AddRecordeView        *recordeView;/** <#注释#> */
/** pin码 */
@property (nonatomic, copy) NSString *pinCd;

//@property (nonatomic, copy) NSString *workOrder;/** 记录单号，本地推送使用 */
//@property (nonatomic, strong) <#NSString#> <#属性#>;/** <#注释#> */
@end
static NSString *workOrder;

@implementation WorkOrderDetailsViewControll
#pragma MARK ===================懒加载==================================
- (NSMutableArray *)recordArray{
    if (_recordArray == nil) {
        _recordArray = [NSMutableArray array];
    }
    return _recordArray;
}
- (NSMutableArray *)modelDataArray{
    if (_modelDataArray == nil) {
        _modelDataArray = [NSMutableArray array];
    }
    return _modelDataArray;
}
- (void)updateData{
    dispatch_async(dispatch_get_global_queue(0,0),^{
        
        ServerReturnInfo *retInfo;
        retInfo = [ServerProvider getTicketTypeListDetail:_malfunctionId detailId:_detailId boolIS:NO];
        if (retInfo.bSuccess)
        {

                NSDictionary *dataArray = retInfo.data;
                if (dataArray != nil && [dataArray.allKeys count] > 0)
                {
                    topModel *model = [[topModel alloc]init];
                    ticketModel = [[topModelFrame alloc]init];
                    [model setValuesForKeysWithDictionary:dataArray];
                    _pinCd = model.pinCd;
                    guestId = model.guestId;
                    workOrder = model.malfunctionId;
                    dispatch_async(dispatch_get_global_queue(0,0),^{
                        
                        ServerReturnInfo *retInfo;
                        retInfo = [ServerProvider getTicketTypeListDetail:_malfunctionId detailId:_detailId boolIS:YES];
                        if (retInfo.bSuccess)
                        {
                            
                            ticketModel.iamgeArray = retInfo.data;
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                if ([model.detailStatus  isEqualToString:@"dtlSts00"]||[model.detailStatus  isEqualToString:@"dtlSts10"]||[model.detailStatus  isEqualToString:@"dtlSts11"]||[model.detailStatus  isEqualToString:@"dtlSts21"]){
                                    [_but updateButton:self action:@selector(buttonAction:) judge:YES buttonTitle:@"" color1:COLOR(64, 161, 132, 1) color2:COLOR(192, 192, 192, 1)];
                                    [_but.setOutButton setTitle:@"出发" forState:(UIControlStateNormal)];

                                }else if ([model.detailStatus  isEqualToString:@"dtlSts30"]){
                                    [_but updateButton:self action:@selector(buttonAction:) judge:YES buttonTitle:@"" color1:COLOR(64, 161, 132, 1) color2:COLOR(192, 192, 192, 1)];
                                    [_but.setOutButton setTitle:@"开始维修" forState:(UIControlStateNormal)];
                                }else if ([model.detailStatus  isEqualToString:@"dtlSts31"]){
                                    [_but updateButton:self action:@selector(buttonAction:) judge:NO buttonTitle:@"" color1:COLOR(192, 192, 192, 1) color2:COLOR(64, 161, 132, 1)];
                                    [_but.setOutButton setTitle:@"维修中" forState:(UIControlStateNormal)];
                                }else if ([model.detailStatus  isEqualToString:@"dtlSts32"]){
                                    [_but updateButton:self action:@selector(buttonAction:) judge:NO buttonTitle:@"" color1:COLOR(192, 192, 192, 1) color2:COLOR(64, 161, 132, 1)];

                                    _but.hidden = YES;
                                    self.baseScrollView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 40);
                                    [_but.setOutButton setTitle:@"维修完毕" forState:(UIControlStateNormal)];

                                    ticketModel.issssss = NO;

                                }else if ([model.detailStatus  isEqualToString:@"dtlSts33"]){
                                    [_but updateButton:self action:@selector(buttonAction:) judge:NO buttonTitle:@"" color1:COLOR(192, 192, 192, 1) color2:COLOR(64, 161, 132, 1)];
                                    [_but.setOutButton setTitle:@"维修完毕" forState:(UIControlStateNormal)];
                                    _but.hidden = YES;
                                    ticketModel.issssss = NO;

                                }

                                ticketModel.topModel = model;
                                self.TOPvIEW.topModelFrame = ticketModel;
                                [self.baseScrollView addSubview:self.TOPvIEW];
                                
                                _recordeView.frame = CGRectMake(0, CGRectGetMaxY(_TOPvIEW.frame) + 10, kScreenWidth, 100);
                                [self.baseScrollView addSubview:_recordeView];
                                
                                [self loadArray];
                                ACButton.frame = CGRectMake(5, CGRectGetMaxY(_TOPvIEW.frame), kScreenWidth - 20, 45);
                            });
                        }
                        
                        
                    });

                    
               
                }

        }
        
        
    });
}

- (BOOL)jugeArray:(NSArray *)ARRAY MODEL:(topModel *)model{
    BOOL isSher = NO;
    for (topModel *model1 in ARRAY) {

        if ([model1.updateTime isEqualToString:model.updateTime]) {
            NSLog(@"%@",model1.updateTime);
            NSLog(@"%@",model.updateTime);
            return YES;
        }
    }
    return isSher;
}
- (void)loadArray{

      dispatch_async(dispatch_get_global_queue(0,0),^{
    ServerReturnInfo *retInfo;
    retInfo = [ServerProvider getTicketTypeGetArray:_malfunctionId detailId:_detailId];
    if (retInfo.bSuccess)
    {

        self.recordArray = nil;
        for (NSDictionary *dic in retInfo.data) {
             topModel *MODEL = [[topModel alloc]init];
            [MODEL setValuesForKeysWithDictionary:dic];

            
          BOOL isHe =  [self jugeArray:self.recordArray MODEL:MODEL];
            if (!isHe) {
                [self.recordArray addObject:MODEL];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
    
        _recordeView.itemsArray = self.recordArray;
        _but.frame = CGRectMake(0, kScreenHeight - 105, kScreenWidth , 45);

        self.baseScrollView.contentSize = CGSizeMake(kScreenWidth,CGRectGetMaxY(_recordeView.frame) + 64);
          });
    }
          
      });
}
#pragma ==============================观察者方法
- (void)stopTime{
    [timer invalidate];
    timer = nil;
    timer.fireDate = [NSDate distantFuture];

}

- (void)setUpObserver{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopTime) name:NSNotificationCenterToStopTime object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:@"NSNotificationCenterNameForCell" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:NSNotificationCenterName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pinVerifacation) name:@"PinCodeverification" object:nil];

    
}
- (void)pinVerifacation{
    [pinView hidden];
    [self updateData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"客户工单";
    self.view.backgroundColor = COLOR(238, 238, 238, 1);
    [self setUpObserver];//添加观察者

    self.navigationController.navigationBar.translucent = NO;
    //添加滚动视图
    [self addScrollViewAndSetAttribute];
    [self updateUI];
    [self updateData];
    number = 0;
    /**
     * 点击维修中，隔断时间提示添加记录
     */
    shareModel *model = [shareModel sharedManager];
    NSInteger second = [model.remindtick integerValue];
    //second * 60 * 30
    timer = [NSTimer timerWithTimeInterval:second * 60 * 30  target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    timer.fireDate = [NSDate distantFuture];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    _RecordModel = [AVAudioRecorderModel shareInstance];
}
//切换听筒和扬声器
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    NSLog(@"90909090909090909090909090");
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        //Device is close to user
        NSLog(@"1010101010101010101101010101");
        [Common bubbleTip:@"已从扬声器切换回听筒播放" andView:self.view];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    else
    {
        //Device is not close to user
        NSLog(@"20202022020202202020220202");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [Common bubbleTip:@"已从听筒切换回扬声器播放" andView:self.view];
    }
}


- (void)updateUI{
    SNUIBarButtonItem *leftItem = [SNUIBarButtonItem backItemWithImage:@"nav_setting" target:self action:@selector(showSideMenu)];
    self.navigationItem.leftBarButtonItem = leftItem;

    self.TOPvIEW = [[TopView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
    _TOPvIEW.delegate = self;
    _TOPvIEW.timeArray = _modelArray;
  
    _recordeView = [[AddRecordeView alloc]init];

    
    //按钮添加
    NSArray *array = [[NSBundle mainBundle]loadNibNamed:@"View" owner:nil options:nil];
    _but = array.lastObject;
    _but.size = CGSizeMake(0, 0);
    _but.layer.borderWidth = 1;
    _but.layer.borderColor = [COLOR(64, 161, 132, 1) CGColor];
    [self.view addSubview:_but];

    
}
- (void)dealloc{
    [timer invalidate];
    timer = nil;
    [_RecordModel.audioPlayer stop];
    
}


- (void)timeAction{
    
//    [WorkOrderDetailsViewControll registerLocalNotification:1];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"tongzhi" object:nil];
}
- (void)buttonAction:(UIButton *)sender{
    //出发按钮
    
    if (sender == _but.setOutButton) {
        NSDictionary *BodyDictionary = [NSDictionary dictionary];
        if ([sender.titleLabel.text isEqualToString:@"出发"] || [sender.titleLabel.text isEqualToString:@"出发中"]) {
            BodyDictionary = @{@"malfunctionId":_malfunctionId,@"detailId":_detailId,@"detailStatus":@"dtlSts30",@"guestId":guestId,@"pinCd":_pinCd};
            [_but.setOutButton setTitle:@"开始维修" forState:(UIControlStateNormal)];
            [_but updateButton:self action:@selector(buttonAction:) judge:YES buttonTitle:@"" color1:COLOR(64, 161, 132, 1) color2:COLOR(192, 192, 192, 1)];

             isBackgroud = NO;
             [self setStatus:BodyDictionary];
            isTag = NO;
            
        }else if ([_but.setOutButton.titleLabel.text isEqualToString:@"开始维修"]) {
            isTag = YES;
                BodyDictionary = nil;
                BodyDictionary = @{@"malfunctionId":_malfunctionId,@"detailId":_detailId,@"detailStatus":@"dtlSts31",@"guestId":guestId,@"pinCd":_pinCd};
            
            [self setStatus:BodyDictionary];
           
        }
        
        
        
    }
    //确认完成
    if (sender == _but.confirmButton) {
        [self sheetViewControlelr];


    }
    /**添加记录*/
    if (sender == _but.addRecordButton) {
        
        [self pushController];
        
    }
    
    if (sender == ACButton) {
        
    }
}
- (void)setStatus:(NSDictionary *)dic{
    VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL setWODetailURL]];
    [networkFramework startRequestToServer:@"POST" parameter:dic result:^(id responseObject, NSError *error) {
        ServerReturnInfo *retInfo = [[ServerReturnInfo alloc]init];
        if (error)
        {
            retInfo.bSuccess = NO;
            retInfo.strErrorMsg = error.localizedDescription;
            [MBProgressHUD showSuccess:retInfo.strErrorMsg toView:nil];
        }
        else
        {
            
            
            
            if ([_but.setOutButton.titleLabel.text isEqualToString:@"开始维修"] && isTag) {
                [_but.setOutButton setTitle:@"维修中" forState:(UIControlStateNormal)];
                 [_but updateButton:self action:@selector(buttonAction:) judge:NO buttonTitle:@"" color1:COLOR(192, 192, 192, 1) color2:COLOR(64, 161, 132, 1)];
                _but.setOutButton.userInteractionEnabled = NO;
                _but.confirmButton.userInteractionEnabled = YES;
                _but.addRecordButton.userInteractionEnabled = YES;
                [WorkOrderDetailsViewControll registerLocalNotification:1 key:workOrder];
                [WorkOrderDetailsViewControll registerLocalNotification:30 * 60 key:[NSString stringWithFormat:@"%@key",workOrder]];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"tongzhi" object:nil];
            }
            retInfo.bSuccess = YES;




        }
        
    }];
    

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}
- (void)pushController{
    AddRecordViewController *addControlelr = [[AddRecordViewController alloc]init];
    addControlelr.malfunctionId = _malfunctionId;
    addControlelr.detailId = _detailId;
    addControlelr.guestId = guestId;
    addControlelr.pinCd = _pinCd;
    addControlelr.no = _recordArray.count;
    topModel *MODEL = _recordArray.lastObject;
    addControlelr.pacNumber = MODEL.percentage;
    _RecordModel.isPlaying = YES;
    if ([_RecordModel.audioPlayer isPlaying]) {
        [_RecordModel.audioPlayer stop];
        [_RecordModel.vioceButton.soundImage stopAnimating];

    }
    
    [self.navigationController pushViewController:addControlelr animated:YES];
    
}
- (void)fdafdafs:(BOOL)isend isNormalEnd:(BOOL)is{
    
    AddRecordViewController *addControlelr = [[AddRecordViewController alloc]init];
    addControlelr.isEnd = isend;
    addControlelr.malfunctionId = _malfunctionId;
    addControlelr.detailId = _detailId;
    addControlelr.pinCd = _pinCd;
    addControlelr.guestId = guestId;
    addControlelr.no = _recordArray.count;
    _RecordModel.isPlaying = YES;
    addControlelr.isNormalEnd = is;

    if ([_RecordModel.audioPlayer isPlaying]) {
        [_RecordModel.audioPlayer stop];
        [_RecordModel.vioceButton.soundImage stopAnimating];
    }

    [self.navigationController pushViewController:addControlelr animated:YES];
    
}
- (void)sheetViewControlelr{
    UIAlertController *controller =[UIAlertController alertControllerWithTitle:@"请选择进度" message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"非正常完成" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self fdafdafs:YES isNormalEnd:NO];
        
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"正常完成" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self fdafdafs:YES isNormalEnd:YES];
    }];
    
    
    
    [controller addAction:action2];
    [controller addAction:action3];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];

}
#pragma mark - =============TOPvIEWdelegate==================
- (void)pinCodeVerification:(void (^)(NSString *))block{
    pinView = [[NSBundle mainBundle]loadNibNamed:NSStringFromClass([LXGDPinCodeVerification class]) owner:nil options:nil].lastObject;
    [pinView show:^(NSString *text) {
        block(text);
    }];
}

- (void)addScrollViewAndSetAttribute{
    self.baseScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 105)];
    self.baseScrollView.contentSize = CGSizeMake(kScreenWidth, 1.5 * kScreenHeight);
    self.baseScrollView.showsVerticalScrollIndicator = NO;
    self.baseScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_baseScrollView];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
  
}

- (void)addView:(viewToShowInformation *)view toView:(UIView*)view2{
    view.y = CGRectGetMaxY(view2.frame);
    [self.baseScrollView addSubview:view];
}


- (void)showSideMenu{
    [_addView removeFromSuperview];
    _RecordModel.isPlaying = YES;
    if ([_RecordModel.audioPlayer isPlaying]) {
        [_RecordModel.audioPlayer stop];
        [_RecordModel.vioceButton.soundImage stopAnimating];

    }
    [self.navigationController popViewControllerAnimated:YES];//导航控制左按钮，返回上层控制器

}

static NSInteger number ;

// 设置本地通知
+ (void)registerLocalNotification:(NSInteger)alertTime key:(NSString *)str{

    
    
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        // 通知重复提示的单位，可以是天、周、月
    } else {
        // 通知重复提示的单位，可以是天、周、月
    }
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 设置触发通知的时间
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:alertTime];
    NSLog(@"fireDate=%@",fireDate);
    
    notification.fireDate = fireDate;
    // 时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    // 设置重复的间隔
    notification.repeatInterval = kCFCalendarUnitHour;
    
    // 通知内容
    notification.alertBody =  [NSString stringWithFormat:@"%@工单，请添加新记录",workOrder];
    
    
    notification.applicationIconBadgeNumber = 1;
    // 通知被触发时播放的声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    // 通知参数
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@工单，请添加新记录",workOrder] forKey:str];
    notification.userInfo = userDict;

    // 执行通知注册
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

// 取消某个本地推送通知
+ (void)cancelLocalNotificationWithKey:(NSString *)key {
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    
    for (UILocalNotification *notification in localNotifications) {
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            // 根据设置通知参数时指定的key来获取通知参数
            NSString *info = userInfo[key];
            
            // 如果找到需要取消的通知，则取消
            if (info != nil) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
             
            }
        }
    }
}

 
@end
