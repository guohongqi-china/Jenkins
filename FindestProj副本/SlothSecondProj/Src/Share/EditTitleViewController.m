//
//  EditTitleViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/15.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "EditTitleViewController.h"
#import "BRPlaceholderTextView.h"

@interface EditTitleViewController ()<UITextViewDelegate>
{
    UIBarButtonItem *rightItem;
}

@property (weak, nonatomic) IBOutlet UILabel *lblTitleCount;
@property (weak, nonatomic) IBOutlet BRPlaceholderTextView *txtViewTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextH;

@end

@implementation EditTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.txtViewTitle becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.txtViewTitle resignFirstResponder];
}

- (void)initView
{
    rightItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(completeAction)];
    rightItem.tintColor = [UIColor whiteColor];
    rightItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self setTitle:@"编辑标题"];
    
    
    
    self.view.backgroundColor = [SkinManage colorNamed:@"All_textField_bg_color"];
    self.txtViewTitle.placeholder = @"标题（必填）";
    [self.txtViewTitle setPlaceholderFont:[UIFont systemFontOfSize:16]];
    
    
    
    //    _txtViewTitle.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
    //    _txtViewTitle.layer.borderWidth = 1;
    _txtViewTitle.backgroundColor = [SkinManage colorNamed:@"All_textField_bg_color"];
    _txtViewTitle.textColor = [SkinManage colorNamed:@"share_text_textColor"];
    [_txtViewTitle setPlaceholderColor:[SkinManage colorNamed:@"share_text_placeholderColor"]];
    
    _lblTitleCount.textColor = [SkinManage colorNamed:@"share_text_textColor"];
    
    
    
}

- (void)setText:(NSString *)strText
{
    self.txtViewTitle.text = strText;
    [self updateTextViewHeight];
}

- (void)completeAction
{
    [self.delegate completedEditShareTitle:self.txtViewTitle.text];
    [self backForePage];
}

//动态更新UITextView的高度
- (void)updateTextViewHeight
{
    CGFloat fContentH = [_txtViewTitle sizeThatFits:CGSizeMake(_txtViewTitle.frame.size.width, CGFLOAT_MAX)].height;
    if (fContentH > 52 && fabs(fContentH-_txtViewTitle.frame.size.height) > 0.01)//进行优化，避免每次输入都更新height
    {
        self.constraintTextH.constant = fContentH;
        [self.view layoutIfNeeded];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        return NO;
    }
    
    NSString *string = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if ([string length] > 40)
    {
        //防止输入或粘帖字数超过40
        string = [string substringToIndex:40];
        textView.text = string;
        [self updateTextViewHeight];
        return NO;
    }
    else
    {
        [self updateTextViewHeight];
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if(textView.text.length > 40)
    {
        textView.text = [textView.text substringToIndex:40];
    }
    
    self.lblTitleCount.text = [NSString stringWithFormat:@"%li/40",(unsigned long)textView.text.length];
    
    [self updateTextViewHeight];
    if (textView.text.length > 0)
    {
        rightItem.enabled = YES;
    }
    else
    {
        rightItem.enabled = NO;
    }
}

@end
