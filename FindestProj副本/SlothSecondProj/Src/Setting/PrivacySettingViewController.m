//
//  PrivacySettingViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/11.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "PrivacySettingViewController.h"
#import "SettingViewCell.h"
#import "MenuVo.h"
#import "UserVo.h"

@interface PrivacySettingViewController ()<UITableViewDataSource,UITableViewDelegate,SettingViewDelegate>
{
    NSMutableArray *arySetting;
    UserVo *userVo;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewSetting;

@end

@implementation PrivacySettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    [self setTitle:@"隐私"];
    
    self.tableViewSetting.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewSetting.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [_tableViewSetting registerNib:[UINib nibWithNibName:@"SettingViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"SettingViewCell"];
    
    [self.tableViewSetting reloadData];
}

- (void)initData
{
    arySetting = [NSMutableArray array];
    userVo = [Common getCurrentUserVo];
    
    NSMutableArray *aryFirst = [NSMutableArray array];
    MenuVo *menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"viewPhone";
    menuVo.strName = @"手机号对任何人可见";
    menuVo.bBoolValue = userVo.bViewPhone;
    [aryFirst addObject:menuVo];
    [arySetting addObject:aryFirst];
    
    NSMutableArray *arySecond = [NSMutableArray array];
    menuVo = [[MenuVo alloc]init];
    menuVo.strID = @"viewStore";
    menuVo.strName = @"收藏夹对任何人可见";
    menuVo.bBoolValue = userVo.bViewFavorite;
    [arySecond addObject:menuVo];
//    [arySetting addObject:arySecond];
}

#pragma mark - SettingViewDelegate
- (void)switchControlChanged:(MenuVo *)menuVo state:(BOOL)bOn
{
    NSMutableDictionary *dicBody = [[NSMutableDictionary alloc]init];
    [dicBody setObject:[Common getCurrentUserVo].strUserID forKey:@"id"];
    if ([menuVo.strID isEqualToString:@"viewPhone"])
    {
        [dicBody setObject:bOn?@1:@0 forKey:menuVo.strID];
    }
    else
    {
        [dicBody setObject:bOn?@1:@0 forKey:menuVo.strID];
    }
   
    [Common showProgressView:nil view:self.view modal:NO];
    [ServerProvider updateUserInfoByDictionary:dicBody result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            //刷新视图
            if ([menuVo.strID isEqualToString:@"viewPhone"])
            {
                userVo.bViewPhone = bOn;
                menuVo.bBoolValue = bOn;
            }
            else
            {
                userVo.bViewFavorite = bOn;
                menuVo.bBoolValue = bOn;
            }
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arySetting.count;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *aryTemp = arySetting[section];
    return aryTemp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    MenuVo *menuVo = arySetting[indexPath.section][indexPath.row];
    cell.entity = menuVo;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //section头部高度
    CGFloat fHeight = 15;
    return fHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //section尾部高度
    return CGFLOAT_MIN;
}

@end
