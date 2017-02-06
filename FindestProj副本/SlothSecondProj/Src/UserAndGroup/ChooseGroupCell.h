//
//  ChooseGroupCell.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-28.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupVo.h"
#import "UserVo.h"

@interface ChooseGroupCell : UITableViewCell

@property(nonatomic,strong)GroupVo *m_groupVo;

@property(nonatomic,strong)UIImageView *imgViewChkBtn;
@property(nonatomic,strong)UIImageView *imgViewBK;
@property(nonatomic,strong)UIView *viewVertical1;       //垂直线
@property(nonatomic,strong)UIView *viewVertical2;
@property(nonatomic,strong)UIImageView *imgViewGroupType;

@property(nonatomic,strong)UIView *viewNameContainer;

@property(nonatomic,strong)UILabel *lblGroupName;
@property(nonatomic,strong)UILabel *lblMemberNum;
@property(nonatomic,strong)UILabel *lblCreatorName;
@property(nonatomic,strong)UILabel *lblGroupDetail;

@property(nonatomic,strong)UIButton *btnDetail;

@property(nonatomic,strong)UIImage *imgChk;
@property(nonatomic,strong)UIImage *imgUnChk;

-(void)initWithGroupVo:(GroupVo*)groupVo;
-(void)updateCheckImage:(BOOL)bChecked;

+ (CGFloat)calculateCellHeight:(GroupVo*)groupVo;

@end
