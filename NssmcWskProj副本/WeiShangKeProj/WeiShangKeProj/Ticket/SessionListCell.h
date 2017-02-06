//
//  SessionListCell.h
//  WeiShangKeProj
//
//  Created by 焱 孙 on 5/17/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceLabel.h"

@class SessionListViewController;
@interface SessionListCell : UITableViewCell

@property(nonatomic,retain)UIImageView *imgViewHead;
@property(nonatomic,retain)UILabel *lblName;
@property(nonatomic,retain)FaceLabel *lblChatMsg;
@property(nonatomic,retain)UILabel *lblDateTime;

@property(nonatomic,retain)UIImageView *imgViewUnseeNum;
@property(nonatomic,retain)UILabel *lblUnseeNum;

@property(nonatomic,retain)ChatObjectVo *m_chatObjectVo;

@property(nonatomic,retain)UIView *viewLine;

-(void)initWithChatObjectVo:(ChatObjectVo*)chatObjectVo;
+(CGFloat)calculateCellHeight;

@end
