//
//  MeetingBookingFormViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/21.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MeetingBookingFormViewController.h"
#import "BRPlaceholderTextView.h"
#import "MeetingBookDetailViewController.h"
#import "UserVo.h"
#import <objc/runtime.h>
@interface MeetingBookingFormViewController ()<UITextFieldDelegate,UITextViewDelegate>
{
    UIBarButtonItem *rightItem;
}

@property (weak, nonatomic) IBOutlet UITextField *txtTopic;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet BRPlaceholderTextView *txtViewRemark;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UILabel *topicLable;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *remarkLabel;
@property (weak, nonatomic) IBOutlet UIView *line1;

@property (weak, nonatomic) IBOutlet UIView *line2;

@property (weak, nonatomic) IBOutlet UIView *line3;
@end

@implementation MeetingBookingFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.viewContainer.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    
    self.txtTopic.textColor = [SkinManage colorNamed:@"metting_Tite_color"];
    self.txtName.textColor = [SkinManage colorNamed:@"metting_Tite_color"];
    self.txtPhone.textColor = [SkinManage colorNamed:@"metting_Tite_color"];
    self.txtViewRemark.textColor = [SkinManage colorNamed:@"metting_Tite_color"];
    
    self.txtTopic.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"主题" attributes:@{NSForegroundColorAttributeName: [SkinManage colorNamed:@"meetingPlacderColor"]} ];
    self.txtName.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"姓名" attributes:@{NSForegroundColorAttributeName: [SkinManage colorNamed:@"meetingPlacderColor"]} ];
    self.txtPhone.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"电话" attributes:@{NSForegroundColorAttributeName: [SkinManage colorNamed:@"meetingPlacderColor"]} ];
    
    
    self.txtViewRemark.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    
    NSString *topTitle = @"*主题";
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:topTitle];
    [str1 setAttributes:@{NSForegroundColorAttributeName:[SkinManage colorNamed:@"metting_Tite_Precolor"]} range:[topTitle rangeOfString:@"*"]];
    [str1 setAttributes:@{NSForegroundColorAttributeName:[SkinManage colorNamed:@"metting_Tite_color"]} range:NSMakeRange(1, 2)];
    
    self.topicLable.attributedText = str1;
    
    
    [str1 replaceCharactersInRange:NSMakeRange(1, 2) withString:@"姓名"];
    self.nameLabel.attributedText = str1;
    
    [str1 replaceCharactersInRange:NSMakeRange(1, 2) withString:@"电话"];
    self.phoneLabel.attributedText = str1;
    
    [str1 replaceCharactersInRange:NSMakeRange(0, 1) withString:@" "];
    [str1 replaceCharactersInRange:NSMakeRange(1, 2) withString:@"备注"];
    self.remarkLabel.attributedText = str1;
    
    self.line1.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.line2.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.line3.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    
    
    
    self.isNeedBackItem = YES;
    [self setTitle:@"填写会议信息"];
    
    rightItem = [self rightBtnItemWithTitle:@"完成"];
    rightItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = rightItem;
    
    _txtName.text = [Common getCurrentUserVo].strRealName;
    _txtPhone.text = [Common getCurrentUserVo].strPhoneNumber;
    
    _txtViewRemark.placeholder = @"备注";
    [_txtViewRemark setPlaceholderColor:[SkinManage colorNamed:@"meetingPlacderColor"]];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundTap)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)righBarClick
{
    self.bookVo.strTitle = _txtTopic.text;
    self.bookVo.strUserName = _txtName.text;
    self.bookVo.strContact = _txtPhone.text;
    self.bookVo.strRemark = _txtViewRemark.text;
    
    MeetingBookDetailViewController *meetingBookDetailViewController = [[UIStoryboard storyboardWithName:@"MeetingBooking" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MeetingBookDetailViewController"];
    meetingBookDetailViewController.bookVo = self.bookVo;
    [self.navigationController pushViewController:meetingBookDetailViewController animated:YES];
}

-(void)backgroundTap
{
    for(UIView*view in[self.viewContainer subviews])
    {
        if([view isFirstResponder])
        {
            [view resignFirstResponder];
            return;
        }
    }
}

- (IBAction)textFieldEditingChanged:(id)sender
{
    if(_txtTopic.text.length == 0)
    {
        rightItem.enabled = NO;
        return;
    }
    
    if(_txtName.text.length == 0)
    {
        rightItem.enabled = NO;
        return;
    }
    
    if(_txtPhone.text.length == 0)
    {
        rightItem.enabled = NO;
        return;
    }
    
    rightItem.enabled = YES;
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txtTopic)
    {
        [_txtName becomeFirstResponder];
    }
    else if (textField == _txtName)
    {
        [_txtPhone becomeFirstResponder];
    }
    else if (textField == _txtPhone)
    {
        [_txtViewRemark becomeFirstResponder];
    }
    return YES;
}


@end
