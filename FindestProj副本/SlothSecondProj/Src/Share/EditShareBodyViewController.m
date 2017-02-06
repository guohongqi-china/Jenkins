//
//  EditShareBodyViewController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "EditShareBodyViewController.h"
#import "PublicToolView.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>
#import "ResizeImage.h"
#import "UIImage+UIImageScale.h"
#import "Utils.h"
#import "SYTextAttachment.h"
#import "BRPlaceholderTextView.h"
#import "UIViewExt.h"
#import "VideoCaptureViewController.h"
#import "CheckVideoViewController.h"
#import "CommonNavigationController.h"
#import "VideoPreviewView.h"
#import "InPutView.h"

#import "TZImagePickerController.h"

@interface EditShareBodyViewController ()<InPutSendDelegateWithAttach,PublicToolDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextViewDelegate,TZImagePickerControllerDelegate>
{
    UIBarButtonItem *rightItem;
    PublicToolView *publicToolView;
    NSURL *urlVideoFile;
    
    UIImagePickerController *photoAlbumController;
}


@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewContent;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet BRPlaceholderTextView *txtViewBody;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomH;
@property (weak, nonatomic) IBOutlet UIView *viewBottom;

////////////////////////////////////////////////////////////////////////////////////////////////////
@property(nonatomic,strong) UIView *viewSepLine;

//share link
@property(nonatomic,strong) InPutView *inPutView;
@property(nonatomic,strong) NSString *strLinkValue;

@property (strong, nonatomic) UIView *viewLinkCotainer;
@property (strong, nonatomic) UIImageView *imgViewLinkIcon;
@property (strong, nonatomic) UILabel *lblLinkText;

//Video
@property(nonatomic,strong)VideoPreviewView *videoPreviewView;

@end

@implementation EditShareBodyViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"CompletedVideoCaptureAction" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self refreshBottomView];
    [self initData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.constraintBottomH.constant = kScreenHeight - 128 - NAV_BAR_HEIGHT;
    [self.view layoutIfNeeded];
    
    _txtViewBody.selectedRange = NSMakeRange(_txtViewBody.textStorage.length, 0);
    [self.txtViewBody becomeFirstResponder];
}

- (void)initView
{
    self.isNeedBackItem = YES;
    
    NSString *strRightBtnTitle;
    NSString *strPublicToolType;
    if (self.editShareBodyType == EditShareBodyBlogType)
    {
        strRightBtnTitle = @"完成";
        strPublicToolType = @"blog";
        [self setTitle:@"编辑正文"];
        self.txtViewBody.placeholder = @"分享新鲜事...";
    }
    else
    {
        strRightBtnTitle = @"发布";
        strPublicToolType = @"answer";
        [self setTitle:@"添加回答"];
        self.txtViewBody.placeholder = @"填写回答内容";
    }
    
    rightItem = [[UIBarButtonItem alloc] initWithTitle:strRightBtnTitle style:UIBarButtonItemStylePlain target:self action:@selector(completeAction)];
    rightItem.tintColor = [UIColor whiteColor];
    rightItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.txtViewBody setPlaceholderFont:[UIFont systemFontOfSize:16]];
    [self.txtViewBody setBackgroundColor:[SkinManage colorNamed:@"All_textField_bg_color"]];
    [self.txtViewBody setPlaceholderColor:[SkinManage colorNamed:@"share_text_placeholderColor"]];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture)];
    [_viewBottom addGestureRecognizer:recognizer];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(completedChoosedVideo:) name:@"CompletedVideoCaptureAction" object:nil];
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //bottom view
    self.viewSepLine = [[UIView alloc]initWithFrame:CGRectMake(12, 12, kScreenWidth-24, 0.5)];
    self.viewSepLine.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
    self.viewSepLine.hidden = YES;
    [self.viewBottom addSubview:self.viewSepLine];
    
    @weakify(self)
    self.videoPreviewView = [[VideoPreviewView alloc]initWithFrame:CGRectMake(12, 12, kScreenWidth-24, kScreenWidth-24) previewBlock:^{
        @strongify(self)
        CheckVideoViewController *checkVideoViewController = [[CheckVideoViewController alloc]init];
        checkVideoViewController.urlVideo = urlVideoFile;
        
        CommonNavigationController *navController = [[CommonNavigationController alloc] initWithRootViewController:checkVideoViewController];
        navController.navigationBarHidden = YES;
        [self presentViewController:navController animated:YES completion:nil];
        
    } deleteBlock:^{
        @strongify(self)
        urlVideoFile = nil;
        //移除View
        self.videoPreviewView.hidden = YES;
        [self refreshBottomView];
    }];
    self.videoPreviewView.hidden = YES;
    [self.viewBottom addSubview:self.videoPreviewView];
    
    //link view
    self.viewLinkCotainer = [[UIView alloc]initWithFrame:CGRectMake(12, 12, kScreenWidth-24, 70)];
    self.viewLinkCotainer.backgroundColor = [SkinManage colorNamed:@"link_bg"];
    self.viewLinkCotainer.hidden = YES;
    [self.viewBottom addSubview:self.viewLinkCotainer];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToDeleteLinkAction)];
    [self.viewLinkCotainer addGestureRecognizer:tapGesture];
    
    self.imgViewLinkIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 50, 50)];
    self.imgViewLinkIcon.image = [SkinManage imageNamed:@"share_link"];
    [self.viewLinkCotainer addSubview:self.imgViewLinkIcon];
    
    self.lblLinkText = [[UILabel alloc]initWithFrame:CGRectMake(self.imgViewLinkIcon.right+10, 10, self.viewLinkCotainer.width-80, 50)];
    self.lblLinkText.textAlignment = NSTextAlignmentLeft;
    self.lblLinkText.textColor = [SkinManage colorNamed:@"Menu_Title_Color"];
    self.lblLinkText.font = [UIFont systemFontOfSize:16];
    self.lblLinkText.text = @"文章链接";
    [self.viewLinkCotainer addSubview:self.lblLinkText];
    
    //tool view
    publicToolView = [[PublicToolView alloc]initWithType:strPublicToolType];
    publicToolView.delegate = self;
    [self.view addSubview:publicToolView.view];
    [publicToolView.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(0);
        make.height.equalTo(44);
    }];
    
    
    self.view.backgroundColor = [SkinManage colorNamed:@"All_textField_bg_color"];
    self.viewContainer.backgroundColor = [SkinManage colorNamed:@"All_textField_bg_color"];
    self.viewBottom.backgroundColor= [SkinManage colorNamed:@"All_textField_bg_color"];
    _txtViewBody.textColor = [SkinManage colorNamed:@"share_text_textColor"];
    
}

- (void)initData
{
    
}

- (void)tapGesture
{
    _txtViewBody.selectedRange = NSMakeRange(_txtViewBody.textStorage.length, 0);
    [self.txtViewBody becomeFirstResponder];
}

- (void)completeAction
{
    if (self.editShareBodyType == EditShareBodyBlogType)
    {
        [self.delegate completedEditShareBody:self.txtViewBody.attributedText video:urlVideoFile link:self.strLinkValue];
        [self backForePage];
    }
    else
    {
        //发布答案
        [self publicAnswer];
    }
}

- (void)publicAnswer
{
    PublishVo *publishVo = [[PublishVo alloc]init];
    publishVo.strRefID = self.strRefID;
    publishVo.attriContent =  [[NSMutableAttributedString alloc] initWithAttributedString:self.txtViewBody.attributedText];
    publishVo.streamContent = publishVo.attriContent.string;
    
    //查询content中是否包含图片
    NSMutableAttributedString *strAttribute = [[NSMutableAttributedString alloc] initWithAttributedString:publishVo.attriContent];
    publishVo.aryAttriRange = [NSMutableArray array];
    publishVo.imgList = [NSMutableArray array];
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
    
    [Common showProgressView:@"发布中..." view:self.view modal:NO];
    [ServerProvider addAnswer:publishVo result:^(ServerReturnInfo *retInfo) {
        [Common hideProgressView:self.view];
        if (retInfo.bSuccess)
        {
            [self.delegate completedEditShareBodyWithAnswer:retInfo.data];
            [self backForePage];
        }
        else
        {
            [Common tipAlert:retInfo.strErrorMsg];
        }
    }];
}

- (void)appendTextAttachment:(NSArray *)strImagePathArr
{
    //NSMutableAttributedString *strMutable = [[NSMutableAttributedString alloc] initWithAttributedString:self.txtViewBody.attributedText];
    //给附件添加图片
    for (int i = 0; i < strImagePathArr.count; i++) {
        NSString *imagePath = strImagePathArr[i];
        SYTextAttachment *textAttachment = [[SYTextAttachment alloc] init];
        textAttachment.image = [UIImage imageWithContentsOfFile:imagePath];
        textAttachment.strImagePath = imagePath;
        CGSize size = CGSizeMake(kScreenWidth-24, (kScreenWidth-24)*textAttachment.image.size.height*1.0/textAttachment.image.size.width);
        textAttachment.bounds = CGRectMake(0, 0, size.width, size.height);
        
        //设置图片
        [_txtViewBody.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment] atIndex:_txtViewBody.selectedRange.location];
        
//        //Move selection location
        _txtViewBody.selectedRange = NSMakeRange(_txtViewBody.selectedRange.location + 1, _txtViewBody.selectedRange.length);
        
        //插入空格行
        NSAttributedString *attString;
        if (i == (strImagePathArr.count-1))
        {
            //最后一张图片
            attString = [[NSAttributedString alloc]initWithString:@"\n "];
        }
        else
        {
            attString = [[NSAttributedString alloc]initWithString:@"\n"];
        }
        [_txtViewBody.textStorage insertAttributedString:attString atIndex:_txtViewBody.selectedRange.location];
        _txtViewBody.selectedRange = NSMakeRange(_txtViewBody.selectedRange.location + 1, _txtViewBody.selectedRange.length);
    }
    
    [_txtViewBody becomeFirstResponder];
    
    //设置字体（添加完图片后，字符font变动）
    [_txtViewBody.textStorage addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"share_text_textColor"] range:NSMakeRange(0, _txtViewBody.textStorage.length)];
    [_txtViewBody.textStorage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, _txtViewBody.textStorage.length)];
    
    //当第一个输入为图片，placeholder不消失的bug
    [_txtViewBody DidChange:nil];
    [self textViewDidChange:_txtViewBody];
    [self updateTextViewHeight];
}

//动态更新UITextView的高度
- (void)updateTextViewHeight
{
    CGFloat fContentH = [_txtViewBody sizeThatFits:CGSizeMake(_txtViewBody.frame.size.width, CGFLOAT_MAX)].height;
    if (fContentH > 128 && fabs(fContentH-_txtViewBody.frame.size.height) > 0.01)//进行优化，避免每次输入都更新height
    {
        self.constraintTextH.constant = fContentH;
        [_txtViewBody layoutIfNeeded];
        [self.view layoutIfNeeded];
        
        [self fieldOffset:self.txtViewBody];
    }
}

- (void)setText:(NSAttributedString *)attriText link:(NSString *)strLink
{
    self.txtViewBody.attributedText = attriText;
    [self updateTextViewHeight];
    
    //link
    self.strLinkValue = strLink;
    [self refreshBottomView];
}

- (void)refreshBottomView
{
    CGFloat fHeight = 12;
    //sep line
    if (self.strLinkValue.length == 0 && self.videoPreviewView.hidden)
    {
        self.viewSepLine.hidden = YES;
    }
    else
    {
        self.viewSepLine.hidden = NO;
    }
    self.viewSepLine.frame = CGRectMake(12, fHeight, kScreenWidth-24, 0.5);
    fHeight += 12;
    
    //link
    if(self.strLinkValue.length > 0)
    {
        self.viewLinkCotainer.hidden = NO;
        self.viewLinkCotainer.frame = CGRectMake(12, fHeight, kScreenWidth-24, 70);
        fHeight += self.viewLinkCotainer.height + 12;
    }
    else
    {
        self.viewLinkCotainer.hidden = YES;
    }
    
    //video
    if (!self.videoPreviewView.hidden)
    {
        self.videoPreviewView.frame = CGRectMake(12, fHeight, kScreenWidth-24, kScreenWidth-24);
    }
}

//调整键盘高度
-(void)fieldOffset:(UIView *)subView
{
    //获取特定subView相对于容器的布局height
    float fViewHeight = subView.top + subView.height;
    
    //当前scrollView 偏移量
    float fScrollOffset = _scrollViewContent.contentOffset.y;
    
    //可视界面的范围(0~fVisibleHeigh),假定容器从底部开始布局
    float fVisibleHeigh = _scrollViewContent.height-310;//中文键盘252
    
    //控件当前高度值（从屏幕顶部开始计算）
    float fCurrHeight = fViewHeight-fScrollOffset;
    
    //当subView超过了可见范围，则滚动scrollView
    if (fCurrHeight>fVisibleHeigh)
    {
        [_scrollViewContent setContentOffset:CGPointMake(0, fViewHeight-fVisibleHeigh+21+20) animated:YES];
    }
}

- (void)tapToDeleteLinkAction
{
    UIActionSheet *actionSheetGender = [[UIActionSheet alloc] initWithTitle:@"删除链接"
                                                                   delegate:self
                                                          cancelButtonTitle:@"取消"
                                                     destructiveButtonTitle:@"删除"
                                                          otherButtonTitles: nil];
    actionSheetGender.tag = 1002;
    [actionSheetGender showInView:self.view];
}

//视频相关/////////////////////////////////////////////////////////////////////
//完成选择视频文件
- (void)completedChoosedVideo:(NSNotification*)notification
{
    NSURL *urlFile = [notification object];
    if (urlFile)
    {
        urlVideoFile = urlFile;
        self.videoPreviewView.hidden = NO;
        //绑定视图
        [self.videoPreviewView setVideoFileURL:urlVideoFile];
        [self refreshBottomView];
    }
}

#pragma mark - InPutSendDelegateWithAttach
-(void)completeSend:(NSString*)strText
{
    if (strText.length == 0)
    {
        //清空链接
        self.strLinkValue = nil;
        [self.inPutView doCancel];
        [self refreshBottomView];
    }
    else
    {
        if([Common validateURL:strText])
        {
            self.strLinkValue = strText;
            [self.inPutView doCancel];
            [self refreshBottomView];
        }
        else
        {
            [Common tipAlert:@"该链接不正确，请重新填写"];
        }
    }
}

-(void)cancelSend
{
    
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self fieldOffset:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self updateTextViewHeight];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateTextViewHeight];
    if (textView.text.length > 0)
    {
        rightItem.enabled = YES;
    }
    else
    {
        rightItem.enabled = NO;
    }
}

#pragma mark - PublicToolDelegate
- (void)toolButtonAction:(NSInteger)nType
{
    if(nType == 0)
    {
        //camera
        [self.txtViewBody resignFirstResponder];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"小视频", nil];
        actionSheet.tag = 1001;
        if(self.editShareBodyType == EditShareBodyAnswerType)
        {
            //问答只有拍照
            [self actionSheet:actionSheet clickedButtonAtIndex:0];
        }
        else
        {
            [actionSheet showInView:self.view];
        }
    }
    else if (nType == 1)
    {
        //change by fjz 2016.4.12
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
        imagePickerVc.allowPickingVideo = NO;
        imagePickerVc.allowPickingOriginalPhoto = NO;
        [self presentViewController:imagePickerVc animated:YES completion:nil];
        //end
    }
    else
    {
        //link
        if(self.txtViewBody.isFirstResponder)
        {
            [self.txtViewBody resignFirstResponder];
        }
        
        //分享链接
        if (self.inPutView == nil)
        {
            self.inPutView = [[InPutView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            self.inPutView.delegate = self;
            self.inPutView.parentController = self;
            [self.inPutView initView];
            self.inPutView.btnAttach.hidden = YES;
            self.inPutView.btnFace.hidden = YES;
            self.inPutView.titleLab.text = @"链接";
            [self.inPutView.sendBtn setTitle:@"确定" forState:UIControlStateNormal];
        }
        [self.inPutView initInputViewControlValue];
        self.inPutView.inputTextView.text = self.strLinkValue;
        [self.view.window addSubview:self.inPutView];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == 1001)
    {
        if (buttonIndex == 0)
        {
            //拍照
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
            {
                return;
            }
            UIImagePickerController *photoController = [[UIImagePickerController alloc] init];
            photoController.navigationBar.backgroundColor = [SkinManage colorNamed:@"Page_BK_Color"];
            photoController.delegate = self;
            photoController.mediaTypes = @[(NSString*)kUTTypeImage];
            photoController.sourceType = UIImagePickerControllerSourceTypeCamera;
            photoController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            photoController.allowsEditing = YES;
            [photoController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            
            [self presentViewController:photoController animated:YES completion: nil];
        }
        else if (buttonIndex == 1)
        {
            //小视频
            VideoCaptureViewController *videoCaptureViewController = [[VideoCaptureViewController alloc]init];
            videoCaptureViewController.urlVideoChoosed = urlVideoFile;
            CommonNavigationController *navController = [[CommonNavigationController alloc]initWithRootViewController:videoCaptureViewController];
            navController.navigationBarHidden = YES;
            [self presentViewController:navController animated:YES completion:nil];
        }
    }
    else
    {
        
        if (buttonIndex == 0)
        {
            //删除链接
            self.strLinkValue = nil;
            [self refreshBottomView];
        }
    }
}

#pragma mark - <TZImagePickerControllerDelegate>
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    NSMutableArray *pathArr = [@[] mutableCopy];
    for (int i = 0;i < photos.count;i++)
    {
        UIImage *image = photos[i];
        float fWidth = image.size.width;
        float fHeight = image.size.height;
        image = [Common rotateImage:image];
        //当图片尺寸过大，进行缩放处理
        CGSize sizeImage = CGSizeMake(fWidth, fHeight);
        if (sizeImage.width>IMAGE_MAX_SIZE && sizeImage.height>IMAGE_MAX_SIZE)
        {
            sizeImage = CGSizeMake(1024, (1024*sizeImage.height)/sizeImage.width);
        }
        image = [ResizeImage imageWithImage:image scaledToSize:sizeImage];
        
        //保存图片
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        NSString *imagePathDir = [[Utils tmpDirectory] stringByAppendingPathComponent:CHAT_TEMP_DIRECTORY];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:imagePathDir];
        if (!fileExists)
        {
            //create director
            [fileManager createDirectoryAtPath:imagePathDir withIntermediateDirectories:YES  attributes:nil error:nil];
        }
        
        //save file
        NSString *imagePath = [imagePathDir stringByAppendingPathComponent:[Common createImageNameByDateTimeAndPara:i]];
        [fileManager createFileAtPath:imagePath contents:imageData attributes:nil];
        
        
        [pathArr addObject:imagePath];
    }
    //set send parameter
    [self appendTextAttachment:pathArr];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //        if (editedImage)
        //        {
        //            imageToSave = editedImage;
        //        }
        //        else
        {
            imageToSave = originalImage;
            
        }
        imageToSave = [Common rotateImage:imageToSave];
        
        // Save the new image (original or edited) to the Camera Roll
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        }
        
        //当图片尺寸过大，进行缩放处理
        CGSize sizeImage = CGSizeMake(imageToSave.size.width, imageToSave.size.height);
        if (sizeImage.width>IMAGE_MAX_SIZE && sizeImage.height>IMAGE_MAX_SIZE)
        {
            sizeImage = CGSizeMake(1024, (1024*sizeImage.height)/sizeImage.width);
        }
        imageToSave = [ResizeImage imageWithImage:imageToSave scaledToSize:sizeImage];
        
        //保存图片
        NSData *imageData = UIImageJPEGRepresentation(imageToSave, 0.5);
        NSString *imagePathDir = [[Utils tmpDirectory] stringByAppendingPathComponent:CHAT_TEMP_DIRECTORY];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:imagePathDir];
        if (!fileExists)
        {
            //create director
            [fileManager createDirectoryAtPath:imagePathDir withIntermediateDirectories:YES  attributes:nil error:nil];
        }
        
        //save file
        NSString *imagePath = [imagePathDir stringByAppendingPathComponent:[Common createImageNameByDateTime]];
        [fileManager createFileAtPath:imagePath contents:imageData attributes:nil];
        
        //set send parameter
        [self appendTextAttachment:@[imagePath]];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
