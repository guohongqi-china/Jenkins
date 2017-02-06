//
//  RegisterPhoneViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/25.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "UserVo.h"
typedef NS_ENUM(NSUInteger,RegisterPhoneType){
    RegisterPhoneRegisterType,  //注册流程
    RegisterPhoneResetPwdType   //重置密码
};

@interface RegisterPhoneViewController : CommonViewController

@property (nonatomic) RegisterPhoneType viewType;

@property(nonatomic , strong)UserVo *registerVo;

@end
