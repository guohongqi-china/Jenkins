//
//  PhotoAlbumViewController.h
//  ChinaMobileSocialProj
//
//  Created by 焱 孙 on 13-10-28.
//
//

#import "QNavigationViewController.h"
#import "AlbumFolderListViewController.h"

typedef enum _PhotoAlbumType{
    PhotoAlbumMyType = 0,                 //我的相册
    PhotoAlbumPublicType,                 //公共相册
}PhotoAlbumType;

@interface PhotoAlbumViewController : UIViewController <UIWebViewDelegate,UIWebViewDelegate>

@property(nonatomic)PhotoAlbumType mainTabType;

@property(nonatomic,strong)UIView *viewTab;

@property(nonatomic,strong)UIButton *myAlbumBtn;
@property(nonatomic,strong)UIButton *publicAlbumBtn;

@property(nonatomic,strong)UINavigationController *myAlbumNavigationController;
@property(nonatomic,strong)UINavigationController *publicAlbumNavigationController;

@property(nonatomic,strong)AlbumFolderListViewController *myAlbumListViewController;
@property(nonatomic,strong)AlbumFolderListViewController *publicAlbumListViewController;

-(void)hideBottomTabBar:(BOOL)bHide;

@end
