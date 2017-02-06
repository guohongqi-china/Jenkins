//
//  AddAndEditGroupViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-9.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "ChooseUserViewController.h"
#import "GroupVo.h"

@interface AddAndEditGroupViewController : QNavigationViewController<UIScrollViewDelegate,UITextFieldDelegate,ChooseUserViewControllerDelegate>

@property (nonatomic) GroupPageName groupPageName;
@property (nonatomic, strong) NSString* strGroupName;
@property (nonatomic, strong) NSMutableDictionary *dicOffsetY;

@property (nonatomic) BOOL bRefreshGroupList;

//选择成员
@property (nonatomic, retain) NSMutableArray *aryChooseUser;
@property (nonatomic, retain) ChooseUserViewController *chooseUserViewController;

//当前群组
@property (nonatomic, retain) GroupVo *m_groupVo;

//add////////////////////////////////////////////////////////////////
//background
@property (nonatomic, strong) UIImageView *imgViewTopBK;

//群组名称
@property (nonatomic, strong) UILabel *lblGroupName;
@property (nonatomic, strong) UITextField *txtGroupName;

//群外人可以看到本群
@property (nonatomic, strong) UILabel *lblAllowSee;
@property (nonatomic, strong) UISwitch *switchAllowSee;

//群外人可以自由加入本群
@property (nonatomic, strong) UILabel *lblAllowJoin;
@property (nonatomic, strong) UISwitch *switchAllowJoin;

//群成员
@property (nonatomic, strong) UILabel *lblMemSumNum;

//成员
@property (nonatomic, strong) UIImageView *imgViewColleagueBK;
@property (nonatomic, strong) UIImageView *imgViewColleague;
@property (nonatomic, strong) UILabel *lblColleague;
@property (nonatomic, strong) UILabel *lblColleagueNum;
@property (nonatomic, strong) UIImageView *imgViewColleagueArrow;
@property (nonatomic, strong) UIButton *btnColleague;

//外部用户
@property (nonatomic, strong) UIImageView *imgViewOutBK;
@property (nonatomic, strong) UIImageView *imgViewOut;
@property (nonatomic, strong) UILabel *lblOut;
@property (nonatomic, strong) UILabel *lblOutNum;
@property (nonatomic, strong) UIImageView *imgViewOutArrow;
@property (nonatomic, strong) UIButton *btnOut;

//add button
@property (nonatomic, strong) UIButton *btnAddGroup;

//////////////////////////////////////////////////////////////////
@property (nonatomic, strong) UIScrollView *viewScrollGroup;

@end
