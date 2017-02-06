//
//  ChatContentViewController.h
//  Sloth
//
//  Created by 焱 孙 on 13-6-18.
//
//

#import <UIKit/UIKit.h>
#import "QNavigationViewController.h"
#import "UserVo.h"
#import "ChatContentVo.h"
#import "ChatContentCell.h"
#import "FaceToolBar.h"
#import "ChatObjectVo.h"
#import "SendChatVo.h"
#import "GroupAndUserDao.h"
#import "ReplyUserViewController.h"

//文档来自类型
typedef enum {
    ChatContentPlainType = 0,              //普通聊天视图
    ChatContentMeetingType                 //会务人员聊天视图
}ChatContentViewType;

@interface ChatContentViewController : QNavigationViewController<AVAudioPlayerDelegate,UITableViewDelegate,UITableViewDataSource,FaceToolBarDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,ReplyUserDelegate>

@property (nonatomic, retain) NSMutableArray *aryChatCon;
@property (nonatomic, retain) UITableView *tableViewChat;
@property (nonatomic, strong) UIRefreshControl* refreshControl;

@property (nonatomic, retain) FaceToolBar *faceToolBar;
@property (nonatomic, retain) SendChatVo *m_sendChatVo;
@property (nonatomic, retain) ServerReturnInfo *serverReturnInfo;
@property (nonatomic, retain) ChatObjectVo *m_chatObjectVo;         //列表传递过来的参数

@property(nonatomic,retain) UIImagePickerController *photoController;
@property(nonatomic,retain) UIImagePickerController *photoAlbumController;
    
@property(nonatomic,retain)UIImage *imgHeadSelf;            //自己的头像
@property(nonatomic,retain)UIImage *imgHeadOther;           //对方的头像

@property (nonatomic)ChatContentViewType chatContentViewType;

//分页查寻数据
@property (nonatomic) long long nQueryDateTime;
@property (nonatomic) int nChatPageNum;

@property (nonatomic) BOOL bReturnRefresh;//返回是否刷新

@property (nonatomic) BOOL bFirstLoad;//is or not first load

@property (nonatomic) BOOL bRunningUpdate;

//聊天的图片列表
@property (nonatomic,strong) NSMutableArray *aryImageList;//只存放strCId和strImgURL
@property (nonatomic,strong) NSMutableArray *aryImageURL;//只存放maxURL和minURL
@property (nonatomic) NSInteger nImageMaxIndex;//用于定义推送过来的图片的自定义ID

//音频处理
@property (nonatomic) BOOL bAudioPlaying;   //是否正在播放音频
@property (nonatomic, weak) ChatContentVo *chatContentVoAudio;
@property(nonatomic,strong) NSMutableArray *aryReceiverAudioIcon;//用于播放时动态显示
@property(nonatomic,strong) NSMutableArray *arySenderAudioIcon;//用于播放时动态显示
@property(nonatomic,strong) AVAudioPlayer *audioPlayer;

//@回复他人的操作
@property(nonatomic,strong) ReplyUserViewController *replyUserViewController;
@property(nonatomic,strong) NSMutableArray *aryReplyUser;
@property (nonatomic) BOOL bRefreshATList;//是否刷新@用户列表

@property(nonatomic,strong) NSString *m_endMessageID;

//在聊天详细页面，生成讨论组，开始新的聊天
-(void)startNewChat:(ChatObjectVo*)chatObjectVo;

//处理音频操作
- (void)tackleAudioAction:(ChatContentVo*)chatContentVo andImgView:(UIImageView*)imgView;
- (void)writeButtonClicked:(NSString*)strContent andImage:(UIImage*)imgTransfer;
- (void)postPasteImageOperate;
- (void)doTouchTableView;

@end