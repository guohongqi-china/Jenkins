//
//  CertificateUploadViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/6.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "AttachmentVo.h"

@interface CertificateUploadViewController : QNavigationViewController

@end

@interface CertificateUploadVo : NSObject

@property (nonatomic) NSInteger nType;  //0:行驶证,1:驾照,2:身份证
@property (nonatomic,strong) NSString *strTypeName;
@property (nonatomic,strong) AttachmentVo *attach;

@end
