//
//  CheXiangService.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/6.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerProvider.h"
#import "ServerReturnInfo.h"
#import "ServerURL.h"
#import "AttachmentVo.h"
#import "JobVo.h"

@interface CheXiangService : NSObject

+ (void)uploadCertificatePhoto:(NSString *)strPath type:(NSInteger)nType result:(ResultBlock)resultBlock;

+ (void)loginToCheXiangServer:(NSString *)strAccount pwd:(NSString *)strPwd result:(ResultBlock)resultBlock;;

+ (void)unbindCheXiangAccount:(ResultBlock)resultBlock;

+ (void)uploadWeixinCardPhoto:(NSString *)strPath result:(ResultBlock)resultBlock;

+ (void)verifyCheXiangAccount:(ResultBlock)resultBlock;

+ (void)getMyJobListByType:(NSInteger)nType result:(ResultBlock)resultBlock;

+ (void)editChexiangJob:(NSString *)strID type:(NSInteger)nType result:(ResultBlock)resultBlock;

@end
