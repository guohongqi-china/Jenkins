//
//  ChooseUserCell.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/27.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ChooseUserCell.h"
#import "UIImageView+WebCache.h"

@interface ChooseUserCell ()
{
    UIView *viewSelected;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgViewCheck;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@end

@implementation ChooseUserCell

- (void)awakeFromNib {
    // Initialization code
    
    
    self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.lblName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    
    viewSelected = [[UIView alloc] initWithFrame:self.frame];
    viewSelected.backgroundColor =[SkinManage colorNamed:@"Table_Selected_Color"];
    self.selectedBackgroundView = viewSelected;
    
    
    
    self.imgChk = [UIImage imageNamed:@"list_selected"];
    self.imgUnChk = [SkinManage imageNamed:@"list_unselected"];
    self.imgCanNotChk = [UIImage imageNamed:@"list_select_unedit"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEntity:(UserVo *)entity
{
    if (self.delegate != nil)
    {
        //在线搜索，未关注的用户是否已经处于bCanNotCheck
        UserVo *userVoResult = [self.delegate isUserVoChecked:entity];
        if (userVoResult != nil)
        {
            if (userVoResult.bCanNotCheck)
            {
                entity.bChecked = YES;
                entity.bCanNotCheck = YES;
                _imgViewCheck.image = self.imgCanNotChk;
            }
            else
            {
                entity.bChecked = YES;
                _imgViewCheck.image = self.imgChk;
            }
        }
        else
        {
            entity.bChecked = NO;
            _imgViewCheck.image = self.imgUnChk;
        }
    }
    else
    {
        if (entity.bCanNotCheck)
        {
            _imgViewCheck.image = self.imgCanNotChk;
        }
        else if (entity.bChecked)
        {
            _imgViewCheck.image = self.imgChk;
        }
        else
        {
            _imgViewCheck.image = self.imgUnChk;
        }
    }
    
    [self.imgViewHeader sd_setImageWithURL:[NSURL URLWithString:entity.strHeadImageURL] placeholderImage:[UIImage imageNamed:@"default_m"]];
    
    self.lblName.text = entity.strUserName;
}

-(void)updateCheckImage:(BOOL)bChecked
{
    if (bChecked)
    {
        _imgViewCheck.image = self.imgChk;
    }
    else
    {
        _imgViewCheck.image = self.imgUnChk;
    }
}

@end
