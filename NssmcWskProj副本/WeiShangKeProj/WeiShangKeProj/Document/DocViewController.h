//
//  DocViewController.h
//  NewWeiBO
//
//  Created by 焱 孙 on 12-12-3.
//
//

#import <UIKit/UIKit.h>
#import "QNavigationViewController.h"
#import "MBProgressHUD.h"
#import <MediaPlayer/MediaPlayer.h>

typedef enum _DocType
{
    DocMediaType,
    DocImageType,
    DocTextType
}DocType;

@interface DocViewController : QNavigationViewController<UIWebViewDelegate>

@property(nonatomic,strong)UIWebView *webViewDoc;
@property(nonatomic,strong)NSURL *urlFile;
@property(nonatomic,strong)NSString *strDocName;
@property(nonatomic)DocType docType;
@property(nonatomic,strong)MPMoviePlayerViewController *playerViewController;

@end
