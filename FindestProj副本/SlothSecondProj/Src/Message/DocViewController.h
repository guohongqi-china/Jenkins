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

@property(nonatomic,retain)UIWebView *webViewDoc;
@property(nonatomic,retain)NSURL *urlFile;
@property(nonatomic,retain)NSString *strDocName;
@property(nonatomic,assign)DocType docType;
@property(nonatomic,retain)MPMoviePlayerViewController *playerViewController;

@end
