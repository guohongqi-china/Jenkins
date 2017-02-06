//
//  CertificateUploadViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/6.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "CertificateUploadViewController.h"
#import "UIViewExt.h"
#import "CustomPicker.h"
#import "UIImage+UIImageScale.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "Utils.h"
#import "ResizeImage.h"
#import "CheXiangService.h"
#import "SkinManage.h"
#import "InsetsTextField.h"
#import "VerifyPhoneView.h"
#import "SkinManage.h"

@implementation CertificateUploadVo
@end

@interface CertificateUploadViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    ////////////////////////////////////////////////
    UIView *viewLine;
    UIImage *imgButtonLine;
    
    UIButton *btnVehicleLicense;
    UIButton *btnDriveLicense;
    UIButton *btnIDCard;
    
    UIButton *btnChoosePhoto;
    UIImageView *imgViewUploadTip;
    UILabel *lblUploadTip;
    
    UIButton *btnUpload;
    
    NSMutableArray *aryCertificate;
    CertificateUploadVo *currCertificate;
}

@end

@implementation CertificateUploadViewController

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
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    [self setTopNavBarTitle:@"百宝箱"];
    
    CGFloat fHeight = NAV_BAR_HEIGHT + 15;
    CGFloat fButtonW = (kScreenWidth-60)/3;
    
    viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight+30, kScreenWidth, 1)];
    viewLine.backgroundColor = COLOR(205, 205, 205, 1.0);
    [self.view addSubview:viewLine];
    
    viewLine.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    
    imgButtonLine = [[UIImage imageNamed:@"cer_button_line"]stretchableImageWithLeftCapWidth:10 topCapHeight:1];
    
    btnVehicleLicense = [UIButton buttonWithType:UIButtonTypeCustom];
    btnVehicleLicense.tag = 1000;
    btnVehicleLicense.frame = CGRectMake(15, fHeight, fButtonW, 31);
    [btnVehicleLicense setBackgroundImage:imgButtonLine forState:UIControlStateNormal];
    [btnVehicleLicense setTitle:@"行驶证" forState:UIControlStateNormal];
    [btnVehicleLicense setTitleColor:[SkinManage colorNamed:@"myjob_Button_title_color"]
                            forState:UIControlStateNormal];
    btnVehicleLicense.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnVehicleLicense addTarget:self action:@selector(choosePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnVehicleLicense];
    
    btnDriveLicense = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDriveLicense.tag = 1001;
    btnDriveLicense.frame = CGRectMake(btnVehicleLicense.right + 15, fHeight, fButtonW, 31);
    [btnDriveLicense setBackgroundImage:nil forState:UIControlStateNormal];
    [btnDriveLicense setTitle:@"驾照" forState:UIControlStateNormal];
    [btnDriveLicense setTitleColor:[SkinManage colorNamed:@"myjob_Button_title_color"] forState:UIControlStateNormal];
    btnDriveLicense.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnDriveLicense addTarget:self action:@selector(choosePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnDriveLicense];
    
    btnIDCard = [UIButton buttonWithType:UIButtonTypeCustom];
    btnIDCard.tag = 1002;
    btnIDCard.frame = CGRectMake(btnDriveLicense.right + 15, fHeight, fButtonW, 31);
    [btnIDCard setBackgroundImage:nil forState:UIControlStateNormal];
    [btnIDCard setTitle:@"身份证" forState:UIControlStateNormal];
    [btnIDCard setTitleColor:[SkinManage colorNamed:@"myjob_Button_title_color"] forState:UIControlStateNormal];
    btnIDCard.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnIDCard addTarget:self action:@selector(choosePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnIDCard];
    
    fHeight += btnIDCard.height + 20;
    
    CGFloat fRate = 0.647;
    btnChoosePhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    btnChoosePhoto.layer.cornerRadius = 4;
    btnChoosePhoto.layer.borderColor = [SkinManage colorNamed:@"myjob_Button_BorderLayer_color"].CGColor;
    btnChoosePhoto.layer.borderWidth = 0.5;
    btnChoosePhoto.layer.masksToBounds = YES;
    btnChoosePhoto.frame = CGRectMake(15, fHeight, kScreenWidth-30, (kScreenWidth-30)*fRate);
    btnChoosePhoto.imageView.contentMode = UIViewContentModeScaleAspectFill;
    btnChoosePhoto.imageView.clipsToBounds = YES;
    [btnChoosePhoto addTarget:self action:@selector(choosePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnChoosePhoto];
    
    imgViewUploadTip = [[UIImageView alloc]initWithFrame:CGRectMake((btnChoosePhoto.width-42)/2, (btnChoosePhoto.height-42)/2, 42, 42)];
    imgViewUploadTip.image = [UIImage imageNamed:@"upload_photo_card"];
    [btnChoosePhoto addSubview:imgViewUploadTip];
    
    lblUploadTip = [[UILabel alloc]initWithFrame:CGRectMake((imgViewUploadTip.width-200)/2, 60, 200, 25)];
    lblUploadTip.text = @"请上传证件照";
    lblUploadTip.textAlignment = NSTextAlignmentCenter;
    lblUploadTip.font = [UIFont systemFontOfSize:14];
    lblUploadTip.textColor = [SkinManage colorNamed:@"myjob_Upload_Label_Tip_color"];
    [imgViewUploadTip addSubview:lblUploadTip];
    fHeight += btnChoosePhoto.height+20;
    
    btnUpload = [UIButton buttonWithType:UIButtonTypeCustom];
    btnUpload.layer.cornerRadius = 4;
    btnUpload.layer.borderWidth = 0;
    btnUpload.layer.masksToBounds = YES;
    btnUpload.frame = CGRectMake(15, fHeight, kScreenWidth-30, 36);
    [btnUpload setBackgroundImage:[Common getImageWithColor:[SkinManage skinColor]] forState:UIControlStateNormal];
    [btnUpload setBackgroundImage:[Common getImageWithColor:[SkinManage skinColor]] forState:UIControlStateHighlighted];
    if ([SkinManage getCurrentSkin] == SkinNightType) {
        [btnUpload setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Function_BK_Color"]] forState:UIControlStateNormal];
        [btnUpload setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Function_BK_Color"]] forState:UIControlStateHighlighted];
    }
    [btnUpload setTitle:@"上  传" forState:UIControlStateNormal];
    [btnUpload setTitleColor:[SkinManage colorNamed:@"myjob_Upload_Button_color"] forState:UIControlStateNormal];
    [btnUpload addTarget:self action:@selector(uploadPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnUpload];
}

- (void)initData
{
    aryCertificate = [NSMutableArray array];
    CertificateUploadVo *uploadVo = [[CertificateUploadVo alloc]init];
    uploadVo.nType = 0;
    uploadVo.strTypeName = @"行驶证";
    [aryCertificate addObject:uploadVo];
    
    uploadVo = [[CertificateUploadVo alloc]init];
    uploadVo.nType = 1;
    uploadVo.strTypeName = @"驾照";
    [aryCertificate addObject:uploadVo];
    
    uploadVo = [[CertificateUploadVo alloc]init];
    uploadVo.nType = 2;
    uploadVo.strTypeName = @"身份证";
    [aryCertificate addObject:uploadVo];
    
    currCertificate = aryCertificate[0];
}

- (void)choosePhoto:(UIButton *)sender
{
    if (sender != btnChoosePhoto)
    {
        [btnVehicleLicense setBackgroundImage:nil forState:UIControlStateNormal];
        [btnDriveLicense setBackgroundImage:nil forState:UIControlStateNormal];
        [btnIDCard setBackgroundImage:nil forState:UIControlStateNormal];
        if (sender == btnVehicleLicense)
        {
            currCertificate = aryCertificate[0];
            [btnVehicleLicense setBackgroundImage:imgButtonLine forState:UIControlStateNormal];
        }
        else if (sender == btnDriveLicense)
        {
            currCertificate = aryCertificate[1];
            [btnDriveLicense setBackgroundImage:imgButtonLine forState:UIControlStateNormal];
        }
        else if (sender == btnIDCard)
        {
            currCertificate = aryCertificate[2];
            [btnIDCard setBackgroundImage:imgButtonLine forState:UIControlStateNormal];
        }
        [self updatePreviewImage];
    }
    
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
    photoController.allowsEditing = NO;
    [photoController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    [self presentViewController:photoController animated:YES completion: nil];
}

- (void)uploadPhoto
{
    if (currCertificate.attach == nil)
    {
        [Common tipAlert:@"请选择要上传的图片"];
    }
    else
    {
        [self isHideActivity:NO];
        [CheXiangService uploadCertificatePhoto:currCertificate.attach.strAttachLocalPath type:currCertificate.nType result:^(ServerReturnInfo *retInfo) {
            [self isHideActivity:YES];
            if (retInfo.bSuccess)
            {
                [Common tipAlert:retInfo.strErrorMsg];
                
                //清理数据
                [btnChoosePhoto setImage:nil forState:UIControlStateNormal];
                imgViewUploadTip.hidden = NO;
                currCertificate.attach = nil;
                
                if (currCertificate.nType == 0)
                {
                    [btnVehicleLicense setTitle:@"行驶证" forState:UIControlStateNormal];
                }
                else if (currCertificate.nType == 1)
                {
                    [btnDriveLicense setTitle:@"驾照" forState:UIControlStateNormal];
                }
                else if (currCertificate.nType == 2)
                {
                    [btnIDCard setTitle:@"身份证" forState:UIControlStateNormal];
                }
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
            }
        }];
    }
}

- (void)updatePreviewImage
{
    if (currCertificate.attach)
    {
        [btnChoosePhoto setImage:currCertificate.attach.imgAttach forState:UIControlStateNormal];
        imgViewUploadTip.hidden = YES;
    }
    else
    {
        [btnChoosePhoto setImage:nil forState:UIControlStateNormal];
        imgViewUploadTip.hidden = NO;
    }
}

//显示隐藏PickerView控件
- (void)setPickerHidden:(UIView*)pickerViewCtrl andHide:(BOOL)hidden
{
    int nHeight = pickerViewCtrl.frame.size.height * (-1);
    CGAffineTransform transform = hidden ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, nHeight);
    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        pickerViewCtrl.transform = transform;
    } completion:nil];
    
    if (!hidden)
    {
        self.view.backgroundColor = [UIColor whiteColor];
        //self.m_scrollView.frame = CGRectMake(0, NAV_BAR_HEIGHT, self.view.bounds.size.width, (kScreenHeight-NAV_BAR_HEIGHT-260+44));
    }
    else
    {
        //self.m_scrollView.frame = CGRectMake(0, NAV_BAR_HEIGHT, self.view.bounds.size.width, kScreenHeight-NAV_BAR_HEIGHT);
    }
}

- (void)backButtonClicked
{
    //清理临时照片文件
    [Utils clearTempPath];
    
    [super backButtonClicked];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        imageToSave = originalImage;
        imageToSave = [Common rotateImage:imageToSave];
        
        //当图片尺寸过大，进行缩放处理
        CGSize sizeImage = CGSizeMake(imageToSave.size.width, imageToSave.size.height);
        if (sizeImage.width>1000 && sizeImage.height>1000)
        {
            sizeImage = CGSizeMake(1024, (1024*sizeImage.height)/sizeImage.width);
        }
        imageToSave = [ResizeImage imageWithImage:imageToSave scaledToSize:sizeImage];
        
        //2.保存图片
        NSData *imageData = UIImageJPEGRepresentation(imageToSave,0.5);
        NSString *imagePathDir = [[Utils tmpDirectory] stringByAppendingPathComponent:POST_TEMP_DIRECTORY];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:imagePathDir];
        if (!fileExists)
        {
            //create director
            [fileManager createDirectoryAtPath:imagePathDir withIntermediateDirectories:YES  attributes:nil error:nil];
        }
        
        //save file
        NSString *imagePath = [imagePathDir stringByAppendingPathComponent:[Common createImageNameByDateTime]];
        [fileManager createFileAtPath:imagePath contents:imageData attributes:nil];
        
        //保存临时数据
        AttachmentVo *attach = [[AttachmentVo alloc]init];
        attach.imgAttach = imageToSave;
        attach.strAttachLocalPath = imagePath;
        currCertificate.attach = attach;
        
        [self updatePreviewImage];
    }
    [picker dismissViewControllerAnimated:YES completion: nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
