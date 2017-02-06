//
//  ActivityDetailOldViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-5-29.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "BlogVo.h"
#import "InsetsTextField.h"
#import "CustomPicker.h"

@interface ActivityDetailOldViewController : QNavigationViewController<UITextFieldDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate,UIWebViewDelegate,UIScrollViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,CustomPickerDelegate>

//down view button
@property(nonatomic,strong)UIView   *viewContainer;
@property(nonatomic,strong)UIView   *viewProjectList;

@property(nonatomic,strong)UIView   *viewBottom;
@property(nonatomic,strong)UIImageView *imgViewTabLine;
@property(nonatomic,strong)UIButton *btnPraise;
@property(nonatomic,strong)UIButton *btnForward;
@property(nonatomic,strong)UIButton *btnComment;

@property(nonatomic,strong)UIScrollView * m_scrollView;
@property(nonatomic,strong)NSString * m_strRefID;
@property(nonatomic,strong)UIButton *btnEdit;
@property(nonatomic)int isFavorite;
@property(nonatomic,strong)BlogVo *m_blogVo;
@property(nonatomic,strong)UIWebView *webViewContent;
@property(nonatomic)int nWebViewHeight;
@property(nonatomic,strong)UIImageView *imageHead;
@property(nonatomic,strong)UILabel *lblName;
@property(nonatomic,strong)UILabel *lblTime;
@property(nonatomic,strong)UIView *viewLine1;
@property(nonatomic,strong)UILabel *lblArticleTitle;
@property(nonatomic,strong)UILabel *lblActivityRemark;

//附件列表
@property(nonatomic,strong)UIView *viewAttachmentContainer;

//会议报名
@property(nonatomic,strong)UIView *viewMeetingContainer;

@property(nonatomic,strong)UILabel *lblRealName;
@property(nonatomic,strong)InsetsTextField *txtRealName;

@property(nonatomic,strong)UILabel *lblGender;
@property(nonatomic,strong)InsetsTextField *txtGender;

@property(nonatomic,strong)UILabel *lblPhoneNum;
@property(nonatomic,strong)InsetsTextField *txtPhoneNum;

@property(nonatomic,strong)UILabel *lblEmail;
@property(nonatomic,strong)InsetsTextField *txtEmail;

@property(nonatomic,strong)UILabel *lblDepartment;
@property(nonatomic,strong)InsetsTextField *txtDepartment;
@property(nonatomic,strong)CustomPicker *pickerDepartment;

@property(nonatomic,strong)UIView *viewFieldContainer;//会议自定义字段

@property(nonatomic,strong)UIButton *btnSignup;//会议报名按钮

@property(nonatomic,strong)NSMutableDictionary *dicOffsetY; //键盘视图，调整位置

//赞列表
@property(nonatomic,strong)UILabel *lblPraiseDetail;               //详细赞名称
@property(nonatomic,strong)UILabel *lblPraiseDes;                  //部分赞名称
@property(nonatomic,strong)UIButton *btnShowDetail;                //显示、隐藏赞列表
@property(nonatomic)BOOL bShow;       //展开和隐藏

@property(nonatomic)BOOL bReturnRefresh;        //返回是否刷新列表

@property(nonatomic,strong)NSString *strDepartmentID;       //缓存departmentID

////////////////////////////////////////////////////////////////////////
@property(nonatomic,strong)NSMutableArray *aryProjectList;//报名的项目列表

@property(nonatomic)BOOL bScrolling;   //UIWebView是否正在滚动，优化分享详情图片点击

@end
