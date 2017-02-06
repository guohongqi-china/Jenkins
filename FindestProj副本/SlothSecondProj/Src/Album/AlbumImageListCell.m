//
//  AlbumImageListCell.m
//  ChinaMobileSocialProj
//
//  Created by 焱 孙 on 14-3-15.
//
//

#import "AlbumImageListCell.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"

@implementation AlbumImageListCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        //改变选中背景色
        UIView *viewSelected = [[UIView alloc] initWithFrame:self.frame];
        viewSelected.backgroundColor = TABLEVIEW_SELECTED_COLOR;
        self.selectedBackgroundView = viewSelected;
        
        self.imgViewPhoto = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewPhoto.userInteractionEnabled = YES;
        [self.imgViewPhoto.layer setBorderWidth:1.0];
        self.imgViewPhoto.layer.borderColor = [COLOR(221, 221, 221, 1.0) CGColor];
        self.imgViewPhoto.backgroundColor = [UIColor whiteColor];
        self.imgViewPhoto.clipsToBounds = YES;
        self.imgViewPhoto.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imgViewPhoto];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)initWithAlbumImageInfoVO:(AlbumImageInfoVO*)albumImageInfoVO
{
    self.imgViewPhoto.frame = CGRectMake(4,4,69,69);
    UIImage *imgDefault =[UIImage imageNamed:@"default_image"];
    [self.imgViewPhoto sd_setImageWithURL:[NSURL URLWithString:albumImageInfoVO.imageMinUrl] placeholderImage:imgDefault];
}

@end
