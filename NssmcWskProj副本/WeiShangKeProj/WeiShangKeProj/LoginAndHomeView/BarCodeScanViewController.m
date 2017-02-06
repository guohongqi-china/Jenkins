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
#import "CustomTicketViewController.h"

@interface BarCodeScanViewController ()
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
    self.fd_prefersNavigationBarHidden = YES;
    
    [self setTopNavBarTitle:[Common localStr:@"Menu_SignIn" value:@"二维码"]];
    
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
        [Common tipAlert:[NSString stringWithFormat:[Common localStr:@"Common_Private_Camera" value:@"请在iPhone的“设置-隐私-相机”选项中，允许%@访问你的相机。"],[Common getAppName]]];
        return;
    }
    
    if ([[Common getDevicePlatform] isEqualToString:@"iOS Simulator"])
    {
        [Common tipAlert:[Common localStr:@"Common_Simulator_Tip" value:@"iOS模拟器不能运行相机"]];
        return;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
    {
        [Common tipAlert:[NSString stringWithFormat:[Common localStr:@"Common_Private_Camera" value:@"请在iPhone的“设置-隐私-相机”选项中，允许%@访问你的相机。"],[Common getAppName]]];
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
    
    overlayView = [[QROverlayView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT)];
    overlayView.rcScanArea = CGRectMake((kScreenWidth-220)/2, 66, 220, 220);
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
        
        if(metadataObject.stringValue.length>0)
        {
            [self stopScanQRA];
            
            //播放提示音
            SystemSoundID soundID;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"qrcode_found" ofType:@"wav"]], &soundID);
            AudioServicesPlaySystemSound(soundID);
            
            CustomTicketViewController *customTicketViewController = [[CustomTicketViewController alloc]init];
            customTicketViewController.strURL = metadataObject.stringValue;
            [self.navigationController pushViewController:customTicketViewController animated:YES];
        }
    }
}

@end
