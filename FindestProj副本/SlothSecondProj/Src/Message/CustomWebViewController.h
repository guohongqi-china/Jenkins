//
//  CustomWebViewController.h
//  Sloth
//
//  Created by 焱 孙 on 13-3-5.
//fv
//

#import <UIKit/UIKit.h>
#import "QNavigationViewController.h"
@interface CustomWebViewController : QNavigationViewController<UIWebViewDelegate>

@property(nonatomic,retain)UIWebView *webView;
@property(nonatomic,retain)NSURL *urlFile;
@property(nonatomic)BOOL bNeedFresh;

@end
