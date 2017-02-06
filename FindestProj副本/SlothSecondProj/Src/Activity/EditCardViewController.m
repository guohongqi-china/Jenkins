//
//  EditCardViewController.m
//  TaoZhiHuiProj
//
//  Created by fujunzhi on 16/5/10.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "EditCardViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+UIImageScale.h"
#import "CheXiangService.h"
#import "UserVo.h"
#import "Utils.h"
#import "SkinManage.h"


@interface EditCardViewController()<UIWebViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (strong, nonatomic) MBProgressHUD *HUD;
@end

@implementation EditCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = COLOR(46, 49, 50, 1.0);
    self.title = @"编辑名片";
    
    NSString *requestStr = [NSString stringWithFormat:@"%@%@",[ServerURL getEditWeixinCardURL],[[Common getCurrentUserVo] strUserID]];
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:requestStr]];
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth,kScreenHeight - 64)];
    [webView loadRequest:request];
    [webView setAutoresizesSubviews:YES];
    [webView setAutoresizingMask:UIViewAutoresizingNone];
    [webView setUserInteractionEnabled: YES ];
    [webView setOpaque:YES ];
    webView.delegate = self;
    webView.backgroundColor=[UIColor clearColor];
    webView.scalesPageToFit = YES;
    [self.view addSubview:webView];
    self.webView = webView;
    
    self.HUD = [[MBProgressHUD alloc] initWithFrame:self.view.bounds];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    [self.view addSubview:self.HUD];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIWebView delegate methods
- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [self.HUD show:YES];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.HUD hide:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewTemp
{
    [self.HUD hide:YES];
}

#pragma mark UIWebView delegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeReload || navigationType == UIWebViewNavigationTypeOther)
    {
        NSString *strURL = [request URL].absoluteString;
        if (strURL != nil && strURL.length>0)
        {
            //1.上传头像照片
            NSRange range = [strURL rangeOfString:@"http://wxcard.tzhapp.upload.control" options:NSCaseInsensitiveSearch];
            if(range.length>0 && range.location == 0)
            {
                [self.HUD hide:YES];
                [self uploadPhotoAction];
                return NO;
            }
            
            //3.返回按钮
            range = [strURL rangeOfString:@"http://wxcard.tzhapp.return.control" options:NSCaseInsensitiveSearch];
            if(range.length>0 && range.location == 0)
            {
                [self backForePage];
                return NO;
            }
        }
    }
    return YES;
}

- (void)backForePage
{
    if ([self.webView canGoBack])
    {
        [self.webView goBack];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//上传头像操作
- (void)uploadPhotoAction
{
    //关闭键盘
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    UIActionSheet *photoSheet = [[UIActionSheet alloc] initWithTitle:@"图片上传" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"用户相册", nil];
    [photoSheet showInView:self.view];
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
        photoAlbumController.navigationBar.barTintColor = [SkinManage skinColor];
        photoAlbumController.navigationBar.tintColor = [SkinManage colorNamed:@"Nav_Bar_Title_Color"];
        NSDictionary *titleTextAttributes = @{
                                              NSFontAttributeName : [UIFont systemFontOfSize:18],
                                              NSForegroundColorAttributeName : [UIColor whiteColor]
                                              };
        [photoAlbumController.navigationBar setTitleTextAttributes:titleTextAttributes];
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
        UIImage *imgTemp2 = [imgTemp1 scaleToSize:CGSizeMake(320,320)];
        
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
        
        //更新封面图
        [self updateHeadImageToServer:imagePath image:imgTemp2];
    }
    [picker dismissViewControllerAnimated:YES completion: nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateHeadImageToServer:(NSString*)strPath image:(UIImage*)imageData
{
    [self.HUD show:YES];
    [CheXiangService uploadWeixinCardPhoto:strPath result:^(ServerReturnInfo *retInfo) {
        [self.HUD hide:YES];
        if (retInfo.bSuccess)
        {
            [Common bubbleTip:@"图片上传成功" andView:self.view];
            //执行一段JS方法 function uploadCallbakc(imgUrl){...}
            NSString *strJS = [NSString stringWithFormat:@"uploadCallback('%@');",retInfo.data];
            [self.webView stringByEvaluatingJavaScriptFromString:strJS];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}


@end
