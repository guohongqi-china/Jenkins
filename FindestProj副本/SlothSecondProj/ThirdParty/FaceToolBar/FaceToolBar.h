//
//  FaceToolBar.h
//  TestKeyboard
//
//  Created by wangjianle on 13-2-26.
//  Copyright (c) 2013年 wangjianle. All rights reserved.
//
#define Time  0.3
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define keyboardHeight 216
#define toolBarHeight 45
#define choiceBarHeight 35
#define facialViewHeight 170
#define buttonWh 34

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "SMPageControl.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioTipView.h"

@protocol FaceToolBarDelegate <NSObject>
-(void)sendTextAction:(NSAttributedString *)inputText;
-(void)sendAudioAction:(NSString *)strFilePath andDuration:(NSString*)strDuration;
-(void)toolBarYOffsetChange:(float)fYOffset;
-(void)clickMoreBtnAction:(UIButton*)btnSender;
//录音状态变更，停止其他行为，YES:准备录音，NO:结束录音
-(void)recordAudioStateChanged:(BOOL)bState;
@end
//注：dealloc 将FaceToolBar从通知中心移除，否则下次进来会继续向FaceToolBar发送消息，但是已经释放，会出现Clash
@interface FaceToolBar:NSObject <HPGrowingTextViewDelegate,UIScrollViewDelegate>

@property(nonatomic,retain) UIImageView *toolBar;                 //工具栏
@property(nonatomic,retain) HPGrowingTextView *textView;      //文本输入框
@property(nonatomic,retain) UIButton *btnFacial;
@property(nonatomic,retain) UIButton *btnMore;
@property(nonatomic,retain) UIButton *btnAudio;
@property(nonatomic,retain) UIButton *btnRecord;    //录音按钮

@property(nonatomic,retain) UIView *viewContainer;          //弹出容器视图
@property(nonatomic,strong) UIScrollView *scrollViewFacial;       //表情视图
@property(nonatomic,strong) UIScrollView *scrollViewMore;         //更多视图
@property(nonatomic,strong) SMPageControl *pageControlFace;
@property(nonatomic) NSInteger nPage;

@property(nonatomic,assign) BOOL keyboardIsShow;                //键盘是否显示
@property(nonatomic,assign) BOOL bBottomShow;                   //底部是否弹起
@property(nonatomic,assign) BOOL bTouchFunctionButton;          //触摸功能键，关闭键盘

@property(nonatomic,assign) UIView *theSuperView;
@property(nonatomic,assign) CGRect rcSuperView;
@property(nonatomic,assign) id<FaceToolBarDelegate> delegateFaceToolBar;

//表情操作
@property(nonatomic,strong) UIButton *btnSenderFacial;

//录音操作
@property(nonatomic,strong) AVAudioRecorder *recorder;
@property(nonatomic,strong) NSString *strCurrPath;
@property(nonatomic) BOOL bRecording;//是否正在录音
@property(nonatomic,strong) AudioTipView *audioTipView;
@property(nonatomic,strong) NSTimer *timerAudio;//检测音量

-(id)init:(CGRect)rcSuperView superView:(UIView *)superView;

-(void)dismissKeyBoard;

@end
