//
//  EditUserHeaderViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/7.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "EditUserHeaderViewController.h"
#import "UIImageView+WebCache.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+UIImageScale.h"
#import "Utils.h"
#import "UserVo.h"

@interface EditUserHeaderViewController ()<UIScrollViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UserVo *userVo;
    BOOL bNeedRefresh;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewHeader;


@end

@implementation EditUserHeaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.title = @"个人头像";
    self.fd_interactivePopDisabled = YES;
    self.isNeedBackItem = NO;
    self.navigationItem.leftBarButtonItem = [self leftBtnItemWithTitle:@"取消"];
    self.navigationItem.rightBarButtonItem = [self rightBtnItemWithImage:@"nav_btn_more"];
    
    
    UITapGestureRecognizer *tapGestureDouble = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDoubleHeaderImage)];
    tapGestureDouble.numberOfTapsRequired = 2;
    [self.imgViewHeader addGestureRecognizer:tapGestureDouble];
    
    self.imgViewHeader.contentMode = UIViewContentModeScaleAspectFit;
    [self.imgViewHeader sd_setImageWithURL:[NSURL URLWithString:userVo.strMaxHeadImageURL] placeholderImage:[UIImage imageNamed:@"default_image"]];
}

- (void)initData
{
    bNeedRefresh = NO;
    userVo = [Common getCurrentUserVo];
}

- (void)tapDoubleHeaderImage
{
    if (self.scrollViewHeader.zoomScale >1.0)
    {
        [self.scrollViewHeader setZoomScale:1.0 animated:YES];
    }
    else
    {
        [self.scrollViewHeader setZoomScale:2.0 animated:YES];
    }
}

- (void)righBarClick
{
    UIActionSheet *photoSheet = [[UIActionSheet alloc] initWithTitle:@"修改头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从手机相册选择", nil];
    [photoSheet showInView:self.view];
}

- (void)backForePage
{
    if (bNeedRefresh)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshUserDetail" object:nil];
        self.menuVo.strValue = userVo.strHeadImageURL;
    }
    [super backForePage];
}

- (void)completeUpateHeaderImage:(NSString *)strImagePath
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc]init];
    [dicBody setObject:userVo.strUserID forKey:@"id"];
    [dicBody setObject:strImagePath forKey:@"HeaderImagePath"];
    
    [Common showProgressView:nil view:self.view modal:NO];
    [ServerProvider updateUserInfoByDictionary:dicBody result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            self.imgViewHeader.image = [UIImage imageWithContentsOfFile:strImagePath];
            [Common bubbleTip:@"头像更新成功" andView:self.view];
            userVo.strHeadImageURL = retInfo.data;
            userVo.strMaxHeadImageURL = retInfo.data2;
            bNeedRefresh = YES;
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //拍照
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        {
            return;
        }
        UIImagePickerController *photoController = [[UIImagePickerController alloc] init];
        photoController.delegate = self;
        photoController.mediaTypes = @[(NSString*)kUTTypeImage];
        photoController.sourceType = UIImagePickerControllerSourceTypeCamera;
        photoController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        photoController.allowsEditing = YES;
        [photoController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        
        [self presentViewController:photoController animated:YES completion: nil];
    }
    else if (buttonIndex == 1)
    {
        //用户相册
        UIImagePickerController *photoAlbumController = [[UIImagePickerController alloc]init];
        photoAlbumController.delegate = self;
        photoAlbumController.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
        photoAlbumController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        photoAlbumController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        photoAlbumController.allowsEditing = YES;
        [photoAlbumController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        
        [self presentViewController:photoAlbumController animated:YES completion: nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (editedImage)
        {
            imageToSave = editedImage;
        }
        else
        {
            imageToSave = originalImage;
            
        }
        imageToSave = [Common rotateImage:imageToSave];
        
        // Save the new image (original or edited) to the Camera Roll
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        }
        
        float fWidth = imageToSave.size.width;
        float fHeight = imageToSave.size.height;
        
        //1.get middle image(square)
        CGRect rect;
        if(fWidth >= fHeight)
        {
            rect  = CGRectMake((fWidth-fHeight)/2, 0, fHeight, fHeight);
        }
        else
        {
            rect  = CGRectMake(0,(fHeight-fWidth)/2, fWidth, fWidth);
        }
        
        UIImage *imgTemp1 = [imageToSave getSubImage:rect];
        UIImage *imgTemp2 = [imgTemp1 scaleToSize:CGSizeMake(640,640)];
        
        //2.保存图片
        NSData *imageData = UIImageJPEGRepresentation(imgTemp2,1.0);
        NSString *imagePathDir = [[Utils tmpDirectory] stringByAppendingPathComponent:POST_TEMP_DIRECTORY];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:imagePathDir];
        if (fileExists)
        {
            //delete director
            [fileManager removeItemAtPath:imagePathDir error:nil];
        }
        
        //create director
        [fileManager createDirectoryAtPath:imagePathDir  withIntermediateDirectories:YES  attributes:nil error:nil];
        
        //save file
        NSString *imagePath = [imagePathDir stringByAppendingPathComponent:[Common createImageNameByDateTime]];
        [fileManager createFileAtPath:imagePath contents:imageData attributes:nil];
        
        //3.assign userVo value
        [self completeUpateHeaderImage:imagePath];
    }
    [picker dismissViewControllerAnimated:YES completion: nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imgViewHeader;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self.scrollViewHeader setZoomScale:scale animated:YES];
}

@end
