//
//  ShareDetailViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/6.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlogVo.h"
#import "QNavigationViewController.h"
#import "SDWebImageDataSource.h"
#import "KTPhotoScrollViewController.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "ShareInfoVo.h"
#import <ShareSDK/ShareSDK.h>
#import "Common.h"
#import "CustomPicker.h"
#import "CustomHeaderView.h"
#import "SimpleToolBar.h"
#import "ContentWebView.h"
#import "CommentVo.h"

typedef NS_ENUM(NSInteger,ShareDetailViewControllerType)
{
    ShareDetailViewControllerIS,
    ShareDetailViewControllerNO,
};

@interface ShareDetailViewController : UIViewController

@property (nonatomic, strong) BlogVo *m_blogVo;
@property (nonatomic, strong) BlogVo *m_originalBlogVo;//原始（初始化分享详情必须传递，需要streamId、strBlogType两个字段）

@property (nonatomic, assign) ShareDetailViewControllerType shareType;/** <#注释#> */

@property (nonatomic, assign) BOOL isHe;/** <#注释#> */
@property(nonatomic,strong) ShareInfoVo *m_shareInfoVo;

//down view button
@property(nonatomic,strong)UIView   *viewBottom;
@property(nonatomic,strong)UIView *viewTabLine;
@property(nonatomic,strong)UIButton *btnDelete;
@property(nonatomic,strong)UIButton *btnPraise;
@property(nonatomic,strong)UIButton *btnReply;
@property(nonatomic,strong)UIButton *btnInviteAnswer;
@property(nonatomic,strong)UIButton *btnAddAnswer;
@property(nonatomic,strong)UIView *viewSeparate1;
@property(nonatomic,strong)UIView *viewSeparate2;

@property (nonatomic, assign) BOOL detailType;/** <#注释#> */

@property(nonatomic)BOOL bFirstRefresh;//用于解决加载评论时容易出现网络错误（暂定为与加载文章抢占网络资源）
//从提醒跳转过来,评论了你的分享、评论了你的评论、评论的@功能
@property(nonatomic,strong) NSString *strNotifyCommentID;

@property(nonatomic)BOOL bDoCollectionAction;//是否做了收藏或取消的操作，YES，则返回刷新列表
@property(nonatomic)NSInteger nDoShareAction;//0:没有任何改变,1：操作了评论、赞,2:删除分享操作（则返回刷新列表）
@property(nonatomic)int isFavorite;

//简介评论模块
@property(nonatomic,strong) UIView *viewComment;
@property(nonatomic,strong) SimpleToolBar *simpleToolBar;
@property(nonatomic,strong) NSString *strParentCommentID;//父评论ID
@property(nonatomic,strong) CommentVo *commentVoTap;

@property(nonatomic)BOOL bScrolling;   //UIWebView是否正在滚动，优化分享详情图片点击

@property(nonatomic,weak) id parentController;

- (void)loadAnswerData:(BOOL)bRefresh;
- (void)refreshTableHeaderView;

@end
