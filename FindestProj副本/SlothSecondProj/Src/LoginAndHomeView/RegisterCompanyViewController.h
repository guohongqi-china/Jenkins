//
//  RegisterCompanyViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/12/25.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "UserVo.h"
@interface RegisterCompanyViewController : CommonViewController

@property(nonatomic , copy)NSString *userName;

@property(nonatomic , strong)UserVo *registerVo;

@end
