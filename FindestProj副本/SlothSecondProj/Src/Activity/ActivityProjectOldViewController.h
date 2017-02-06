//
//  ActivityProjectOldViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-5-29.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "ActivityProjectVo.h"
#import "BlogVo.h"
#import "InsetsTextField.h"

@interface ActivityProjectOldViewController : QNavigationViewController<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate,UITextFieldDelegate>

@property(nonatomic,strong)UIScrollView * m_scrollView;
@property(nonatomic,strong)UIView   *viewBK;
@property(nonatomic,strong)UILabel *lblProjectName;
@property(nonatomic,strong)UILabel *lblProjectDateTime;
@property(nonatomic,strong)UIView *viewLine1;
@property(nonatomic,strong)UIImageView *imgViewProject;
@property(nonatomic,strong)UILabel *lblProjectDesc;

@property(nonatomic,strong)UIView   *viewSignupBK;
@property(nonatomic,strong)UILabel *lblRealName;
@property(nonatomic,strong)InsetsTextField *txtRealName;
@property(nonatomic,strong)UILabel *lblPhoneNum;
@property(nonatomic,strong)InsetsTextField *txtPhoneNum;
@property(nonatomic,strong)UILabel *lblWorkUnit;
@property(nonatomic,strong)InsetsTextField *txtWorkUnit;
@property(nonatomic,strong)UILabel *lblPosition;
@property(nonatomic,strong)InsetsTextField *txtPosition;

@property(nonatomic,strong)UIButton *btnSignup;

@property(nonatomic,strong)UITableView *tableViewUser;

@property(nonatomic,strong)UIImage *imgProject;
@property(nonatomic,strong)ActivityProjectVo *m_activityProjectVo;
@property(nonatomic,strong)BlogVo *m_blogVo;
@property(nonatomic,strong)NSMutableDictionary *dicOffsetY; //键盘视图，调整位置

@end
