//
//  LeftMenuCell.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-14.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftMenuVo.h"

@interface LeftMenuCell : UITableViewCell

@property(nonatomic,strong)UIImageView *imgViewBK;
@property(nonatomic,strong)UIImageView *imgViewIcon;
@property(nonatomic,strong)UIView *viewSepLine;
@property(nonatomic,strong)UILabel *lblName;

//notice num
@property(nonatomic,strong)UIImageView *imgViewNoticeNum;
@property(nonatomic,strong)UILabel *lblNoticeNum;

-(void)initWithLeftMenuVo:(LeftMenuVo*)leftMenuVo;

@end
