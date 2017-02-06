//
//  ChatContentViewController.h
//  Sloth
//
//  Created by 焱 孙 on 13-6-18.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "QNavigationViewController.h"
#import "UserVo.h"
#import "ChatContentVo.h"
#import "ChatContentCell.h"
#import "PullingRefreshTableView.h"
#import "FaceToolBar.h"
#import "ChatObjectVo.h"
#import "SendChatVo.h"
#import "GroupAndUserDao.h"

@interface ChatContentViewController : QNavigationViewController<AVAudioPlayerDelegate,UITableViewDelegate,UITableViewDataSource,FaceToolBarDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) NSMutableArray *aryChatCon;
@property (nonatomic, retain) NSMutableArray *aryHeaderImage;   //头像数组
@property (nonatomic, retain) UITableView *tableViewChat;
@property (nonatomic, strong) UIRefreshControl* refreshControl;

@property (nonatomic, retain) FaceToolBar *faceToolBar;
@property (nonatomic, retain) SendChatVo *m_sendChatVo;
@property (nonatomic, retain) ChatObjectVo *m_chatObjectVo;         //列表传递过来的参数

@property(nonatomic,retain) UIImagePickerController *photoController;
@property(nonatomic,retain) UIImagePickerController *photoAlbumController;
    
@property(nonatomic,retain)UIImage *imgHeadSelf;            //自己的头像
@property(nonatomic,retain)UIImage *imgHeadOther;           //对方的头像

//分页查寻数据
@property (nonatomic) long long nQueryDateTime;
@property (nonatomic) int nChatPageNum;

@property (nonatomic) BOOL bReturnRefresh;//返回是否刷新

@property (nonatomic) BOOL bFirstLoad;//is or not first load

@property (nonatomic) BOOL bRunningUpdate;

//音频处理
@property (nonatomic) BOOL bAudioPlaying;   //是否正在播放音频
@property (nonatomic, weak) ChatContentVo *chatContentVoAudio;
@property(nonatomic,strong) NSMutableArray *aryReceiverAudioIcon;//用于播放时动态显示
@property(nonatomic,strong) NSMutableArray *arySenderAudioIcon;//用于播放时动态显示
@property(nonatomic,strong) AVAudioPlayer *audioPlayer;

//处理音频操作
- (void)tackleAudioAction:(ChatContentVo*)chatContentVo andImgView:(UIImageView*)imgView;
- (void)writeButtonClicked:(NSString*)strContent andImage:(UIImage*)imgTransfer;
- (void)postPasteImageOperate;
- (void)doTouchTableView;

@end

