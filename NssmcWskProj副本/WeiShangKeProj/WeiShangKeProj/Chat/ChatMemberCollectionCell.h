//
//  ChatMemberCollectionCell.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-5-20.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserVo.h"

@class ChatInfoViewController;
@interface ChatMemberCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIButton *btnMinus;
@property (nonatomic, strong) UIButton *btnMember;
@property (nonatomic, strong) UILabel *lblName;

@property (nonatomic, strong) UserVo *m_userVo;
@property (nonatomic, weak) ChatInfoViewController *parentViewController;

@property(nonatomic) BOOL bShowDeleteBtn;

- (void)initUserVo:(UserVo *)userVo;

@end
