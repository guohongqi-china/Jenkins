//
//  PublishShareViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/13.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "PublishShareViewController.h"
#import "PublicTagVoteCell.h"
#import "PublicATCell.h"
#import "CommonTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MenuVo.h"
#import "PublishVo.h"
#import "HomeViewController.h"
#import "UserVo.h"
#import "EditShareBodyViewController.h"
#import "BRPlaceholderTextView.h"
#import "TagListViewController.h"
#import "TagVo.h"
#import "SYTextAttachment.h"
#import "EditTitleViewController.h"
#import "UIViewExt.h"
#import "ChooseUserViewController.h"
#import "VoteOptionViewController.h"
#import "VoteVo.h"
#import "VoteOptionVo.h"
#import "VideoCaptureViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface PublishShareViewController ()<UITableViewDataSource,UITableViewDelegate,VoteOptionDelegate,EditShareBodyDelegate,TagListViewDelegate,EditTitleDelegate,ChooseUserViewControllerDelegate>
{
    NSString *strTitle;                 //主题
    NSAttributedString *attriContent;     //内容
    NSString *strLinkValue;                  //分享链接
    
    MenuVo *menuTag;
    MenuVo *menuVote;
    
    EditTitleViewController *editTitleViewController;
    EditShareBodyViewController *editShareBodyViewController;
    TagListViewController *chooseTagViewController;
    ChooseUserViewController *chooseUserViewController;
    VoteOptionViewController *voteOptionViewController;
    
    //header view
    NSMutableArray *aryTag;
    NSMutableArray *_aryChooseUser;
    
    UIBarButtonItem *rightItem;
    
    VoteVo *voteVo;
    NSURL *urlVideoFile;
}

@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UIButton *btnTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnContent;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet BRPlaceholderTextView *txtViewContent;
@property (weak, nonatomic) IBOutlet UITableView *tableViewPublic;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *sepLine1;
@property (weak, nonatomic) IBOutlet UIView *sepLine2;
@property (weak, nonatomic) IBOutlet UIView *sepLine3;

@end

@implementation PublishShareViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_BACKTOHOME object:nil];
}

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

//设置status bar 颜色
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)initView
{
    self.lblTitle.textColor = [SkinManage colorNamed:@"share_text_placeholderColor"];
    self.isNeedBackItem = NO;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(backButtonClicked)];
    leftItem.tintColor = [SkinManage colorNamed:@"Nav_Btn_label_Color"];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    rightItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(publicAction)];
    rightItem.tintColor = [SkinManage colorNamed:@"Nav_Btn_label_Color"];
    //rightItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = rightItem;
    
    if (self.nPublicType == 0)
    {
        [self setTitle:@"发分享"];
    }
    else
    {
        [self setTitle:@"发投票"];
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //table view
    self.tableViewPublic.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
    self.tableViewPublic.separatorColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    //COLOR(250, 246, 245, 1.0);
    
    _tableHeaderView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    _headerView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    _sepLine1.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    _sepLine2.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    _sepLine3.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.txtViewContent.placeholder = @"分享新鲜事...(必填)";
    [self.txtViewContent setPlaceholderColor:[SkinManage colorNamed:@"share_text_placeholderColor"]];//COLOR(166, 143, 136, 1.0)];
    self.txtViewContent.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    self.txtViewContent.textColor = [SkinManage colorNamed:@"share_text_textColor"];
    [self.txtViewContent setPlaceholderFont:[UIFont systemFontOfSize:16]];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapTextView:)];
    [self.txtViewContent addGestureRecognizer:recognizer];
    
    
    [self.btnTitle setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"publish_btn_bg"]] forState:UIControlStateHighlighted];
    
    //    COLOR(217, 217, 217, 1.0)
    [self.btnContent setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"publish_btn_bg"]] forState:UIControlStateHighlighted];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToHome) name:NOTIFY_BACKTOHOME object:nil];
}

- (void)initData
{
    menuVote = [[MenuVo alloc]init];
    menuVote.strImageName = @"vote_icon";
    menuVote.strName = @"投票选项";
    menuVote.strRemark = @"";
    
    menuTag = [[MenuVo alloc]init];
    menuTag.strImageName = @"tag_icon";
    menuTag.strName = @"添加标签";
    
    [self.tableViewPublic reloadData];
}

- (void)backButtonClicked
{
    if (self.linkStr.length)
    {    [self.navigationController popToRootViewControllerAnimated:YES];}
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)backToHome {
    [self dismissViewControllerAnimated:NO completion:nil];
}

//发分享操作
- (void)publicAction
{
    if (strTitle.length == 0)
    {
        [Common tipAlert:@"主题不能为空"];
    }
    else if (self.txtViewContent.text.length == 0)
    {
        [Common tipAlert:@"正文不能为空"];
    }
    else if (self.nPublicType == 1 && voteVo == nil)
    {
        [Common tipAlert:@"请编写投票选项内容"];
    }
    else
    {
        //判断视频url的来源是文件还是相册里面
        if (urlVideoFile && [urlVideoFile.scheme isEqualToString:@"assets-library"])
        {
            //需要从相册中拷贝出来，并且转换为MP4文件
            [Common showProgressView:nil view:self.view modal:NO];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self saveVideoToMp4:urlVideoFile result:^(NSString *strResult) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [Common hideProgressView:self.view];
                        if(strResult)
                        {
                            //转换失败
                            [Common tipAlert:strResult];
                        }
                        else
                        {
                            [self sendToServer];
                        }
                    });
                }];
            });
        }
        else
        {
            [self sendToServer];
        }
    }
}

- (void)sendToServer
{
    PublishVo *publishVo = [[PublishVo alloc]init];
    publishVo.imgList = [NSMutableArray array];
    
    if(self.nPublicType == 1)
    {
        //投票
        publishVo.voteVo = voteVo;
    }
    
    //查询content中是否包含图片
    NSMutableAttributedString *strAttribute = [[NSMutableAttributedString alloc] initWithAttributedString:attriContent];
    publishVo.aryAttriRange = [NSMutableArray array];
    NSRange effectiveRange = { 0, 0 };
    do {
        NSRange range = NSMakeRange (NSMaxRange(effectiveRange),[strAttribute length] - NSMaxRange(effectiveRange));
        NSDictionary *attributeDict = [strAttribute attributesAtIndex:range.location longestEffectiveRange:&effectiveRange inRange:range];
        SYTextAttachment *temp = (SYTextAttachment *)[attributeDict objectForKey:@"NSAttachment"];
        if (temp != nil)
        {
            [publishVo.aryAttriRange addObject:[NSValue valueWithRange:effectiveRange]];
            [publishVo.imgList addObject:temp.strImagePath];
        }
    } while (NSMaxRange(effectiveRange) < [strAttribute length]);
    
    //视频文件
    if(urlVideoFile)
    {
        publishVo.strVideoPath = urlVideoFile.path;
    }
    
    //tagList
    publishVo.aryTag = [NSMutableArray array];
    for (TagVo *tagVo in aryTag)
    {
        [publishVo.aryTag addObject:tagVo.strID];
    }
    
    //@ list
    publishVo.aryAT = [NSMutableArray array];
    if (_aryChooseUser != nil)
    {
        for (UserVo *userVo in _aryChooseUser)
        {
            [publishVo.aryAT addObject:userVo.strUserID];
        }
    }
    
    publishVo.streamTitle = strTitle;
    
    //content
    publishVo.attriContent = strAttribute;
    publishVo.streamContent = strAttribute.string;
    
    //分享链接
    publishVo.strShareLink = strLinkValue;
    
    //ComeFromType
    publishVo.streamComefrom = 2;
    
    //post action
    rightItem.enabled = NO;
    [Common showProgressView:@"发布中..." view:self.view modal:NO];
    [ServerProvider publishShare:publishVo result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        rightItem.enabled = YES;
        if (retInfo.bSuccess)
        {
            //                NSNumber *numIntegral = retInfo.data;
            
            //                //添加动画
            //                [BusinessCommon addAnimation:numIntegral.doubleValue andView:self.viewControllerParent.view];
            //
            //                //清理视频文件
            //                NSFileManager *fileManager = [NSFileManager defaultManager];
            //                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            //                NSString *strVideoFolder = [[paths objectAtIndex:0]stringByAppendingPathComponent:VIDEO_FOLDER];
            //                [fileManager removeItemAtPath:strVideoFolder error:nil];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshShareList" object:nil];
            [self backButtonClicked];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)tapTextView:(UITapGestureRecognizer *)recognizer
{
    //    if (recognizer.state == UIGestureRecognizerStateBegan)
    //    {
    //        _btnContent.highlighted = YES;
    //    }
    //    else if (recognizer.state == UIGestureRecognizerStateEnded)
    //    {
    //        _btnContent.highlighted = NO;
    //        [self buttonAction:_btnContent];
    //    }
    
    [self buttonAction:_btnContent];
}

//title & content
- (IBAction)buttonAction:(UIButton *)sender
{
    if(sender == _btnTitle)
    {
        if (editTitleViewController == nil)
        {
            editTitleViewController = [[UIStoryboard storyboardWithName:@"ShareModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"EditTitleViewController"];
            editTitleViewController.delegate = self;
        }
        [editTitleViewController setText:strTitle];
        [self.navigationController pushViewController:editTitleViewController animated:YES];
    }
    else
    {
        if (editShareBodyViewController == nil)
        {
            editShareBodyViewController = [[UIStoryboard storyboardWithName:@"ShareModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"EditShareBodyViewController"];
            editShareBodyViewController.editShareBodyType = EditShareBodyBlogType;
            editShareBodyViewController.delegate = self;
        }
        if (strLinkValue.length == 0)
            strLinkValue = self.linkStr;
        [editShareBodyViewController setText:self.txtViewContent.attributedText link:strLinkValue];
        [self.navigationController pushViewController:editShareBodyViewController animated:YES];
    }
}

- (void)configureCell:(CommonTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    
    id entity;
    
    if (self.nPublicType == 0)
    {
        if (indexPath.section == 0)
        {
            entity = menuTag;
        }
        else
        {
            entity = _aryChooseUser;
        }
    }
    else if (self.nPublicType == 1)
    {
        if (indexPath.section == 0)
        {
            entity = menuVote;
        }
        else if (indexPath.section == 1)
        {
            entity = menuTag;
        }
        else
        {
            entity = _aryChooseUser;
        }
    }
    else
    {
        entity = nil;
    }
    
    [cell setEntity:entity];
}

//添加投票项
- (void)addVote
{
    if(voteOptionViewController == nil)
    {
        voteOptionViewController = [[UIStoryboard storyboardWithName:@"ShareModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"VoteOptionViewController"];
        voteOptionViewController.delegate = self;
    }
    else
    {
        [voteOptionViewController refreshWithVoteVo:voteVo];
    }
    [self.navigationController pushViewController:voteOptionViewController animated:YES];
}

//添加标签
- (void)addTag
{
    if(chooseTagViewController == nil)
    {
        chooseTagViewController = [[UIStoryboard storyboardWithName:@"ShareModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"TagListViewController"];
        chooseTagViewController.delegate = self;
    }
    [chooseTagViewController initBindChoosedData:aryTag];
    [self.navigationController pushViewController:chooseTagViewController animated:YES];
}

//添加提醒人
- (void)addAttention
{
    //colleague
    if (chooseUserViewController == nil)
    {
        chooseUserViewController = [[UIStoryboard storyboardWithName:@"UserModule" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ChooseUserViewController"];;
        chooseUserViewController.delegate = self;
    }
    
    //编辑群组 已选用户
    chooseUserViewController.chooseUserType = ChooseUserAtType;
    chooseUserViewController.aryUserPreChoosed = _aryChooseUser;
    [self.navigationController pushViewController:chooseUserViewController animated:YES];
}

//将content内容尽可能延展到最大，但是所有内容不超过一屏
- (void)refreshHeaderView
{
    //title h
    CGFloat fHeaderH = 315;
    CGFloat fContentMaxH = kScreenHeight-NAV_BAR_HEIGHT;
    
    CGSize sizeTextView = [_txtViewContent sizeThatFits:CGSizeMake(kScreenWidth-14, MAXFLOAT)];
    if (sizeTextView.height + _lblTitle.height < fHeaderH)
    {
        //如果内容高度小于最小高度，以最小高度为标准
        _tableHeaderView.height = fHeaderH;
    }
    else
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        CGFloat fTagH = [self.tableViewPublic fd_heightForCellWithIdentifier:@"PublicTagVoteCell" cacheByIndexPath:indexPath configuration:^(CommonTableViewCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
        
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        CGFloat fAtH = [self.tableViewPublic fd_heightForCellWithIdentifier:@"PublicATCell" cacheByIndexPath:indexPath configuration:^(CommonTableViewCell *cell) {
            [self configureCell:cell atIndexPath:indexPath];
        }];
        
        CGFloat fTotalH = _lblTitle.height + 30 + fTagH + fAtH;
        
        if (sizeTextView.height > (fContentMaxH - fTotalH))
        {
            _tableHeaderView.height = fContentMaxH - fTotalH + _lblTitle.height;
        }
        else
        {
            _tableHeaderView.height = sizeTextView.height + _lblTitle.height;
        }
    }
    
    self.tableViewPublic.tableHeaderView = _tableHeaderView;
    _tableHeaderView.backgroundColor = [SkinManage colorNamed:@"Function_BK_Color"];
    [self.tableViewPublic reloadData];
    [self.view layoutIfNeeded];
}

//video////////////////////////////////////////////////////////////////////
- (void)saveVideoToMp4:(NSURL*)urlAsset result:(void(^)(NSString *))resultBlock
{
    //创建文件路径
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyyMMddHHmmss"];
    
    [VideoCaptureViewController createVideoFolderIfNotExist];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:VIDEO_FOLDER];
    __block NSString *strMp4Path = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Choosed.mp4",[formater stringFromDate:[NSDate date]]]];
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:urlAsset options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    exportSession.outputURL = [NSURL fileURLWithPath: strMp4Path];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        NSString *strResult = nil;
        switch ([exportSession status])
        {
            case AVAssetExportSessionStatusFailed:
            {
                strResult = [[exportSession error] localizedDescription];
                break;
            }
            case AVAssetExportSessionStatusCancelled:
            {
                strResult = @"Export canceled";
                break;
            }
            case AVAssetExportSessionStatusCompleted:
            {
                urlVideoFile = [NSURL fileURLWithPath:strMp4Path];
                break;
            }
            default:
            {
                strResult = @"Other Error";
                break;
            }
        }
        resultBlock(strResult);
    }];
}

#pragma mark - VoteOptionDelegate
-(void)completeVoteAction:(VoteVo *)voteVoData
{
    voteVo = voteVoData;
    if (voteVo != nil)
    {
        menuVote.strRemark = [NSString stringWithFormat:@"%li项(%@)",(unsigned long)voteVo.aryVoteOption.count,(voteVo.nVoteType == 0)?@"单选":@"多选"];
    }
    else
    {
        menuVote.strRemark = @"";
    }
    [self.tableViewPublic reloadData];
}

#pragma mark - ChooseUserViewControllerDelegate(完成成员选择)
-(void)completeChooseUserAction:(NSMutableArray*)aryChoosedUser group:(GroupVo*)groupVo
{
    _aryChooseUser = aryChoosedUser;
    [self.tableViewPublic reloadData];
    
    [self refreshHeaderView];
}

#pragma mark - ChooseTagViewControllerDelegate
-(void)completeChooseTagAction:(NSMutableArray*)aryChoosedTag
{
    aryTag = aryChoosedTag;
    
    NSMutableString *strTag = [[NSMutableString alloc]init];
    for (TagVo *tagVo in aryTag)
    {
        [strTag appendFormat:@"%@、",tagVo.strTagName];
    }
    if (strTag.length > 0)
    {
        menuTag.strName = [strTag substringToIndex:strTag.length-1];
    }
    else
    {
        menuTag.strName = @"添加标签";
    }
    
    //刷新视图
    [self.tableViewPublic reloadData];
    [self refreshHeaderView];
}

#pragma mark - EditTitleDelegate
- (void)completedEditShareTitle:(NSString *)strText
{
    if (strText.length > 0)
    {
        strTitle = strText;
        self.lblTitle.text = strText;
        self.lblTitle.textColor = [SkinManage colorNamed:@"share_text_textColor"];
    }
    else
    {
        strTitle = nil;
        self.lblTitle.text = @"分享新鲜事...";
        self.lblTitle.textColor = [SkinManage colorNamed:@"share_text_placeholderColor"];
    }
    [self refreshHeaderView];
}

#pragma mark - EditShareBodyDelegate
- (void)completedEditShareBody:(NSAttributedString*)attriText video:(NSURL*)urlVideo link:(NSString *)strLink
{
    if (attriText.length > 0)
    {
        attriContent = attriText;
        self.txtViewContent.attributedText = attriText;
        self.txtViewContent.placeholder = @"";
    }
    else
    {
        attriContent = nil;
        self.txtViewContent.text = nil;
        self.txtViewContent.placeholder = @"分享新鲜事...(必填)";
    }
    
    urlVideoFile = urlVideo;
    
    //link
    strLinkValue = strLink;
    
    [self refreshHeaderView];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.nPublicType == 0)
    {
        return 2;
    }
    else if (self.nPublicType == 1)
    {
        return 3;
    }
    else
    {
        return 0;
    }
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.nPublicType == 0)
    {
        //分享
        if (indexPath.section == 0)
        {
            static NSString *identifier = @"PublicTagVoteCell";
            PublicTagVoteCell *cell = (PublicTagVoteCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
            [self configureCell:cell atIndexPath:indexPath];
            return cell;
        }
        else
        {
            static NSString *identifier = @"PublicATCell";
            PublicATCell *cell = (PublicATCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
            [self configureCell:cell atIndexPath:indexPath];
            return cell;
        }
    }
    else if (self.nPublicType == 1)
    {
        //投票
        if (indexPath.section == 0 || indexPath.section == 1)
        {
            static NSString *identifier = @"PublicTagVoteCell";
            PublicTagVoteCell *cell = (PublicTagVoteCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
            [self configureCell:cell atIndexPath:indexPath];
            return cell;
        }
        else
        {
            static NSString *identifier = @"PublicATCell";
            PublicATCell *cell = (PublicATCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
            [self configureCell:cell atIndexPath:indexPath];
            return cell;
        }
    }
    else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.nPublicType == 0)
    {
        if (indexPath.section == 0)
        {
            return [tableView fd_heightForCellWithIdentifier:@"PublicTagVoteCell" cacheByIndexPath:indexPath configuration:^(CommonTableViewCell *cell) {
                [self configureCell:cell atIndexPath:indexPath];
            }];
        }
        else
        {
            return [tableView fd_heightForCellWithIdentifier:@"PublicATCell" cacheByIndexPath:indexPath configuration:^(CommonTableViewCell *cell) {
                [self configureCell:cell atIndexPath:indexPath];
            }];
        }
    }
    else if (self.nPublicType == 1)
    {
        if (indexPath.section == 0 || indexPath.section == 1)
        {
            return [tableView fd_heightForCellWithIdentifier:@"PublicTagVoteCell" cacheByIndexPath:indexPath configuration:^(CommonTableViewCell *cell) {
                [self configureCell:cell atIndexPath:indexPath];
            }];
        }
        else
        {
            return [tableView fd_heightForCellWithIdentifier:@"PublicATCell" cacheByIndexPath:indexPath configuration:^(CommonTableViewCell *cell) {
                [self configureCell:cell atIndexPath:indexPath];
            }];
        }
    }
    else
    {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.nPublicType == 0)
    {
        if (indexPath.section == 0)
        {
            [self addTag];
        }
        else
        {
            [self addAttention];
        }
    }
    else if (self.nPublicType == 1)
    {
        if (indexPath.section == 0 )
        {
            [self addVote];
        }
        else if (indexPath.section == 1)
        {
            [self addTag];
        }
        else
        {
            [self addAttention];
        }
    }
    else
    {
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //section头部高度
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //section尾部高度
    return CGFLOAT_MIN;
}

@end
