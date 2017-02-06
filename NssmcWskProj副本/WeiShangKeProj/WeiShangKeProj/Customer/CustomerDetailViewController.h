//
//  CustomerDetailViewController.h
//  WeiShangKeProj
//
//  Created by 焱 孙 on 4/29/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "CustomerVo.h"
#import "ChatObjectVo.h"

@interface CustomerDetailViewController : QNavigationViewController<UITextFieldDelegate,UITextViewDelegate>

@property(nonatomic)BOOL bModifyInfo;//是否修改了客户信息，用于更新
@property(nonatomic,strong)NSMutableDictionary *dicOffsetY; //键盘视图，调整位置
@property(nonatomic,strong)CustomerVo *m_customerVo;

@property(nonatomic,strong)UIScrollView *m_scrollView;
@property(nonatomic,strong)UIView *viewHeadTop;
@property(nonatomic,strong)UIImageView *imgViewHead;

@property(nonatomic,strong)UIButton *btnSessionDetail;//会话详情
@property(nonatomic,strong)UIButton *btnTicket;//工单

@property(nonatomic,strong)UIImageView *imgViewName;
@property(nonatomic,strong)UITextField *txtName;
@property(nonatomic,strong)UIView *viewLineName;

@property(nonatomic,strong)UIImageView *imgViewCode;
@property(nonatomic,strong)UITextField *txtCode;
@property(nonatomic,strong)UIView *viewLineCode;

@property(nonatomic,strong)UIImageView *imgViewPhone;
@property(nonatomic,strong)UITextField *txtPhone;
@property(nonatomic,strong)UIView *viewLinePhone;

@property(nonatomic,strong)UIImageView *imgViewEmail;
@property(nonatomic,strong)UITextField *txtEmail;
@property(nonatomic,strong)UIView *viewLineEmail;

@property(nonatomic,strong)UIImageView *imgViewRemark;
@property(nonatomic,strong)UITextView *txtViewRemark;
@property(nonatomic,strong)UIView *viewLineRemark;


@end
