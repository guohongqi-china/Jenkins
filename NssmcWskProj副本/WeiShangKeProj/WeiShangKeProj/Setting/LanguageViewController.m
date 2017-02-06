//
//  LanguageViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 7/4/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "LanguageViewController.h"
#import "LanguageVo.h"
#import "Utils.h"
#import "LanguageManage.h"

@interface LanguageViewController ()

@end

@implementation LanguageViewController

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
    self.view.backgroundColor = COLOR(239, 239, 244, 1.0);
    [self setTopNavBarTitle:[Common localStr:@"Setting_Language" value:@"多语言2"]];
    
    UIButton *btnRight = [Utils buttonWithTitle:[Common localStr:@"Common_Save" value:@"保存"] frame:[Utils getNavRightBtnFrame:CGSizeMake(106,76)] target:self action:@selector(saveLanguage)];
    [self setRightBarButton:btnRight];
    
    self.aryLanguage = [NSMutableArray array];
    
    LanguageVo *languageVo = [[LanguageVo alloc]init];
    languageVo.strID = @"auto";
    languageVo.strName = [Common localStr:@"Setting_SystemLanguage" value:@"跟随系统"];
    [self.aryLanguage addObject:languageVo];
    
    languageVo = [[LanguageVo alloc]init];
    languageVo.strID = @"zh-Hans";
    languageVo.strName = @"简体中文";
    [self.aryLanguage addObject:languageVo];
    
    languageVo = [[LanguageVo alloc]init];
    languageVo.strID = @"en";
    languageVo.strName = @"English";
    [self.aryLanguage addObject:languageVo];
    
    for (int i=0;i<self.aryLanguage.count;i++)
    {
        LanguageVo *languageVo = [self.aryLanguage objectAtIndex:i];
        if ([languageVo.strID isEqualToString:[LanguageManage getUserDefaultLanguage]])
        {
            self.nCurLanguage = i;
            break;
        }
    }
    
    self.tableViewLanguage = [[UITableView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT) style:UITableViewStyleGrouped];
    self.tableViewLanguage.dataSource = self;
    self.tableViewLanguage.delegate = self;
    self.tableViewLanguage.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableViewLanguage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveLanguage
{
    LanguageVo *languageVo = [self.aryLanguage objectAtIndex:self.nCurLanguage];
    //当语言确实更改了
    if (![languageVo.strID isEqualToString:[LanguageManage getUserDefaultLanguage]])
    {
        [LanguageManage setCurrLanguage:languageVo.strID];
        [LanguageManage updateLanguageToServer];
        //重新进入应用
        NSDictionary *dicValue = @{@"fromView":@"LanguageViewController"};
        [[NSNotificationCenter defaultCenter]postNotificationName:@"JumpToHomeView" object:dicValue];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"NOTIFY_REFRESH_LANGUAGE" object:dicValue];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.aryLanguage.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;//section头部高度
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;//section尾部高度
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"LanguageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        UILabel * lblName = [[UILabel alloc]initWithFrame:CGRectMake(15, 5,200,34)];
        lblName.font = [UIFont boldSystemFontOfSize:17.0];
        lblName.textColor =[UIColor blackColor];
        lblName.backgroundColor = [UIColor clearColor];
        lblName.tag = 1001;
        [cell.contentView addSubview:lblName];
        
        UIImageView *imgViewSelected = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth-33, 11, 22, 22)];
        imgViewSelected.tag = 1002;
        [cell.contentView addSubview:imgViewSelected];
    }
    
    LanguageVo *languageVo = [self.aryLanguage objectAtIndex:indexPath.row];
    
    UILabel *lblName = (UILabel*)[cell.contentView viewWithTag:1001];
    lblName.text = languageVo.strName;
    
    UIImageView *imgViewSelected = (UIImageView*)[cell.contentView viewWithTag:1002];
    if (indexPath.row == self.nCurLanguage)
    {
        //该语言选中了
        imgViewSelected.image = [UIImage imageNamed:@"language_chk"];
    }
    else
    {
        imgViewSelected.image = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.nCurLanguage = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableViewLanguage reloadData];
}

@end
