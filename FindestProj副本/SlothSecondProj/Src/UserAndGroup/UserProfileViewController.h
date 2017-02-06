//
//  UserProfileViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/26.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserVo.h"
#import "CommonViewController.h"

@interface UserProfileViewController : CommonViewController

@property(nonatomic,strong)NSString *strUserID;
@property (nonatomic,strong) UITableView *tableViewList;

@property (nonatomic) NSInteger nCellHeight;

@end
