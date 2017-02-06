//
//  AlbumImageListCell.h
//  ChinaMobileSocialProj
//
//  Created by 焱 孙 on 14-3-15.
//
//

#import <UIKit/UIKit.h>
#import "AlbumImageInfoVO.h"
#import "AlbumImageListViewController.h"
#import "SDWebImageManagerDelegate.h"

@interface AlbumImageListCell : UICollectionViewCell<UIAlertViewDelegate,SDWebImageManagerDelegate>

@property(nonatomic,strong)UIImageView *imgViewPhoto;
@property(nonatomic,strong)UILongPressGestureRecognizer *longPress;
@property(nonatomic,strong)AlbumImageInfoVO *m_albumImageInfoVO;

@property (nonatomic,weak)AlbumImageListViewController *parentViewController;

-(void)initWithAlbumImageInfoVO:(AlbumImageInfoVO*)albumImageInfoVO;

@end
