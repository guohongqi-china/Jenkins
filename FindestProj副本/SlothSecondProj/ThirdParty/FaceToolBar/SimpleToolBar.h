//
//  SimpleToolBar.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 5/6/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPGrowingTextView.h"
#import "SMPageControl.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioTipView.h"
#import "FaceToolBar.h"
#import "CTAssetsPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ReplyUserViewController.h"

typedef enum _SimpleToolBarType{
    SimpleToolBarFaceType,      //表情
    SimpleToolBarAttachType       //附件
}SimpleToolBarType;

@protocol SimpleToolBarDelegate <NSObject>
@optional
-(void)sendTextAction:(NSString*)strText;
-(void)toolBarYOffsetChange:(float)fYOffset;
-(void)clickMoreBtnAction:(UIButton*)btnSender;
-(void)hideKeyboard;
-(void)showKeyboard;
-(void)hideBottomTab;

- (void)cameraButton:(id)sender;
- (void)photoButton:(id)sender;
- (void)videoButton:(id)sender;
@end

@interface SimpleToolBar : NSObject<ReplyUserDelegate,CTAssetsPickerControllerDelegate,HPGrowingTextViewDelegate,UIScrollViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIScrollView *contentView;
}

@property(nonatomic) SimpleToolBarType simpleToolBarType;

@property(nonatomic,retain) UIToolbar *toolBar;                 //工具栏
@property(nonatomic,retain) HPGrowingTextView *textView;      //文本输入框
@property(nonatomic,retain) UIButton *btnFacial;
@property(nonatomic,retain) UIButton *btnMore;

@property(nonatomic,retain) UIView *viewContainer;          //弹出容器视图
@property(nonatomic,strong) UIScrollView *scrollViewFacial;       //表情视图
@property(nonatomic,strong) SMPageControl *pageControlFace;
@property(nonatomic) NSInteger nPage;

@property(nonatomic) BOOL keyboardIsShow;                //键盘是否显示
@property(nonatomic) BOOL bBottomShow;                   //底部是否弹起
@property(nonatomic) BOOL bTouchFunctionButton;          //触摸功能键，关闭键盘
@property(nonatomic) BOOL bEnableAT;                     //是否启用@功能
@property(nonatomic) BOOL bHideBottomTab;                //是否关闭父类bottom tab

@property(nonatomic,assign) UIView *theSuperView;
@property(nonatomic,assign) CGRect rcSuperView;
@property(nonatomic,weak) id<SimpleToolBarDelegate> delegateFaceToolBar;

@property(nonatomic,strong)UIView *viewAttach;
@property(nonatomic,strong)NSMutableArray *attachList;
@property(nonatomic,strong)UIButton *previewButton;
@property(nonatomic,strong)NSMutableArray *aryAssets;

//@回复
@property(nonatomic,strong)ReplyUserViewController *replyUserViewController;
@property(nonatomic,strong)NSMutableArray *aryReplyUser;

//表情操作
@property(nonatomic,strong) UIButton *btnSenderFacial;

-(id)init:(CGRect)rcView superView:(UIView *)superView type:(SimpleToolBarType)simpleToolBarType;

-(void)showKeyboard;
-(void)dismissKeyBoard;
-(void)resetFrame;
-(void)deleteAllAttachView;
-(void)clearToolBarData;

@end
