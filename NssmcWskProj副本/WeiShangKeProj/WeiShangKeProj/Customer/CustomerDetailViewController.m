//
//  CustomerDetailViewController.m
//  WeiShangKeProj
//
//  Created by 焱 孙 on 4/29/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "CustomerDetailViewController.h"
#import "Utils.h"
#import "UIViewExt.h"
#import "UIImage+Extras.h"
#import "UIImageView+WebCache.h"
#import "TicketListViewController.h"
#import "SessionDetailViewController.h"

@interface CustomerDetailViewController ()

@end

@implementation CustomerDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)initView
{
    [self setTopNavBarTitle:@"客户信息"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.dicOffsetY = [[NSMutableDictionary alloc]init];
    
    //右边按钮
    UIButton *btnEdit = [Utils buttonWithImageName:[UIImage imageNamed:@"nav_save"] frame:[Utils getNavRightBtnFrame:CGSizeMake(100,76)] target:self action:@selector(doCommit)];
    btnEdit.hidden = YES;
    [self setRightBarButton:btnEdit];
    
    self.m_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT)];
    self.m_scrollView.autoresizingMask = NO;
    self.m_scrollView.clipsToBounds = YES;
    [self.view addSubview:self.m_scrollView];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, -kScreenHeight, kScreenWidth, kScreenHeight)];
    [topView setBackgroundColor:THEME_COLOR];
    [self.m_scrollView addSubview:topView];
    
    CGFloat fHeight = 0.0;
    
    //head
    self.viewHeadTop = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 150)];
    self.viewHeadTop.backgroundColor = THEME_COLOR;
    [self.m_scrollView addSubview:self.viewHeadTop];
    
    self.imgViewHead = [[UIImageView alloc]initWithFrame:CGRectMake((kScreenWidth-94)/2, (self.viewHeadTop.height-94)/2, 94, 94)];
    [self.imgViewHead.layer setBorderWidth:1.0];
    [self.imgViewHead.layer setCornerRadius:47];
    self.imgViewHead.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.imgViewHead.layer setMasksToBounds:YES];
    [self.viewHeadTop addSubview:self.imgViewHead];
    [self.imgViewHead sd_setImageWithURL:[NSURL URLWithString:self.m_customerVo.strHeadImageURL] placeholderImage:[UIImage imageNamed:@"default_m"]];
    fHeight += 150;
    
    //session and ticket button
    self.btnTicket = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnTicket setImage:[UIImage imageNamed:@"customer_ticket_icon"] forState:UIControlStateNormal];
    self.btnTicket.frame = CGRectMake(kScreenWidth-50, fHeight-40, 50, 40);
    self.btnTicket.imageEdgeInsets = UIEdgeInsetsMake(7.5, 12.5, 7.5, 12.5);
    [self.btnTicket addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.btnTicket.hidden = YES;
    [self.m_scrollView addSubview:self.btnTicket];
    
    self.btnSessionDetail = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnSessionDetail setImage:[UIImage imageNamed:@"customer_session_icon"] forState:UIControlStateNormal];
    self.btnSessionDetail.frame = CGRectMake(self.btnTicket.left-50, fHeight-40, 50, 40);
    self.btnSessionDetail.imageEdgeInsets = UIEdgeInsetsMake(7.5, 12.5, 7.5, 12.5);
    [self.btnSessionDetail addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.btnSessionDetail.hidden = YES;
    [self.m_scrollView addSubview:self.btnSessionDetail];
    
//    [self.btnTicket setBackgroundImage:[Common getImageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
//    [self.btnSessionDetail setBackgroundImage:[Common getImageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
    
    //name
    self.imgViewName = [[UIImageView alloc]initWithFrame:CGRectMake(14, fHeight+10, 25, 25)];
    self.imgViewName.image = [UIImage imageNamed:@"customer_name"];
    [self.m_scrollView addSubview:self.imgViewName];
    
    self.txtName = [[UITextField alloc]initWithFrame:CGRectMake(55,fHeight+12.5, kScreenWidth-65,20)];
    self.txtName.font = [UIFont fontWithName:APP_FONT_NAME size:15];
    self.txtName.textColor = COLOR(51, 51, 51, 1.0);
    self.txtName.placeholder = @"客户姓名";
    self.txtName.text = self.m_customerVo.strName;
    self.txtName.delegate = self;
    self.txtName.tag = 501;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"501"];
    [self.m_scrollView addSubview:self.txtName];
    
    self.viewLineName = [[UIView alloc]initWithFrame:CGRectMake(55, fHeight+45, kScreenWidth-55, 0.5)];
    self.viewLineName.backgroundColor = COLOR(201, 201, 201, 1.0);
    [self.m_scrollView addSubview:self.viewLineName];
    fHeight += 45.5;
    
    //code
    self.imgViewCode = [[UIImageView alloc]initWithFrame:CGRectMake(14, fHeight+10, 25, 25)];
    self.imgViewCode.image = [UIImage imageNamed:@"customer_code"];
    [self.m_scrollView addSubview:self.imgViewCode];
    
    self.txtCode = [[UITextField alloc]initWithFrame:CGRectMake(55,fHeight+12.5, kScreenWidth-65,20)];
    self.txtCode.font = [UIFont fontWithName:APP_FONT_NAME size:15];
    self.txtCode.textColor = COLOR(51, 51, 51, 1.0);
    self.txtCode.placeholder = @"客户编号";
    self.txtCode.text = self.m_customerVo.strCode;
    self.txtCode.delegate = self;
    self.txtCode.tag = 502;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"502"];
    [self.m_scrollView addSubview:self.txtCode];
    
    self.viewLineCode = [[UIView alloc]initWithFrame:CGRectMake(55, fHeight+45, kScreenWidth-55, 0.5)];
    self.viewLineCode.backgroundColor = COLOR(201, 201, 201, 1.0);
    [self.m_scrollView addSubview:self.viewLineCode];
    fHeight += 45.5;
    
    //phone
    self.imgViewPhone = [[UIImageView alloc]initWithFrame:CGRectMake(14, fHeight+10, 25, 25)];
    self.imgViewPhone.image = [UIImage imageNamed:@"customer_phone"];
    [self.m_scrollView addSubview:self.imgViewPhone];
    
    self.txtPhone = [[UITextField alloc]initWithFrame:CGRectMake(55,fHeight+12.5, kScreenWidth-65,20)];
    self.txtPhone.font = [UIFont fontWithName:APP_FONT_NAME size:15];
    self.txtPhone.textColor = COLOR(51, 51, 51, 1.0);
    self.txtPhone.placeholder = @"手机号";
    self.txtPhone.text = self.m_customerVo.strPhone;
    self.txtPhone.delegate = self;
    self.txtPhone.tag = 503;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"503"];
    [self.m_scrollView addSubview:self.txtPhone];
    
    self.viewLinePhone = [[UIView alloc]initWithFrame:CGRectMake(55, fHeight+45, kScreenWidth-55, 0.5)];
    self.viewLinePhone.backgroundColor = COLOR(201, 201, 201, 1.0);
    [self.m_scrollView addSubview:self.viewLinePhone];
    fHeight += 45.5;
    
    //mail
    self.imgViewEmail = [[UIImageView alloc]initWithFrame:CGRectMake(14, fHeight+10, 25, 25)];
    self.imgViewEmail.image = [UIImage imageNamed:@"customer_email"];
    [self.m_scrollView addSubview:self.imgViewEmail];
    
    self.txtEmail = [[UITextField alloc]initWithFrame:CGRectMake(55,fHeight+12.5, kScreenWidth-65,20)];
    self.txtEmail.font = [UIFont fontWithName:APP_FONT_NAME size:15];
    self.txtEmail.textColor = COLOR(51, 51, 51, 1.0);
    self.txtEmail.placeholder = @"邮箱";
    self.txtEmail.text = self.m_customerVo.strEmail;
    self.txtEmail.delegate = self;
    self.txtEmail.tag = 504;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"504"];
    [self.m_scrollView addSubview:self.txtEmail];
    
    self.viewLineEmail = [[UIView alloc]initWithFrame:CGRectMake(55, fHeight+45, kScreenWidth-55, 0.5)];
    self.viewLineEmail.backgroundColor = COLOR(201, 201, 201, 1.0);
    [self.m_scrollView addSubview:self.viewLineEmail];
    fHeight += 45.5;
    
    //remark
    self.imgViewRemark = [[UIImageView alloc]initWithFrame:CGRectMake(14, fHeight+10, 25, 25)];
    self.imgViewRemark.image = [UIImage imageNamed:@"customer_remark"];
    [self.m_scrollView addSubview:self.imgViewRemark];
    
    self.txtViewRemark = [[UITextView alloc]initWithFrame:CGRectMake(55, fHeight, kScreenWidth-65,80)];
    self.txtViewRemark.font = [UIFont fontWithName:APP_FONT_NAME size:15];
    self.txtViewRemark.textColor = COLOR(0, 0, 0, 1.0);
    self.txtViewRemark.delegate = self;
    self.txtViewRemark.text = self.m_customerVo.strRemark;
    self.txtViewRemark.tag = 505;
    [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+15] forKey:@"505"];
    [self.m_scrollView addSubview:self.txtViewRemark];
    
    self.viewLineRemark = [[UIView alloc]initWithFrame:CGRectMake(55, fHeight+80, kScreenWidth-55, 0.5)];
    self.viewLineRemark.backgroundColor = COLOR(201, 201, 201, 1.0);
    [self.m_scrollView addSubview:self.viewLineRemark];
    fHeight += 80.5;
    
    fHeight += 255;
    [self.m_scrollView setContentSize:CGSizeMake(kScreenWidth, fHeight)];
    
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundTap)];
    [self.m_scrollView addGestureRecognizer:tapGestureRecognizer1];
    
    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundTap)];
    [self.view addGestureRecognizer:tapGestureRecognizer2];
}

- (void)initData
{
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        //do thread work
        ServerReturnInfo *retInfo = [ServerProvider getCustomerDetail:self.m_customerVo.strID];
        if (retInfo.bSuccess)
        {
            self.m_customerVo = retInfo.data;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self isHideActivity:YES];
                [self refreshView];
            });
        }
    });
}

- (void)refreshView
{
    [self.imgViewHead sd_setImageWithURL:[NSURL URLWithString:self.m_customerVo.strHeadImageURL] placeholderImage:[UIImage imageNamed:@"default_m"]];
    
    //name
    self.txtName.text = self.m_customerVo.strName;
    
    //code
    self.txtCode.text = self.m_customerVo.strCode;
    
    //phone
    self.txtPhone.text = self.m_customerVo.strPhone;
    
    //mail
    self.txtEmail.text = self.m_customerVo.strEmail;
    
    //remark
    self.txtViewRemark.text = self.m_customerVo.strRemark;
    
    if (self.m_customerVo.chatObjectVo == nil)
    {
        self.btnTicket.hidden = YES;
        self.btnSessionDetail.hidden = YES;
    }
    else
    {
        self.btnTicket.hidden = NO;
        self.btnSessionDetail.hidden = NO;
    }
}

-(void)doCommit
{
    if (self.m_customerVo == nil)
    {
        [Common bubbleTip:@"修改客户信息失败" andView:self.view];
        return;
    }
    
    CustomerVo *customerVo = [[CustomerVo alloc]init];
    customerVo.strID = self.m_customerVo.strID;
    
    customerVo.strName = self.txtName.text;
    if (customerVo.strName .length == 0)
    {
        [Common bubbleTip:@"客户姓名不能为空" andView:self.view];
        return;
    }
    
    customerVo.strCode = self.txtCode.text;
    if (customerVo.strCode.length == 0)
    {
        [Common bubbleTip:@"客户编号不能为空" andView:self.view];
        return;
    }
    
    customerVo.strPhone = self.txtPhone.text;
    if (customerVo.strPhone.length == 0)
    {
        [Common bubbleTip:@"电话不能为空" andView:self.view];
        return;
    }
    
    customerVo.strEmail = self.txtEmail.text;
    if (customerVo.strEmail.length == 0)
    {
        [Common bubbleTip:@"邮箱不能为空" andView:self.view];
        return;
    }
    
    customerVo.strHeadImageURL = self.m_customerVo.strHeadImageURL;
    
    customerVo.strRemark = self.txtViewRemark.text;
    
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        //do thread work
        ServerReturnInfo *retInfo = [ServerProvider updateCustomer:customerVo];
        if (retInfo.bSuccess)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Common bubbleTip:@"成功修改客户信息" andView:self.view];
                [self backgroundTap];
                self.btnRightNav.hidden = YES;
                self.bModifyInfo = YES;
                [self isHideActivity:YES];
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

-(void)backgroundTap
{
    for(UIView*view in[self.m_scrollView subviews])
    {
        if([view isFirstResponder])
        {
            [view resignFirstResponder];
            return;
        }
    }
}

- (void)backButtonClicked
{
    if (self.bModifyInfo)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"UpdateCustomerList" object:nil];
    }
    
    [super backButtonClicked];
}

//调整键盘高度
-(void)fieldOffset:(NSUInteger)nTextTag
{
    //获取特定的UITextField偏移量
    float offset = [[self.dicOffsetY objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)nTextTag]] floatValue];
    //当前scrollView 偏移量
    float scrollOffset = self.m_scrollView.contentOffset.y;
    
    //键盘标准高度值
    float fHeighKey = kScreenHeight-NAV_BAR_HEIGHT-252;//中文键盘252
    //控件当前高度值（本身高度-scrollview滚动高度）
    float fCtrlHeight = offset-scrollOffset;
    
    if (fCtrlHeight>fHeighKey)
    {
        //被键盘遮挡，需要滚动到最上方
        [self.m_scrollView setContentOffset:CGPointMake(0, (offset-80)) animated:YES];//offset-10
    }
}

-(void)buttonAction:(UIButton*)sender
{
//    if (sender == self.btnTicket)
//    {
//        TicketListViewController *ticketListViewController = [[TicketListViewController alloc]init];
//        ticketListViewController.ticketListType = TicketListCustomerType;
//        ticketListViewController.m_chatObjectVo = self.m_customerVo.chatObjectVo;
//        [self.navigationController pushViewController:ticketListViewController animated:YES];
//    }
//    else
//    {
//        SessionDetailViewController *sessionDetailViewController = [[SessionDetailViewController alloc] init];
//        sessionDetailViewController.m_chatObjectVo = self.m_customerVo.chatObjectVo;
//        sessionDetailViewController.refreshSessionBlock = nil;
//        [self.navigationController pushViewController:sessionDetailViewController animated:YES];
//    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //编辑时调整view
    [self fieldOffset:textField.tag];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.btnRightNav.hidden = NO;
    return YES;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //编辑时调整view
    [self fieldOffset:textView.tag];
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.btnRightNav.hidden = NO;
}

@end
