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
#import "AlbumFolderListViewController.h"
#import "SDWebImageManager.h"
#import "SDImageCache.h"
#import <ImageIO/ImageIO.h>

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
        
        self.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressChat:)];
        [self addGestureRecognizer:self.longPress];
    }
    return self;
}

-(void)initWithAlbumImageInfoVO:(AlbumImageInfoVO*)albumImageInfoVO
{
    self.m_albumImageInfoVO = albumImageInfoVO;
    self.imgViewPhoto.frame = CGRectMake(4,4,69,69);
    UIImage *imgDefault =[UIImage imageNamed:@"default_image"];
    
    //由于服务器端对小的gif图片做了压缩处理，导致中图和小图显示的图片不对，原图可以
    NSURL *urlImage = nil;
    if ([[albumImageInfoVO.imageMaxUrl lowercaseString] hasSuffix:@".gif"])
    {
        urlImage = [NSURL URLWithString:albumImageInfoVO.imageMaxUrl];
    }
    else
    {
        //普通图片
        urlImage = [NSURL URLWithString:albumImageInfoVO.imageMinUrl];
    }
    [self.imgViewPhoto setImageWithURL:urlImage placeholderImage:imgDefault];
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
            [aryMenuItem addObject:[[UIMenuItem alloc] initWithTitle:[Common localStr:@"Common_Delete" value:@"删除"] action:@selector(deleteFile)]];
            
            [self becomeFirstResponder];
            [menuController setMenuItems:aryMenuItem];
            [menuController setTargetRect:CGRectMake(50,40, 0, 0) inView:self.contentView];
            [menuController setMenuVisible:YES animated:YES];
        }
    }
}

- (void)deleteFile
{
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:nil message:[Common localStr:@"Albums_Photo_Delete" value:@"你确定要删除该图片？"] delegate:self cancelButtonTitle:[Common localStr:@"Common_OK" value:@"确定"] otherButtonTitles:[Common localStr:@"Common_Cancel" value:@"取消"],nil];
    [alertView show];
}

#pragma mark -
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(deleteFile))
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
            ServerReturnInfo *retInfo = [ServerProvider removeImageFromFolder:self.m_albumImageInfoVO];
            if (retInfo.bSuccess)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.parentViewController isHideActivity:YES];
                    [self.parentViewController.aryPhotoList removeObject:self.m_albumImageInfoVO];
                    [self.parentViewController refreshPhotoList];
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

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    //modify by sunyan 在block里面直接获取，不需要代理
    //[self setImage:image];
}

@end
