//
//  SkinViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 12/5/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "SkinViewController.h"
#import "Utils.h"
#import "KeyValueVo.h"

@interface SkinViewController ()

@end

@implementation SkinViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = COLOR(239, 239, 244, 1.0);
    [self setTopNavBarTitle:@"选择皮肤"];
    
    UIButton *btnRight = [Utils buttonWithTitle:[Common localStr:@"Common_Save" value:@"保存"] frame:[Utils getNavRightBtnFrame:CGSizeMake(106,76)] target:self action:@selector(saveSkinType)];
    [self setRightBarButton:btnRight];
    
    //BK
    self.imgViewBK = [[UIImageView alloc]initWithFrame:CGRectMake(10, NAV_BAR_HEIGHT+10, kScreenWidth-20, kScreenHeight - NAV_BAR_HEIGHT-20)];
    self.imgViewBK.contentMode = UIViewContentModeScaleAspectFill;
    [self.imgViewBK.layer setBorderWidth:1.0];
    [self.imgViewBK.layer setCornerRadius:5];
    self.imgViewBK.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.imgViewBK.layer setMasksToBounds:YES];
    self.imgViewBK.clipsToBounds = YES;
    [self.view addSubview:self.imgViewBK];
    
    self.arySkin = [NSMutableArray array];
    
    KeyValueVo *keyValueVo = [[KeyValueVo alloc]init];
    keyValueVo.strKey = @"0";
    keyValueVo.strValue = @"激情";
    [self.arySkin addObject:keyValueVo];
    
    keyValueVo = [[KeyValueVo alloc]init];
    keyValueVo.strKey = @"1";
    keyValueVo.strValue = @"清新";
    [self.arySkin addObject:keyValueVo];
    
    keyValueVo = [[KeyValueVo alloc]init];
    keyValueVo.strKey = @"2";
    keyValueVo.strValue = @"典雅";
    [self.arySkin addObject:keyValueVo];
    
    keyValueVo = [[KeyValueVo alloc]init];
    keyValueVo.strKey = @"3";
    keyValueVo.strValue = @"浪漫";
    [self.arySkin addObject:keyValueVo];
    
    for (int i=0;i<self.arySkin.count;i++)
    {
        KeyValueVo *keyValueVo = [self.arySkin objectAtIndex:i];
        if (keyValueVo.strKey.integerValue == [SkinManage getCurrentSkin])
        {
            self.nCurrSkin = i;
            break;
        }
    }
    [self setImageViewImage:self.nCurrSkin];
    
    self.tableViewSkin = [[UITableView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT) style:UITableViewStyleGrouped];
    self.tableViewSkin.dataSource = self;
    self.tableViewSkin.delegate = self;
    self.tableViewSkin.backgroundColor = COLOR(0, 0, 0, 0.35);;//COLOR(255, 255, 255, 0.45);
    self.tableViewSkin.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableViewSkin];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveSkinType
{
    KeyValueVo *keyValueVo= [self.arySkin objectAtIndex:self.nCurrSkin];
    //当语言确实更改了
    if (keyValueVo.strKey.integerValue != [SkinManage getCurrentSkin])
    {
        [SkinManage setCurrentSkin:(SkinType)keyValueVo.strKey.integerValue];
        //更新其他页面语言
        [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFY_REFRESH_SKIN object:nil userInfo:nil];
        [self.navigationController popViewControllerAnimated:NO];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arySkin.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 160;//section头部高度
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;//section尾部高度
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SkinCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        cell.backgroundColor = [UIColor clearColor];//COLOR(255, 255, 255, 0.5);
        cell.contentView.backgroundColor = COLOR(255, 255, 255, 0.90);
        
        UILabel * lblName = [[UILabel alloc]initWithFrame:CGRectMake(15, 5,kScreenWidth-120,34)];
        lblName.font = [UIFont systemFontOfSize:17.0];
        lblName.textColor =[UIColor blackColor];
        lblName.backgroundColor = [UIColor clearColor];
        lblName.tag = 1001;
        [cell.contentView addSubview:lblName];
        
        UIImageView *imgViewSelected = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth-43, 11, 22, 22)];
        imgViewSelected.tag = 1002;
        [cell.contentView addSubview:imgViewSelected];
        
        UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, kScreenWidth, 0.5)];
        viewLine.backgroundColor = COLOR(200, 199, 204, 1.0);
        [cell.contentView addSubview:viewLine];
    }
    
    KeyValueVo *keyValueVo = [self.arySkin objectAtIndex:indexPath.row];
    
    UILabel *lblName = (UILabel*)[cell.contentView viewWithTag:1001];
    lblName.text = keyValueVo.strValue;
    
    UIImageView *imgViewSelected = (UIImageView*)[cell.contentView viewWithTag:1002];
    if (indexPath.row == self.nCurrSkin)
    {
        //该皮肤选中了
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
    self.nCurrSkin = (SkinType)indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self setImageViewImage:self.nCurrSkin];
    
    [self.tableViewSkin reloadData];
}

- (void)setImageViewImage:(SkinType)skinType
{
//    switch (skinType)
//    {
//        case SkinBlueType:
//            self.imgViewBK.image = [UIImage imageNamed:@"blue_skin_bk"];
//            break;
//        case SkinBrownType:
//            self.imgViewBK.image = [UIImage imageNamed:@"brown_skin_bk"];
//            break;
//        case SkinPinkType:
//            self.imgViewBK.image = [UIImage imageNamed:@"pink_skin_bk"];
//            break;
//        default:
//            self.imgViewBK.image = [UIImage imageNamed:@"default_skin_bk"];
//            break;
//    }
}


@end
