//
//  GroupListCell.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-26.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupVo.h"
#import "UserVo.h"

@class GroupListViewController;

@interface GroupListCell : UITableViewCell

@property(nonatomic,strong)UIImageView *imgViewBK;
@property(nonatomic,strong)UIImageView *imgViewGroupType;

@property(nonatomic,strong)UIView *viewNameContainer;

@property(nonatomic,strong)UILabel *lblGroupName;
@property(nonatomic,strong)UILabel *lblAllowJoin;
@property(nonatomic,strong)UILabel *lblMemberNum;
@property(nonatomic,strong)UILabel *lblCreatorName;

@property(nonatomic,strong)UIButton *btnDetail;

@property(nonatomic,strong)GroupVo *m_groupVo;
@property(nonatomic,weak)GroupListViewController *parentView;

-(void)initWithGroupVo:(GroupVo*)groupVo;

+ (CGFloat)calculateCellHeight:(GroupVo*)groupVo;

@end
