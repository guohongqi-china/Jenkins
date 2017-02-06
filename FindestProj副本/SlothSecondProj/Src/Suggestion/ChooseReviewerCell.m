//
//  ChooseReviewerCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 4/27/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "ChooseReviewerCell.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import "UIViewExt.h"
@implementation ChooseReviewerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        viewSelected = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView = viewSelected;
        viewSelected.backgroundColor = [SkinManage colorNamed:@"Table_Selected_Color"];
        self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        // Initialization code
        self.imgViewHead = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewHead.userInteractionEnabled = YES;
        [self.imgViewHead.layer setBorderWidth:0];
        [self.imgViewHead.layer setCornerRadius:20];
        _imgViewHead.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.imgViewHead.layer setMasksToBounds:YES];
        [self addSubview:_imgViewHead];
        
        self.lblRealName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblRealName.backgroundColor = [UIColor clearColor];
        self.lblRealName.font = [UIFont systemFontOfSize:16];
        self.lblRealName.textColor = [SkinManage colorNamed:@"metting_Tite_color"];
        [self addSubview:self.lblRealName];
        
        self.lblAliasName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblAliasName.backgroundColor = [UIColor clearColor];
        self.lblAliasName.font = [UIFont systemFontOfSize:14];
        self.lblAliasName.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];
        [self addSubview:self.lblAliasName];
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

-(void)initWithUserVo:(UserVo*)userVo
{
    //head image
    self.imgViewHead.frame = CGRectMake(15,10,40,40);
    [self.imgViewHead sd_setImageWithURL:[NSURL URLWithString:userVo.strHeadImageURL] placeholderImage:[UIImage imageNamed:@"default_m"]];
    
    //true name
    self.lblRealName.text = userVo.strRealName;
    self.lblRealName.frame = CGRectMake(65, 12.5, kScreenWidth-75, 20);
    
    //alias name
    if(userVo.strUserName.length>0)
    {
        self.lblAliasName.text = [NSString stringWithFormat:@"%@（别名）",userVo.strUserName];
    }
    self.lblAliasName.frame = CGRectMake(65, 35, kScreenWidth-75, 20);
}


@end
