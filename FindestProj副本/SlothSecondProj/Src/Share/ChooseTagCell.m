//
//  ChooseTagCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 12/24/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "ChooseTagCell.h"

@implementation ChooseTagCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.imgChk = [UIImage imageNamed:@"select_user_group"];
        self.imgUnChk = [UIImage imageNamed:@"unselect_user_group"];
        
        self.imgViewChkBtn = [[UIImageView alloc]initWithFrame:CGRectZero];
        self.imgViewChkBtn.image = self.imgUnChk;
        [self addSubview:self.imgViewChkBtn];
      
        self.lblTagName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblTagName.backgroundColor = [UIColor clearColor];
        self.lblTagName.font = [UIFont systemFontOfSize:16];
        self.lblTagName.lineBreakMode = NSLineBreakByCharWrapping;
        self.lblTagName.textColor = COLOR(19,19,19,1);
        [self addSubview:self.lblTagName];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initWithTagVo:(TagVo*)tagVo
{
    //0.chk btn
    self.imgViewChkBtn.frame = CGRectMake(15,(40-10)/2,10,10);
    if (tagVo.bChecked)
    {
        self.imgViewChkBtn.image = self.imgChk;
    }
    else
    {
        self.imgViewChkBtn.image = self.imgUnChk;
    }
    
    //1.label name
    self.lblTagName.text = tagVo.strTagName;
    CGSize size = [Common getStringSize:self.lblTagName.text font:self.lblTagName.font bound:CGSizeMake(kScreenWidth-40-10, MAXFLOAT) lineBreakMode:self.lblTagName.lineBreakMode];
    if (size.height<20)
    {
        size.height = 20;
    }
    self.lblTagName.frame = CGRectMake(40,10,kScreenWidth-40-10,size.height);
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

+(CGFloat)calculateCellHeight:(TagVo*)tagVo
{
    CGFloat fHeight = 10.0;
    CGSize size = [Common getStringSize:tagVo.strTagName font:[UIFont systemFontOfSize:16] bound:CGSizeMake(kScreenWidth-40-10, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    if (size.height<20)
    {
        size.height = 20;
    }
    fHeight += size.height+10;
    return fHeight;
}

@end
