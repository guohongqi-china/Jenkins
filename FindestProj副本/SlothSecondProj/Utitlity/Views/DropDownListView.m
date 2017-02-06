//
//  DropDownListView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/2/27.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "DropDownListView.h"
#import "DropDownListCell.h"
#import "UIViewExt.h"

@interface DropDownListView ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
{
    UITableView *tableViewMenu;
    NSMutableArray *aryMenu;
}

@end

@implementation DropDownListView

- (instancetype)initWithFrame:(CGRect)frame menu:(NSArray*)aryData
{
    self = [super initWithFrame:frame];
    if (self)
    {
        aryMenu = [NSMutableArray array];
        [aryMenu addObjectsFromArray:aryData];
        if(aryMenu.count > 0)
        {
            ((MenuVo *)aryMenu[0]).bSelected = YES;
        }
        
        
        self.clipsToBounds = YES;
        self.backgroundColor = COLOR(0, 0, 0, 0.4);
        
        self.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        
        
        tableViewMenu = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, aryMenu.count*44)];
        tableViewMenu.dataSource = self;
        tableViewMenu.delegate = self;
        tableViewMenu.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableViewMenu.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        [self addSubview:tableViewMenu];
        tableViewMenu.center = CGPointMake(tableViewMenu.center.x, -tableViewMenu.height/2);
        
        [tableViewMenu registerNib:[UINib nibWithNibName:@"DropDownListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DropDownListCell"];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackground)];
        tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)showWithAnimation
{
    self.alpha = 0;
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.35 animations:^{
            tableViewMenu.center = CGPointMake(tableViewMenu.center.x, tableViewMenu.height/2);
            self.bShow = YES;
        } completion:nil];
    }];
}

//取消选择
- (void)cancelChooseAnimated:(BOOL)animated
{
    [self dismissWithAnimation:animated];
    
    if ([self.delegate respondsToSelector:@selector(cancelChooseMenu)])
    {
        [self.delegate cancelChooseMenu];
    }
}

- (void)dismissWithAnimation:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:0.35 animations:^{
            tableViewMenu.center = CGPointMake(tableViewMenu.center.x, -tableViewMenu.height/2);
        } completion:^(BOOL finished) {
            self.alpha = 1.0;
            [UIView animateWithDuration:0.15 animations:^{
                self.alpha = 0.0;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                self.bShow = NO;
            }];
        }];
    }
    else
    {
        tableViewMenu.center = CGPointMake(tableViewMenu.center.x, -tableViewMenu.height/2);
        [self removeFromSuperview];
        self.bShow = NO;
    }
}

- (void)tapBackground
{
    [self cancelChooseAnimated:YES];
}

#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"])
    {   //如果当前是tableView 做自己想做的事
        return NO;
    }
    return YES;
}

#pragma mark - Table view data source and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return aryMenu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DropDownListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DropDownListCell" forIndexPath:indexPath];
    MenuVo *menuVo = aryMenu[indexPath.row];
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
    
    for (MenuVo *menuVo in aryMenu)
    {
        menuVo.bSelected = NO;
    }
    
    MenuVo *menuVo = aryMenu[indexPath.row];
    menuVo.bSelected = YES;
    
    if ([self.delegate respondsToSelector:@selector(completedChooseMenu:)])
    {
        [self.delegate completedChooseMenu:menuVo];
    }
    [self dismissWithAnimation:YES];
    
    //刷新选择状态
    [tableView reloadData];
}

@end
