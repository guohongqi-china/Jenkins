//
//  JobWebViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/22.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"
#import "JobVo.h"

@interface JobWebViewController : CommonViewController

@property (nonatomic)NSInteger nFlag;           //0:其他，1:车享里面的 - 我的工作台（不包含解绑）
@property (nonatomic,strong) JobVo *jobVo;

@end
