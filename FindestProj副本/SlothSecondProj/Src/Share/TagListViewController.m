//
//  TagListViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "TagListViewController.h"
#import "TagListCell.h"

@interface TagListViewController ()
{
    UIBarButtonItem *rightItem;
    NSMutableArray *aryTag;
    
    NSInteger _nSelectedNum;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewTag;

@end

@implementation TagListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.isNeedBackItem = YES;
    
    rightItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(completeAction)];
    rightItem.tintColor = [UIColor whiteColor];
    rightItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = rightItem;
    [self setTitle:@"添加标签"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableViewTag.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewTag.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [_tableViewTag registerNib:[UINib nibWithNibName:@"TagListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"TagListCell"];
}

- (void)initData
{
    _nSelectedNum = 0;
    
    aryTag = [NSMutableArray array];
    [Common showProgressView:nil view:self.view modal:NO];
    [ServerProvider getTagVoListByType:@"O" result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            NSMutableArray *aryData = retInfo.data;
            if (aryData != nil && aryData.count>0)
            {
                [aryTag addObjectsFromArray:aryData];
            }
            
            [self.tableViewTag reloadData];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)completeAction
{
    NSMutableArray *aryChoosedTag = [NSMutableArray array];
    for (TagVo *tagVo in aryTag)
    {
        if (tagVo.bChecked)
        {
            [aryChoosedTag addObject:tagVo];
        }
    }
    
    [self.delegate completeChooseTagAction:aryChoosedTag];
    
    [self backForePage];
}

//初始化绑定数据
-(void)initBindChoosedData:(NSMutableArray *)aryChoosedTag
{
    _nSelectedNum = 0;
    //清空选中状态
    for (TagVo *tagVo in aryTag)
    {
        tagVo.bChecked = NO;
    }
    
    //初始选中状态
    if (aryChoosedTag != nil)
    {
        for (TagVo *tagVoChoosed in aryChoosedTag)
        {
            for (TagVo *tagVo in aryTag)
            {
                if ([tagVoChoosed.strID isEqualToString:tagVo.strID])
                {
                    tagVo.bChecked = YES;
                    _nSelectedNum ++;
                    break;
                }
            }
        }
    }
    [self.tableViewTag reloadData];
}

#pragma mark Table View
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return aryTag.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TagListCell *cell = (TagListCell*)[tableView dequeueReusableCellWithIdentifier:@"TagListCell" forIndexPath:indexPath];
    cell.entity = aryTag[indexPath.row];
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TagVo *tagVo = [aryTag objectAtIndex:[indexPath row]];
    
    //如果超过三个这不能选择
    if (_nSelectedNum >= 3 && !tagVo.bChecked)
    {
        [Common bubbleTip:@"最多只能添加3个标签" andView:self.view];
        return;
    }
    
    //反选
    tagVo.bChecked = !tagVo.bChecked;
    TagListCell *cell = (TagListCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell updateCheckImage:tagVo.bChecked];
    
    //完成按钮
    if (tagVo.bChecked)
    {
        _nSelectedNum ++;
    }
    else
    {
        _nSelectedNum --;
    }
    
    if (_nSelectedNum > 0)
    {
        rightItem.enabled = YES;
    }
    else
    {
        rightItem.enabled = NO;
    }
}

@end
