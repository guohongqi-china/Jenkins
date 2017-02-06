//
//  AlbumImageListCell.h
//  ChinaMobileSocialProj
//
//  Created by 焱 孙 on 14-3-15.
//
//

#import <UIKit/UIKit.h>
#import "AlbumImageInfoVO.h"

@interface AlbumImageListCell : UICollectionViewCell

@property(nonatomic,retain)UIImageView *imgViewPhoto;

-(void)initWithAlbumImageInfoVO:(AlbumImageInfoVO*)albumImageInfoVO;

@end
