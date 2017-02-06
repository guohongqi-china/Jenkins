//
//  ChatContentCell.h
//  Sloth
//
//  Created by 焱 孙 on 13-6-19.
//
//

#import <UIKit/UIKit.h>
#import "ChatContentVo.h"
#import "FaceLabel.h"
#import "InsetsLabel.h"

@class ChatContentViewController;

@interface ChatContentCell : UITableViewCell
  
@property (nonatomic, strong) UIImageView *imgViewHead;
@property (nonatomic, strong) UIImageView *imgViewChatBK;
@property (nonatomic, strong) UIImageView *imgViewDateTime;
@property (nonatomic, strong) UIImageView *imgViewChat;

//附件内容
@property (nonatomic, strong) UIImageView *imgViewAttachmentIcon;   //附件ICON
@property (nonatomic, strong) UILabel *lblAttachmentName;           //附件名称

@property (nonatomic, strong) UIButton *btnConCover;    //覆盖内容

@property (nonatomic, strong) UILabel *lblName;

@property (nonatomic, strong) FaceLabel *txtViewContent;
@property (nonatomic, strong) UILabel *lblDateTime;

@property (nonatomic, weak) ChatContentViewController *topNavController;

@property (nonatomic, strong) ChatContentVo *m_chatContentVo;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@property(nonatomic,strong)UIImage *imgHeadSelf;            //自己的头像
@property(nonatomic,strong)UIImage *imgHeadOther;           //对方的头像
@property(nonatomic,strong)UIImage *imgTransfer;
@property(nonatomic,strong)NSString *strLastChatTime;

//语音相关
@property (nonatomic, strong) UILabel *lblAudioDuration;
@property (nonatomic, strong) UIImageView *imgViewAudioIcon;

//通知信息（有人加入和退出群聊）
@property (nonatomic, strong) InsetsLabel *lblChatNotification;

- (void)initWithChatContent:(ChatContentVo *)chatContentVo;
+ (CGFloat)calculateCellHeight:(ChatContentVo *)chatContentVo andLastChatTime:(NSString*)strLastTime;

@end
