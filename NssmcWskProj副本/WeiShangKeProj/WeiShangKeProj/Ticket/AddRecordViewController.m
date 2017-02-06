//
//  AddRecordViewController.m
//  NssmcWskProj
//
//  Created by MacBook on 16/5/27.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "AddRecordViewController.h"
#import "addAlertView.h"
#import "SNUIBarButtonItem.h"
#import "RecordView.h"
#import "RecordModel.h"
#import "Common.h"
@interface AddRecordViewController ()
{
    RecordModel *RDModel;
}
@property (nonatomic, assign) BOOL isJudgeAddRecordStatus;/** <#注释#> */
@property (nonatomic, strong) addAlertView *alerView;/** <#注释#> */

@end
@implementation AddRecordViewController


- (void)viewDidLoad{
    self.title = @"添加记录";
    //注册接近传感器的通知
    SNUIBarButtonItem *leftItem = [SNUIBarButtonItem backItemWithImage:@"nav_setting" target:self action:@selector(showSideMenu)];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationController.navigationBar.translucent = NO;
    [self updateUI];
    
    //**判断沙盒的可用空间*/
//    NSNumber *number1 = [self freeDiskSpace];
//    NSNumber *number2 = [self totalDiskSpace];
}

//- (RecordModel *)RDModel{
//    if (_RecordModel) {
//        _RDModel = [[RecordModel alloc]initWith:self voiceView:self.SDView];
//        //        [self.SDView insertSubview:_RDModel.soundView aboveSubview:self];
//    }
//    return _RDModel;
//}

//判断沙盒的总空间
- (NSNumber *)totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}
//判断沙盒的可用空间
- (NSNumber *)freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}
- (void)updateUI{
    NSArray *VIEWarray = [[NSBundle mainBundle]loadNibNamed:@"addAlertView" owner:nil options:nil];
    addAlertView *alertViewll = [VIEWarray lastObject];
    alertViewll.malfunctionId = _malfunctionId;
    alertViewll.guestId = _guestId;
    alertViewll.detailId  = _detailId;
    alertViewll.no = _no;
    alertViewll.SDView = self.view;
    alertViewll.isNormalEnd = _isNormalEnd;
    alertViewll.frame = self.view.frame;
    alertViewll.pinCd = _pinCd;
    [self.view addSubview:alertViewll];
    [alertViewll updateUI];
    if (_isEnd) {
        alertViewll.ProgressSlide.value = 1;
        alertViewll.percentage = @"100";
        alertViewll.judgeView.hidden = NO;
        alertViewll.inputView.hidden = YES;
        alertViewll.baseview.hidden = YES;
    }else{
        alertViewll.percentage = _pacNumber;
    }

}

- (void)showSideMenu{
    [self.navigationController popViewControllerAnimated:YES];//导航控制左按钮，返回上层控制器
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];


}














@end
