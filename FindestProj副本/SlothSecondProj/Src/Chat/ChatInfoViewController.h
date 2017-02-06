//
//  ChatInfoViewController.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-5-20.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "QNavigationViewController.h"
#import "ChooseUserAndGroupViewController.h"
#import "ChatObjectVo.h"

@interface ChatInfoViewController : QNavigationViewController<UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UIActionSheetDelegate,ChooseUserAndGroupDelegate>

@property(nonatomic,strong)ChatObjectVo *m_chatObjectVo;

@property(nonatomic,strong)UIScrollView *scollViewChatInfo;
@property(nonatomic,strong)UICollectionView *collectionMember;
@property(nonatomic,strong)UIView *viewCollectionBK;
@property(nonatomic,strong)UITableView *tableViewChatInfo;
@property(nonatomic,strong)UIButton *btnExitAndDelete;

@property(nonatomic)BOOL bShowDeleteBtn;
//0:不刷新,1:只刷新会话列表,2:刷新会话列表+聊天内容标题更改,3:刷新会话列表+清空聊天内容记录
@property(nonatomic,assign) NSInteger nRefreshState;

@property(nonatomic,strong)NSMutableArray *m_aryChoosedUser;
@property(nonatomic,strong)NSMutableArray *m_aryChoosedGroup;

- (void)clickMemberAction:(UserVo*)userVo;
- (void)clickMinusAction:(UserVo*)userVo;
- (void)longPressMemberAction:(UserVo*)userVo;
- (void)refreshData;

@end
