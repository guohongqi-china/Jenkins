//
//  ChooseTagViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 12/24/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "ChooseTagViewController.h"
#import "ChooseTagCell.h"
#import "Utils.h"

@interface ChooseTagViewController ()

@end

@implementation ChooseTagViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    [self setTopNavBarTitle:@"添加话题"];
    
    UIButton *btnRight = [Utils buttonWithTitle:@"完成" frame:[Utils getNavRightBtnFrame:CGSizeMake(106,76)] target:self action:nil];
    [btnRight addTarget:self action:@selector(completeChoose) forControlEvents:UIControlEventTouchUpInside];
    [self setRightBarButton:btnRight];
    
    self.tableViewTag = [[UITableView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT)];
    self.tableViewTag.dataSource = self;
    self.tableViewTag.delegate = self;
    [self.view addSubview:self.tableViewTag];
}

-(void)initData
{
    self.aryTag = [NSMutableArray array];
    [self isHideActivity:NO];
    [ServerProvider getTagVoListByType:@"O" result:^(ServerReturnInfo *retInfo) {
        [self isHideActivity:YES];
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryData = retInfo.data;
            if (aryData != nil && aryData.count>0)
            {
                [self.aryTag addObjectsFromArray:aryData];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableViewTag reloadData];
                [self isHideActivity:YES];
            });
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//初始化绑定数据
-(void)initBindChoosedData:(NSMutableArray *)aryChoosedTag
{
    //清空选中状态
    for (TagVo *tagVo in self.aryTag)
    {
        tagVo.bChecked = NO;
    }
    
    //初始选中状态
    if (aryChoosedTag != nil)
    {
        for (TagVo *tagVoChoosed in aryChoosedTag)
        {
            for (TagVo *tagVo in self.aryTag)
            {
                if ([tagVoChoosed.strID isEqualToString:tagVo.strID])
                {
                    tagVo.bChecked = YES;
                    break;
                }
            }
        }
    }
    [self.tableViewTag reloadData];
}

//完成选择
-(void)completeChoose
{
    NSMutableArray *aryChoosedTag = [NSMutableArray array];
    for (TagVo *tagVo in self.aryTag)
    {
        if (tagVo.bChecked)
        {
            [aryChoosedTag addObject:tagVo];
        }
    }
    
    [self.delegate completeChooseTagAction:aryChoosedTag];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Table View
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.aryTag.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ChooseTagCell calculateCellHeight:[self.aryTag objectAtIndex:indexPath.row]];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TagVo *tagVo = [self.aryTag objectAtIndex:[indexPath row]];
    
    static NSString *identifier=@"ChooseTagCell";
    ChooseTagCell *cell = (ChooseTagCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[ChooseTagCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
        //改变选中背景色
        UIView *viewSelected = [[UIView alloc] initWithFrame:cell.frame];
        viewSelected.backgroundColor =TABLEVIEW_SELECTED_COLOR;
        cell.selectedBackgroundView = viewSelected;
    }
    [cell initWithTagVo:tagVo];
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TagVo *tagVo = [self.aryTag objectAtIndex:[indexPath row]];
    
    //反选
    tagVo.bChecked = !tagVo.bChecked;
    ChooseTagCell *cell = (ChooseTagCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell updateCheckImage:tagVo.bChecked];
}


@end
