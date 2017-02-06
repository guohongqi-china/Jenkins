//
//  TicketDetailViewController.h
//  WeiShangKeProj
//
//  Created by 焱 孙 on 15/5/28.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "TicketVo.h"
#import "InsetsTextField.h"
#import "CustomPicker.h"
#import "ChooseTagViewController.h"
#import "InPutView.h"
#import "SZTextView.h"
#import "EmailInputView.h"

//定义返回刷新Block类型
typedef void (^RefreshTicketBlock)(void);

typedef enum _TicketDetailType{
    TicketDetailAddType,
    TicketDetailModifyType
}TicketDetailType;

@interface TicketDetailViewController : QNavigationViewController<EmailInputViewDelegate,UIAlertViewDelegate,InPutSendDelegateWithAttach,ChooseTagViewControllerDelegate,UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,CustomPickerDelegate>

@property(nonatomic)TicketDetailType ticketDetailType;
@property(nonatomic,strong)TicketVo *m_ticketVo;
@property(nonatomic,strong)NSMutableArray *aryType;
@property(nonatomic,strong)NSString *strTypeID;

@property(nonatomic,strong)UIScrollView *m_scrollView;

//title
@property(nonatomic,strong)InsetsTextField *txtTitle;
@property(nonatomic,strong)UIView *viewLineTitle;

//content
@property(nonatomic,strong)SZTextView *txtViewContent;
@property(nonatomic,strong)UIView *viewLineContent;

//工单类型选择
@property(nonatomic,strong)InsetsTextField *txtType;
@property(nonatomic,strong)UIImageView *imgViewTypeArrow;
@property(nonatomic,strong)CustomPicker *pickerType;
@property(nonatomic,strong)UIView *viewLineType;

//标签管理
@property(nonatomic,strong)UIView *viewTag;
@property(nonatomic,strong)UIView *viewTagContainer;
@property(nonatomic,strong)UIButton *btnAddTag;
@property(nonatomic,strong)UIView *viewLineTag;
@property(nonatomic,strong)UILabel *lblTagPlaceHolder;

//工单操作记录
@property(nonatomic,strong)UITableView *tableViewRecord;

//bottom button
@property(nonatomic,strong)UIView *viewBottom;
@property(nonatomic,strong)UIButton *btnMerge;
@property(nonatomic,strong)UIButton *btnClose;
@property(nonatomic,strong)UIButton *btnSend;
@property(nonatomic,strong)UIButton *btnAddRecord;

//合并工单
@property(nonatomic,strong)CustomPicker *pickerTicket;
@property(nonatomic,strong)NSMutableArray *aryOutTicket;    //外部工单列表(避免重复查询)
@property(nonatomic,strong)NSMutableArray *aryTicket;       //内部查询的工单列表

//发送邮件
//@property(nonatomic,strong)EmailInputView *emailInputView;

//
@property(nonatomic,strong)ChooseTagViewController *chooseTagViewController;

//add record
@property(nonatomic,strong)InPutView *inPutView;

@property(nonatomic)BOOL bBackRefresh;  //返回页面是否刷新列表
//block
@property(nonatomic,copy)RefreshTicketBlock refreshTicketBlock;

@end
