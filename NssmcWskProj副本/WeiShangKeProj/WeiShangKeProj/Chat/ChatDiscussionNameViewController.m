//
//  ChatDiscussionNameViewController.m
//  ChinaMobileSocialProj
//
//  Created by 焱 孙 on 14-5-27.
//
//

#import "ChatDiscussionNameViewController.h"
#import "Utils.h"

@interface ChatDiscussionNameViewController ()

@end

@implementation ChatDiscussionNameViewController
@synthesize m_chatObjectVo;
@synthesize txtName;
@synthesize activity;
@synthesize imgViewWaiting;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setTopNavBarTitle:[Common localStr:@"Chat_GroupName" value:@"聊天组名称"]];
    
    UIButton *addTeamItem = [Utils buttonWithTitle:[Common localStr:@"Common_Save" value:@"保存"] frame:[Utils getNavRightBtnFrame:CGSizeMake(106,76)] target:self action:@selector(modifyDiscussionName)];
    [self setRightBarButton:addTeamItem];
    
    self.txtName = [[UITextField alloc]initWithFrame:CGRectMake(10, NAV_BAR_HEIGHT+20, kScreenWidth-20, 40)];
    self.txtName.returnKeyType = UIReturnKeyDone;
    self.txtName.borderStyle = UITextBorderStyleRoundedRect;
    self.txtName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.txtName.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.txtName becomeFirstResponder];
    self.txtName.delegate = self;
    [self.view addSubview:self.txtName];
    if (self.m_chatObjectVo.bUnnaming)
    {
        //未命名
        self.txtName.text = @"";
    }
    else
    {
        //已命名
        self.txtName.text = self.m_chatObjectVo.strGroupName;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self modifyDiscussionName];
    return YES;
}

- (void)modifyDiscussionName
{
    if(txtName.text.length == 0)
    {
        [Common tipAlert:[Common localStr:@"Chat_GroupName_Empty" value:@"聊天组名称不允许为空"]];
    }
    else if (txtName.text.length>50)
    {
        [Common tipAlert:[Common localStr:@"Chat_GroupName_WordNumMax" value:@"聊天组名称不允许超过50个字符"]];
    }
    else
    {
        [self isHideActivity:NO];
        dispatch_async(dispatch_get_global_queue(0,0),^{
            ServerReturnInfo *retInfo = [ServerProvider renameChatDiscussion:self.m_chatObjectVo andNewName:txtName.text];
            if (retInfo.bSuccess)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self isHideActivity:YES];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshChatInfoData" object:[@{@"RefreshPara":@"updateNameSuccess"} mutableCopy]];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Common tipAlert:retInfo.strErrorMsg];
                    [self isHideActivity:YES];
                });
            }
        });
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([toBeString length] > 50 && string.length > 0)
    {
        return NO;
    }
    return YES;
}

@end
