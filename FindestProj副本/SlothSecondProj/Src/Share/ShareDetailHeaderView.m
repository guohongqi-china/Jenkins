//
//  ShareDetailHeaderView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/6.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ShareDetailHeaderView.h"
#import "UIImageView+WebCache.h"
#import "BusinessCommon.h"
#import "ShareDetailViewController.h"
#import "CommonHeaderView.h"
#import "Utils.h"
#import "ActivityService.h"
#import "ActivityProjectVo.h"
#import "CommonUserListViewController.h"
#import "ActivityProjectViewController.h"
#import "CommonNavigationController.h"
#import "VideoPreviewView.h"
#import "CheckVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "TagVo.h"
#import "IntegralInfoVo.h"
#import "UserProfileViewController.h"

//注：出现约束冲突之一
//ShareDetailHeaderView.height 与 webViewConten.height不一致，采用将webViewConten.height优先级降低为200，比lblTitle的吸附优先级251还低，防止标题居中
@interface ShareDetailHeaderView ()<UIWebViewDelegate,UIGestureRecognizerDelegate,CommonHeaderViewDelegate>
{
    //头像、名称、标题
    UIView  *viewHeadContainer;
    
    CommonHeaderView *headerView;
    UIView *viewQuestionTitle;
    UIView *viewQuestionTitleSep;
    UIView *viewQuestionContentSep;
    UILabel *lblQuestionTitle;
    UILabel *lblAnswerTime;
    UIButton *btnPraise;
    
    UILabel *lblName;
    UIImageView *imgViewLevel;
    UIImageView *imgViewTimeIcon;
    UILabel *lblTime;
    
    //收藏
    UIImageView *imgViewStore;
    UIImageView *imgViewStoreIcon;
    UILabel *lblStoreNum;
    UIButton *btnStore;
    
    UILabel *lblTitle;
    UIView *viewSepView;
    
    //UIWebView
    UIWebView *webViewContent;
    
    //分享链接
    UIView *viewLinkBK;
    UIImageView *imgViewLink;
    UILabel *lblLinkTitle;
    
    //投票
    UIView *viewVoteContainer;
    
    //视频
    UIView *viewVideoContainer;
    
    //活动
    UIImageView *imgViewActivityBK;
    UIView *visualEffectView;//毛玻璃效果
    UIView *viewPosterContainer;
    UIImageView *imgViewPoster;
    UILabel *lblActivityTitle;
    
    UIView *viewActivityContainer;
    
    //标签容器
    UIView *viewTagContainer;
    
    //Foot View
    UIView *viewFootView;
    
    BlogVo *_blogVo;
}

@end

@implementation ShareDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame parent:(ShareDetailViewController*)controller
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        self.parentController = controller;
        _blogVo = controller.m_originalBlogVo;
        
        [self initView];
    }
    return self;
}

//1.初始化View
- (void)initView
{
    //初始化头部视图
    [self initHeadContainer];
    
    //webView
    webViewContent = [[UIWebView alloc]init];
    webViewContent.delegate = self;
    [webViewContent setAutoresizesSubviews:YES];
    [webViewContent setAutoresizingMask:UIViewAutoresizingNone];
    [webViewContent setUserInteractionEnabled:YES];
    webViewContent.scrollView.alwaysBounceVertical = NO;//内容小于frame时纵向不滚动
    [webViewContent setOpaque:NO ]; //透明
    webViewContent.backgroundColor=[UIColor whiteColor];
    webViewContent.scrollView.scrollsToTop = NO;
    [self addSubview: webViewContent];
    [webViewContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(4);
        make.right.equalTo(-4);
        make.top.equalTo(viewHeadContainer.mas_bottom).offset(10);
        make.height.equalTo(1).priority(200);
    }];
    webViewContent.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleWebViewImage:)];
    tap.delegate = self;
    [webViewContent addGestureRecognizer:tap];
    
    //初始化尾部视图
    [self initFootView];
}

- (void)refreshView:(BlogVo *)blogVo
{
    _blogVo = blogVo;
    
    //head view
    [self refreshHeadContainer];
    
    //web view
    NSString *strContent = blogVo.strContent;
    if(blogVo.scheduleVo != nil)
    {
        strContent = [strContent stringByAppendingString:blogVo.scheduleVo.strScheduleContent];
    }
    [webViewContent loadHTMLString:strContent baseURL:nil];
    
    //foot view
    [self refreshFootView];
    
    [self layoutIfNeeded];
    [self.parentController refreshTableHeaderView];
}

//2.初始化头部视图
- (void)initHeadContainer
{
    viewHeadContainer = [[UIView alloc]init];
    [self addSubview:viewHeadContainer];
    [viewHeadContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        make.width.equalTo(kScreenWidth);
        make.height.equalTo(0);
    }];
    
    viewHeadContainer.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    
    if ([_blogVo.strBlogType isEqualToString:@"activity"])
    {
        //活动
        [self initActivityHeader];
    }
    else
    {
        [self initShareAndAnswerHeader];
    }
}

- (void)initShareAndAnswerHeader
{
    viewQuestionTitle = [[UIView alloc]init];
    viewQuestionTitle.backgroundColor = COLOR(250, 246, 245, 1.0);
    [viewHeadContainer addSubview:viewQuestionTitle];
    
    lblQuestionTitle = [[UILabel alloc]init];
    lblQuestionTitle.userInteractionEnabled = YES;
    lblQuestionTitle.numberOfLines = 0;
    lblQuestionTitle.font = [Common fontWithName:@"PingFangSC-Medium" size:16];
    lblQuestionTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];//COLOR(51, 43, 41, 1.0);
    [viewQuestionTitle addSubview:lblQuestionTitle];
    
    viewQuestionTitleSep = [[UIView alloc]init];
    viewQuestionTitleSep.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [viewQuestionTitle addSubview:viewQuestionTitleSep];
    
    headerView = [[CommonHeaderView alloc]initWithFrame:CGRectZero canTap:YES parent:self.parentController];
    headerView.delegate = self;
    [viewHeadContainer addSubview:headerView];
    
    
    lblName = [[UILabel alloc]init];
    lblName.font = [UIFont systemFontOfSize:16];
    lblName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    [viewHeadContainer addSubview:lblName];
    
    imgViewLevel = [UIImageView new];
    imgViewLevel.contentMode = UIViewContentModeScaleAspectFit;
    [viewHeadContainer addSubview:imgViewLevel];
    
    imgViewTimeIcon = [[UIImageView alloc]init];
    imgViewTimeIcon.image = [UIImage imageNamed:@"share_time_icon"];
    [viewHeadContainer addSubview:imgViewTimeIcon];
    
    lblTime = [[UILabel alloc]init];
    lblTime.font = [UIFont systemFontOfSize:12];
    lblTime.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    [viewHeadContainer addSubview:lblTime];
    
    btnStore = [UIButton buttonWithType:UIButtonTypeCustom];
    btnStore.hidden = YES;
    [btnStore addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeadContainer addSubview:btnStore];
    
    imgViewStore = [[UIImageView alloc]initWithImage:[SkinManage imageNamed:@"collection_icon_bk"]];
    imgViewStore.hidden = YES;
    [viewHeadContainer addSubview:imgViewStore];
    
    imgViewStoreIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"collection_icon"]];
    imgViewStoreIcon.frame = CGRectMake(10, 6, 20, 19);
    [imgViewStore addSubview:imgViewStoreIcon];
    
    lblStoreNum = [[UILabel alloc]initWithFrame:CGRectMake(29, 0, 50, 31)];
    lblStoreNum.textAlignment = NSTextAlignmentCenter;
    lblStoreNum.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    lblStoreNum.font = [UIFont systemFontOfSize:13];
    [imgViewStore addSubview:lblStoreNum];
    
    btnPraise = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPraise.titleLabel.font = [UIFont systemFontOfSize:15];
    [btnPraise setTitleColor:[SkinManage colorNamed:@"Tab_Item_Color"] forState:UIControlStateNormal];
    [btnPraise setImage:[UIImage imageNamed:@"comment_praise"] forState:UIControlStateNormal];
    [btnPraise addTarget:self action:@selector(praiseAnswer) forControlEvents:UIControlEventTouchUpInside];
    [viewHeadContainer addSubview:btnPraise];
    
    viewQuestionContentSep = [[UIView alloc]init];
    viewQuestionContentSep.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [viewHeadContainer addSubview:viewQuestionContentSep];
    
    lblTitle = [[UILabel alloc]init];
    lblTitle.numberOfLines = 0;
    lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
    lblTitle.font = [Common fontWithName:@"PingFangSC-Medium" size:16];
    lblTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    [viewHeadContainer addSubview:lblTitle];
}

- (void)initActivityHeader
{
    imgViewActivityBK = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 250)];
    imgViewActivityBK.contentMode = UIViewContentModeScaleAspectFill;
    imgViewActivityBK.clipsToBounds = YES;
    [viewHeadContainer addSubview:imgViewActivityBK];
    
    //毛玻璃效果从iOS8开始支持
    if(iOSPlatform >= 8)
    {
        visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    }
    else
    {
        visualEffectView = [[UIView alloc] init];
        visualEffectView.backgroundColor = COLOR(0, 0, 0, 0.6);
    }
    visualEffectView.frame = CGRectMake(0, 0, kScreenWidth, 250);
    [imgViewActivityBK addSubview:visualEffectView];
    
    viewPosterContainer = [[UIView alloc]initWithFrame:CGRectMake((kScreenWidth-153)/2, 20, 153, 210)];
    viewPosterContainer.layer.shadowColor = [UIColor blackColor].CGColor;         //设置阴影的颜色
    viewPosterContainer.layer.shadowOffset = CGSizeMake(0, 2);                   //设置阴影的偏移量，也可以设置成负数
    viewPosterContainer.layer.shadowOpacity = 0.3;//设置阴影的不透明度
    viewPosterContainer.layer.shadowRadius = 4.0;//设置阴影的模糊半径（blur radius）
    [imgViewActivityBK addSubview:viewPosterContainer];
    
    imgViewPoster = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 153, 210)];
    imgViewPoster.contentMode = UIViewContentModeScaleAspectFill;
    imgViewPoster.clipsToBounds = YES;
    [viewPosterContainer addSubview:imgViewPoster];
    
    lblActivityTitle = [[UILabel alloc]init];
    lblActivityTitle.numberOfLines = 0;
    lblActivityTitle.lineBreakMode = NSLineBreakByWordWrapping;
    lblActivityTitle.font = [Common fontWithName:@"PingFangSC-Medium" size:18];
    lblActivityTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    [viewHeadContainer addSubview:lblActivityTitle];
}

- (void)refreshHeadContainer
{
    CGFloat fHeight = 0;
    CGSize size;
    if([_blogVo.strBlogType isEqualToString:@"answer"])
    {
        lblQuestionTitle.text = _blogVo.strTitle;
        size = [Common getStringSize:lblQuestionTitle.text font:lblQuestionTitle.font bound:CGSizeMake(kScreenWidth-24, MAXFLOAT) lineBreakMode:lblQuestionTitle.lineBreakMode];
        lblQuestionTitle.frame = CGRectMake(12, 10, kScreenWidth-24, size.height);
        
        //viewQuestionTitle会产生1像素的空白
        viewQuestionTitle.frame = CGRectMake(0, 0, kScreenWidth, lblQuestionTitle.height+20);
        fHeight += viewQuestionTitle.height;
        
        viewQuestionTitleSep.frame = CGRectMake(0, viewQuestionTitle.height-0.5, kScreenWidth, 0.5);
        
        fHeight += 12;
        [headerView refreshViewWithImage:_blogVo.vestImg userID:_blogVo.strCreateBy];
        headerView.frame = CGRectMake(12, fHeight, 40, 40);
        fHeight += headerView.height+12;
        
        lblName.text = _blogVo.strCreateByName;
        size = [Common getStringSize:lblName.text font:lblName.font bound:CGSizeMake(kScreenWidth-150, MAXFLOAT) lineBreakMode:lblName.lineBreakMode];
        //change by fjz 5.16   headerView.top+10 -> headerView.top
        lblName.frame = CGRectMake(headerView.right+10, headerView.top, size.width, 20);
        
        imgViewLevel.image = [UIImage imageNamed:[BusinessCommon getIntegralInfo:_blogVo.fIntegral].strLevelImage];
        imgViewLevel.frame = CGRectMake(lblName.right+5, lblName.top-2.5, 25, 25);
        
        btnPraise.frame = CGRectMake(kScreenWidth-100, headerView.top, 100, 40);
        [btnPraise setTitle:[NSString stringWithFormat:@"%li",(unsigned long)_blogVo.nPraiseCount] forState:UIControlStateNormal];
        [Common setButtonImageLeftTitleRight:btnPraise spacing:10];
        btnPraise.hidden = YES;
        
        viewQuestionContentSep.frame = CGRectMake(0, headerView.bottom+11.5, kScreenWidth, 0.5);
        
        imgViewTimeIcon.hidden = YES;
        lblTime.hidden = YES;
        lblTitle.hidden = YES;
    }
    else if([_blogVo.strBlogType isEqualToString:@"activity"])
    {
        [imgViewActivityBK sd_setImageWithURL:[NSURL URLWithString:_blogVo.strPictureUrl] placeholderImage:[UIImage imageNamed:@"default_image"]];
        [imgViewPoster sd_setImageWithURL:[NSURL URLWithString:_blogVo.strPictureUrl] placeholderImage:[UIImage imageNamed:@"default_image"]];
        fHeight += 250;
        
        fHeight += 20;
        lblActivityTitle.text = _blogVo.strTitle;
        size = [Common getStringSize:lblActivityTitle.text font:lblActivityTitle.font bound:CGSizeMake(kScreenWidth-24, MAXFLOAT) lineBreakMode:lblActivityTitle.lineBreakMode];
        lblActivityTitle.frame = CGRectMake(12, fHeight, kScreenWidth-24, size.height+5);
        fHeight += size.height+5;
    }
    else
    {
        viewQuestionTitle.hidden = YES;
        
        [headerView refreshViewWithImage:_blogVo.vestImg userID:_blogVo.strCreateBy];
        headerView.frame = CGRectMake(12, fHeight+12, 40, 40);
        fHeight += headerView.height+12;
        
        lblName.text = _blogVo.strCreateByName;
        size = [Common getStringSize:lblName.text font:lblName.font bound:CGSizeMake(kScreenWidth-150, MAXFLOAT) lineBreakMode:lblName.lineBreakMode];
        //change by fjz 5.16   headerView.top+10 -> headerView.top
        lblName.frame = CGRectMake(headerView.right+10, headerView.top, size.width, 20);
        
        imgViewLevel.image = [UIImage imageNamed:[BusinessCommon getIntegralInfo:_blogVo.fIntegral].strLevelImage];
        imgViewLevel.frame = CGRectMake(lblName.right+5, lblName.top-2.5, 25, 25);
        
        imgViewTimeIcon.frame = CGRectMake(headerView.right+10, lblName.bottom+5, 13, 13);
        lblTime.text = [Common getDateTimeStrStyle2:_blogVo.strCreateDate andFormatStr:@"yy/MM/dd HH:mm"];
        lblTime.frame = CGRectMake(imgViewTimeIcon.right+5, imgViewTimeIcon.top-1, 200, 15);
        
        //收藏
        btnStore.hidden = NO;
        btnStore.frame = CGRectMake(kScreenWidth-79, 16, 79, 40);
        if(_blogVo.bCollection)
        {
            imgViewStore.frame = CGRectMake(kScreenWidth-79, 21, 79, 31);
        }
        else
        {
            imgViewStore.frame = CGRectMake(kScreenWidth-38, 21, 79, 31);
        }
        imgViewStore.hidden = NO;
        [self refreshStoreView];
        
        btnPraise.hidden = YES;
        viewQuestionContentSep.hidden = YES;
        
        NSString *strTitle = _blogVo.strTitle;
        if ([_blogVo.strBlogType isEqualToString:@"vote"] && _blogVo.voteVo != nil)
        {
            strTitle = [NSString stringWithFormat:@"%@【%@】",strTitle,(_blogVo.voteVo.nVoteType == 0)?@"单选":@"多选"];
        }
        lblTitle.text = strTitle;
        size = [Common getStringSize:lblTitle.text font:lblTitle.font bound:CGSizeMake(kScreenWidth-24, MAXFLOAT) lineBreakMode:lblTitle.lineBreakMode];
        lblTitle.frame = CGRectMake(12, headerView.bottom+24, kScreenWidth-24, size.height+5);
        
        fHeight += 12+size.height+5;
    }
    
    [viewHeadContainer mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(fHeight);
    }];
    
}

//3.初始化尾部视图
- (void)initFootView
{
    viewFootView = [[UIView alloc]init];
    viewFootView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    [self addSubview:viewFootView];
    [viewFootView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(0);
        make.top.equalTo(webViewContent.mas_bottom).offset(10);
        make.height.equalTo(0);
    }];
    
    //标签
    
    //问答时间
    lblAnswerTime = [[UILabel alloc]init];
    lblAnswerTime.textAlignment = NSTextAlignmentRight;
    lblAnswerTime.font = [UIFont systemFontOfSize:15];
    lblAnswerTime.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];//COLOR(166, 143, 136, 1.0);
    [viewFootView addSubview:lblAnswerTime];
    
    //sep view
    viewSepView = [[UIView alloc]init];
    viewSepView.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    [viewFootView addSubview: viewSepView];
    
    UIView *viewSepLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
    viewSepLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    [viewSepView addSubview:viewSepLine];
}

- (void)refreshFootView
{
    CGFloat fHeight = 10;
    
    if ([_blogVo.strBlogType  isEqualToString:@"answer"])
    {
        lblAnswerTime.text = [Common getDateTimeStrStyle2:_blogVo.strCreateDate andFormatStr:@"yyyy-MM-dd HH:mm"];
        lblAnswerTime.frame = CGRectMake(0, fHeight, kScreenWidth-12, 24);
        fHeight += lblAnswerTime.height+10;
    }
    else
    {
        lblAnswerTime.hidden = YES;
    }
    
    //投票
    fHeight += [self initVoteView:fHeight];
    
    //活动
    fHeight += [self initActivityView:fHeight];
    
    //小视频
    fHeight += [self initVideoView:fHeight];
    
    //链接
    fHeight += [self initLinkView:fHeight];
    
//#warning ...............投票详情界面，标签放在正文下面
//    fHeight += [self initTagView:fHeight];
    
    fHeight += 10;
    viewSepView.frame = CGRectMake(0, fHeight, kScreenWidth, 10);
    fHeight += viewSepView.height;
    
    [viewFootView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(fHeight);
    }];
}

- (void)refreshStoreView
{
    lblStoreNum.text = [BusinessCommon getCollectionNumByInt:_blogVo.nCollectCount];
    if(_blogVo.bCollection)
    {
        imgViewStoreIcon.image = [UIImage imageNamed:@"collection_icon_h"];
        lblStoreNum.textColor = COLOR(255, 187, 82, 1.0);
    }
    else
    {
        imgViewStoreIcon.image = [UIImage imageNamed:@"collection_icon"];
        lblStoreNum.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];//COLOR(164, 143, 136, 1.0);
    }
}

- (void)buttonAction:(UIButton *)sender
{
    if (sender == btnStore)
    {
        self.parentController.bDoCollectionAction = YES;
        if (_blogVo.bCollection)
        {
            //取消收藏
            [Common showProgressView:nil view:self modal:NO];
            [ServerProvider cancelCollection:_blogVo.streamId andType:_blogVo.strBlogType result:^(ServerReturnInfo *retInfo) {
                [Common hideProgressView:self];
                if (retInfo.bSuccess)
                {
                    _blogVo.bCollection = NO;
                    _blogVo.nCollectCount -= 1;
                    _blogVo.nCollectCount = (_blogVo.nCollectCount < 0) ? 0 : _blogVo.nCollectCount;
                    [self refreshStoreView];
                    
                    [UIView animateWithDuration:0.15 animations:^{
                        imgViewStore.frame = CGRectMake(kScreenWidth-38, 21, 79, 31);
                    }];
                }
                else
                {
                    [Common tipAlert:retInfo.strErrorMsg];
                }
            }];
        }
        else
        {
            //收藏
            [Common showProgressView:nil view:self modal:NO];
            [ServerProvider addCollection:_blogVo.streamId andType:_blogVo.strBlogType result:^(ServerReturnInfo *retInfo) {
                [Common hideProgressView:self];
                if (retInfo.bSuccess)
                {
                    _blogVo.bCollection = YES;
                    _blogVo.nCollectCount += 1;
                    [self refreshStoreView];
                    
                    [UIView animateWithDuration:0.15 animations:^{
                        imgViewStore.frame = CGRectMake(kScreenWidth-79, 21, 79, 31);
                    }];
                }
                else
                {
                    [Common tipAlert:retInfo.strErrorMsg];
                }
            }];
        }
    }
}

- (void)handleWebViewImage:(UITapGestureRecognizer *)sender
{
    if (!self.parentController.bScrolling)
    {
        CGPoint touchPoint = [sender locationInView:webViewContent];
        //大图不存在，则获取中图
        NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
        NSString *strImgSrc = [webViewContent stringByEvaluatingJavaScriptFromString:imgURL];
        if (strImgSrc != nil && strImgSrc.length>0)
        {
            [self previewImage:strImgSrc];
        }
    }
}

- (void)previewImage:(NSString*)url
{
    if (_blogVo.aryPictureUrl.count>0)
    {
        //预览图片
        NSInteger nIndex = 0;
        for (NSInteger i=0;i<_blogVo.aryPictureUrl.count;i++)
        {
            NSString *strURL = _blogVo.aryPictureUrl[i];
            if ([strURL isEqualToString:url])
            {
                nIndex = i;
                break;
            }
        }
        
        if (_blogVo.aryMaxPictureUrl == nil)
        {
            _blogVo.aryMaxPictureUrl = [NSMutableArray array];
            for (NSString *strURL in _blogVo.aryPictureUrl)
            {
                //取大图
                NSURL *urlMax = [NSURL URLWithString:[strURL stringByReplacingOccurrencesOfString:@"-mid." withString:@"."]];
                NSURL *urlMin = [NSURL URLWithString:strURL];
                
                if (urlMax == nil || urlMin == nil)
                {
                    continue;
                }
                
                NSArray *ary = @[urlMax,urlMin];
                [_blogVo.aryMaxPictureUrl addObject:ary];
            }
        }
        
        SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
        dataSource.images_ = _blogVo.aryMaxPictureUrl;
        KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
                                                                  initWithDataSource:dataSource
                                                                  andStartWithPhotoAtIndex:nIndex];
        photoScrollViewController.bShowImageNumBarBtn = YES;
        [self.parentController.navigationController pushViewController:photoScrollViewController animated:YES];
    }
}

//赞答案
- (void)praiseAnswer
{
    
}

//查看链接
- (void)tapLinkView
{
    [BusinessCommon checkShareURLJump:_blogVo.strShareLink parent:self.parentController];
}

//视频相关/////////////////////////////////////////////////////////////////////////////////
-(CGFloat)initVideoView:(CGFloat)fTopHeight
{
    CGFloat fHeight = 0.0;
    if (viewVideoContainer != nil)
    {
        [viewVideoContainer removeFromSuperview];
    }
    
    if(_blogVo.aryVideoUrl.count == 0)
    {
        return fHeight;
    }
    
    viewVideoContainer = [[UIView alloc]init];
    viewVideoContainer.backgroundColor = [UIColor clearColor];
    
    VideoPreviewView *videoPreviewView = [[VideoPreviewView alloc]initWithFrame:CGRectMake(12, 12, kScreenWidth-24, kScreenWidth-24) previewBlock:^{
        [BusinessCommon presentVideoViewController:[NSURL URLWithString:_blogVo.aryVideoUrl[0]] controller:self.parentController];
    } deleteBlock:^{}];
    
    [videoPreviewView hideCloseButton];
    [viewVideoContainer addSubview:videoPreviewView];
    
    [videoPreviewView setVideoFileURL:[NSURL URLWithString:_blogVo.aryVideoUrl[0]]];
    fHeight += kScreenWidth;
    
    //end
    viewVideoContainer.frame = CGRectMake(0, fTopHeight, kScreenWidth, fHeight);
    [viewFootView addSubview:viewVideoContainer];
    return fHeight;
}

//链接相关/////////////////////////////////////////////////////////////////////////////////
-(CGFloat)initLinkView:(CGFloat)fTopHeight
{
    CGFloat fHeight = 0.0;
    if (viewLinkBK != nil)
    {
        [viewLinkBK removeFromSuperview];
    }
    
    if(_blogVo.strShareLink.length == 0)
    {
        return fHeight;
    }
    
    fHeight += 10;
    viewLinkBK = [[UIView alloc]initWithFrame:CGRectMake(12, fTopHeight, kScreenWidth-24, 32)];
    viewLinkBK.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    fHeight += viewLinkBK.height;
    
    UITapGestureRecognizer *linkViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLinkView)];
    [viewLinkBK addGestureRecognizer:linkViewTap];
    
    imgViewLink = [[UIImageView alloc]initWithFrame:CGRectMake(2, 2, 28, 28)];
    imgViewLink.image = [SkinManage imageNamed:@"share_link"];
    [viewLinkBK addSubview:imgViewLink];
    
    lblLinkTitle = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, viewLinkBK.width-50, 32)];
    lblLinkTitle.textColor = [SkinManage colorNamed:@"Content_Color"];
    lblLinkTitle.font = [Common fontWithName:@"PingFangSC-Light" size:14];
    lblLinkTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    lblLinkTitle.numberOfLines = 1;
    lblLinkTitle.text = _blogVo.strLinkTitle;
    [viewLinkBK addSubview:lblLinkTitle];
    
    fHeight += 10;
    
    //end
    [viewFootView addSubview:viewLinkBK];
    return fHeight;
}

//活动相关/////////////////////////////////////////////////////////////////////////////////
//初始化活动视图
-(CGFloat)initActivityView:(CGFloat)fTopHeight
{
    CGFloat fHeight = 0.0;
    if (viewActivityContainer != nil)
    {
        [viewActivityContainer removeFromSuperview];
    }
    if(![_blogVo.strBlogType isEqualToString:@"activity"])
    {
        return fHeight;
    }
    viewActivityContainer = [[UIView alloc]init];
    viewActivityContainer.backgroundColor = [UIColor clearColor];
    
    //1.他们也来参加
    if(_blogVo.aryActivityUser.count > 0)
    {
        UIView *viewAttend = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 104)];
        [viewActivityContainer addSubview:viewAttend];
        
        UIView *viewGap = [[UIView alloc]initWithFrame:CGRectMake(-0.5, 0, kScreenWidth+1, 10.5)];
        viewGap.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
        viewGap.layer.borderWidth = 0.5;
        viewGap.layer.masksToBounds = YES;
        viewGap.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
        [viewAttend addSubview:viewGap];
        
        UIView *viewAttendBK = [[UIView alloc]initWithFrame:CGRectMake(-0.5, 10, kScreenWidth+1, 94)];
        viewAttendBK.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
        viewAttendBK.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
        viewAttendBK.layer.borderWidth = 0.5;
        viewAttendBK.layer.masksToBounds = YES;
        [viewAttend addSubview:viewAttendBK];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(getMoreAttendedUser)];
        [viewAttendBK addGestureRecognizer:tapGesture];
        
        UILabel *lblAttendTip = [[UILabel alloc]initWithFrame:CGRectMake(12.5, 10, kScreenWidth-25, 20)];
        lblAttendTip.textColor =  [SkinManage colorNamed:@"Menu_Title_Color"];
        //COLOR(51, 43, 41, 1.0);
        lblAttendTip.font = [UIFont systemFontOfSize:14];
        lblAttendTip.text = @"TA们也来参加";
        [viewAttendBK addSubview:lblAttendTip];
        
        UIButton *btnMore = [UIButton buttonWithType:UIButtonTypeSystem];
        btnMore.frame = CGRectMake(kScreenWidth-65, 0, 65, 38);
        btnMore.titleLabel.font = [UIFont systemFontOfSize:14];
        [btnMore setTitle:@"更多" forState:UIControlStateNormal];
        [btnMore setImage:[UIImage imageNamed:@"table_accessory"] forState:UIControlStateNormal];
        btnMore.tintColor = [SkinManage colorNamed:@"Tab_Item_Color"];
        //COLOR(166, 143, 136, 1.0);
        [btnMore addTarget:self action:@selector(getMoreAttendedUser) forControlEvents:UIControlEventTouchUpInside];
        [viewAttendBK addSubview:btnMore];
        [Common setButtonImageRightTitleLeft:btnMore spacing:5];
        
        UIView *viewSep = [[UIView alloc]initWithFrame:CGRectMake(12.5, lblAttendTip.bottom+7, kScreenWidth-25, 0.5)];
        viewSep.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
        [viewAttendBK addSubview:viewSep];
        
        NSInteger nMaxUser = (kScreenWidth-12)/45;
        for (int i=0; i<_blogVo.aryActivityUser.count && i<nMaxUser; i++)
        {
            UserVo *userVo = _blogVo.aryActivityUser[i];
            UIImageView *imgViewUser = [[UIImageView alloc]initWithFrame:CGRectMake(12+i*(36+9), viewSep.bottom+9, 36, 36)];
            imgViewUser.layer.cornerRadius = 5;
            imgViewUser.layer.masksToBounds = YES;
            [imgViewUser sd_setImageWithURL:[NSURL URLWithString:userVo.strHeadImageURL] placeholderImage:[UIImage imageNamed:@"default_m"]];
            [viewAttendBK addSubview:imgViewUser];
        }
        fHeight += viewAttend.height;
    }
    
    //2.选择场次
    UIView *viewProjectContainer = [[UIView alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 104)];
    [viewActivityContainer addSubview:viewProjectContainer];
    viewProjectContainer.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    CGFloat fProjectStartH = 0;
    UIView *viewGap2 = [[UIView alloc]initWithFrame:CGRectMake(-0.5, -0.5, kScreenWidth+1, 10)];
    viewGap2.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
    viewGap2.layer.borderWidth = 0.5;
    viewGap2.layer.masksToBounds = YES;
    viewGap2.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    [viewProjectContainer addSubview:viewGap2];
    fProjectStartH += viewGap2.height;
    
    UILabel *lblSelectProjTip = [[UILabel alloc]initWithFrame:CGRectMake(12, fProjectStartH+15, kScreenWidth-24, 22)];
    lblSelectProjTip.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    lblSelectProjTip.font = [Common fontWithName:@"PingFangSC-Medium" size:16];
    lblSelectProjTip.text = @"选择场次";
    [viewProjectContainer addSubview:lblSelectProjTip];
    fProjectStartH += lblSelectProjTip.bottom;
    
    for (int i=0;i<_blogVo.aryActivityProject.count;i++)
    {
        ActivityProjectVo *projectVo = _blogVo.aryActivityProject[i];
        
        CGFloat fInnerH = 0;
        UIButton *btnProject = [UIButton buttonWithType:UIButtonTypeCustom];
        btnProject.tag = 1000+i;
        btnProject.frame = CGRectMake(12, fProjectStartH, kScreenWidth-24, 94);
        [btnProject setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Page_BK_Color"]] forState:UIControlStateNormal];
        [btnProject setBackgroundImage:[Common getImageWithColor:COLOR(246, 246, 246, 1.0)] forState:UIControlStateHighlighted];
        btnProject.layer.masksToBounds = YES;
        btnProject.layer.cornerRadius = 5;
        [btnProject addTarget:self action:@selector(tapActivityProject:) forControlEvents:UIControlEventTouchUpInside];
        [viewProjectContainer addSubview:btnProject];
        
        //项目标题
        UILabel *lblProjTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 12, btnProject.width-110-10, 20)];
        lblProjTitle.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
        lblProjTitle.font = [UIFont systemFontOfSize:14];
        lblProjTitle.text = projectVo.strProjectName;
        lblProjTitle.numberOfLines = 0;
        lblProjTitle.lineBreakMode = NSLineBreakByWordWrapping;
        [btnProject addSubview:lblProjTitle];
        CGSize size = [Common getStringSize:lblProjTitle.text font:lblProjTitle.font bound:CGSizeMake(lblProjTitle.width, MAXFLOAT) lineBreakMode:lblProjTitle.lineBreakMode];
        if (size.height < 20)
        {
            size.height = 20;
        }
        lblProjTitle.height = size.height;
        
        //报名人数以及状态
        NSString *strStatus = @" ";
        if (projectVo.nStatus == 1)
        {
            strStatus = @"报名已结束";
        }
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"已有 %li 人报名　%@",(long)projectVo.nSignupCount,strStatus]];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Tab_Item_Color"] range:NSMakeRange(0, attributedString.length-strStatus.length)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Tab_Item_Color_H"] range:NSMakeRange(attributedString.length-strStatus.length, strStatus.length)];
        
        UILabel *lblUserNum = [[UILabel alloc]initWithFrame:CGRectMake(10, lblProjTitle.bottom+5, lblProjTitle.width, 15)];
        lblUserNum.font = [UIFont systemFontOfSize:11];
        lblUserNum.attributedText = attributedString;
        [btnProject addSubview:lblUserNum];
        fInnerH += lblUserNum.bottom+12;
        
        //已报名logo
        if (projectVo.nSelfSignup == 1)
        {
            UIImageView *imgViewAttended = [[UIImageView alloc]initWithFrame:CGRectMake(btnProject.width-106, (fInnerH-59)/2, 65, 59)];
            imgViewAttended.image = [UIImage imageNamed:@"activity_enrolled"];
            [btnProject addSubview:imgViewAttended];
        }
        
        UIImageView *imgViewArrow = [[UIImageView alloc]initWithFrame:CGRectMake(btnProject.width-20, (fInnerH-14)/2, 8, 14)];
        imgViewArrow.image = [SkinManage imageNamed:@"table_accessory"];
        [btnProject addSubview:imgViewArrow];
        
        btnProject.height = fInnerH;
        fInnerH += 7.5;
        fProjectStartH += fInnerH;
    }
    fProjectStartH += 10;
    viewProjectContainer.height = fProjectStartH;
    fHeight += viewProjectContainer.height;
    
    //end
    viewActivityContainer.frame = CGRectMake(0, fTopHeight, kScreenWidth, fHeight);
    [viewFootView addSubview:viewActivityContainer];
    viewActivityContainer.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    return fHeight;
}

//获取更多参与人
- (void)getMoreAttendedUser
{
    CommonUserListViewController *commonUserListViewController = [[UIStoryboard storyboardWithName:@"UserModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"CommonUserListViewController"];
    commonUserListViewController.blogVo = _blogVo;
    commonUserListViewController.userListType = UserListActivityType;
    [self.parentController.navigationController pushViewController:commonUserListViewController animated:YES];
}

- (void)tapActivityProject:(UIButton *)sender
{
    ActivityProjectVo *projectVo = _blogVo.aryActivityProject[sender.tag-1000];
    
    ActivityProjectViewController *activitySuccessViewController = [[UIStoryboard storyboardWithName:@"ActivityModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ActivityProjectViewController"];
    activitySuccessViewController.m_activityProjectVo = projectVo;
    activitySuccessViewController.m_blogVo = _blogVo;
    [self.parentController.navigationController pushViewController:activitySuccessViewController animated:YES];
}

//投票相关/////////////////////////////////////////////////////////////////////////////////
//初始化投票视图
-(CGFloat)initVoteView:(CGFloat)fTopHeight
{
    CGFloat fHeight = 0.0;
    if (viewVoteContainer != nil)
    {
        [viewVoteContainer removeFromSuperview];
    }
    if(_blogVo.voteVo == nil)
    {
        return fHeight;
    }
    viewVoteContainer = [[UIView alloc]init];
    viewVoteContainer.backgroundColor = [UIColor clearColor];
    
    //sep line
    UIView *viewTopSep = [[UIView alloc]initWithFrame:CGRectMake(-0.5, 0, kScreenWidth+1, 10)];
    viewTopSep.layer.borderWidth = 0.5;
    viewTopSep.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
    viewTopSep.layer.masksToBounds = YES;
    viewTopSep.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    [viewVoteContainer addSubview:viewTopSep];
    fHeight += viewTopSep.height;
    
    //投票说明
    fHeight += 20;
    UILabel *lblVoteDes = [[UILabel alloc]initWithFrame:CGRectMake(12, fHeight, kScreenWidth-24, 22)];
    lblVoteDes.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    lblVoteDes.backgroundColor = [UIColor clearColor];
    lblVoteDes.font = [UIFont systemFontOfSize:16.0];
    [viewVoteContainer addSubview:lblVoteDes];
    if (_blogVo.voteVo.nVoteType == 0)
    {
        //单选题
        lblVoteDes.text = @"单选";
    }
    else
    {
        //多选题
        NSString *strMaxTip;
        if (_blogVo.voteVo.nMaxOption == 0)
        {
            strMaxTip = @"最多不限";
        }
        else
        {
            strMaxTip = [NSString stringWithFormat:@"最多%li项",(long)_blogVo.voteVo.nMaxOption];
        }
        lblVoteDes.text = [NSString stringWithFormat:@"多选（最少%li项，%@）",(long)_blogVo.voteVo.nMinOption,strMaxTip];
    }
    fHeight += lblVoteDes.height+10;
    
    //BK
    UIImageView *imgViewVoteBK = [[UIImageView alloc]init];
    imgViewVoteBK.image = [[UIImage imageNamed:@"groupedit_cell_bk"] stretchableImageWithLeftCapWidth:105 topCapHeight:22];
    [viewVoteContainer addSubview:imgViewVoteBK];
    
    //Vote Option
    if (!_blogVo.voteVo.bOverdue && !_blogVo.voteVo.bAlreadVote)
    {
        //1.未投票视图(没有过期并且没有投票)
        for (int i=0; i<_blogVo.voteVo.aryVoteOption.count; i++)
        {
            VoteOptionVo *voteOptionVo = [_blogVo.voteVo.aryVoteOption objectAtIndex:i];
            
            //background view
            UIView *viewBK = [[UIView alloc]initWithFrame:CGRectMake(12, fHeight, kScreenWidth-24, 58)];
            viewBK.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
            viewBK.layer.cornerRadius = 5;
            viewBK.layer.masksToBounds = YES;
            [viewVoteContainer addSubview:viewBK];
            
            //check button
            UIButton *btnVote = [UIButton buttonWithType:UIButtonTypeCustom];
            btnVote.frame = CGRectMake(12, fHeight, 58, 58);
            btnVote.tag = 3000+voteOptionVo.nOptionId;
            [btnVote addTarget:self action:@selector(doVoteOperation:) forControlEvents:UIControlEventTouchUpInside];
            [btnVote setImage:[SkinManage imageNamed:@"list_unselected"] forState:UIControlStateNormal];
            [viewVoteContainer addSubview:btnVote];
            
            //vote option name
            UILabel *lblVoteOptionName = [[UILabel alloc]init];
            lblVoteOptionName.text = voteOptionVo.strOptionName;
            lblVoteOptionName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
            lblVoteOptionName.font = [UIFont systemFontOfSize:14.0];
            lblVoteOptionName.textAlignment = NSTextAlignmentLeft;
            lblVoteOptionName.lineBreakMode = NSLineBreakByTruncatingTail;
            lblVoteOptionName.numberOfLines = 2;
            [viewVoteContainer addSubview:lblVoteOptionName];
            
            if(_blogVo.voteVo.nContentType == 1)
            {
                //图片投票
                UIImageView *voteImgViewHead = [[UIImageView alloc] initWithFrame:CGRectMake(72, fHeight+7, 44,44)];
                [voteImgViewHead sd_setImageWithURL:[NSURL URLWithString:voteOptionVo.strImage] placeholderImage:[UIImage imageNamed:@"default_image"]];
                voteImgViewHead.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
                voteImgViewHead.layer.borderWidth = 1;
                voteImgViewHead.layer.masksToBounds = YES;
                voteImgViewHead.contentMode = UIViewContentModeScaleAspectFill;
                voteImgViewHead.clipsToBounds = YES;
                voteImgViewHead.userInteractionEnabled = YES;
                voteImgViewHead.tag = 999+i;
                [viewVoteContainer addSubview:voteImgViewHead];
                
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVoteImageView:)];
                [voteImgViewHead addGestureRecognizer:singleTap];
                
                lblVoteOptionName.frame = CGRectMake(voteImgViewHead.right+18, fHeight+7, kScreenWidth-(voteImgViewHead.right+18)-21,44);
            }
            else
            {
                //文字投票
                lblVoteOptionName.frame = CGRectMake(70, fHeight+7, kScreenWidth-70-21,44);
            }
            
            fHeight += 60;
        }
        
        fHeight += 28;
        //投票
        UIButton *btnCommit = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCommit.frame = CGRectMake((kScreenWidth-70)/2, fHeight, 70, 70);
        btnCommit.tag = 501;
        [btnCommit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnCommit.titleLabel.font = [UIFont systemFontOfSize:16];;
        [btnCommit setTitle:@"投票" forState:UIControlStateNormal];
        [btnCommit addTarget:self action:@selector(doCommitVote:) forControlEvents:UIControlEventTouchUpInside];
        [btnCommit.layer setCornerRadius:35];
        [btnCommit.layer setMasksToBounds:YES];
        [btnCommit setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Tab_Item_Color_H"]] forState:UIControlStateNormal];
        [viewVoteContainer addSubview:btnCommit];
        fHeight += btnCommit.height+15;
        
        //投票人数
        UILabel *lblVoteNum = [[UILabel alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 17.5)];
        lblVoteNum.textAlignment = NSTextAlignmentCenter;
        lblVoteNum.font = [Common fontWithName:@"PingFangSC-Light" size:12];
        lblVoteNum.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];
        lblVoteNum.text = [NSString stringWithFormat:@"%li人参与投票",(unsigned long)_blogVo.voteVo.nVotePersonTotal];
        [viewVoteContainer addSubview:lblVoteNum];
        fHeight += lblVoteNum.height+20;
    }
    else
    {
        //2.已投票&已过期视图
        for (int i=0; i<_blogVo.voteVo.aryVoteOption.count; i++)
        {
            VoteOptionVo *voteOptionVo = [_blogVo.voteVo.aryVoteOption objectAtIndex:i];
            
            //background view
            UIView *viewBK = [[UIView alloc]initWithFrame:CGRectMake(12, fHeight, kScreenWidth-24, 58)];
            viewBK.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
            viewBK.layer.cornerRadius = 5;
            viewBK.layer.masksToBounds = YES;
            [viewVoteContainer addSubview:viewBK];
            
            //vote option name
            UILabel *lblVoteOptionName = [[UILabel alloc]init];
            lblVoteOptionName.text = voteOptionVo.strOptionName;
            lblVoteOptionName.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
            lblVoteOptionName.font = [UIFont systemFontOfSize:14.0];
            lblVoteOptionName.textAlignment = NSTextAlignmentLeft;
            lblVoteOptionName.lineBreakMode = NSLineBreakByTruncatingTail;
            lblVoteOptionName.numberOfLines = 2;
            [viewVoteContainer addSubview:lblVoteOptionName];
            
            if(_blogVo.voteVo.nContentType == 1)
            {
                //图片投票
                UIImageView *voteImgViewHead = [[UIImageView alloc] initWithFrame:CGRectMake(21, fHeight+7, 44,44)];
                [voteImgViewHead sd_setImageWithURL:[NSURL URLWithString:voteOptionVo.strImage] placeholderImage:[UIImage imageNamed:@"default_image"]];
                voteImgViewHead.layer.borderColor = [SkinManage colorNamed:@"Wire_Frame_Color"].CGColor;
                voteImgViewHead.layer.borderWidth = 1;
                voteImgViewHead.layer.masksToBounds = YES;
                voteImgViewHead.contentMode = UIViewContentModeScaleAspectFill;
                voteImgViewHead.clipsToBounds = YES;
                voteImgViewHead.userInteractionEnabled = YES;
                voteImgViewHead.tag = 999+i;
                [viewVoteContainer addSubview:voteImgViewHead];
                
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVoteImageView:)];
                [voteImgViewHead addGestureRecognizer:singleTap];
                
                lblVoteOptionName.frame = CGRectMake(voteImgViewHead.right+18, fHeight+8, kScreenWidth-(voteImgViewHead.right+18)-77,36);
            }
            else
            {
                //文字投票
                lblVoteOptionName.frame = CGRectMake(21, fHeight+8, kScreenWidth-21-77,36);
            }
            
            CGFloat fPercentage = 0;
            if(_blogVo.voteVo.nVoteTotal > 0)
            {
                fPercentage = (voteOptionVo.nCount*1.0)/_blogVo.voteVo.nVoteTotal;
            }
            
            //百分比进度条
            UIProgressView *progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(lblVoteOptionName.left, lblVoteOptionName.bottom+3, lblVoteOptionName.width-20, 4)];
            progressView.layer.cornerRadius = 2;
            progressView.layer.masksToBounds = YES;
            progressView.progress = fPercentage;
            if (voteOptionVo.bAlreadyVote)
            {
                //当前用户投过票,则进度条颜色加深
                progressView.progressTintColor = [SkinManage colorNamed:@"Tab_Item_Color_H"];      //进度条颜色
            }
            else
            {
                progressView.progressTintColor = COLOR(240, 167, 137, 1.0);    //进度条颜色
            }
            progressView.trackTintColor = COLOR(221, 208, 204, 1.0);	//背景颜色
            progressView.transform = CGAffineTransformMakeScale(1, 2);
            [viewVoteContainer addSubview:progressView];
            
            //票数
            UILabel *lblVoteNum = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth-55-22, fHeight+7, 55, 20)];
            lblVoteNum.text = [NSString stringWithFormat:@"%li票数",(unsigned long)voteOptionVo.nCount];
            lblVoteNum.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
            lblVoteNum.font = [UIFont systemFontOfSize:14.0];
            lblVoteNum.textAlignment = NSTextAlignmentRight;
            [viewVoteContainer addSubview:lblVoteNum];
            
            //百分比(采用下取整)
            unsigned long nPercentage = 0;
            if (voteOptionVo.nCount > 0)
            {
                nPercentage = floor(fPercentage*100.0);
                nPercentage = (nPercentage == 0) ? 1 : nPercentage;
            }
            UILabel *lblVotePercentage = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth-55-22, lblVoteNum.bottom, 55, 20)];
            lblVotePercentage.text = [NSString stringWithFormat:@"%li%%",nPercentage];
            lblVotePercentage.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
            lblVotePercentage.font = [UIFont systemFontOfSize:14.0];
            lblVotePercentage.textAlignment = NSTextAlignmentRight;
            [viewVoteContainer addSubview:lblVotePercentage];
            
            fHeight += 60;
        }
        
        fHeight += 28;
        
        //投票
        UIButton *btnCommit = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCommit.frame = CGRectMake((kScreenWidth-70)/2, fHeight, 70, 70);
        btnCommit.tag = 501;
        btnCommit.enabled = NO;
        [btnCommit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnCommit.titleLabel.font = [UIFont systemFontOfSize:16];;
        [btnCommit setTitle:@"已投" forState:UIControlStateNormal];
        [btnCommit addTarget:self action:@selector(doCommitVote:) forControlEvents:UIControlEventTouchUpInside];
        [btnCommit.layer setCornerRadius:35];
        [btnCommit.layer setMasksToBounds:YES];
        [btnCommit setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"Wire_Frame_Color"]] forState:UIControlStateDisabled];
        [btnCommit setTitleColor:[SkinManage colorNamed:@"Menu_Title_Color"] forState:UIControlStateNormal];
        [viewVoteContainer addSubview:btnCommit];
        fHeight += btnCommit.height+15;
        
        if (_blogVo.voteVo.bAlreadVote)
        {
            //已投
            [btnCommit setTitle:@"已投" forState:UIControlStateNormal];
        }
        else if (_blogVo.voteVo.bOverdue)
        {
            //过期
            [btnCommit setTitle:@"过期" forState:UIControlStateNormal];
        }
        
        //投票人数
        UILabel *lblVoteNum = [[UILabel alloc]initWithFrame:CGRectMake(0, fHeight, kScreenWidth, 17.5)];
        lblVoteNum.textAlignment = NSTextAlignmentCenter;
        lblVoteNum.font = [Common fontWithName:@"PingFangSC-Light" size:12];
        lblVoteNum.textColor = [SkinManage colorNamed:@"myjob_Button_title_color"];
        
        //COLOR(153, 153, 153, 1.0);
        lblVoteNum.text = [NSString stringWithFormat:@"%li人参与投票",(unsigned long)_blogVo.voteVo.nVotePersonTotal];
        [viewVoteContainer addSubview:lblVoteNum];
        fHeight += lblVoteNum.height+20;
    }
    
    viewVoteContainer.frame = CGRectMake(0, fTopHeight, kScreenWidth, fHeight);
    [viewFootView addSubview:viewVoteContainer];
    return fHeight;
}

//选择投票项
- (void)doVoteOperation:(UIButton*)sender
{
    if (_blogVo.voteVo.nVoteType == 0)
    {
        //single choose
        for (int i=0; i<_blogVo.voteVo.aryVoteOption.count; i++)
        {
            VoteOptionVo *voteOptionVo = [_blogVo.voteVo.aryVoteOption objectAtIndex:i];
            if (voteOptionVo.nOptionId == (sender.tag-3000))
            {
                //sender
                voteOptionVo.nSelected = 1;
                voteOptionVo.nCount ++;
                UIButton *btnVoteOption = (UIButton *)[viewVoteContainer viewWithTag:(voteOptionVo.nOptionId+3000)];
                [btnVoteOption setImage:[UIImage imageNamed:@"list_selected"] forState:UIControlStateNormal];
            }
            else
            {
                if (voteOptionVo.nSelected == 1)
                {
                    //update value
                    voteOptionVo.nSelected = 0;
                    voteOptionVo.nCount --;
                }
                UIButton *btnVoteOption = (UIButton *)[viewVoteContainer viewWithTag:(voteOptionVo.nOptionId+3000)];
                [btnVoteOption setImage:[SkinManage imageNamed:@"list_unselected"] forState:UIControlStateNormal];
            }
        }
    }
    else
    {
        //multiple choose
        NSInteger nCount = 0;
        for (int i=0; i<_blogVo.voteVo.aryVoteOption.count; i++)
        {
            VoteOptionVo *voteOptionVo = [_blogVo.voteVo.aryVoteOption objectAtIndex:i];
            if (voteOptionVo.nSelected)
            {
                nCount++;
            }
        }
        
        for (int i=0; i<_blogVo.voteVo.aryVoteOption.count; i++)
        {
            VoteOptionVo *voteOptionVo = [_blogVo.voteVo.aryVoteOption objectAtIndex:i];
            if (voteOptionVo.nOptionId == (sender.tag-3000))
            {
                //sender
                if (voteOptionVo.nSelected == 0)
                {
                    //_blogVo.voteVo.nMaxOption == 0 说明最多不限
                    if (_blogVo.voteVo.nMaxOption != 0 && nCount == _blogVo.voteVo.nMaxOption)
                    {
                        [Common bubbleTip:@"不能超过最多选项" andView:self.parentController.view];
                        return;
                    }
                    //will choose
                    voteOptionVo.nSelected = 1;
                    voteOptionVo.nCount ++;
                    [sender setImage:[UIImage imageNamed:@"list_selected"] forState:UIControlStateNormal];
                }
                else
                {
                    //will cancel choose
                    voteOptionVo.nSelected = 0;
                    voteOptionVo.nCount --;
                    [sender setImage:[SkinManage imageNamed:@"list_unselected"] forState:UIControlStateNormal];
                }
                break;
            }
        }
    }
}

//提交投票
-(void)doCommitVote:(UIButton*)sender
{
    int nType = 0;
    if (sender.tag == 501)
    {
        //实名提交
        nType = 0;
    }
    else
    {
        //匿名提交
        nType = 1;
    }
    
    NSMutableArray *aryOptionID = [NSMutableArray array];
    for (int i=0; i<_blogVo.voteVo.aryVoteOption.count; i++)
    {
        VoteOptionVo *voteOptionVo = [_blogVo.voteVo.aryVoteOption objectAtIndex:i];
        if (voteOptionVo.nSelected)
        {
            [aryOptionID addObject:[NSNumber numberWithInteger:voteOptionVo.nOptionId]];
            voteOptionVo.bAlreadyVote = YES;
        }
        else
        {
            voteOptionVo.bAlreadyVote = NO;
        }
    }
    
    //空选项退出
    if (aryOptionID.count == 0)
    {
        [Common tipAlert:@"请选择投票项"];
        return;
    }
    
    if(_blogVo.voteVo.nVoteType == 1)
    {
        //多选题(最少以及最大选项)
        NSString *strTipAlert;
        if(aryOptionID.count<_blogVo.voteVo.nMinOption)
        {
            strTipAlert = [NSString stringWithFormat:@"最少%li项",(long)_blogVo.voteVo.nMinOption];
            [Common tipAlert:strTipAlert];
            return;
        }
        else if(_blogVo.voteVo.nMaxOption != 0 && aryOptionID.count>_blogVo.voteVo.nMaxOption)
        {
            strTipAlert = [NSString stringWithFormat:@"最多%li项",(long)_blogVo.voteVo.nMaxOption];
            [Common tipAlert:strTipAlert];
            return;
        }
    }
    
    [Common showProgressView:nil view:self.parentController.view modal:NO];
    [ServerProvider operateVote:_blogVo.voteVo.strID andVoteOption:aryOptionID andType:nType result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.parentController.view];
        if (retInfo.bSuccess)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshShareDetailNotification" object:nil];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

//查看投票人操作
- (void)doViewVoterName:(UIButton*)sender
{
    //    VoteOptionVo *voteOptionVo = [_blogVo.voteVo.aryVoteOption objectAtIndex:(sender.tag-3000)];
    //    voteOptionVo.bExpansion = !voteOptionVo.bExpansion;
    //    [self refreshView];
}

- (void)tapVoteImageView:(id)sender
{
    UITapGestureRecognizer *singleTap = (UITapGestureRecognizer *)sender;
    VoteOptionVo *voteOptionVo = [_blogVo.voteVo.aryVoteOption objectAtIndex:[singleTap view].tag-999];
    if (voteOptionVo.strImage != nil)
    {
        SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
        dataSource.images_ = [NSArray arrayWithObject:[NSArray arrayWithObject:[NSURL URLWithString:voteOptionVo.strImage]]];
        
        KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
                                                                  initWithDataSource:dataSource
                                                                  andStartWithPhotoAtIndex:0];
        photoScrollViewController.bShowToolBarBtn = NO;
        [self.parentController.navigationController presentViewController:photoScrollViewController animated:YES completion: nil];
    }
}

//标签视图/////////////////////////////////////////////////////////////////////////////////
- (CGFloat)initTagView:(CGFloat)fTopHeight
{
    CGFloat fHeight = 0.0;
    if (viewTagContainer != nil)
    {
        [viewTagContainer removeFromSuperview];
    }
    
    if(_blogVo.aryTagList.count == 0)
    {
        return fHeight;
    }
    
    viewTagContainer = [[UIView alloc]init];
    viewTagContainer.backgroundColor = [UIColor clearColor];
    
    //tag icon
    UIImageView *imgViewTagIcon = [[UIImageView alloc]initWithImage:[SkinManage imageNamed:@"tag_icon"]];
    imgViewTagIcon.frame = CGRectMake(12, 7, 16, 16);
    [viewTagContainer addSubview:imgViewTagIcon];
    
    //tag name
    UILabel *lblTagName = [[UILabel alloc]init];
    lblTagName.numberOfLines = 0;
    lblTagName.font = [UIFont systemFontOfSize:14];
    lblTagName.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];// COLOR(166, 143, 136, 1.0);
    [viewTagContainer addSubview:lblTagName];
    
    NSMutableString *strTag = [[NSMutableString alloc]init];
    for (TagVo *tagVo in _blogVo.aryTagList)
    {
        [strTag appendFormat:@"%@、",tagVo.strTagName];
    }
    lblTagName.text = [strTag substringToIndex:strTag.length-1];
    CGSize size = [Common getStringSize:lblTagName.text font:lblTagName.font bound:CGSizeMake(kScreenWidth-38-12,MAXFLOAT) lineBreakMode:lblTagName.lineBreakMode];
    if(size.height < 20)
    {
        size.height = 20;
    }
    lblTagName.frame = CGRectMake(38, 5, size.width, size.height);
    fHeight += lblTagName.bottom+5;
    
    //end
    viewTagContainer.frame = CGRectMake(0, fTopHeight, kScreenWidth, fHeight);
    [self addSubview:viewTagContainer];
    return fHeight;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint touchPoint = [touch locationInView:self.parentController.view];
    BOOL bRes =  CGRectContainsPoint(self.parentController.simpleToolBar.toolBar.frame, touchPoint) ||  CGRectContainsPoint(self.parentController.simpleToolBar.viewContainer.frame, touchPoint);
    //BOOL bRes =  CGRectContainsPoint(self.simpleToolBar.toolBar.frame, touchPoint);
    return !bRes;
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGSize sizeFits = [webView sizeThatFits:CGSizeZero];
    //标签
   CGFloat tagH = [self initTagView:webViewContent.top + sizeFits.height];
    [webViewContent mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(sizeFits.height + tagH).priority(200);
        [self layoutIfNeeded];
    }];

    [self.parentController refreshTableHeaderView];
    

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        NSString *strURL = [request URL].absoluteString;
        if (strURL != nil && strURL.length>0)
        {
            NSRange range = [strURL rangeOfString:@"tel:"];
            if(range.length>0 && range.location == 0)
            {
                NSString *strPhoneTipInfo = [NSString stringWithFormat:@"您确定要呼叫 %@ ？",[strURL substringFromIndex:4]];
                if ([Common ask:strPhoneTipInfo] == 1)
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strURL]];
                }
            }
            else
            {
                [BusinessCommon checkShareURLJump:request.URL.absoluteString parent:self.parentController];
            }
        }
        return NO;
    }
    else
    {
        //[self isHideActivity:NO];
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:( NSError *)error
{
    [self.parentController refreshTableHeaderView];
}


- (void)tapHeaderViewAction:(CommonHeaderView *)headerView
{
    UserProfileViewController *userProfileViewController = [[UserProfileViewController alloc]init];
    userProfileViewController.strUserID = _blogVo.strCreateBy;
    [self.currentViewController.navigationController pushViewController:userProfileViewController animated:YES];
}

- (UIViewController *)currentViewController
{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

@end
