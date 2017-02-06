//
//  ChatPostImageView.m
//  Sloth
//
//  Created by 焱 孙 on 13-7-25.
//
//

#import "ChatPostImageView.h"

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
        self.backgroundColor = COLOR(0, 0, 0, 0.7);
        
        self.imgViewAlertBK = [[UIImageView alloc]initWithFrame:CGRectMake(10, 158, 300, 180)];
        self.imgViewAlertBK.image = [[UIImage imageNamed:@"paste_img_bk"] stretchableImageWithLeftCapWidth:24 topCapHeight:30];
        [self addSubview:self.imgViewAlertBK];
        
        self.imgViewPost = [[UIImageView alloc]initWithFrame:CGRectMake(125, 180, 70, 70)];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        self.imgViewPost.contentMode = UIViewContentModeScaleAspectFill;
        self.imgViewPost.clipsToBounds = YES;
        self.imgViewPost.image = pasteboard.image;
        [self addSubview:self.imgViewPost];
        
        self.btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnCancel.frame = CGRectMake(33, 278, 120, 41);
        [self.btnCancel setTitleColor:COLOR(0, 0, 0, 1.0) forState:UIControlStateNormal];
        [self.btnCancel setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
        [self.btnCancel.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0]];
        [self.btnCancel setBackgroundImage:[[UIImage imageNamed:@"cancel_btn_bk"] stretchableImageWithLeftCapWidth:22 topCapHeight:0] forState:UIControlStateNormal];
        self.btnCancel.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.btnCancel.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.btnCancel setTitle:[Common localStr:@"Common_Cancel" value:@"取消"] forState:UIControlStateNormal];
        [self.btnCancel addTarget:self action:@selector(cancelPost) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnCancel];
        
        self.btnPost = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnPost.frame = CGRectMake(167, 278, 120, 41);
        [self.btnPost setTitleColor:COLOR(255, 255, 255, 1.0) forState:UIControlStateNormal];
        [self.btnPost setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
        [self.btnPost.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0]];
        [self.btnPost setBackgroundImage:[[UIImage imageNamed:@"post_btn_bk"] stretchableImageWithLeftCapWidth:22 topCapHeight:0] forState:UIControlStateNormal];
        self.btnPost.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.btnPost.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.btnPost setTitle:[Common localStr:@"Common_NAV_Send" value:@"发送"] forState:UIControlStateNormal];
        [self.btnPost addTarget:self action:@selector(doPost) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btnPost];
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
