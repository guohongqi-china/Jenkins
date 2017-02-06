//
//  ChexiangJobViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/24.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"
#import "JobVo.h"

@interface ChexiangJobViewController : CommonViewController

@property (nonatomic,strong) NSString *strJobID;

@property (nonatomic,strong) NSString *strChexiangAccount;      //登录后的车享账号
@property (nonatomic,strong) NSString *strMyWorkbenchURL;      //我的工作台超链接（如果登录或验证接口返回，就用返回的链接，没有则用配置的链接）

@end
