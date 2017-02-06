//
//  UserListCell.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-2-24.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "CustomerListCell.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import "UIViewExt.h"

@implementation CustomerListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.imgViewHead = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewHead.userInteractionEnabled = YES;
        [self.imgViewHead.layer setBorderWidth:0];
        [self.imgViewHead.layer setCornerRadius:20];
        _imgViewHead.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.imgViewHead.layer setMasksToBounds:YES];
        [self addSubview:_imgViewHead];
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblName.backgroundColor = [UIColor clearColor];
        self.lblName.font = [UIFont systemFontOfSize:15];
        self.lblName.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblName.textColor = COLOR(50,50,50,1);
        self.lblName.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_lblName];
        
        self.lblCode = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblCode.backgroundColor = [UIColor clearColor];
        self.lblCode.font = [UIFont systemFontOfSize:14];
        self.lblCode.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblCode.textColor = COLOR(153,153,153,1);
        self.lblCode.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.lblCode];
        
        self.imgViewPhoneIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"phone_icon"]];
        [self addSubview:self.imgViewPhoneIcon];
        
        self.lblPhoneNum = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblPhoneNum.backgroundColor = [UIColor clearColor];
        self.lblPhoneNum.font = [UIFont systemFontOfSize:13];
        self.lblPhoneNum.textColor = COLOR(153,153,153, 1);
        self.lblPhoneNum.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_lblPhoneNum];
        
        self.imgViewArrowIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cell_right_arrow"]];
        [self addSubview:self.imgViewArrowIcon];
        
        self.viewLine = [[UIView alloc]initWithFrame:CGRectZero];
        self.viewLine.backgroundColor = COLOR(224, 224, 224, 1.0);
        [self addSubview:self.viewLine];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//bSearchResultTableView:是不是搜索结果的tableView
-(void)initWithData:(CustomerVo*)customerVo;
{
    //1.header img
    self.imgViewHead.frame = CGRectMake(10,10,40,40);
    [self.imgViewHead sd_setImageWithURL:[NSURL URLWithString:customerVo.strHeadImageURL] placeholderImage:[UIImage imageNamed:@"default_m"]];
    
    //2.name
    self.lblName.text = customerVo.strName;
    self.lblName.frame = CGRectMake(60,12.5,kScreenWidth-60-110,16);

    //3.position
    self.lblCode.text = customerVo.strCode;
    self.lblCode.frame = CGRectMake(60,36,kScreenWidth-60-110,16);

    //4.phone icon and phone number
    if(customerVo.strPhone.length>0)
    {
        self.imgViewPhoneIcon.frame = CGRectMake(kScreenWidth-107.5, 15, 12, 12);
        
        self.lblPhoneNum.text = customerVo.strPhone;
        self.lblPhoneNum.frame = CGRectMake(self.imgViewPhoneIcon.right+3,13,92,16);
    }
    else
    {
        self.imgViewPhoneIcon.frame = CGRectZero;
        self.lblPhoneNum.frame = CGRectZero;
    }
    
    self.imgViewArrowIcon.frame = CGRectMake(kScreenWidth-22, 40, 13, 13);
    
    //5.line
    self.viewLine.frame = CGRectMake(60, 60.5, kScreenWidth-60, 0.5);
}

@end
