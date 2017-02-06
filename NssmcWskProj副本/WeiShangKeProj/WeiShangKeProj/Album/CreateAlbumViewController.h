//
//  CreateAlbumViewController.h
//  ChinaMobileSocialProj
//
//  Created by 焱 孙 on 14-3-14.
//
//

#import "QNavigationViewController.h"
#import "AlbumInfoVO.h"

typedef enum _EditAlbumType
{
    CreateAlbumType,
    ModifyAlbumType
}EditAlbumType;

@interface CreateAlbumViewController : QNavigationViewController<UITextFieldDelegate>

@property (nonatomic)EditAlbumType editAlbumType;
@property (nonatomic, strong) AlbumInfoVO *m_albumInfoVO;

@property (nonatomic, retain) UITextField *txtAlbumName;
@property (nonatomic, retain) UIActivityIndicatorView * activity;
@property (nonatomic, retain) UIImageView *imgViewWaiting;

@end
