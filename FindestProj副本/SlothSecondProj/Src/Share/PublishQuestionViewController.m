//
//  PublishQuestionViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/2.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "PublishQuestionViewController.h"
#import "BRPlaceholderTextView.h"
#import "PublishVo.h"
#import "UIViewExt.h"

@interface PublishQuestionViewController ()
{
    UIBarButtonItem *rightItem;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewPublish;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIView *sepLine;
@property (weak, nonatomic) IBOutlet BRPlaceholderTextView *txtTitle;
@property (weak, nonatomic) IBOutlet BRPlaceholderTextView *txtContent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTitleH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintContentH;

@end

@implementation PublishQuestionViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_BACKTOHOME object:nil];
}

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
    self.isNeedBackItem = NO;
    self.title = @"发问题";
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked)];
    leftItem.tintColor = [SkinManage colorNamed:@"Nav_Btn_label_Color"];    self.navigationItem.leftBarButtonItem = leftItem;
    
    rightItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(publicAction)];
    rightItem.tintColor = [SkinManage colorNamed:@"Nav_Btn_label_Color"];
    rightItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.txtTitle.placeholder = @"请写下你的问题并用问号结尾";
    [self.txtTitle setPlaceholderColor:[SkinManage colorNamed:@"share_text_placeholderColor"]];
    [self.txtTitle setPlaceholderFont:[UIFont systemFontOfSize:16]];
    
    
    self.txtContent.placeholder = @"请填写问题相关描述信息";
    [self.txtContent setPlaceholderColor:[SkinManage colorNamed:@"share_text_placeholderColor"]];
    [self.txtContent setPlaceholderFont:[UIFont systemFontOfSize:16]];
    
    [self.txtTitle becomeFirstResponder];
    
    self.viewContainer.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.sepLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.txtTitle.textColor = [SkinManage colorNamed:@"share_text_textColor"];
    self.txtContent.textColor = [SkinManage colorNamed:@"share_text_textColor"];
    
    
    self.txtContent.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.txtTitle.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToHome) name:NOTIFY_BACKTOHOME object:nil];
}

- (void)backToHome {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)backButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)publicAction
{
    PublishVo *publishVo = [[PublishVo alloc]init];
    //title
    publishVo.streamTitle = self.txtTitle.text;
    
    //content
    publishVo.streamContent = self.txtContent.text;
    
    //ComeFromType
    publishVo.streamComefrom = 2;
    publishVo.isDraft = 0;
    
    //post action
    [Common showProgressView:nil view:self.view modal:NO];
    [ServerProvider addQuest:publishVo result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshShareList" object:nil];
            [self backButtonClicked];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
    
}

//动态更新UITextView的高度
- (void)updateTextViewHeight:(BRPlaceholderTextView *)textView
{
    CGFloat fContentH = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, CGFLOAT_MAX)].height;
    
    if (textView == self.txtTitle)
    {
        if (fContentH > 36 && fabs(fContentH-textView.frame.size.height) > 0.01)//进行优化，避免每次输入都更新height
        {
            self.constraintTitleH.constant = fContentH;
            [self.view layoutIfNeeded];
            
            [self fieldOffset:textView];
        }
    }
    else
    {
        if (fContentH > 200 && fabs(fContentH-textView.frame.size.height) > 0.01)//进行优化，避免每次输入都更新height
        {
            self.constraintContentH.constant = fContentH;
            [self.view layoutIfNeeded];
            
            [self fieldOffset:textView];
        }
    }
}

//调整键盘高度
-(void)fieldOffset:(UIView *)subView
{
    //获取特定subView相对于容器的布局height
    float fViewHeight = subView.top+subView.height;
    
    //当前scrollView 偏移量
    float fScrollOffset = self.scrollViewPublish.contentOffset.y;
    
    //可视界面的范围(0~fVisibleHeigh),假定容器从底部开始布局
    float fVisibleHeigh = self.scrollViewPublish.height-278;//中文键盘258+20
    
    //控件当前高度值（从屏幕顶部开始计算）
    float fCurrHeight = fViewHeight-fScrollOffset;
    
    //当subView超过了可见范围，则滚动scrollView
    if (fCurrHeight>fVisibleHeigh)
    {
        [self.scrollViewPublish setContentOffset:CGPointMake(0, fViewHeight-fVisibleHeigh) animated:YES];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView == self.txtTitle)
    {
        if ([text isEqualToString:@"\n"])
        {
            return NO;
        }
    }
    
    [self updateTextViewHeight:(BRPlaceholderTextView *)textView];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateTextViewHeight:(BRPlaceholderTextView *)textView];
    
    if (self.txtTitle.text.length > 0 && self.txtContent.text.length > 0)
    {
        rightItem.enabled = YES;
    }
    else
    {
        rightItem.enabled = NO;
    }
}

@end
