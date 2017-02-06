//
//  UserDetailViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-17.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "UserVo.h"

@interface UserDetailViewController : QNavigationViewController

@property(nonatomic,strong)UserVo *m_userVo;
///////////////////////////////////////////////////////////////
@property(nonatomic,strong)UIScrollView *m_scrollView;

@property (nonatomic, strong)UIImageView *imgViewTopBK;
@property(nonatomic,strong)UILabel *lblHeadImage;
@property(nonatomic,strong)UIImageView *imgViewHead;

@property (nonatomic, strong)UIImageView *imgViewBottomBK;
@property(nonatomic,strong)UILabel *lblName;

@property(nonatomic,strong)UILabel *lblBirthday;

@property(nonatomic,strong)UILabel *lblGender;

@property(nonatomic,strong)UILabel *lblPosition;

//@property(nonatomic,strong)UILabel *lblCompany;

@property(nonatomic,strong)UILabel *lblPhoneNum;

@property(nonatomic,strong)UILabel *lblQQ;

@property(nonatomic,strong)UILabel *lblEmail;

@property(nonatomic,strong)UILabel *lblAddress;

@property(nonatomic,strong)UILabel *lblSignature;

-(void)refreshView;

@end
