//
//  AlbumImageListViewController.m
//  ChinaMobileSocialProj
//
//  Created by Yuson Xing on 14-3-11.
//
//

#import "AlbumImageListViewController.h"
#import "Utils.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>
#import <ImageIO/ImageIO.h>
#import "ResizeImage.h"
#import "AlbumImageListCell.h"
#import "SDWebImageDataSource.h"
#import "KTPhotoScrollViewController.h"
#import "AlbumFolderListViewController.h"

#define MAX_UPLOAD_IMAGE_NUM 8

@interface AlbumImageListViewController ()

@end

@implementation AlbumImageListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self initView];
    [self initData];
    
    self.bUploadImage = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.nAlbumType != ALBUM_OTHER_USER_TYPE)
    {
        UIButton *rigthBtn = [Utils buttonWithTitle:[Common localStr:@"Albums_Photo_Upload" value:@"上传相片"] frame:[Utils getNavRightBtnFrame:CGSizeMake(140,76)] target:self action:@selector(uploadImage)];
        [self setRightBarButton:rigthBtn];
    }
   
    [self setTopNavBarTitle:self.m_albumInfoVO.albumFolderName];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize=CGSizeMake(77,77);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    self.collectionViewImageList = [[UICollectionView alloc]initWithFrame:CGRectMake(6, NAV_BAR_HEIGHT+6, kScreenWidth-12, kScreenHeight-NAV_BAR_HEIGHT-12) collectionViewLayout:flowLayout];
    self.collectionViewImageList.dataSource = self;
    self.collectionViewImageList.delegate = self;
    self.collectionViewImageList.backgroundColor = [UIColor clearColor];
    self.collectionViewImageList.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.collectionViewImageList];
    [self.collectionViewImageList registerClass:[AlbumImageListCell class] forCellWithReuseIdentifier:@"AlbumImageListCell"];
    
    self.aryImageURL = [NSMutableArray array];
}

-(void)initData
{
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        //do thread work
    	ServerReturnInfo *retInfo = [ServerProvider getImageFolderFromID:self.m_albumInfoVO.albumFolderID];
    	if (retInfo.bSuccess)
    	{
            AlbumImageVO *albumImageVO = retInfo.data;
        	self.aryPhotoList = (NSMutableArray*)albumImageVO.imageList;
            [self generateURLArray];
        	dispatch_async(dispatch_get_main_queue(), ^{
                //reload data
                [self.collectionViewImageList reloadData];
                [self isHideActivity:YES];
        	});
    	}
    	else
    	{
        	dispatch_async(dispatch_get_main_queue(), ^{
                [Common tipAlert:retInfo.strErrorMsg];
                [self isHideActivity:YES];
        	});
    	}
    });
}

//产生KTPhotoBrowser的数据源
-(void)generateURLArray
{
    [self.aryImageURL removeAllObjects];
    for (AlbumImageInfoVO *albumImageVO in self.aryPhotoList)
    {
        if (albumImageVO.imageMaxUrl == nil || albumImageVO.imageMinUrl == nil)
        {
            continue;
        }
        //避免转义时出现错误导致NSURL为nil
        albumImageVO.imageMaxUrl = [albumImageVO.imageMaxUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        albumImageVO.imageMinUrl = [albumImageVO.imageMinUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        NSURL *urlMax = [NSURL URLWithString:albumImageVO.imageMaxUrl];
        NSURL *urlMin = [NSURL URLWithString:albumImageVO.imageMinUrl];
        
        if (urlMax == nil || urlMin == nil)
        {
            continue;
        }
        
        NSArray *ary = @[urlMax,urlMin];
        [self.aryImageURL addObject:ary];
    }
}

-(void)refreshPhotoList
{
    [self generateURLArray];
    [self.collectionViewImageList reloadData];
}

-(void)uploadImage
{
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.maximumNumberOfSelections = 8;
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)backButtonClicked
{
    if(self.bUploadImage)
    {
        //post notification
        NSMutableDictionary *dicNotifyData = [[NSMutableDictionary alloc]init];
        [dicNotifyData setObject:[NSNumber numberWithInt:self.nAlbumType] forKey:@"NotifyData"];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshAlbumFoldList" object:dicNotifyData];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Assets Picker Delegate
- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    NSMutableArray *aryChoosedImage = [NSMutableArray arrayWithArray:assets];
    
    int nFileNamePara = 0;
    NSMutableArray *aryImagePath = [NSMutableArray array];
    for (ALAsset *asset in aryChoosedImage)
    {
        nFileNamePara ++;
        ALAssetRepresentation* representation = [asset defaultRepresentation];
        [representation orientation];
        
        //图片缩放处理
        UIImage *imageToSave = [UIImage imageWithCGImage:[representation fullScreenImage] scale:0.8 orientation:UIImageOrientationUp];        
        CGSize sizeImage = [representation dimensions];
        if (sizeImage.width>IMAGE_MAX_SIZE && sizeImage.height>IMAGE_MAX_SIZE)
        {
            sizeImage = CGSizeMake(640, (640*sizeImage.height)/sizeImage.width);
        }
        imageToSave = [ResizeImage imageWithImage:imageToSave scaledToSize:sizeImage];
        
        //保存图片
        NSData *imageData = UIImageJPEGRepresentation(imageToSave, 0.6f);
        //自动清理上次产生的图片以及目录"tmp/TempFile"
        NSString *imagePath = [[Utils getTempPath] stringByAppendingPathComponent:[Common createImageNameByDateTimeAndPara:nFileNamePara]];
        [imageData writeToFile:imagePath atomically:YES];
        
        [aryImagePath addObject:imagePath];
    }
    
    //选择完照片后，上传相片到服务器
    if (aryImagePath.count>0)
    {
        [self isHideActivity:NO];
        dispatch_async(dispatch_get_global_queue(0,0),^{
            //do thread work
            ServerReturnInfo *retInfo = [ServerProvider addImagesIntoFolder:aryImagePath forFolder:self.m_albumInfoVO.albumFolderID];
            if (retInfo.bSuccess)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //reload data
                    [self initData];
                    self.bUploadImage = YES;
                    [Utils clearTempPath];
                    [self isHideActivity:YES];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Common tipAlert:retInfo.strErrorMsg];
                    [Utils clearTempPath];
                    [self isHideActivity:YES];
                });
            }
        });
    }
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAssetForSelection:(ALAsset *)asset
{
    // Enable video clips if they are at least 5s
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
    {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return lround(duration) >= 5;
    }
    else
    {
        return YES;
    }
}

#pragma mark - UICollectionViewDataSource UICollectionViewDelegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"AlbumImageListCell";
    AlbumImageListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    AlbumImageInfoVO *albumImageInfoVO = [self.aryPhotoList objectAtIndex:[indexPath row]];
    cell.parentViewController = self;
    [cell initWithAlbumImageInfoVO:albumImageInfoVO];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.aryPhotoList.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
    dataSource.images_ = self.aryImageURL;
    KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
                                                               initWithDataSource:dataSource
                                                               andStartWithPhotoAtIndex:[indexPath row]];
    photoScrollViewController.bShowToolBarBtn = YES;
    photoScrollViewController.aryImageVo = self.aryPhotoList;
    [self.navigationController pushViewController:photoScrollViewController animated:YES];
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

@end
