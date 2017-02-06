//
//  UserDetailView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/15.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "UserDetailView.h"
#import "UserEditVo.h"
#import "UserVo.h"
#import "UserDetailViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "UIImageView+WebCache.h"
#import "UIViewExt.h"

@interface UserDetailView ()<UITableViewDataSource,UITableViewDelegate>
{
    UserVo *userVo;
    NSMutableArray *aryUserSection;
    UIView *viewTableHeader;
    
    UIView *visualEffectView;//毛玻璃效果
}

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UITableView *tableViewDetail;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTop;

@end

@implementation UserDetailView

- (instancetype)initWithFrame:(CGRect)frame user:(UserVo *)userData
{
    self = [super init];
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:@"UserDetailView" owner:self options:nil];
        self.view.frame = frame;
        userVo = userData;
        
        [self initView];
        [self initData];
    }
    return self;
}

- (void)initView
{
    //毛玻璃效果从iOS8开始支持
    if(iOSPlatform >= 8)
    {
        visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    }
    else
    {
        visualEffectView = [[UIView alloc] init];
        visualEffectView.backgroundColor = COLOR(0, 0, 0, 0.6);
    }
    visualEffectView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.view addSubview:visualEffectView];
    [self.view sendSubviewToBack:visualEffectView];
    
    [_tableViewDetail registerNib:[UINib nibWithNibName:@"UserDetailViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"UserDetailViewCell"];
    [self initTableHeader];
    
    self.constraintTop.constant = kScreenHeight;
    self.constraintBottom.constant = -(kScreenHeight-53-33);
    [self.view layoutIfNeeded];
}

- (void)initData
{
    aryUserSection = [NSMutableArray array];
    
    //个人信息
    NSMutableArray *aryFirst = [NSMutableArray array];
    UserEditVo *menuVo = [[UserEditVo alloc]init];
    menuVo.strTitle = @"姓名";
    menuVo.strValue = userVo.strRealName;
    menuVo.bRequired = YES;
    menuVo.nMaxLength = 20;
    [aryFirst addObject:menuVo];
    
    menuVo = [[UserEditVo alloc]init];
    menuVo.strTitle = @"生日";
    menuVo.strValue = userVo.strBirthday;
    [aryFirst addObject:menuVo];
    
    menuVo = [[UserEditVo alloc]init];
    menuVo.strTitle = @"手机";
    if(userVo.bViewPhone)
    {
        menuVo.strValue = userVo.strPhoneNumber;
    }
    else
    {
        menuVo.strValue = @"未公开";
    }
    menuVo.bRequired = YES;
    [aryFirst addObject:menuVo];
    
    menuVo = [[UserEditVo alloc]init];
    menuVo.strTitle = @"性别";
    [aryFirst addObject:menuVo];
    if (userVo.gender == 0)
    {
        menuVo.strValue = @"女";
    }
    else if (userVo.gender == 1)
    {
        menuVo.strValue = @"男";
    }
    else
    {
        menuVo.strValue = @"";
    }
    
    menuVo = [[UserEditVo alloc]init];
    menuVo.strTitle = @"积分";
    menuVo.strValue = [NSString stringWithFormat:@"%g",userVo.fIntegrationCount];
    menuVo.bRequired = YES;
    [aryFirst addObject:menuVo];
    [aryUserSection addObject:aryFirst];
    
    //工作信息
    NSMutableArray *arySecond = [NSMutableArray array];
    menuVo = [[UserEditVo alloc]init];
    menuVo.strTitle = @"公司";
    menuVo.strValue = userVo.strDepartmentName;
    [arySecond addObject:menuVo];
    
    menuVo = [[UserEditVo alloc]init];
    menuVo.strTitle = @"职务";
    menuVo.strValue = userVo.strPosition;
    [arySecond addObject:menuVo];
    [aryUserSection addObject:arySecond];
    
    //社交信息
    NSMutableArray *aryThird = [NSMutableArray array];
    menuVo = [[UserEditVo alloc]init];
    menuVo.strTitle = @"QQ";
    menuVo.strValue = userVo.strQQ;
    [aryThird addObject:menuVo];
    
    menuVo = [[UserEditVo alloc]init];
    menuVo.strTitle = @"邮箱";
    menuVo.strValue = userVo.strEmail;
    [aryThird addObject:menuVo];
    [aryUserSection addObject:aryThird];
    
    [self.tableViewDetail reloadData];
}

- (void)initTableHeader
{
    self.bgView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.tableViewDetail.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    
    
    viewTableHeader = [[UIView alloc]init];
    viewTableHeader.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    UIImageView *imgViewHeader = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 60, 60)];
    imgViewHeader.layer.cornerRadius = 5;
    imgViewHeader.layer.masksToBounds = YES;
    [imgViewHeader sd_setImageWithURL:[NSURL URLWithString:userVo.strHeadImageURL] placeholderImage:[UIImage imageNamed:@"default_m"]];
    [viewTableHeader addSubview:imgViewHeader];
    
    UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(87, 20, kScreenWidth-114-47, 24)];
    lblName.font = [Common fontWithName:@"PingFangSC-Medium" size:16];
    lblName.textColor = [SkinManage colorNamed:@"nameLabel_Color"];
    lblName.text = userVo.strUserName;
    [viewTableHeader addSubview:lblName];
    
    UILabel *lblSignature = [[UILabel alloc]init];
    lblSignature.numberOfLines = 2;
    lblSignature.font = [UIFont systemFontOfSize:13];
    lblSignature.textColor = COLOR(100, 100, 100, 1.0);
    lblSignature.numberOfLines = 0;
    
    [viewTableHeader addSubview:lblSignature];
    
    CGSize size = [Common getStringSize:userVo.strSignature font:lblSignature.font bound:CGSizeMake(kScreenWidth-114-47, MAXFLOAT) lineBreakMode:lblSignature.lineBreakMode];
    lblSignature.frame = CGRectMake(87, 49, kScreenWidth-114-47, size.height);
    lblSignature.text = userVo.strSignature;
    
    CGFloat fSepH = imgViewHeader.bottom;
    if(lblSignature.bottom > imgViewHeader.bottom)
    {
        fSepH = lblSignature.bottom;
    }
    
    UIView *viewSep = [[UIView alloc]initWithFrame:CGRectMake(15, fSepH+10, kScreenWidth-84, 1)];
    viewSep.backgroundColor = [SkinManage colorNamed:@"myLine_back_color"];
    [viewTableHeader addSubview:viewSep];
    
    viewTableHeader.frame = CGRectMake(0, 0, kScreenWidth-54, viewSep.bottom);
    self.tableViewDetail.tableHeaderView = viewTableHeader;
}

- (IBAction)closeDetailView:(UIButton *)sender
{
    [self dismissWithAnimation];
}

- (void)showWithAnimation
{
    self.tableViewDetail.contentOffset = CGPointZero;
    
    self.view.alpha = 0;
    [UIView animateWithDuration:0.1 animations:^{
        self.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.constraintTop.constant = 53;
            self.constraintBottom.constant = 33;
            [self.view layoutIfNeeded];
        } completion:nil];
    }];
}

- (void)dismissWithAnimation
{
    [UIView animateWithDuration:0.2 animations:^{
        self.constraintTop.constant = kScreenHeight;
        self.constraintBottom.constant = -(kScreenHeight-53-33);
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.view.alpha = 1.0;
        [UIView animateWithDuration:0.1 animations:^{
            self.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
        }];
    }];
}

- (void)configureCell:(UserDetailViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    
    NSMutableArray *aryTemp = aryUserSection[indexPath.section];
    UserEditVo *menuVo = aryTemp[indexPath.row];
    NSInteger nLocation = indexPath.row;
    if (nLocation != 0)
    {
        if (nLocation == (aryTemp.count-1))
        {
            nLocation = 2;
        }
        else
        {
            nLocation = 1;
        }
    }
    
    [cell setEntity:menuVo location:nLocation];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return aryUserSection.count;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *aryTemp = aryUserSection[section];
    return aryTemp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserDetailViewCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *header = @"UserDetailViewHeader";
    UITableViewHeaderFooterView *viewHeader = [tableView dequeueReusableHeaderFooterViewWithIdentifier:header];
    if (viewHeader == nil)
    {
        viewHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:header];
        viewHeader.tag = section;
        viewHeader.contentView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        
        UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, kScreenWidth-40, 38)];
        lblTitle.tag = 1001;
        lblTitle.textColor = [SkinManage colorNamed:@"nameLabel_Color"];
        lblTitle.font = [Common fontWithName:@"PingFangSC-Medium" size:13];
        [viewHeader addSubview:lblTitle];
    }
    
    UILabel *lblTitle = [viewHeader viewWithTag:1001];
    if(section == 0)
    {
        lblTitle.text = @"个人信息";
    }
    else if(section == 1)
    {
        lblTitle.text = @"工作信息";
    }
    else
    {
        lblTitle.text = @"社交信息";
    }
    
    return viewHeader;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //采用自动计算高度，并且带有缓存机制
    return [tableView fd_heightForCellWithIdentifier:@"UserDetailViewCell" cacheByIndexPath:indexPath configuration:^(UserDetailViewCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //section头部高度
    return 38;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //section尾部高度
    CGFloat fHeight = CGFLOAT_MIN;
    return fHeight;
}

@end
