//
//  UserListCell.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-24.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerVo.h"

@interface CustomerListCell : UITableViewCell

@property(nonatomic,strong)UIImageView *imgViewHead;
@property(nonatomic,strong)UILabel *lblName;
@property(nonatomic,strong)UILabel *lblCode;
@property(nonatomic,strong)UILabel *lblPhoneNum;
@property(nonatomic,strong)UIImageView *imgViewPhoneIcon;
@property(nonatomic,strong)UIImageView *imgViewArrowIcon;
@property(nonatomic,strong)UIView *viewLine;

-(void)initWithData:(CustomerVo*)customerVo;

@end
