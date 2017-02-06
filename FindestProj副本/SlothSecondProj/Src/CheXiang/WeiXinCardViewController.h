//
//  WeiXinCardViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/10/22.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"

@interface WeiXinCardViewController : QNavigationViewController

@property(nonatomic)NSInteger nType;//1:查看名片  ,2:编辑名片
@property(nonatomic,strong)NSString *strUserID;

@end
