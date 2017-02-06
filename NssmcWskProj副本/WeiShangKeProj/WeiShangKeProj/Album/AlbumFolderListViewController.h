//
//  AlbumFolderListViewController.h
//  ChinaMobileSocialProj
//
//  Created by Yuson Xing on 14-3-11.
//
//

#import "QNavigationViewController.h"
#import "AlbumInfoVO.h"
#import "UserVo.h"

@class PhotoAlbumViewController;

enum
{
    ALBUM_MINE_TYPE = 0,
    ALBUM_PUBLIC_TYPE,
    ALBUM_OTHER_USER_TYPE,
    ALBUM_GROUP_TYPE
};

typedef enum _FromViewToAlbumType
{
    FromMainAlbumToAlbumType = 0,
    FromUserCenterToAlbumType
}FromViewToAlbumType;

@interface AlbumFolderListViewController : QNavigationViewController<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic) int nAlbumType;
@property (nonatomic) FromViewToAlbumType fromViewToAlbumType;
@property (nonatomic, strong) NSMutableArray *folderArray;
@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) UserVo *userVo;
@property (nonatomic, strong) NSString *albumTitle;
@property (nonatomic, strong) NSString *strKey;
@property (nonatomic,weak) PhotoAlbumViewController *homeViewController;

//UICollectionView
@property (nonatomic, strong) UICollectionView *collectionViewAlbumList;

- (id) initWithAlbumType:(int)nType;
- (id) initGroupAlbumWithID:(NSString *)gID;
- (void)hideBottomWhenPushed;

- (void) initView:(id)folderInfo;
- (void) ObtainFolderInfoProc;

@end
