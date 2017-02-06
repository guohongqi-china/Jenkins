//
//  BarCodeScanViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-5-4.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "QNavigationViewController.h"

@protocol BarCodeScanViewDelegate <NSObject>
@optional
-(void)completeBarCodeScanAction:(NSString*)strResultValue;
@end

@interface BarCodeScanViewController : QNavigationViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,AVCaptureMetadataOutputObjectsDelegate>

@property(nonatomic,assign)id<BarCodeScanViewDelegate> delegate;

@end


