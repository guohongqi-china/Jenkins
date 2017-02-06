//
//  PublicToolView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "PublicToolView.h"

@interface PublicToolView ()
{
    NSString *strPublicType;
}

@property (weak, nonatomic) IBOutlet UIButton *btnLink;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintCenterX;
@property (weak, nonatomic) IBOutlet UIView *sepLine1;
@property (weak, nonatomic) IBOutlet UIView *sepLine2;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *albumButton;
@property (weak, nonatomic) IBOutlet UIButton *linkButton;

@end

@implementation PublicToolView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (instancetype)initWithType:(NSString *)strType
{
    self = [super init];
    if (self)
    {
        strPublicType = strType;
        [[NSBundle mainBundle] loadNibNamed:@"PublicToolView" owner:self options:nil];
        
        [self initView];
    }
    return self;
}

- (void)initView
{
    [self registerForKeyboardNotifications];
    
    if ([strPublicType isEqualToString:@"answer"])
    {
        self.constraintCenterX.constant = 46.5;
        self.btnLink.hidden = YES;
        [self.view layoutIfNeeded];
    }
    self.sepLine1.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.sepLine2.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.view.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    [self.cameraButton setImage:[SkinManage imageNamed:@"public_camera"] forState:UIControlStateNormal];
    [self.albumButton setImage:[SkinManage imageNamed:@"public_pic"] forState:UIControlStateNormal];
    [self.linkButton setImage:[SkinManage imageNamed:@"public_link"] forState:UIControlStateNormal];
    [self.linkButton setImage:[SkinManage imageNamed:@"public_link_disable"] forState:UIControlStateDisabled];
}

- (IBAction)buttonAction:(UIButton *)sender
{
    if(sender.tag == 1001)
    {
        //camera
        [self.delegate toolButtonAction:0];
    }
    else if (sender.tag == 1002)
    {
        //album
        [self.delegate toolButtonAction:1];
    }
    else
    {
        //link
        [self.delegate toolButtonAction:2];
    }
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize sizeKeyboard = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [self.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(-sizeKeyboard.height);
    }];
    [self.view.superview layoutIfNeeded];
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    [self.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(0);
    }];
    [self.view.superview layoutIfNeeded];
}

@end
