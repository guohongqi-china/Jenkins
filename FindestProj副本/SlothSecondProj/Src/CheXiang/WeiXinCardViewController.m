//
//  WeiXinCardViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/10/22.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import "WeiXinCardViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "ServerURL.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import "UIImage+UIImageScale.h"
#import "Utils.h"
#import "CheXiangService.h"
#import "ShareInfoVo.h"
#import "SkinManage.h"
#import <ShareSDK/ShareSDK.h>

@interface WeiXinCardViewController ()<UIWebViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIView *viewBK;
    UIWebView *webViewWeiXinCard;
    NSURL *urlLocation;
    UIButton *btnReturn;
}

@end

@implementation WeiXinCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imgViewTopBar.image = [Common getImageWithColor:[UIColor clearColor]];
    self.view.backgroundColor = [UIColor whiteColor];;//[UIColor blackColor];//[SkinManage skinColor];
    viewBK = [[UIView alloc]initWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth, kScreenHeight-kStatusBarHeight)];
    viewBK.backgroundColor = COLOR(46, 49, 50, 1.0);
    [self.view addSubview:viewBK];
    
    [self setLeftBarButton:nil];
    
    if (self.nType == 1)
    {
        urlLocation = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[ServerURL getViewWeixinCardURL],self.strUserID]];
    }
    else
    {
        urlLocation = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[ServerURL getEditWeixinCardURL],self.strUserID]];
    }
    
    NSURLRequest *request =[NSURLRequest requestWithURL:urlLocation];
    webViewWeiXinCard = [[UIWebView alloc]initWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth,kScreenHeight-kStatusBarHeight)];
    [webViewWeiXinCard loadRequest:request];
    [webViewWeiXinCard setAutoresizesSubviews:YES];
    [webViewWeiXinCard setAutoresizingMask:UIViewAutoresizingNone];
    [webViewWeiXinCard setUserInteractionEnabled: YES ];
    [webViewWeiXinCard setOpaque:YES ];
    webViewWeiXinCard.delegate = self;
    webViewWeiXinCard.backgroundColor=[UIColor clearColor];
    webViewWeiXinCard.scalesPageToFit = YES;
    [self.view addSubview:webViewWeiXinCard];
    
    //返回按钮
    btnReturn = [Utils leftButtonWithTitle:@"返回" frame:[Utils getNavLeftBtnFrame:CGSizeMake(120,60)] target:self action:@selector(backAction)];
    [btnReturn setImage:[UIImage imageNamed:@"nav_left_arrow"] forState:UIControlStateNormal];
    [btnReturn setBackgroundImage:[Common getImageWithColor:COLOR(27, 26, 31, 0.6)] forState:UIControlStateNormal];//[SkinManage skinColor]
    [btnReturn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnReturn.layer setBorderWidth:1.0];
    [btnReturn.layer setCornerRadius:3];
    btnReturn.layer.borderColor = [[UIColor clearColor] CGColor];
    [btnReturn.layer setMasksToBounds:YES];
    [Common setButtonImageLeftTitleRight:btnReturn spacing:0];
    [self.view addSubview:btnReturn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回上一层
- (void)backAction
{
    if ([webViewWeiXinCard canGoBack])
    {
        [webViewWeiXinCard goBack];
    }
    else
    {
        [self backButtonClicked];
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

//分享到微信
- (void)doShareToWeixin:(NSString*)strURL
{
    ShareInfoVo *shareInfoVo = [[ShareInfoVo alloc]init];
    
    NSString *strImageURL = [ServerURL getShareWeixinCardImageURL];
    NSString *strTitle = @"微信名片";
    NSString *strContent = @"微信名片";
    strURL =[strURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSRange range = [strURL rangeOfString:@"http://wxcard.tzhapp.share.control/?infoJSON=" options:NSCaseInsensitiveSearch];
    
    if(range.length>0 && range.location == 0)
    {
        NSString *strJSON = [strURL substringFromIndex:range.length];
        NSDictionary *dicInfo= [Common getObjectFromJSONString:strJSON];
        if (dicInfo != nil && [dicInfo isKindOfClass:[NSDictionary class]])
        {
            strImageURL = [Common checkStrValue:dicInfo[@"imgUrl"]];
            strTitle = [Common checkStrValue:dicInfo[@"title"]];
            strContent = [Common checkStrValue:dicInfo[@"content"]];
        }
    }
    
    shareInfoVo.strImageURL = strImageURL;
    shareInfoVo.strTitle = strTitle;
    shareInfoVo.strContent = strContent;
    shareInfoVo.strLinkURL = [NSString stringWithFormat:@"%@%@",[ServerURL getViewWeixinCardURL],self.strUserID];
    
    NSArray *aryShareType = [ShareSDK getShareListWithType:ShareTypeWeixiSession,ShareTypeWeixiTimeline,nil];
    [BusinessCommon shareContentToThirdPlatform:self shareVo:shareInfoVo shareList:aryShareType];
}

-(void)updateHeadImageToServer:(NSString*)strPath image:(UIImage*)imageData
{
    [self isHideActivity:NO];
    [CheXiangService uploadWeixinCardPhoto:strPath result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            [Common bubbleTip:@"图片上传成功" andView:self.view];
            //执行一段JS方法 function uploadCallbakc(imgUrl){...}
            NSString *strJS = [NSString stringWithFormat:@"uploadCallback('%@');",retInfo.data];
            [webViewWeiXinCard stringByEvaluatingJavaScriptFromString:strJS];
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
                [self isHideActivity:YES];
                [self uploadPhotoAction];
                return NO;
            }
            
            //2.分享第三平台
            range = [strURL rangeOfString:@"http://wxcard.tzhapp.share.control" options:NSCaseInsensitiveSearch];
            if(range.length>0 && range.location == 0)
            {
                [self doShareToWeixin:strURL];
                return NO;
            }
            
            //3.返回按钮
            range = [strURL rangeOfString:@"http://wxcard.tzhapp.return.control" options:NSCaseInsensitiveSearch];
            if(range.length>0 && range.location == 0)
            {
                [self backButtonClicked];
                return NO;
            }
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //[self isHideActivity:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self isHideActivity:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewTemp
{
    [self isHideActivity:YES];
}

@end
