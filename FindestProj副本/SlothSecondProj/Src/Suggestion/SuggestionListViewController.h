//
//  SuggestionListViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/3/16.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "SuggestionBaseVo.h"
#import "CustomPicker.h"

typedef NS_ENUM(NSInteger, SuggestionListType)
{
    SuggestionListAllType,      //所有合理化建议
    SuggestionListMyType        //我的合理化建议
};

@interface SuggestionListViewController : QNavigationViewController<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (nonatomic) SuggestionListType suggestionListType;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *suggestionSearchDisplayController;
@property (nonatomic, strong) UITableView *tableViewSuggestion;
@property (nonatomic, strong) UIView *viewContainer;
@property (nonatomic, strong) UIButton *btnCompanyFilter;
@property (nonatomic, strong) UIButton *btnStatusFilter;
@property (nonatomic, strong) UIButton *btnAboutMeFilter;

@property (nonatomic) NSInteger nCurrPage;
@property (nonatomic, strong) NSString *strSearchText;
@property (nonatomic, strong) NSMutableArray *aryObject;            //tableView data
@property (nonatomic, strong) NSMutableArray *aryFilteredObject;    //筛选的数据

@property(nonatomic)NSInteger nViewMenu;//当前显示的是哪个菜单，（0：都没显示，1：分公司，2：状态）

@property(nonatomic,strong)CustomPicker *pickerCompany;
@property(nonatomic,strong)CustomPicker *pickerStatus;
@property(nonatomic,strong)CustomPicker *pickerAboutMe;

//基础数据
@property (nonatomic, strong) SuggestionBaseVo *m_suggestionBaseVo;

@property (nonatomic, strong) NSMutableArray *aryDepartmentMenu;
@property (nonatomic, strong) NSMutableArray *aryStatusMenu;
@property (nonatomic, strong) NSMutableArray *aryAboutMeMenu;

@property (nonatomic, strong) NSString *strRelateID;                //全部、代办...

@end