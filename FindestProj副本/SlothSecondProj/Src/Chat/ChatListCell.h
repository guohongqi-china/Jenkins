//
//  ChatListCell.h
//  Sloth
//
//  Created by 焱 孙 on 13-6-18.
//
//

#import <UIKit/UIKit.h>
#import "UserVo.h"
#import "ChatObjectVo.h"
#import "FaceLabel.h"

@class ChatListViewController;

@interface ChatListCell : UITableViewCell

@property(nonatomic,retain)UIImageView *imgViewHead;
@property(nonatomic,retain)UILabel *lblName;
@property(nonatomic,retain)FaceLabel *lblChatMsg;
@property(nonatomic,retain)UILabel *lblDateTime;
@property(nonatomic,retain)UIView *viewSeperate;
@property(nonatomic,retain)ChatObjectVo *m_chatObjectVo;
@property(nonatomic,assign)ChatListViewController *parentView;

@property(nonatomic,retain)UIImageView *imgViewUnseeNum;
@property(nonatomic,retain)UILabel *lblUnseeNum;
@property(nonatomic,retain)UIImageView *imgViewReject;  //退出讨论组状态

-(void)initWithChatObjectVo:(ChatObjectVo*)chatObjectVo;
+(CGFloat)calculateCellHeight;

@end
