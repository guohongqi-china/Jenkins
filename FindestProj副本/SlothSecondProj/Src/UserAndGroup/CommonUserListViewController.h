//
//  CommonUserListViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/19.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"
#import "BlogVo.h"

typedef NS_ENUM(NSInteger,CommonUserListType)
{
    UserListActivityType,           //活动参与人
    UserListAttentionType,          //关注的人
    UserListFansType                //我的粉丝
};

@interface CommonUserListViewController : CommonViewController

@property (nonatomic,strong) BlogVo *blogVo;
@property (nonatomic,strong) NSString *strUserID;
@property (nonatomic) CommonUserListType userListType;


@end
