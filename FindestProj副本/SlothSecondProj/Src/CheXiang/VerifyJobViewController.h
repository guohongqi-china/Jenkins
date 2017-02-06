//
//  VerifyJobViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/22.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"
#import "JobVo.h"

typedef NS_ENUM(NSInteger,VerifyJobPageType)
{
    VerifyJobVerifyType,        //再次验证操作
    VerifyJobAddType            //添加工作验证
};

@interface VerifyJobViewController : CommonViewController

@property (nonatomic,strong) JobVo *jobVo;

@end
