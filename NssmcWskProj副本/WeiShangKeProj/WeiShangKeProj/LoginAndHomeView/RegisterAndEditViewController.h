//
//  RegisterAndEditViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-4-1.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "CustomDatePicker.h"
#import "UserVo.h"

typedef NS_ENUM(NSInteger,RegisterAndEditType)
{
    RegisterUserType,
    EditUserType
};

@interface RegisterAndEditViewController : QNavigationViewController

@property (nonatomic) RegisterAndEditType viewType;
@property (nonatomic,strong) UserVo *m_userVo;

@end
