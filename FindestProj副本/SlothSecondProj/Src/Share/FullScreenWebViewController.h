//
//  FullScreenWebViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 2/10/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "QNavigationViewController.h"

@interface FullScreenWebViewController : QNavigationViewController<UIWebViewDelegate>

@property(nonatomic,strong)UIButton *btnReturn;
@property(nonatomic,retain)UIWebView *webView;
@property(nonatomic,retain)NSURL *urlFile;

@end
