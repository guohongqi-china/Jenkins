//
//  MemberListViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/2/24.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MemberListViewController.h"
#import "MemberListCell.h"
#import "Utils.h"
#import "ChooseUserViewController.h"

@interface MemberListViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate,ChooseUserViewControllerDelegate>
{
    NSMutableArray *m_aryChoosedGroup;
    NSInteger nRefreshState;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBarMember;
@property (weak, nonatomic) IBOutlet UITableView *tableViewMember;
@property (nonatomic, retain) NSString *strSearchText;
@property (nonatomic, retain) UISearchDisplayController *memberSearchDisplayController;

@end

@implementation MemberListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTopNavBarTitle:[NSString stringWithFormat:@"群成员(%li)",(unsigned long)self.aryOrignData.count]];
    self.view.backgroundColor = [UIColor whiteColor];
    //右边按钮
    UIButton *btnRight = [Utils buttonWithTitle:@"添加" frame:[Utils getNavRightBtnFrame:CGSizeMake(86,76)] target:self action:@selector(righBarClick)];
    [self setRightBarButton:btnRight];
    
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.memberSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBarMember contentsController:self];
    self.memberSearchDisplayController.searchResultsDataSource = self;
    self.memberSearchDisplayController.searchResultsDelegate = self;
    self.memberSearchDisplayController.delegate = self;
    self.memberSearchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.memberSearchDisplayController.searchResultsTableView.scrollsToTop = NO;
    if ([SkinManage getCurrentSkin] == SkinNightType) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.searchBarMember.frame.size.height)];
        view.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        [self.searchBarMember insertSubview:view atIndex:1];
    }
    
    self.searchDisplayController.searchResultsTableView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    
    self.tableViewMember.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    
    self.tableViewMember.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewMember.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    
    [self.tableViewMember registerNib:[UINib nibWithNibName:@"MemberListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MemberListCell"];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"MemberListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MemberListCell"];
}

- (void)initData
{
    nRefreshState = 0;
    m_aryChoosedGroup = [[NSMutableArray alloc]init];
    self.aryObject = [[NSMutableArray alloc]init];
    self.aryFilteredObject = [[NSMutableArray alloc]init];
    
    if(self.aryOrignData != nil)
    {
        [self.aryObject addObjectsFromArray:self.aryOrignData];
    }
}

- (void)doSearch
{
    //1.Condition Check
    if (self.strSearchText == nil || self.strSearchText.length<=0)
    {
        return;
    }
    
    if(self.aryOrignData == nil || self.aryOrignData.count <= 0)
    {
        return;
    }
    
    [self.aryFilteredObject removeAllObjects];
    NSMutableArray *aryFilteredName = [[NSMutableArray alloc]init];
    NSMutableArray *aryFilteredJP = [[NSMutableArray alloc]init];
    NSMutableArray *aryFilteredQP = [[NSMutableArray alloc]init];
    
    for (int i=0; i<self.aryOrignData.count; i++)
    {
        UserVo *chatObjectVo = (UserVo *)[self.aryOrignData objectAtIndex:i];
        
        if ([chatObjectVo.strUserName rangeOfString:self.strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //a1.match user name
            [aryFilteredName addObject:chatObjectVo];
        }
        else if ([chatObjectVo.strJP rangeOfString:self.strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //b.match JP
            [aryFilteredJP addObject:chatObjectVo];
        }
        else if ([chatObjectVo.strQP rangeOfString:self.strSearchText options:NSCaseInsensitiveSearch].length>0)
        {
            //c.match QP
            [aryFilteredQP addObject:chatObjectVo];
        }
    }
    
    [self.aryFilteredObject addObjectsFromArray:aryFilteredName];
    [self.aryFilteredObject addObjectsFromArray:aryFilteredJP];
    [self.aryFilteredObject addObjectsFromArray:aryFilteredQP];
}

- (void)righBarClick
{
    //add member
    ChooseUserViewController *chooseUserViewController = [[UIStoryboard storyboardWithName:@"UserModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ChooseUserViewController"];
    chooseUserViewController.delegate = self;
    chooseUserViewController.chooseUserType = ChooseUserUpdateChatType;
    chooseUserViewController.m_chatObjectVo = self.m_chatObjectVo;
    //讨论组
    chooseUserViewController.aryUserPreChoosed = self.m_chatObjectVo.aryMember;
    
    [self.navigationController pushViewController:chooseUserViewController animated:YES];
}

- (void)backButtonClicked
{
    if (nRefreshState > 0)
    {
        //刷新
        [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshChatInfoData" object:[@{@"RefreshPara":@"updateNameSuccess"} mutableCopy]];
    }
    [super backButtonClicked];
}

#pragma mark - ChooseUserAndGroupDelegate(完成群组和成员选择)
-(void)completeChooseUserAction:(NSMutableArray*)aryChoosedUser group:(GroupVo *)groupVo
{
    if (groupVo != nil && aryChoosedUser != nil)
    {
        
        [m_aryChoosedGroup removeAllObjects];
        [m_aryChoosedGroup addObject:aryChoosedUser];
        
        [self.aryOrignData removeAllObjects];
        [self.aryOrignData addObjectsFromArray:aryChoosedUser];
        
        [self.aryObject removeAllObjects];
        [self.aryObject addObjectsFromArray:self.aryOrignData];
        [self.tableViewMember reloadData];
        
        //讨论组（添加成员，重新刷新数据）
        nRefreshState = 1;
    }
}

#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.aryObject.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MemberListCell" forIndexPath:indexPath];
    cell.entity = self.aryObject[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //文字改变
    self.strSearchText = searchText;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //恢复初始状态 （恢复原来数据）
    self.aryObject = self.aryOrignData;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    //要进行实时搜索
    [self doSearch];
    self.aryObject = self.aryFilteredObject;
    return YES;
}

@end
