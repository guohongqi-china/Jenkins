//
//  SessionDetailCell.h
//  WeiShangKeProj
//
//  Created by 焱 孙 on 5/18/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatContentVo.h"
#import "FaceLabel.h"
#import "InsetsLabel.h"

@class SessionDetailViewController;
@interface SessionDetailCell : UITableViewCell

@property (nonatomic, strong) UIImageView *imgViewChatBK;
@property (nonatomic, strong) UIImageView *imgViewDateTime;
@property (nonatomic, strong) UIImageView *imgViewChat;

//附件内容
@property (nonatomic, strong) UIImageView *imgViewAttachmentIcon;   //附件ICON
@property (nonatomic, strong) UILabel *lblAttachmentName;           //附件名称

@property (nonatomic, strong) UIButton *btnConCover;    //覆盖内容

@property (nonatomic, strong) FaceLabel *txtViewContent;
@property (nonatomic, strong) UILabel *txtLinkContent;
@property (nonatomic, strong) UILabel *lblDate;
@property (nonatomic, strong) UILabel *lblTime;

@property (nonatomic, weak) SessionDetailViewController *topNavController;

@property (nonatomic, strong) ChatContentVo *m_chatContentVo;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@property(nonatomic,strong)UIImage *imgTransfer;
@property(nonatomic,strong)NSString *strLastChatTime;

//通知信息（有人加入和退出群聊）
@property (nonatomic, strong) InsetsLabel *lblChatNotification;
//@property (nonatomic, strong) UILabel *lblChatNotification;

//语音相关
@property (nonatomic, strong) UILabel *lblAudioDuration;
@property (nonatomic, strong) UIImageView *imgViewAudioIcon;

- (void)initWithChatContent:(ChatContentVo *)chatContentVo;
+ (CGFloat)calculateCellHeight:(ChatContentVo *)chatContentVo andLastChatTime:(NSString*)strLastTime;

@end
