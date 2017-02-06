//
//  GroupDetailViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-3-10.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "CommonUserListViewController.h"

@interface GroupDetailViewController : QNavigationViewController<UIScrollViewDelegate,CommonUserListDelegate>

@property (nonatomic, assign) BOOL bRefreshGroupList;
@property (nonatomic, retain) GroupVo *m_groupVo;
@property (nonatomic, retain) NSString *strGroupID;

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

//群主
@property (nonatomic, strong) UILabel *lblGroupOwner;

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

@property (nonatomic, strong) UIScrollView *viewScrollGroup;

/////////////////////////////////////////////////////////////////////////
@property (nonatomic, retain) UIButton *btnJoin;
@property (nonatomic, retain) UIButton *btnExit;
@property (nonatomic, retain) UIButton *btnTransferGroup;
@property (nonatomic, retain) UIButton *btnDismissGroup;


@end
