//
//  ChooseUserCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/27.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserVo.h"

@protocol ChooseUserCellDelegate <NSObject>
@optional
-(UserVo*)isUserVoChecked:(UserVo*)userVo;
@end

@interface ChooseUserCell : UITableViewCell

@property(nonatomic,weak)id<ChooseUserCellDelegate> delegate;

@property (nonatomic, strong) UserVo *entity;

@property(nonatomic,strong)UIImage *imgChk;
@property(nonatomic,strong)UIImage *imgUnChk;
@property(nonatomic,strong)UIImage *imgCanNotChk;       //不能选择图片

-(void)updateCheckImage:(BOOL)bChecked;

@end
