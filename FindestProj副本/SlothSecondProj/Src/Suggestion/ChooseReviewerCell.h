//
//  ChooseReviewerCell.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 4/27/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserVo.h"

@interface ChooseReviewerCell : UITableViewCell

{
    UIView *viewSelected;
}


@property(nonatomic,strong)UIImageView *imgViewHead;
@property(nonatomic,strong)UILabel *lblRealName;
@property(nonatomic,strong)UILabel *lblAliasName;//别名

-(void)initWithUserVo:(UserVo*)userVo;

@end
