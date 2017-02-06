//
//  ChatPostImageView.h
//  Sloth
//
//  Created by 焱 孙 on 13-7-25.
//
//

#import <UIKit/UIKit.h>
#import "ChatContentViewController.h"

@interface ChatPostImageView : UIView

@property(nonatomic,retain)UIView *imgViewAlertBK;
@property(nonatomic,retain)UIImageView *imgViewPost;
@property(nonatomic,retain)UIButton *btnCancel;
@property(nonatomic,retain)UIButton *btnPost;

@property(nonatomic,assign)ChatContentViewController *chatContentViewController;

@end
