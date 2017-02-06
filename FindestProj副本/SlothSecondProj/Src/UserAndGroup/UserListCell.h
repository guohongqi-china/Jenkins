//
//  UserListCell.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-24.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserVo.h"
#import "MGSwipeTableCell.h"
#import "CustomHeaderView.h"

@interface UserListCell : MGSwipeTableCell

@property(nonatomic,strong) CustomHeaderView *customHeaderView;

@property(nonatomic,strong)UILabel *lblName;
@property(nonatomic,strong)UILabel *lblPosition;        //职位
@property(nonatomic,strong)UILabel *lblPhoneNum;

@property(nonatomic,strong)UIButton *btnIntegration;   //积分编辑

@property(nonatomic,strong)UIView *viewLine;

@property(nonatomic,strong)UserVo *m_userVo;
@property(nonatomic,weak)UIViewController *parentViewController;

-(void)initWithUserVo:(UserVo*)userVo;

@end
