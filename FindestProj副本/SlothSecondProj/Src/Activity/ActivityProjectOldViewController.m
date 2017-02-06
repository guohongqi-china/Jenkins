//
//  ActivityProjectOldViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 14-5-29.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "ActivityProjectOldViewController.h"
#import "SDWebImageDataSource.h"
#import "SDWebImageManager.h"
#import "KTPhotoScrollViewController.h"
#import "UserVo.h"
#import "Common.h"
#import "SkinManage.h"
#import "ActivityService.h"

@interface ActivityProjectOldViewController ()

@end

@implementation ActivityProjectOldViewController

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
    self.imgProject = nil;
    self.dicOffsetY = [[NSMutableDictionary alloc]init];
    
    [self initView];
    [self refreshData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshData
{
//    if (self.m_activityProjectVo == nil)
//    {
//        [Common tipAlert:@"数据异常，请求失败"];
//        return;
//    }
//    
//    [self isHideActivity:NO];
//    [ActivityService getActivityProjectByID:self.m_activityProjectVo.strID result:^(ServerReturnInfo *retInfo) {
//        [self isHideActivity:YES];
//        if (retInfo.bSuccess)
//        {
//            self.m_activityProjectVo = retInfo.data;
//            [self refreshView];
//        }
//        else
//        {
//            [Common tipAlert:retInfo.strErrorMsg];
//        }
//    }];
}

- (void)initView
{
    [self setTopNavBarTitle:@"活动报名"];
    self.view.backgroundColor = COLOR(242, 242, 242, 1.0);
    
    //UIScrollView
    self.m_scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT)];
    self.m_scrollView.backgroundColor = [UIColor clearColor];
    self.m_scrollView.autoresizingMask = NO;
    self.m_scrollView.clipsToBounds = YES;
    [self.view addSubview:self.m_scrollView];
    
    //0. container
    self.viewBK = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewBK.backgroundColor = [UIColor whiteColor];
    self.viewBK.layer.borderColor = [COLOR(211, 211, 211, 1.0) CGColor];
    [self.viewBK.layer setBorderWidth:0.5];
	[self.viewBK.layer setCornerRadius:6];
	[self.viewBK.layer setMasksToBounds:YES];
    [self.m_scrollView addSubview:self.viewBK];
    
    //1. 标题
    self.lblProjectName = [[UILabel alloc]init];
    self.lblProjectName.font = [UIFont boldSystemFontOfSize:16];
    self.lblProjectName.numberOfLines = 0;
    self.lblProjectName.textColor = COLOR(0, 0, 0, 1.0);
    [self.m_scrollView addSubview:self.lblProjectName];
    
    self.lblProjectDateTime = [[UILabel alloc]init];
    self.lblProjectDateTime.font = [UIFont systemFontOfSize:14];
    self.lblProjectDateTime.numberOfLines = 2;
    self.lblProjectDateTime.textColor = COLOR(138, 138, 138, 1.0);
    self.lblProjectDateTime.lineBreakMode = NSLineBreakByWordWrapping;
    [self.m_scrollView addSubview:self.lblProjectDateTime];
    
    //2. lineview
    self.viewLine1 = [[UIView alloc]init];
    self.viewLine1.backgroundColor = COLOR(204, 204, 204, 1.0);
    [self.m_scrollView addSubview:self.viewLine1];
    
    //3.image content
    self.imgViewProject = [[UIImageView alloc]init];
    self.imgViewProject.userInteractionEnabled = YES;
    [self.imgViewProject.layer setMasksToBounds:YES];
    [self.imgViewProject.layer setBorderWidth:1.0];
    [self.imgViewProject.layer setCornerRadius:2];
    self.imgViewProject.layer.borderColor = [[UIColor clearColor]CGColor];
    [self.m_scrollView addSubview:self.imgViewProject];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
    tap.delegate = self;
    [self.imgViewProject addGestureRecognizer:tap];
    
    //project desc
    self.lblProjectDesc = [[UILabel alloc]init];
    self.lblProjectDesc.font = [UIFont boldSystemFontOfSize:15];
    self.lblProjectDesc.textColor = COLOR(84, 84, 84, 1.0);
    self.lblProjectDesc.backgroundColor = [UIColor clearColor];
    self.lblProjectDesc.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblProjectDesc.numberOfLines = 0;
    self.lblProjectDesc.text = @"描述：";
    [self.m_scrollView addSubview:self.lblProjectDesc];
    
    //4. 报名操作
    self.viewSignupBK = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewSignupBK.backgroundColor = COLOR(230, 230, 230, 1.0);
    self.viewSignupBK.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.viewSignupBK.layer setBorderWidth:0.5];
	[self.viewSignupBK.layer setCornerRadius:6];
	[self.viewSignupBK.layer setMasksToBounds:YES];
    [self.m_scrollView addSubview:self.viewSignupBK];
    
    self.lblRealName = [[UILabel alloc]init];
    self.lblRealName.font = [UIFont boldSystemFontOfSize:15];
    self.lblRealName.textColor = COLOR(84, 84, 84, 1.0);
    self.lblRealName.backgroundColor = [UIColor clearColor];
    self.lblRealName.text = @"真实姓名";
    [self.viewSignupBK addSubview:self.lblRealName];
    
    self.txtRealName = [[InsetsTextField alloc]initWithFrame:CGRectZero];
    self.txtRealName.background = [UIImage imageNamed:@"txt_signup_bk"];
    self.txtRealName.delegate = self;
    self.txtRealName.font = [UIFont systemFontOfSize:15.0];
    self.txtRealName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.viewSignupBK addSubview:self.txtRealName];
    
    self.lblPhoneNum = [[UILabel alloc]init];
    self.lblPhoneNum.font = [UIFont boldSystemFontOfSize:15];
    self.lblPhoneNum.textColor = COLOR(84, 84, 84, 1.0);
    self.lblPhoneNum.backgroundColor = [UIColor clearColor];
    self.lblPhoneNum.text = @"电话号码";
    [self.viewSignupBK addSubview:self.lblPhoneNum];
    
    self.txtPhoneNum = [[InsetsTextField alloc]initWithFrame:CGRectZero];
    self.txtPhoneNum.background = [UIImage imageNamed:@"txt_signup_bk"];
    self.txtPhoneNum.delegate = self;
    self.txtPhoneNum.keyboardType = UIKeyboardTypePhonePad;
    self.txtPhoneNum.font = [UIFont systemFontOfSize:15.0];
    self.txtPhoneNum.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.viewSignupBK addSubview:self.txtPhoneNum];
    
    self.lblWorkUnit = [[UILabel alloc]init];
    self.lblWorkUnit.font = [UIFont boldSystemFontOfSize:15];
    self.lblWorkUnit.textColor = COLOR(84, 84, 84, 1.0);
    self.lblWorkUnit.backgroundColor = [UIColor clearColor];
    self.lblWorkUnit.text = @"所属单位";
    [self.viewSignupBK addSubview:self.lblWorkUnit];
    
    self.txtWorkUnit = [[InsetsTextField alloc]initWithFrame:CGRectZero];
    self.txtWorkUnit.background = [UIImage imageNamed:@"txt_signup_bk"];
    self.txtWorkUnit.delegate = self;
    self.txtWorkUnit.font = [UIFont systemFontOfSize:15.0];
    self.txtWorkUnit.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.viewSignupBK addSubview:self.txtWorkUnit];
    
    self.lblPosition = [[UILabel alloc]init];
    self.lblPosition.font = [UIFont boldSystemFontOfSize:15];
    self.lblPosition.textColor = COLOR(84, 84, 84, 1.0);
    self.lblPosition.backgroundColor = [UIColor clearColor];
    self.lblPosition.text = @"职位名称";
    [self.viewSignupBK addSubview:self.lblPosition];
    
    self.txtPosition = [[InsetsTextField alloc]initWithFrame:CGRectZero];
    self.txtPosition.background = [UIImage imageNamed:@"txt_signup_bk"];
    self.txtPosition.delegate = self;
    self.txtPosition.font = [UIFont systemFontOfSize:15.0];
    self.txtPosition.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.viewSignupBK addSubview:self.txtPosition];
    
    self.btnSignup = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnSignup setTitleColor:COLOR(255, 255, 255, 1.0) forState:UIControlStateNormal];
    [self.btnSignup setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [self.btnSignup.titleLabel setFont:[UIFont boldSystemFontOfSize:23]];
    [self.btnSignup setBackgroundImage:[SkinManage imageNamed:@"activity_project_state"] forState:UIControlStateNormal];
    [self.btnSignup addTarget:self action:@selector(signupActivity) forControlEvents:UIControlEventTouchUpInside];
    
    //已报名用户
    self.tableViewUser = [[UITableView alloc]init];
    self.tableViewUser.dataSource = self;
    self.tableViewUser.delegate = self;
    self.tableViewUser.backgroundColor = [UIColor clearColor];
    [self.m_scrollView addSubview:self.tableViewUser];
    if ([self.tableViewUser respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.tableViewUser setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
}

- (void)refreshView
{
    if (self.m_activityProjectVo == nil)
    {
        return;
    }
    
    CGFloat fHeight = 28;
    
    //title and date time
    self.lblProjectName.text = self.m_activityProjectVo.strProjectName;
    CGSize sizeTitle = [Common getStringSize:self.lblProjectName.text font:self.lblProjectName.font bound:CGSizeMake(kScreenWidth-50, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    self.lblProjectName.frame = CGRectMake(25,fHeight,kScreenWidth-50,sizeTitle.height);
    fHeight += sizeTitle.height;
    
    fHeight += 5;
    self.lblProjectDateTime.text = [NSString stringWithFormat:@"报名开始时间：%@ \r\n报名结束时间：%@",self.m_activityProjectVo.strStartDateTime,self.m_activityProjectVo.strEndDateTime];
    self.lblProjectDateTime.frame = CGRectMake(25,fHeight,kScreenWidth-50,40);
    fHeight += 40;
    
    //lineview
    fHeight += 5;
    self.viewLine1.frame = CGRectMake(25, fHeight, kScreenWidth-50, 0.5);
    
    //image content
    fHeight += 10;
    UIImage *imgTemp = [UIImage imageNamed:@"default_image"];
    if (self.imgProject == nil)
    {
        //加载网络图片
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:self.m_activityProjectVo.strMaxImageURL] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
            if (image && finished)
            {
                self.imgProject = image;
                [self refreshView];//再次刷新,有递归调用，造成显示图片显示不出来
            }
        }];
        
        //停止第一次的调用
        if (self.imgProject != nil)
        {
            return;
        }
    }
    else
    {
        imgTemp = self.imgProject;
    }
    CGFloat fImageH = imgTemp.size.height*(kScreenWidth-50)/imgTemp.size.width;
    self.imgViewProject.image = imgTemp;
    self.imgViewProject.frame = CGRectMake(25, fHeight, kScreenWidth-50, fImageH);
    fHeight += self.imgViewProject.frame.size.height;
    
    //project desc
    if (self.m_activityProjectVo.strProjectDesc.length>0)
    {
        fHeight += 20;
        NSString *strProjectDesc = self.m_activityProjectVo.strProjectDesc;
        self.lblProjectDesc.text = strProjectDesc;
        CGSize sizeProjectDesc = [Common getStringSize:self.lblProjectDesc.text font:self.lblProjectDesc.font bound:CGSizeMake(kScreenWidth-50, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        self.lblProjectDesc.frame = CGRectMake(25,fHeight,kScreenWidth-50,sizeProjectDesc.height);
        fHeight += sizeProjectDesc.height;
    }
    
    //报名操作
    if (self.m_activityProjectVo.nStatus == 3 && ![self isSignupThisActivity])
    {
        //报名状态处于“报名正在进行”，并且自己没有报过名
        fHeight += 20;
        self.viewSignupBK.frame = CGRectMake(25, fHeight, kScreenWidth-50, 336);
        
        CGFloat fSignupH = 0;
        self.lblRealName.frame = CGRectMake(20, fSignupH+10, kScreenWidth-70, 16);
        self.txtRealName.frame = CGRectMake(20, fSignupH+35, kScreenWidth-90, 28);
        self.txtRealName.tag = 501;
        [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+fSignupH+35] forKey:@"501"];
        
        fSignupH += 63;
        self.lblPhoneNum.frame = CGRectMake(20, fSignupH+10, kScreenWidth-70, 16);
        self.txtPhoneNum.frame = CGRectMake(20, fSignupH+35, kScreenWidth-90, 28);
        self.txtPhoneNum.tag = 502;
        [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+fSignupH+35] forKey:@"502"];
        
        fSignupH += 63;
        self.lblWorkUnit.frame = CGRectMake(20, fSignupH+10, kScreenWidth-70, 16);
        self.txtWorkUnit.frame = CGRectMake(20, fSignupH+35, kScreenWidth-90, 28);
        self.txtWorkUnit.tag = 503;
        [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+fSignupH+35] forKey:@"503"];
        
        fSignupH += 63;
        self.lblPosition.frame = CGRectMake(20, fSignupH+10, kScreenWidth-70, 16);
        self.txtPosition.frame = CGRectMake(20, fSignupH+35, kScreenWidth-90, 28);
        self.txtPosition.tag = 504;
        [self.dicOffsetY setObject:[NSNumber numberWithFloat:fHeight+fSignupH+35] forKey:@"504"];
        
        fSignupH += 63;
        self.btnSignup.frame = CGRectMake(22, fSignupH + 20, kScreenWidth-94, 46);
        self.btnSignup.userInteractionEnabled = YES;
        [self.btnSignup setTitle:@"我要报名" forState:UIControlStateNormal];
        [self.viewSignupBK addSubview:self.btnSignup];
        fHeight += 336;
    }
    else if (self.m_activityProjectVo.nStatus == 2)
    {
        //报名尚未开始
        fHeight += 20;
        //self.btnSignup.enabled = NO;
        self.btnSignup.frame = CGRectMake(47, fHeight, kScreenWidth-94, 46);
        self.btnSignup.userInteractionEnabled = NO;
        [self.btnSignup setTitle:@"报名尚未开始" forState:UIControlStateNormal];
        [self.m_scrollView addSubview:self.btnSignup];
        self.viewSignupBK.frame = CGRectZero;
        fHeight += 46;
    }
    else if (self.m_activityProjectVo.nStatus == 1)
    {
        //报名已经结束
        fHeight += 20;
        //self.btnSignup.enabled = NO;
        self.btnSignup.frame = CGRectMake(47, fHeight, kScreenWidth-94, 46);
        self.btnSignup.userInteractionEnabled = NO;
        [self.btnSignup setTitle:@"报名已经结束" forState:UIControlStateNormal];
        [self.m_scrollView addSubview:self.btnSignup];
        self.viewSignupBK.frame = CGRectZero;
        fHeight += 46;
    }
    else if ([self isSignupThisActivity])
    {
        //您已经成功报名
        fHeight += 20;
        //self.btnSignup.enabled = NO;
        self.btnSignup.frame = CGRectMake(47, fHeight, kScreenWidth-94, 46);
        self.btnSignup.userInteractionEnabled = NO;
        [self.btnSignup setTitle:@"您已经成功报名" forState:UIControlStateNormal];
        [self.m_scrollView addSubview:self.btnSignup];
        self.viewSignupBK.frame = CGRectZero;
        fHeight += 46;
    }
    else if ([self.m_blogVo.strCreateBy isEqualToString:[Common getCurrentUserVo].strUserID] && self.m_activityProjectVo.nStatus == 3)
    {
        //管理员
        fHeight += 20;
        //self.btnSignup.enabled = NO;
        self.btnSignup.frame = CGRectMake(47, fHeight, kScreenWidth-94, 46);
        self.btnSignup.userInteractionEnabled = NO;
        [self.btnSignup setTitle:@"报名正在进行" forState:UIControlStateNormal];
        [self.m_scrollView addSubview:self.btnSignup];
        self.viewSignupBK.frame = CGRectZero;
        fHeight += 46;
    }
    
    //已报名用户
    if ([self.m_blogVo.strCreateBy isEqualToString:[Common getCurrentUserVo].strUserID] ||
        (self.m_activityProjectVo.bShow && [self isSignupThisActivity]))
    {
        //管理员，或者已本人经报完名并且是可见
        fHeight += 20;
        self.tableViewUser.frame = CGRectMake(25, fHeight, kScreenWidth-50, (self.m_activityProjectVo.aryMemberList.count*40+44));
        [self.tableViewUser reloadData];
        fHeight += (self.m_activityProjectVo.aryMemberList.count*40+44);
    }
    else
    {
        self.tableViewUser.frame = CGRectZero;
    }
    
    //bk view
    fHeight += 15;
    self.viewBK.frame = CGRectMake(10,15,kScreenWidth-20,fHeight-15);
    
    //滚动高度
    fHeight += 255;
    self.m_scrollView.frame = CGRectMake(0,NAV_BAR_HEIGHT,kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT);
    [self.m_scrollView setContentSize:CGSizeMake(kScreenWidth,fHeight)];
}

- (void)tapImage:(UITapGestureRecognizer *)sender
{
    SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
    dataSource.images_ = [NSArray arrayWithObject:[NSArray arrayWithObject:[NSURL URLWithString:self.m_activityProjectVo.strMaxImageURL]]];
    
    KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
                                                              initWithDataSource:dataSource
                                                              andStartWithPhotoAtIndex:0];
    [self.navigationController pushViewController:photoScrollViewController animated:YES];
}

- (void)signupActivity
{
    NSString *strRealName = self.txtRealName.text;
    if (strRealName.length == 0)
    {
        [Common tipAlert:@"真实姓名不能为空"];
        return;
    }
    
    NSString *strPhoneNum = self.txtPhoneNum.text;
    if (strPhoneNum.length == 0)
    {
        [Common tipAlert:@"电话号码不能为空"];
        return;
    }
    
    NSString *strWorkUnit = self.txtWorkUnit.text;
    if (strWorkUnit.length == 0)
    {
        [Common tipAlert:@"所属单位不能为空"];
        return;
    }
    
    NSString *strPosition = self.txtPosition.text;
    if (strPosition.length == 0)
    {
        [Common tipAlert:@"职位名称不能为空"];
        return;
    }
    
    [self.txtRealName resignFirstResponder];
    [self.txtPhoneNum resignFirstResponder];
    [self.txtWorkUnit resignFirstResponder];
    [self.txtPosition resignFirstResponder];
    
    UserVo *userVo = [[UserVo alloc]init];
    userVo.strUserName = strRealName;
    userVo.strPhoneNumber = strPhoneNum;
    userVo.strCompanyName = strWorkUnit;
    userVo.strPosition = strPosition;
    
    [self isHideActivity:NO];
    [ActivityService signupActivityProject:self.m_activityProjectVo.strID andUserVO:userVo result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            [self refreshData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//是否已经参加报名
- (BOOL)isSignupThisActivity
{
    BOOL bRes = NO;
    for (int i=0; i<self.m_activityProjectVo.aryMemberList.count; i++)
    {
        UserVo *userVo = [self.m_activityProjectVo.aryMemberList objectAtIndex:i];
        if ([userVo.strUserID isEqualToString:[Common getCurrentUserVo].strUserID])
        {
            bRes = YES;
            break;
        }
    }
    return bRes;
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

//隐藏键盘
-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch*touch =[touches anyObject];
	if(touch.phase==UITouchPhaseBegan)
    {
		//find first response view
		for(UIView*view in[self.viewSignupBK subviews])
        {
			if([view isFirstResponder])
            {
				[view resignFirstResponder];
				break;
			}
		}
	}
}

#pragma mark - UITextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.txtRealName)
    {
        [self.txtPhoneNum becomeFirstResponder];
    }
    else if(textField == self.txtPhoneNum)
    {
        [self.txtWorkUnit becomeFirstResponder];
    }
    else if(textField == self.txtWorkUnit)
    {
        [self.txtPosition becomeFirstResponder];
    }
    else if(textField == self.txtPosition)
    {
        [self.txtPosition resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //编辑时调整view
    [self fieldOffset:textField.tag];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if ([self.m_blogVo.strCreateBy isEqualToString:[Common getCurrentUserVo].strUserID])
        {
            //管理员
            UserVo *userVo = [self.m_activityProjectVo.aryMemberList objectAtIndex:alertView.tag-1000];
            NSString *strPhoneNumber = [@"tel://" stringByAppendingString:userVo.strPhoneNumber];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strPhoneNumber]];
        }
        else
        {
            //普通人
        }
    }
}

# pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.m_activityProjectVo.aryMemberList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ActivityProjectCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
        //改变选中背景色
        UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
        viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
        cell.selectedBackgroundView = viewSelected;
    }
    
    UserVo *userVo = [self.m_activityProjectVo.aryMemberList objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.text = userVo.strUserName;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, kScreenWidth, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0, kScreenWidth, 24)];
    label.textColor = COLOR(138, 138, 138, 1.0);
    label.font = [UIFont systemFontOfSize:16.0];
    label.text = @"已报名用户:";
    [headerView addSubview:label];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UserVo *userVo = [self.m_activityProjectVo.aryMemberList objectAtIndex:indexPath.row];
    NSString *strTitle = @"";
    UIAlertView *alertView = nil;
    if ([self.m_blogVo.strCreateBy isEqualToString:[Common getCurrentUserVo].strUserID])
    {
        //管理员
        strTitle = [NSString stringWithFormat:@"真实姓名：%@\r\n电话号码：%@\r\n所属单位：%@\r\n职位名称：%@",userVo.strUserName,userVo.strPhoneNumber,userVo.strCompanyName,userVo.strPosition];
        alertView =[[UIAlertView alloc] initWithTitle:nil message:strTitle delegate:self cancelButtonTitle:@"拨号？" otherButtonTitles:@"取消",nil];
    }
    else
    {
        //普通人
        strTitle = [NSString stringWithFormat:@"真实姓名：%@\r\n所属单位：%@",userVo.strUserName,userVo.strCompanyName];
        alertView =[[UIAlertView alloc] initWithTitle:nil message:strTitle delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
    }
    
    alertView.tag = 1000+indexPath.row;
    [alertView show];
}

@end
