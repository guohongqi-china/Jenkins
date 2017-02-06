//
//  ChooseUserOldCell.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-28.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserVo.h"

@protocol ChooseUserOldCellDelegate <NSObject>
@optional
-(UserVo*)isUserVoChecked:(UserVo*)userVo;
@end

@interface ChooseUserOldCell : UITableViewCell

@property(nonatomic,weak)id<ChooseUserOldCellDelegate> delegate;

@property(nonatomic,strong)UIImageView *imgViewChkBtn;
@property(nonatomic,strong)UIImageView *imgViewHead;
@property(nonatomic,strong)UILabel *lblName;
@property(nonatomic,strong)UILabel *lblPosition;        //职位
@property(nonatomic,strong)UILabel *lblPhoneNum;

@property(nonatomic,strong)UIImage *imgChk;
@property(nonatomic,strong)UIImage *imgUnChk;
@property(nonatomic,strong)UIImage *imgCanNotChk;       //不能选择图片

-(void)initWithUserVo:(UserVo*)userVo;
-(void)updateCheckImage:(BOOL)bChecked;

@end
