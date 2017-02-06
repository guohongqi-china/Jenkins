//
//  ChooseTagViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 12/24/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "NoSearchView.h"

@protocol ChooseTagViewControllerDelegate <NSObject>
@optional
-(void)completeChooseTagAction:(NSMutableArray*)aryChoosedTag;
@end

@interface ChooseTagViewController : QNavigationViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property(nonatomic,weak) id<ChooseTagViewControllerDelegate> delegate;
@property(nonatomic,strong) NSMutableArray *aryChoosedTag;
@property(nonatomic,strong) NSMutableArray *aryTag;
@property(nonatomic,strong)NoSearchView *noSearchView;
@property(nonatomic,strong) UITableView *tableViewTag;

@property (nonatomic) BOOL bFirstLoad;
@property (nonatomic, strong) NSString *strTagType;//M：消息标签；U：特殊标签 ；F：FAQ标签；W：工单标签
@property (nonatomic, strong) NSString *strSearchText;
@property (nonatomic, strong) NSMutableArray *aryFilteredObject;    //筛选的数据

@property (nonatomic, strong) UISearchDisplayController *tagSearchDisplayController;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UIRefreshControl* refreshControl;

-(void)initBindChoosedData:(NSMutableArray *)aryOutTag;

@end
