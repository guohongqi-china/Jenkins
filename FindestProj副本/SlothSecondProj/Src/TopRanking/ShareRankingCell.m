//
//  ShareRankingCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/6/15.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "ShareRankingCell.h"
#import "UserVo.h"
#import "UIImageView+WebCache.h"

@implementation ShareRankingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.viewBK = [[UIView alloc]init];
        self.viewBK.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        self.viewBK.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
        self.contentView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        self.viewBK.layer.borderWidth = 0.5;
        self.viewBK.layer.masksToBounds = YES;
        self.viewBK.layer.cornerRadius = 5;
        [self.contentView addSubview:self.viewBK];
        
        self.lblIndex = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblIndex.backgroundColor = [UIColor clearColor];
        self.lblIndex.font = [UIFont fontWithName:@"HeitiSC-Light" size:20];
        self.lblIndex.textAlignment = NSTextAlignmentCenter;
        [self.viewBK addSubview:self.lblIndex];
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblTitle.backgroundColor = [UIColor clearColor];
        self.lblTitle.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
        self.lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
        [self.viewBK addSubview:self.lblTitle];
        
        self.commonHeaderView = [[CommonHeaderView alloc]init];
        [self.viewBK addSubview:self.commonHeaderView];
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblName.backgroundColor = [UIColor clearColor];
        self.lblName.font = [UIFont fontWithName:@"PingFangSC-Medium" size:13];
        self.lblName.lineBreakMode = NSLineBreakByTruncatingTail;
        self.lblName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
        [self.viewBK addSubview:self.lblName];
        
        self.imgViewShare = [[UIImageView alloc]init];
        self.imgViewShare.contentMode = UIViewContentModeScaleAspectFill;
        self.imgViewShare.clipsToBounds = YES;
        self.imgViewShare.layer.masksToBounds = YES;
        self.imgViewShare.layer.cornerRadius = 5;
        [self.viewBK addSubview:self.imgViewShare];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)initWithData:(BlogVo*)blogVo
{
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.viewBK.frame = CGRectMake(12, 10, kScreenWidth-24, 80);
    
    //index
    self.lblIndex.text = [NSString stringWithFormat:@"%li",(long)blogVo.nIndex];
    self.lblIndex.frame = CGRectMake(0, 0, 46, 80);
    if (blogVo.nIndex <= 3)
    {
        self.lblIndex.textColor = [SkinManage colorNamed:@"Tab_Item_Color_H"];;
    }
    else
    {
        self.lblIndex.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    }
    
    //title
    self.lblTitle.text = blogVo.strTitle;
    
    //hot value
    self.imgViewShare.frame = CGRectMake(self.viewBK.width-60-10, 10, 60, 60);
    if (blogVo.aryPictureUrl.count > 0)
    {
        self.lblTitle.frame = CGRectMake(46,10,self.viewBK.width-46-79,20);
        
        self.imgViewShare.hidden = NO;
        [self.imgViewShare sd_setImageWithURL:[NSURL URLWithString:blogVo.aryPictureUrl[0]] placeholderImage:[UIImage imageNamed:@"default_image"]];
    }
    else
    {
        self.lblTitle.frame = CGRectMake(46,10,self.viewBK.width -46-10,20);
        
        self.imgViewShare.hidden = YES;
    }
    
    //header img
    [self.commonHeaderView refreshViewWithImage:blogVo.vestImg userID:nil];
    self.commonHeaderView.frame = CGRectMake(46,self.lblTitle.bottom+10,30,30);
    
    //label name
    self.lblName.text = blogVo.strCreateByName;
    self.lblName.frame = CGRectMake(self.commonHeaderView.right+10,self.commonHeaderView.top+6,self.lblTitle.width,18);
}

@end
