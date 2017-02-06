//
//  ReplyUserCell.m
//  FindestMeetingProj
//
//  Created by 焱 孙 on 12/30/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "ReplyUserCell.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"

@implementation ReplyUserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.imgViewHead = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewHead.userInteractionEnabled = YES;
        [self.imgViewHead.layer setBorderWidth:1.0];
        [self.imgViewHead.layer setCornerRadius:3];
        _imgViewHead.layer.borderColor = [[UIColor clearColor] CGColor];
        [self.imgViewHead.layer setMasksToBounds:YES];
        [self addSubview:_imgViewHead];
        
        self.lblName = [[UILabel alloc] initWithFrame:CGRectZero];
        self.lblName.backgroundColor = [UIColor clearColor];
        self.lblName.font = [UIFont boldSystemFontOfSize:17];
        self.lblName.lineBreakMode = NSLineBreakByWordWrapping;
        self.lblName.textColor = COLOR(0,0,0,1);
        [self addSubview:_lblName];
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
    //1.header img
    self.imgViewHead.frame = CGRectMake(15,9.5,36,36);
    [self.imgViewHead setImageWithURL:[NSURL URLWithString:userVo.strHeadImageURL] placeholderImage:[UIImage imageNamed:@"default_m"] options:0 success:nil failure:nil];
    
    //2.label name
    self.lblName.frame = CGRectMake(15+36+10,0,kScreenWidth-71,55);
    self.lblName.text = userVo.strUserName;
}

+ (CGFloat)calculateCellHeight:(UserVo*)userVo
{
    return 55;
}

@end
