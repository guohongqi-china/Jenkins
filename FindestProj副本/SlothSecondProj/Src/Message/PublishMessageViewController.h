//
//  PublishMessageViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-27.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "MPTextView.h"
#import "ToolView.h"
#import "ChooseUserAndGroupViewController.h"
#import "ScheduleVo.h"
#import "VoteVo.h"
#import "CTAssetsPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PublishMessageViewController : QNavigationViewController<CTAssetsPickerControllerDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate,ToolViewDelegate,ChooseUserAndGroupDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic)PublishMessageFromType publishMessageFromType;
//进入发表类型（投票/群组）
@property(nonatomic)PublishMsgType enterType;

//init ,out page selected data///////////////////////////////////////////////////////////////
@property (nonatomic, strong) NSMutableArray *aryInitUserChoosed;                //初始选中用户数据
@property (nonatomic, strong) NSMutableArray *aryInitGroupChoosed;               //初始选中群组数据
////////////////////////////////////////////////////////////

@property(nonatomic)BOOL bShowCCAndBCC;//抄送和密送是否显示
@property(nonatomic)BOOL keyboardIsShow;//键盘是否显示
@property(nonatomic,strong)NSMutableArray *attachList;
@property(nonatomic,strong)UIButton *previewButton;

@property(nonatomic,strong)NSMutableArray *aryReceiverList;     //收件人列表
@property(nonatomic,strong)NSMutableArray *aryCCList;           //抄送人列表
@property(nonatomic,strong)NSMutableArray *aryBCList;           //密送人列表

@property(nonatomic,strong)ChooseUserAndGroupViewController *chooseReceiverList;
@property(nonatomic,strong)ChooseUserAndGroupViewController *chooseCCList;
@property(nonatomic,strong)ChooseUserAndGroupViewController *chooseBCList;

//当前发表的类型
@property(nonatomic)PublishMsgType m_publishMsgType;
@property(nonatomic,strong)ScheduleVo *scheduleVo;
@property(nonatomic,strong)VoteVo *voteVo;
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

//附件选择按钮 工具栏
@property(nonatomic,strong)UIView *attachView;      //附件(投票、日程、附件)
@property(nonatomic,strong)ToolView *toolView;      //工具栏

@property(nonatomic,strong)UIButton *btnVote;
@property(nonatomic,strong)UIButton *btnSchedule;
@property(nonatomic,strong)UIButton *btnAttach;
@property(nonatomic,strong)UIImageView *imgViewAttachIcon;

////////////////////////////////////////////////////////////////////////////////
@property(nonatomic,strong)UIView *viewOrigBK;              //BK View
@property(nonatomic,strong)UILabel *lblOrigAuthor;          //引用博文作者
@property(nonatomic,strong)UILabel *lblOrigContent;         //引用博文内容

//外部分享的图片
@property(nonatomic,strong)NSString *strShareImgPath;
@property(nonatomic,strong)UIImage *imgShareThumb;
@property(nonatomic,strong)NSMutableArray *aryAssets;

@end
