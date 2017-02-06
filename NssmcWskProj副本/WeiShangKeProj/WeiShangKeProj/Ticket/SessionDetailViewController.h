//
//  SessionDetailViewController.h
//  WeiShangKeProj
//
//  Created by 焱 孙 on 5/18/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "CustomerVo.h"
#import "ChatContentVo.h"
#import "FaceToolBar.h"
#import "ChatObjectVo.h"
#import "SendChatVo.h"
#import "GroupAndUserDao.h"
#import "CustomPicker.h"
#import "FAQListViewController.h"
#import "FAQVo.h"

//定义返回刷新Block类型
typedef void (^RefreshSessionBlock)(void);

@interface SessionDetailViewController : QNavigationViewController<CustomPickerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,AVAudioPlayerDelegate,UITableViewDelegate,UITableViewDataSource,FaceToolBarDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>

@property (nonatomic, retain) NSMutableArray *aryChatCon;
@property (nonatomic, retain) UITableView *tableViewChat;
@property (nonatomic, strong) UIRefreshControl* refreshControl;

//转交客服
@property(nonatomic,strong) CustomPicker *pickerKefu;
@property (nonatomic, retain) NSMutableArray *aryKefu;

@property (nonatomic, retain) FaceToolBar *faceToolBar;
@property (nonatomic, retain) SendChatVo *m_sendChatVo;
@property (nonatomic, retain) ServerReturnInfo *serverReturnInfo;
@property (nonatomic, retain) ChatObjectVo *m_chatObjectVo;         //列表传递过来的参数

//分页查寻数据
@property (nonatomic,strong) NSString *strEndMessageID;

@property (nonatomic) BOOL bReturnRefresh;//返回是否刷新

@property (nonatomic) BOOL bFirstLoad;//is or not first load

@property (nonatomic) BOOL bRunningUpdate;

//聊天的图片列表
@property (nonatomic,strong) NSMutableArray *aryImageList;//只存放strCId和strImgURL
@property (nonatomic,strong) NSMutableArray *aryImageURL;//只存放maxURL和minURL
@property (nonatomic) NSInteger nImageMaxIndex;//用于定义推送过来的图片的自定义ID

//block
@property (nonatomic,copy) RefreshSessionBlock refreshSessionBlock;//刷新sessionList block

//音频处理
@property (nonatomic) BOOL bAudioPlaying;   //是否正在播放音频
@property (nonatomic, weak) ChatContentVo *chatContentVoAudio;
@property(nonatomic,strong) NSMutableArray *aryReceiverAudioIcon;//用于播放时动态显示
@property(nonatomic,strong) NSMutableArray *arySenderAudioIcon;//用于播放时动态显示
@property(nonatomic,strong) AVAudioPlayer *audioPlayer;

- (void)tackleAudioAction:(ChatContentVo*)chatContentVo andImgView:(UIImageView*)imgView;
- (void)sendFAQ:(FAQVo*)faqVo result:(SendMessageResultBlock)resultBlock type:(NSInteger)nType;
- (void)postPasteImageOperate;
- (void)doTouchTableView;

@end
