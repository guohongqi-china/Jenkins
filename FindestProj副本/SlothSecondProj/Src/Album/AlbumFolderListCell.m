//
//  AlbumFolderListCell.m
//  ChinaMobileSocialProj
//
//  Created by Yuson Xing on 14-3-11.
//
//

#import "AlbumFolderListCell.h"
#import "AlbumFolderListViewController.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@implementation AlbumFolderListCell

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
        
        self.viewBorder = [[UIView alloc]init];
        self.viewBorder.backgroundColor = [UIColor clearColor];
        [self.viewBorder.layer setBorderWidth:1.0];
        [self.viewBorder.layer setCornerRadius:11];
        [self.viewBorder.layer setMasksToBounds:YES];
        self.viewBorder.layer.borderColor = [COLOR(221, 221, 221, 1.0) CGColor];
        [self addSubview:self.viewBorder];
        
        self.imgViewAlbum = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imgViewAlbum.image = [UIImage imageNamed:@"default_album_bk"];
        self.imgViewAlbum.userInteractionEnabled = YES;
        [self.imgViewAlbum.layer setBorderWidth:1.0];
        [self.imgViewAlbum.layer setCornerRadius:5];
        [self.imgViewAlbum.layer setMasksToBounds:YES];
        self.imgViewAlbum.layer.borderColor = [COLOR(221, 221, 221, 1.0) CGColor];//[[UIColor clearColor] CGColor];//
        self.imgViewAlbum.backgroundColor = [UIColor whiteColor];
        self.imgViewAlbum.clipsToBounds = YES;
        self.imgViewAlbum.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imgViewAlbum];
        
        self.folderNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 60, 50)];
        self.folderNameLabel.backgroundColor = [UIColor clearColor];
        self.folderNameLabel.font = [UIFont boldSystemFontOfSize:16];
        self.folderNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.folderNameLabel.textColor = COLOR(47,62,70,1);
        self.folderNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.folderNameLabel];
        
        self.btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnDel setImage:[UIImage imageNamed:@"btn_photo_album_del"] forState:UIControlStateNormal];
        [self.btnDel addTarget:self action:@selector(deleteAlbum) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnDel];
    }
    return self;
}

- (void) initWithAlbumInfo:(AlbumInfoVO *)albumInfo
{
    self.m_albumInfo = albumInfo;
    
    //self.viewBorder.frame = CGRectMake(5, 5, 150, 150);
    
    //相册图片
    self.imgViewAlbum.frame = CGRectMake(30, 10, 100, 100);
    UIImage *imgDefault =[UIImage imageNamed:@"default_album_bk"];
    [self.imgViewAlbum sd_setImageWithURL:[NSURL URLWithString:albumInfo.strAlbumImage] placeholderImage:imgDefault];
    
    self.backgroundColor = [UIColor whiteColor];
    self.folderNameLabel.text = albumInfo.albumFolderName;
    self.folderNameLabel.frame = CGRectMake(10, 120, 125, 20);
    
    if (self.parentViewController.nAlbumType == ALBUM_MINE_TYPE && !self.m_albumInfo.bIsDefault)
    {
        self.btnDel.frame = CGRectMake(103, -13, 50, 50);
    }
    else
    {
        self.btnDel.frame = CGRectZero;
    }
}

- (void)deleteAlbum
{
    NSString *strTipTitle = @"你确定要删除该相册？";
    if(self.m_albumInfo.albumImageList != nil && self.m_albumInfo.albumImageList.count>0)
    {
        strTipTitle = [NSString stringWithFormat:@"你确定要删除该相册,该相册包含了 %lu 张相片？",(unsigned long)self.m_albumInfo.albumImageList.count];
    }
    
    if ([Common ask:strTipTitle])
    {
        [self.parentViewController isHideActivity:NO];
        [ServerProvider removeAlbumFolder:self.m_albumInfo.albumFolderID result:^(ServerReturnInfo *retInfo) {
            [self.parentViewController isHideActivity:YES];
            if (retInfo.bSuccess)
            {
                [self.parentViewController.folderArray removeObject:self.m_albumInfo];
                [self.parentViewController.collectionViewAlbumList reloadData];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
}

@end
