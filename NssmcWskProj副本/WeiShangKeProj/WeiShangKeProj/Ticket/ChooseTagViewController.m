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
#import "UIViewExt.h"

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
    [self setTopNavBarTitle:@"编辑标签"];
    
    UIButton *btnRight = [Utils buttonWithTitle:@"完成" frame:[Utils getNavRightBtnFrame:CGSizeMake(106,76)] target:self action:nil];
    [btnRight addTarget:self action:@selector(completeChoose) forControlEvents:UIControlEventTouchUpInside];
    [self setRightBarButton:btnRight];
    
    //搜索框
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.placeholder = [Common localStr:@"Common_SearchTitle" value:@"搜索"];
    self.searchBar.delegate = self;
    self.searchBar.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth, 44);
    [self.view addSubview:self.searchBar];
    
    self.tagSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.tagSearchDisplayController.searchResultsDataSource = self;
    self.tagSearchDisplayController.searchResultsDelegate = self;
    self.tagSearchDisplayController.delegate = self;
    self.tagSearchDisplayController.searchResultsTableView.showsVerticalScrollIndicator = NO;
    
    self.tableViewTag = [[UITableView alloc]initWithFrame:CGRectMake(0, NAV_BAR_HEIGHT+44, kScreenWidth, kScreenHeight-NAV_BAR_HEIGHT-44)];
    self.tableViewTag.dataSource = self;
    self.tableViewTag.delegate = self;
    [self.view addSubview:self.tableViewTag];
    
    //no search view
    self.noSearchView = [[NoSearchView alloc]initWithFrame:CGRectMake(0, self.tableViewTag.top, kScreenWidth, self.tableViewTag.height) andDes:nil];
    
    //添加刷新
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.tableViewTag addSubview:_refreshControl];
    [self.tableViewTag sendSubviewToBack:_refreshControl];
}

-(void)initData
{
    self.aryFilteredObject = [NSMutableArray array];
    self.aryTag = [NSMutableArray array];
    
    [self refreshData];
}

- (void)refreshData
{
    [self isHideActivity:NO];
    dispatch_async(dispatch_get_global_queue(0,0),^{
        //do thread work
        ServerReturnInfo *retInfo = [ServerProvider getTagVoListByType:self.strTagType];
        if (retInfo.bSuccess)
        {
            self.aryTag = retInfo.data;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                [self bindChoosedStatus];//重新绑定标签数据
                [self isHideActivity:YES];
                
                if (self.aryTag.count == 0)
                {
                    [self.view addSubview:self.noSearchView];
                }
                else
                {
                    [self.noSearchView removeFromSuperview];
                }
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                [Common tipAlert:retInfo.strErrorMsg];
                [self isHideActivity:YES];
            });
        }
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.bFirstLoad)
    {
        //非第一次加载
        if (self.aryTag == nil || self.aryTag.count == 0)
        {
            [self refreshData];
        }
    }
}

//初始化绑定数据
-(void)initBindChoosedData:(NSMutableArray *)aryOutTag
{
    if (self.aryChoosedTag == nil)
    {
        self.aryChoosedTag = [NSMutableArray array];
    }
    [self.aryChoosedTag removeAllObjects];
    [self.aryChoosedTag addObjectsFromArray:aryOutTag];
    [self bindChoosedStatus];
}

//绑定选中状态
- (void)bindChoosedStatus
{
    //清空选中状态
    for (TagVo *tagVo in self.aryTag)
    {
        tagVo.bChecked = NO;
    }
    
    //初始选中状态
    if (self.aryChoosedTag != nil)
    {
        for (TagVo *tagVoChoosed in self.aryChoosedTag)
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

-(void)tackleChoosedTagArray:(TagVo*)tagVoSelect
{
    if (tagVoSelect.bChecked)
    {
        //选中
        [self.aryChoosedTag addObject:tagVoSelect];
    }
    else
    {
        for (TagVo *tagVo in self.aryChoosedTag)
        {
            if ([tagVoSelect.strID isEqualToString:tagVo.strID])
            {
                [self.aryChoosedTag removeObject:tagVo];
                break;
            }
        }
    }
}

- (void)doSearch:(NSMutableArray*)arySearchData
{
    //1.Condition Check
    if (self.strSearchText == nil || self.strSearchText.length<=0)
    {
        return;
    }
    
    if(arySearchData == nil || arySearchData.count <= 0)
    {
        return;
    }
    
    [self.aryFilteredObject removeAllObjects];
    NSMutableArray *aryFilteredName = [[NSMutableArray alloc]init];
    NSMutableArray *aryFilteredJP = [[NSMutableArray alloc]init];
    NSMutableArray *aryFilteredQP = [[NSMutableArray alloc]init];
    
    for (int i=0; i<arySearchData.count; i++)
    {
        TagVo *tagVo = (TagVo*)[arySearchData objectAtIndex:i];
        
        if ([tagVo.strTagName rangeOfString:self.strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //a.match name
            [aryFilteredName addObject:tagVo];
        }
        else if ([tagVo.strJP rangeOfString:self.strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //b.match JP
            [aryFilteredJP addObject:tagVo];
        }
        else if ([tagVo.strQP rangeOfString:self.strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //c.match QP
            [aryFilteredQP addObject:tagVo];
        }
    }
    
    [self.aryFilteredObject addObjectsFromArray:aryFilteredName];
    [self.aryFilteredObject addObjectsFromArray:aryFilteredJP];
    [self.aryFilteredObject addObjectsFromArray:aryFilteredQP];
    
    if (self.aryFilteredObject.count == 0)
    {
        [self.view addSubview:self.noSearchView];
    }
    else
    {
        [self.noSearchView removeFromSuperview];
    }
}

#pragma mark Table View
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableViewTag)
    {
        return self.aryTag.count;
    }
    else
    {
        //search
        return self.aryFilteredObject.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TagVo *tagVo;
    if (tableView == self.tableViewTag)
    {
        tagVo = self.aryTag[indexPath.row];
    }
    else
    {
        //search
        tagVo = self.aryFilteredObject[indexPath.row];
    }
    
    return [ChooseTagCell calculateCellHeight:tagVo];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TagVo *tagVo;
    if (tableView == self.tableViewTag)
    {
        tagVo = self.aryTag[indexPath.row];
    }
    else
    {
        //search
        tagVo = self.aryFilteredObject[indexPath.row];
    }
    
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
    
    TagVo *tagVo;
    if (tableView == self.tableViewTag)
    {
        tagVo = self.aryTag[indexPath.row];
    }
    else
    {
        //search
        tagVo = self.aryFilteredObject[indexPath.row];
    }
    
    //反选
    tagVo.bChecked = !tagVo.bChecked;
    ChooseTagCell *cell = (ChooseTagCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell updateCheckImage:tagVo.bChecked];
    
    [self tackleChoosedTagArray:tagVo];
}

#pragma mark - UISearchBarDelegate
- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableViewTag scrollRectToVisible:self.searchBar.frame animated:animated];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //文字改变
    self.strSearchText = searchText;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //恢复初始状态 （恢复原来数据）
    [self bindChoosedStatus];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //要进行实时搜索
    [self doSearch:self.aryTag];
    [self.searchDisplayController.searchResultsTableView reloadData];
    return YES;
}

@end
