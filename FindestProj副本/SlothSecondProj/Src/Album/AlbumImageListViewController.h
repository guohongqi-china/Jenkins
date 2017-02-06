//
//  AlbumImageListViewController.h
//  ChinaMobileSocialProj
//
//  Created by Yuson Xing on 14-3-11.
//
//

#import "QNavigationViewController.h"
#import "CTAssetsPickerController.h"
#import "AlbumInfoVO.h"
#import "AlbumImageVO.h"

@interface AlbumImageListViewController : QNavigationViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,CTAssetsPickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic)int nAlbumType;
@property(nonatomic)BOOL bUploadImage;  //是否上传了相片，是的话刷新列表
@property(nonatomic,retain)AlbumInfoVO *m_albumInfoVO;

//UICollectionView
@property (nonatomic, retain) UICollectionView *collectionViewImageList;

//data
@property(nonatomic,retain) NSMutableArray *aryPhotoList;
@property(nonatomic,retain) NSMutableArray *aryImageURL;

@end
