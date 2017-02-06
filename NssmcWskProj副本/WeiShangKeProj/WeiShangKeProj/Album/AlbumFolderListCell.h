//
//  AlbumFolderListCell.h
//  ChinaMobileSocialProj
//
//  Created by Yuson Xing on 14-3-11.
//
//

#import <UIKit/UIKit.h>
#import "AlbumInfoVO.h"

@class AlbumFolderListViewController;

@interface AlbumFolderListCell : UICollectionViewCell<UIAlertViewDelegate>

@property (nonatomic, strong) UIView *viewBorder;
@property (nonatomic, strong) UIImageView *imgViewAlbum;
@property (nonatomic, strong) UILabel *folderNameLabel;
@property (nonatomic, strong) AlbumInfoVO *m_albumInfo;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@property (nonatomic, weak)AlbumFolderListViewController *parentViewController;

- (void) initWithAlbumInfo:(AlbumInfoVO *)albumInfo;

@end
