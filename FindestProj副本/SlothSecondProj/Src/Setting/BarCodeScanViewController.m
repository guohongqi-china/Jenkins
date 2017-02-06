//
//  BarCodeScanViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-5-4.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "BarCodeScanViewController.h"
#import "Utils.h"
#import "QROverlayView.h"
#import "ServerURL.h"
#import "FindestProj-Swift.h"

@interface BarCodeScanViewController () <UIAlertViewDelegate>
{
    QROverlayView *overlayView;
    
    AVCaptureDevice * device; 
    AVCaptureDeviceInput * input;
    AVCaptureMetadataOutput * output;
    AVCaptureSession * session;
    AVCaptureVideoPreviewLayer * preview;
}

@end

@implementation BarCodeScanViewController

- (void)dealloc {
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:@"二维码"];
    self.view.backgroundColor =  [SkinManage colorNamed:@"Page_BK_Color"];
    
    [self initSystemQRCodeScan];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initSystemQRCodeScan
{
    //判断隐私中相机是否启用
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus != AVAuthorizationStatusAuthorized && authStatus != AVAuthorizationStatusNotDetermined)
    {
        [Common tipAlert:[Common localStr:@"Common_Private_Camera" value:[NSString stringWithFormat:@"请在iPhone的“设置-隐私-相机”选项中，允许%@访问你的相机。",Constants.strAppName]]];
        return;
    }
    
    if ([[Common getDevicePlatform] isEqualToString:@"iOS Simulator"])
    {
        [Common tipAlert:[Common localStr:@"Common_Simulator_Tip" value:@"iOS模拟器不能运行相机"]];
        return;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
    {
        [Common tipAlert:[NSString stringWithFormat:@"请在iPhone的“设置-隐私-相机”选项中，允许%@访问你的相机。",Constants.strAppName]];
        return;
    }
    
    // Device
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    // Output
    output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    session = [[AVCaptureSession alloc]init];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([session canAddInput:input])
    {
        [session addInput:input];
    }
    
    if ([session canAddOutput:output])
    {
        [session addOutput:output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    // Preview
    preview =[AVCaptureVideoPreviewLayer layerWithSession:session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame =CGRectMake(0,0,kScreenWidth,kScreenHeight);
    [self.view.layer insertSublayer:preview atIndex:0];
    
    [session startRunning];
    
    overlayView = [[QROverlayView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT)];
    overlayView.rcScanArea = CGRectMake((kScreenWidth-258)/2, 66, 258, 258);
    [self.view addSubview:overlayView];
}

- (void)backButtonClicked:(BOOL)animated
{
    //stop video capture
    [self stopScanQRA];
    
    [self.navigationController popViewControllerAnimated:animated];
}

- (void)stopScanQRA
{
    if(session)
    {
        [session stopRunning];
        session = nil;
    }
    device= nil;
}

- (void)tackleCodeAction:(NSString *)strResultValue {
    //1.进入圈子详情
    NSString *strCommunityURL = [ServerURL getWholeNginxURL:@"#/v-info/"];
    NSRange range = [strResultValue rangeOfString:strCommunityURL options:NSCaseInsensitiveSearch];
    if (range.length > 0)
    {
        NSString *strPostFixUrl = [strResultValue substringFromIndex:range.location+range.length];
        NSRange rangeName = [strPostFixUrl rangeOfString:@"?name=" options:NSCaseInsensitiveSearch];
        NSString *strOrgID = [strPostFixUrl substringToIndex:rangeName.location];
        
        CommunityDetailViewController *communityDetailViewController = [[UIStoryboard storyboardWithName:@"CommunityModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CommunityDetailViewController"];
        communityDetailViewController.strOrgID = strOrgID;
        [self.navigationController pushViewController:communityDetailViewController animated:YES];
        return;
    }
    
    //2.会议签到
    NSString *strConferenceURL = @"mobile/meeting/user";
    range = [strResultValue rangeOfString:strConferenceURL options:NSCaseInsensitiveSearch];
    if (range.length > 0)
    {
        [Common showProgressView:nil view:self.view modal:NO];
        [ServerProvider signInConferenceWithQRCode:strResultValue result:^(ServerReturnInfo *retInfo) {
            [Common hideProgressView:self.view];
            if (retInfo.bSuccess)
            {
                [Common tipAlert:@"签到成功"];
                [self backButtonClicked:YES];
            }
            else
            {
                [Common tipAlert:retInfo.strErrorMsg];
                [self backButtonClicked:YES];
            }
        }];
        return;
    }
    
    //3.其他URL，统一跳转到WebView界面
    CommonWebViewController *commonWebViewController = [[UIStoryboard storyboardWithName:@"CommonWebView" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CommonWebViewController"];
    commonWebViewController.strURL = strResultValue;
    commonWebViewController.strPageType = @"BarcodeScanPage";
    [self.navigationController pushViewController:commonWebViewController animated:YES];
}

#pragma mark UIAlertView
- (void)alertView:(CustomAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1000) {
        if (buttonIndex == 1) {
            [Common showProgressView:nil view:self.view modal:NO];
            [CommunityService switchCommunity:alertView.parameter result:^(ServerReturnInfo *retInfo) {
                [Common hideProgressView:self.view];
                if (retInfo.bSuccess) {
                    //切换圈子成功，重新登录
                    [self.navigationController popToRootViewControllerAnimated:NO];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_BACKTOHOME" object: @"ReLoginNotify"];
                } else {
                    [Common tipAlert:retInfo.strErrorMsg];
                    [self backButtonClicked:YES];
                }
            }];
        } else {
            [self backButtonClicked:YES];
        }
    }
}

#pragma mark UIImagePickerControllerDelegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:NO completion:^{
        [picker removeFromParentViewController];
        [self backButtonClicked:YES];
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        NSString *strParameter = metadataObject.stringValue;
        if(strParameter.length>0)
        {
            [self stopScanQRA];
            
            //播放提示音
            SystemSoundID soundID;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"qrcode_found" ofType:@"wav"]], &soundID);
            AudioServicesPlaySystemSound(soundID);
            
            [self tackleCodeAction: strParameter];
        }
    }
}

@end
