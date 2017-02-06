//
//  CardWebViewController.h
//  TaoZhiHuiProj
//
//  Created by fujunzhi on 16/5/10.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardWebViewController : CommonViewController
@property (weak, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSURL *urlFile;
@end
