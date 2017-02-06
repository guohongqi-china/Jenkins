//
//  ChooseUserCell.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-28.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "ChooseUserCell.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import "ChooseUserAndGroupViewController.h"

@implementation ChooseUserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.imgChk = [UIImage imageNamed:@"select_user_group"];
        self.imgUnChk = [UIImage imageNamed:@"unselect_user_group"];
        self.imgCanNotChk = [UIImage imageNamed:@"select_user_group_unedit"];
        
        self.imgViewChkBtn = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.imgViewChkBtn.image = self.imgUnChk;
        [self addSubview:self.imgViewChkBtn];
        
        self.imgViewHead = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewHead.userInteractionEnabled = YES;
        [self.imgViewHead.layer setBorderWidth:1.0];
        [self.imgViewHead.layer setCornerRadius:3];
        _imgViewHead.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.imgViewHead.layer setMasksToBounds:YES];
        [self addSubview:_imgViewHead];
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblName.backgroundColor = [UIColor clearColor];
        self.lblName.font = [UIFont systemFontOfSize:17];
        self.lblName.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblName.textColor = COLOR(19,19,19,1);
        [self addSubview:_lblName];
        
        self.lblPosition = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblPosition.backgroundColor = [UIColor clearColor];
        self.lblPosition.font = [UIFont systemFontOfSize:14];
        self.lblPosition.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblPosition.textColor = COLOR(102,102,102,1);
        [self addSubview:_lblPosition];
        
        self.lblPhoneNum = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblPhoneNum.backgroundColor = [UIColor clearColor];
        self.lblPhoneNum.font = [UIFont systemFontOfSize:14];
        self.lblPhoneNum.textColor = COLOR(102, 102, 102, 1);
        [self addSubview:_lblPhoneNum];
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
    //0.chk btn
    self.imgViewChkBtn.frame = CGRectMake(15,(60-10)/2,10,10);
    if (userVo.bCanNotCheck)
    {
        self.imgViewChkBtn.image = self.imgCanNotChk;
    }
    else
    {
        if (userVo.bChecked)
        {
            self.imgViewChkBtn.image = self.imgChk;
        }
        else
        {
            self.imgViewChkBtn.image = self.imgUnChk;
        }
    }
    
    //1.header img
    self.imgViewHead.frame = CGRectMake(40,14,32,32);
    UIImage *phImage = [[UIImage imageNamed:@"default_m"] roundedWithSize:CGSizeMake(32,32)];
    __weak typeof(self) weakSelf = self;
    [self.imgViewHead setImageWithURL:[NSURL URLWithString:userVo.strHeadImageURL] placeholderImage:phImage options:0 success:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(),^{
            weakSelf.imgViewHead.image = [image roundedWithSize:CGSizeMake(32,32)];
        });}failure:^(NSError *error) {}];
    
    //2.label name
    self.lblName.frame = CGRectMake(40+34+5,12.5,180,18);
    self.lblName.text = userVo.strUserName;
    
    //3.positio
    self.lblPosition.frame = CGRectMake(40+34+5,20+12.5,180,15);
    self.lblPosition.text = userVo.strPosition;
    
//    //4.strPhoneNumber
//    self.lblPhoneNum.frame = CGRectMake(10+34+5,20+12.5,300-(10+34+5),15);
//    self.lblPhoneNum.font = [UIFont systemFontOfSize:14];
//    self.lblPhoneNum.text = userVo.strPhoneNumber;
}

-(void)updateCheckImage:(BOOL)bChecked
{
    if (bChecked)
    {
        self.imgViewChkBtn.image = self.imgChk;
    }
    else
    {
        self.imgViewChkBtn.image = self.imgUnChk;
    }
}

@end
