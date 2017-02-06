//
//  PublishScheduleViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-6-10.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "MPTextView.h"
#import "ChooseUserAndGroupViewController.h"
#import "ScheduleVo.h"
#import "CustomDatePicker.h"

@interface PublishScheduleViewController : QNavigationViewController<UIGestureRecognizerDelegate,UIScrollViewDelegate,ChooseUserAndGroupDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,CustomDatePickerDelegate>

@property(nonatomic)PublishMessageFromType publishMessageFromType;
@property(nonatomic,strong)NSMutableDictionary *dicOffsetY; //键盘视图，调整位置

//init ,out page selected data///////////////////////////////////////////////////////////////
@property (nonatomic, strong) NSMutableArray *aryInitUserChoosed;                //初始选中用户数据
@property (nonatomic, strong) NSMutableArray *aryInitGroupChoosed;               //初始选中群组数据
////////////////////////////////////////////////////////////

@property(nonatomic)BOOL bShowCCAndBCC;//抄送和密送是否显示
@property(nonatomic)BOOL keyboardIsShow;//键盘是否显示

@property(nonatomic,strong)NSMutableArray *aryReceiverList;     //收件人列表
@property(nonatomic,strong)NSMutableArray *aryCCList;           //抄送人列表
@property(nonatomic,strong)NSMutableArray *aryBCList;           //密送人列表

@property(nonatomic,strong)ChooseUserAndGroupViewController *chooseReceiverList;
@property(nonatomic,strong)ChooseUserAndGroupViewController *chooseCCList;
@property(nonatomic,strong)ChooseUserAndGroupViewController *chooseBCList;

@property(nonatomic,strong)ScheduleVo *scheduleVo;
@property(nonatomic,strong)MessageVo *m_messageVo;              //current message vo
@property(nonatomic,strong)MessageVo *m_preMessageVo;           //之前页面 message vo

@property(nonatomic,strong)UIScrollView *scrollViewPublic;

//1.收件人
@property(nonatomic,strong)UIView *viewReceiver;
@property(nonatomic,strong)UIImageView *imgViewArrowIcon;
@property(nonatomic,strong)UIButton *btnAddArrowIcon;

@property(nonatomic,strong)UILabel *lblReceiverTitle;
@property(nonatomic,strong)UILabel *lblReceiverName;
@property(nonatomic,strong)UIButton *btnAddReceiver;
@property(nonatomic,strong)UIView *viewLineReceiver;

//2.抄送
@property(nonatomic,strong)UIView *viewCC;
@property(nonatomic,strong)UILabel *lblCCTitle;
@property(nonatomic,strong)UILabel *lblCCName;
@property(nonatomic,strong)UIButton *btnAddCC;
@property(nonatomic,strong)UIView *viewLineCC;

//3.密送
@property(nonatomic,strong)UIView *viewBC;
@property(nonatomic,strong)UILabel *lblBCTitle;
@property(nonatomic,strong)UILabel *lblBCName;
@property(nonatomic,strong)UIButton *btnAddBC;
@property(nonatomic,strong)UIView *viewLineBC;

//4.协作者（暂时不支持）

//5.主题
@property(nonatomic,strong)UIView *viewConTitle;
@property(nonatomic,strong)UILabel *lblConTitle;
@property(nonatomic,strong)UITextField *txtConTitle;
@property(nonatomic,strong)UIView *viewLineConTitle;

//6.标签
@property(nonatomic,strong)UIView *viewTag;
@property(nonatomic,strong)UILabel *lblTagTitle;
@property(nonatomic,strong)UILabel *lblTagName;
@property(nonatomic,strong)UIButton *btnAddTag;
@property(nonatomic,strong)UIView *viewLineTag;

//7.内容
@property(nonatomic,strong)UIView *viewContent;
@property(nonatomic,strong)MPTextView *txtViewContent;
@property(nonatomic,strong)UIView *viewLineContent;

//8.时间
@property(nonatomic,strong)UIView *viewDateTime;
@property(nonatomic,strong)UILabel *lblDateTime;
@property(nonatomic,strong)UITextField *txtDateTime;
@property(nonatomic,strong)UIButton *btnDateTime;
@property(nonatomic,strong)CustomDatePicker *pickerDateTime;
@property(nonatomic,strong)UIView *viewLineDateTime;

//9.地点
@property(nonatomic,strong)UIView *viewPlace;
@property(nonatomic,strong)UILabel *lblPlace;
@property(nonatomic,strong)UITextField *txtPlace;
@property(nonatomic,strong)UIView *viewLinePlace;

@end
