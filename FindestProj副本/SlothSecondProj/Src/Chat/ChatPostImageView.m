//
//  ChatPostImageView.m
//  Sloth
//
//  Created by 焱 孙 on 13-7-25.
//
//

#import "ChatPostImageView.h"
#import "UIViewExt.h"

@interface ChatPostImageView ()
{
    UIView *viewLineH;
    UIView *viewLineV;
}

@end

@implementation ChatPostImageView
@synthesize imgViewAlertBK;
@synthesize imgViewPost;
@synthesize btnCancel;
@synthesize btnPost;
@synthesize chatContentViewController;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Initialization code
        self.backgroundColor = COLOR(0, 0, 0, 0.6);
        
        self.imgViewAlertBK = [[UIView alloc]initWithFrame:CGRectMake((kScreenWidth-280)/2, (kScreenHeight-335)/2, 280, 335)];
        self.imgViewAlertBK.backgroundColor = COLOR(249, 247, 250, 1.0);
        self.imgViewAlertBK.layer.cornerRadius = 5;
        self.imgViewAlertBK.layer.masksToBounds = YES;
        [self addSubview:self.imgViewAlertBK];
        
        self.imgViewPost = [[UIImageView alloc]initWithFrame:CGRectMake(15, 20, 250, 250)];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        self.imgViewPost.contentMode = UIViewContentModeScaleAspectFit;
        self.imgViewPost.layer.borderColor = COLOR(213, 213, 214, 1.0).CGColor;
        self.imgViewPost.layer.borderWidth = 0.5;
        self.imgViewPost.layer.masksToBounds = YES;
        self.imgViewPost.clipsToBounds = YES;
        self.imgViewPost.image = pasteboard.image;
        [self.imgViewAlertBK addSubview:self.imgViewPost];
        
        viewLineH = [[UIView alloc]initWithFrame:CGRectMake(0, self.imgViewAlertBK.height-50, self.imgViewAlertBK.width, 0.5)];
        viewLineH.backgroundColor = COLOR(174, 173, 175, 1.0);
        [self.imgViewAlertBK addSubview:viewLineH];
        
        viewLineV = [[UIView alloc]initWithFrame:CGRectMake(self.imgViewAlertBK.width/2, self.imgViewAlertBK.height-50, 0.5, 50)];
        viewLineV.backgroundColor = COLOR(174, 173, 175, 1.0);
        [self.imgViewAlertBK addSubview:viewLineV];
        
        self.btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnCancel.frame = CGRectMake(0, self.imgViewAlertBK.height-50, self.imgViewAlertBK.width/2, 50);
        [self.btnCancel setTitleColor:COLOR(53, 53, 53, 1.0) forState:UIControlStateNormal];
        [self.btnCancel setTitle:[Common localStr:@"Common_Cancel" value:@"取消"] forState:UIControlStateNormal];
        self.btnCancel.titleLabel.font = [UIFont systemFontOfSize:17];
        [self.btnCancel addTarget:self action:@selector(cancelPost) forControlEvents:UIControlEventTouchUpInside];
        [self.imgViewAlertBK addSubview:self.btnCancel];
        
        self.btnPost = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnPost.frame = CGRectMake(self.btnCancel.right, self.imgViewAlertBK.height-50, self.imgViewAlertBK.width/2, 50);
        [self.btnPost setTitleColor:COLOR(9, 187, 7, 1.0) forState:UIControlStateNormal];
        self.btnPost.titleLabel.font = [UIFont systemFontOfSize:17];
        [self.btnPost setTitle:[Common localStr:@"Common_NAV_Send" value:@"发送"] forState:UIControlStateNormal];
        [self.btnPost addTarget:self action:@selector(doPost) forControlEvents:UIControlEventTouchUpInside];
        [self.imgViewAlertBK addSubview:self.btnPost];
    }
    return self;
}
//取消发送
-(void)cancelPost
{
    [self removeFromSuperview];
}

//发送
-(void)doPost
{
    [chatContentViewController postPasteImageOperate];
    [self removeFromSuperview];
}

@end
