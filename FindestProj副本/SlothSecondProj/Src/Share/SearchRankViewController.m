//
//  SearchRankViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/26.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "SearchRankViewController.h"
#import "TagVo.h"
#import "SearchRankCell.h"
#import "SearchShareViewController.h"

@interface SearchRankViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewRank;

@end

@implementation SearchRankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    if ([self.strPageType isEqualToString:@"hotSearch"])
    {
        self.title = @"本周热门搜索";
    }
    else
    {
        self.title = @"本周热门话题";
    }
    
    self.tableViewRank.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewRank.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _aryData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SearchRankCell";
    SearchRankCell *cell = (SearchRankCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell setEntity:_aryData[indexPath.row] index:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //采用自动计算高度，并且带有缓存机制
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TagVo *tagVo = _aryData[indexPath.row];
    
    SearchShareViewController *searchShareViewController = [[UIStoryboard storyboardWithName:@"ShareModule" bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:@"SearchShareViewController"];
    searchShareViewController.strPageType = tagVo.strSearchType;
    searchShareViewController.tagVo = tagVo;
    [self.navigationController pushViewController:searchShareViewController animated:YES];
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
