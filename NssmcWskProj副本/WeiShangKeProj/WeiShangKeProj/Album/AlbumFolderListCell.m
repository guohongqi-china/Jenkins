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
#import "CreateAlbumViewController.h"

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
        
        self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressChat:)];
        [self addGestureRecognizer:self.longPress];
    }
    return self;
}

- (void) initWithAlbumInfo:(AlbumInfoVO *)albumInfo
{
    self.m_albumInfo = albumInfo;
    
    //相册图片
    self.imgViewAlbum.frame = CGRectMake(30, 10, 100, 100);
    UIImage *imgDefault =[UIImage imageNamed:@"default_album_bk"];
    [self.imgViewAlbum setImageWithURL:[NSURL URLWithString:albumInfo.strAlbumImage] placeholderImage:imgDefault];
    
    self.backgroundColor = [UIColor whiteColor];
    self.folderNameLabel.text = albumInfo.albumFolderName;
    self.folderNameLabel.frame = CGRectMake(10, 120, 125, 20);
}

- (void)deleteAlbum
{
    NSString *strTipTitle = [Common localStr:@"Albums_Check_Delete" value:@"你确定要删除该相册？"];
    if(self.m_albumInfo.albumImageList != nil && self.m_albumInfo.albumImageList.count>0)
    {
        if (self.m_albumInfo.albumImageList.count == 1)
        {
            strTipTitle = [NSString stringWithFormat:@"%@ %lu %@",[Common localStr:@"Albums_CheckNum_Delete1" value:@"你确定要删除该相册,该相册包含了 "],(unsigned long)self.m_albumInfo.albumImageList.count,[Common localStr:@"Albums_CheckNum_Delete2" value:@" 张相片？"]];
        }
        else
        {
            strTipTitle = [NSString stringWithFormat:@"%@ %lu %@",[Common localStr:@"Albums_CheckNum_Delete1" value:@"你确定要删除该相册,该相册包含了 "],(unsigned long)self.m_albumInfo.albumImageList.count,[Common localStr:@"Albums_CheckNum_Delete3" value:@" 张相片？"]];
        }
    }
    
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:nil message:strTipTitle delegate:self cancelButtonTitle:[Common localStr:@"Common_OK" value:@"确定"] otherButtonTitles:[Common localStr:@"Common_Cancel" value:@"取消"],nil];
	[alertView show];
}

- (void)changeName
{
    CreateAlbumViewController *createAlbumViewController = [[CreateAlbumViewController alloc]init];
    createAlbumViewController.editAlbumType = ModifyAlbumType;
    createAlbumViewController.m_albumInfoVO = self.m_albumInfo;
    [self.parentViewController.navigationController pushViewController:createAlbumViewController animated:YES];
    [self.parentViewController hideBottomWhenPushed];
}

//长按
- (void)longPressChat:(UITapGestureRecognizer *)gestureRecognizer
{
    if (self.parentViewController.nAlbumType == ALBUM_MINE_TYPE)
    {
        if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
        {
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            NSMutableArray *aryMenuItem = [NSMutableArray array];
            [aryMenuItem addObject:[[UIMenuItem alloc] initWithTitle:[Common localStr:@"Documents_DirectoryRename" value:@"改名"] action:@selector(changeName)]];
            if (!self.m_albumInfo.bIsDefault)
            {
                [aryMenuItem addObject:[[UIMenuItem alloc] initWithTitle:[Common localStr:@"Common_Delete" value:@"删除"] action:@selector(deleteAlbum)]];
            }
            
            [self becomeFirstResponder];
            [menuController setMenuItems:aryMenuItem];
            [menuController setTargetRect:CGRectMake(80,40, 0, 0) inView:self.contentView];
            [menuController setMenuVisible:YES animated:YES];
        }
    }
}

#pragma mark -
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(changeName))
    {
        return YES;
    }
    
    if (action == @selector(deleteAlbum))
    {
        return YES;
    }
    
    return [super canPerformAction:action withSender:sender];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0)
    {
        [self.parentViewController isHideActivity:NO];
        dispatch_async(dispatch_get_global_queue(0,0),^{
            //do thread work
            ServerReturnInfo *retInfo = [ServerProvider removeAlbumFolder:self.m_albumInfo.albumFolderID];
            if (retInfo.bSuccess)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.parentViewController isHideActivity:YES];
                    [self.parentViewController.folderArray removeObject:self.m_albumInfo];
                    [self.parentViewController.collectionViewAlbumList reloadData];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Common tipAlert:retInfo.strErrorMsg];
                    [self.parentViewController isHideActivity:YES];
                });
            }
        });
    }
}

@end
