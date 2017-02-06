//
//  UserListCell.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-24.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "UserListCell.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
//#import "UserCenterViewController.h"
#import "PublishMessageViewController.h"
#import "ChatContentViewController.h"
#import "EditIntegralView.h"
//#import "UserListViewController.h"
#import "UIViewExt.h"

@implementation UserListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.customHeaderView = [[CustomHeaderView alloc]initWithRate:HEADER_RATE_BIG andSuffix:@""];
        [self.contentView addSubview:self.customHeaderView];
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblName.backgroundColor = [UIColor clearColor];
        self.lblName.font = [UIFont systemFontOfSize:16];
        self.lblName.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblName.textColor = COLOR(19,19,19,1);
        [self.contentView addSubview:_lblName];
        
        self.lblPosition = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblPosition.backgroundColor = [UIColor clearColor];
        self.lblPosition.font = [UIFont systemFontOfSize:14];
        self.lblPosition.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblPosition.textColor = COLOR(153,153,153,1);
        [self.contentView addSubview:_lblPosition];
        
        self.lblPhoneNum = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblPhoneNum.backgroundColor = [UIColor clearColor];
        self.lblPhoneNum.font = [UIFont systemFontOfSize:14];
        self.lblPhoneNum.textColor = COLOR(153,153,153, 1);
        [self.contentView addSubview:_lblPhoneNum];
        
        self.btnIntegration = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnIntegration setTitleColor:COLOR(146, 146, 146, 1.0) forState:UIControlStateNormal];
        [self.btnIntegration.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
        [self.btnIntegration setBackgroundImage:[Common getImageWithColor:COLOR(247, 247, 247, 1.0)] forState:UIControlStateNormal];
        [self.btnIntegration setTitle:@"积分编辑" forState:UIControlStateNormal];
        [self.btnIntegration addTarget:self action:@selector(editIntegration) forControlEvents:UIControlEventTouchUpInside];
        [self.btnIntegration.layer setBorderWidth:0.5];
        [self.btnIntegration.layer setCornerRadius:3];
        self.btnIntegration.layer.borderColor = COLOR(204, 204, 204, 1.0).CGColor;
        [self.btnIntegration.layer setMasksToBounds:YES];
        [self.contentView addSubview:self.btnIntegration];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//bSearchResultTableView:是不是搜索结果的tableView
-(void)initWithUserVo:(UserVo*)userVo
{
    CGFloat fWidth = 0.0;
    self.m_userVo = userVo;
    
    //1.header img
    [self.customHeaderView refreshView:userVo andFrame:CGRectMake(15,10,40,40)];
    
    //2.label name
    self.lblName.text = userVo.strUserName;
    CGSize sizeNameWidth = [Common getStringSize:self.lblName.text font:self.lblName.font bound:CGSizeMake(MAXFLOAT,280) lineBreakMode:NSLineBreakByCharWrapping];
    self.lblName.frame = CGRectMake(15+40+5,12.5,sizeNameWidth.width,(17));
    fWidth += sizeNameWidth.width+10;

    //3.position
    self.lblPosition.text = userVo.strPosition;
    CGSize sizePosition = [Common getStringSize:self.lblPosition.text font:self.lblPosition.font bound:CGSizeMake(MAXFLOAT, 280) lineBreakMode:NSLineBreakByCharWrapping];
    self.lblPosition.frame = CGRectMake(15+40+5+fWidth,12.5,sizePosition.width,(15));

    //4.strPhoneNumber
    self.lblPhoneNum.frame = CGRectMake(15+40+5,20+12.5,300-(10+34+5),15);
    if (self.m_userVo.bViewPhone)
    {
        self.lblPhoneNum.text = self.m_userVo.strPhoneNumber;
    }
    else
    {
        self.lblPhoneNum.text = @"未公开";
    }
    
    //5.integral edit
    if ([Common getCurrentUserVo].nBadge == 1)
    {
//        //版主并且当前view为用户列表
//        if ([self.parentViewController isKindOfClass:[UserListViewController class]])
//        {
//            self.btnIntegration.frame = CGRectMake(kScreenWidth-75-15, 15, 75, 32);
//            self.btnIntegration.hidden = NO;
//        }
    }
    else
    {
        self.btnIntegration.frame = CGRectZero;
        self.btnIntegration.hidden = YES;
    }
}

-(void)editIntegration
{
//    if ([self.parentViewController isKindOfClass:[UserListViewController class]])
//    {
//        EditIntegralView *editIntegralView = [[EditIntegralView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
//        editIntegralView.userVo = self.m_userVo;
//        editIntegralView.delegate = (UserListViewController*)self.parentViewController;
//        [self.parentViewController.view.window addSubview:editIntegralView];
//    }
}

@end
