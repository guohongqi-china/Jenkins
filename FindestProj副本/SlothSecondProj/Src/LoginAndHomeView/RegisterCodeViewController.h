//
//  RegisterCodeViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/25.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "UserVo.h"
typedef NS_ENUM(NSUInteger,RegisterCodeType){
    RegisterCodeRegisterType,  //注册流程
    RegisterCodeResetPwdType   //重置密码
};

@interface RegisterCodeViewController : CommonViewController

@property (nonatomic) RegisterCodeType viewType;
@property(nonatomic , strong)UserVo *registerVo;

//发送验证码
-(void)sendPhoneCode;

@end
