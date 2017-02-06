//
//  InPutView.m
//  SlothSecondProj
//
//  Created by visionet on 14-3-26.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "InPutView.h"
#import "Utils.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+UIImageScale.h"
#import "ResizeImage.h"
#import "UIImage+Extras.h"
#import "KTPhotoScrollViewController.h"
#import "SDWebImageDataSource.h"
#import "AttachmentVo.h"
#import "SYTextAttachment.h"

@implementation InPutView

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = COLOR(0,0,0,0.5);
    }
    return self;
}

-(void)initView
{
    //init data
    self.attachList = [NSMutableArray array];
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight)];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_bgView];
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.frame = CGRectMake(0, 5.5, 50, 31);
    [self.cancelBtn setTitleColor:COLOR(56, 57, 61, 1.0) forState:UIControlStateNormal];
    [self.cancelBtn.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:16.0]];
    self.cancelBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.cancelBtn setTitle:[Common localStr:@"Common_Cancel" value:@"取消"] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(doCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:self.cancelBtn];
    
    self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, kScreenWidth-120, 40)];
    self.titleLab.backgroundColor = [UIColor clearColor];
    self.titleLab.font = [UIFont systemFontOfSize:19];
    self.titleLab.textAlignment = NSTextAlignmentCenter;
    self.titleLab.text = self.titleStr;
    self.titleLab.textColor = COLOR(19, 19, 19, 1.0);
    [self.bgView addSubview:_titleLab];
    
    self.sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendBtn.frame = CGRectMake(270, 5.5, 50, 31);
    [self.sendBtn setTitleColor:COLOR(56, 57, 61, 1.0) forState:UIControlStateNormal];
    [self.sendBtn.titleLabel setFont:[UIFont fontWithName:APP_FONT_NAME size:16.0]];
    self.sendBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.sendBtn setTitle:[Common localStr:@"Common_NAV_Send" value:@"发送"] forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(doSend) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:self.sendBtn];
    
    self.inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(9, 40, kScreenWidth-18, 81)];
    self.inputTextView.font = [UIFont systemFontOfSize:16];
    self.inputTextView.backgroundColor = COLOR(237, 237, 237, 1.0);
    [self.bgView addSubview:_inputTextView];
    [self.inputTextView becomeFirstResponder];
    
    //attach view and tool view
    self.attachView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-45, kScreenWidth, 45)];
    self.attachView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.attachView];
    
    self.btnAttach = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnAttach.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15.0]];
    self.btnAttach.frame = CGRectMake(kScreenWidth-60, 10, 50, 25);
    [self.btnAttach setBackgroundImage:[[UIImage imageNamed:@"btn_attach_bk"] stretchableImageWithLeftCapWidth:16 topCapHeight:9] forState:UIControlStateNormal];
    [self.btnAttach addTarget:self action:@selector(clickToolViewBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.attachView addSubview:self.btnAttach];
    
    //attach image
    self.imgViewAttachIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"attach_icon"]];
    self.imgViewAttachIcon.frame = CGRectMake((50-15)/2, (25-13.5)/2, 15, 13.5);
    [self.btnAttach addSubview:self.imgViewAttachIcon];
    
    //表情按钮
    self.btnFace = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnFace setImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
    [self.btnFace addTarget:self action:@selector(clickToolViewBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.btnFace.frame = CGRectMake(kScreenWidth-70, 5, 70, 34);//kScreenWidth-60-50
    [self.attachView addSubview:self.btnFace];
    
    //工具栏
    self.toolView = [[ToolView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, TOOL_VIEW_HEIGHT)];
    self.toolView.textView = self.inputTextView;
    self.toolView.toolViewDelegate = self;
    [self addSubview:self.toolView];
    
    //注册键盘侦听事件
    [self registerForKeyboardNotifications];
    
    //    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doCancel)];
    //    [self addGestureRecognizer:singleTap];
}

-(void)initInputViewControlValue
{
    [self.inputTextView becomeFirstResponder];
    [self.attachList removeAllObjects];
    self.inputTextView.text = @"";
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    self.toolView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, TOOL_VIEW_HEIGHT);
    self.attachView.frame = CGRectMake(0, kScreenHeight-kbSize.height-self.attachView.frame.size.height, kScreenWidth, self.attachView.frame.size.height);
    self.bgView.frame = CGRectMake(0, self.attachView.frame.origin.y-131, kScreenWidth, 400);
    [UIView commitAnimations];
    
    self.keyboardIsShow = YES;
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    self.attachView.frame = CGRectMake(0, kScreenHeight-self.attachView.frame.size.height, kScreenWidth, self.attachView.frame.size.height);
    self.bgView.frame = CGRectMake(0, self.attachView.frame.origin.y-131, kScreenWidth, 400);
    [UIView commitAnimations];
    self.keyboardIsShow = NO;
}

-(void)doCancel
{
    self.inputTextView.text = @"";
    [self removeFromSuperview];
    if([self.delegate respondsToSelector:@selector(cancelSend)])
    {
        [self.delegate cancelSend];
    }
}

-(void)doSend
{
    if (self.inputTextView.text.length == 0)
    {
        [Common tipAlert:[Common localStr:@"Common_Check_ContentEmpty" value:@"内容不能为空"]];
        return;
    }
    else
    {
        NSString *strText = @"";
        //TextView表情解析
        if (iOSPlatform >= 7)
        {
            NSMutableAttributedString *strAttribute = [[NSMutableAttributedString alloc] initWithAttributedString:self.inputTextView.attributedText];
            NSMutableArray *aryRange = [NSMutableArray array];
            NSRange effectiveRange = { 0, 0 };
            do {
                NSRange range = NSMakeRange (NSMaxRange(effectiveRange),[strAttribute length] - NSMaxRange(effectiveRange));
                NSDictionary *attributeDict = [strAttribute attributesAtIndex:range.location longestEffectiveRange:&effectiveRange inRange:range];
                SYTextAttachment *temp = (SYTextAttachment *)[attributeDict objectForKey:@"NSAttachment"];
                if (temp != nil)
                {
                    [aryRange addObject:[NSValue valueWithRange:effectiveRange]];
                }
            } while (NSMaxRange(effectiveRange) < [strAttribute length]);
            
            for (long i=aryRange.count-1; i>=0; i--)
            {
                NSRange range;
                [[aryRange objectAtIndex:i] getValue:&range];
                NSDictionary *attributeDict = [strAttribute attributesAtIndex:range.location longestEffectiveRange:&effectiveRange inRange:range];
                SYTextAttachment *temp = (SYTextAttachment *)[attributeDict objectForKey:@"NSAttachment"];
                [strAttribute replaceCharactersInRange:range withAttributedString:[[NSAttributedString alloc] initWithString:temp.strFaceCHS]];
            }
            
            strText = strAttribute.mutableString;
        }
        else
        {
            //iOS6
            strText = self.inputTextView.attributedText.string;
        }
        
        [self.delegate completeSend:strText];
    }
}

- (void)hideAttachView:(BOOL)bHide
{
    if (bHide)
    {
        self.attachView.frame = CGRectZero;
    }
}

////////////////////////////////////////////////////////////////
//tool view button
- (void)clickToolViewBtn:(UIButton*)sender
{
    if (self.keyboardIsShow || self.toolView.frame.origin.y == kScreenHeight
        || (sender == self.btnAttach && self.toolView.viewAttach.hidden == YES)         //若是附件按钮点击，但是当前没有显示附件视图
        || (sender == self.btnFace && self.toolView.scrollViewFacial.hidden == YES))    //若是表情按钮点击，但是当前没有显示表情视图
    {
        [[Utils findFirstResponderBeneathView:self] resignFirstResponder];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.toolView.frame = CGRectMake(0, kScreenHeight-TOOL_VIEW_HEIGHT, kScreenWidth, TOOL_VIEW_HEIGHT);
            self.attachView.frame = CGRectMake(0, kScreenHeight-TOOL_VIEW_HEIGHT-self.attachView.frame.size.height, kScreenWidth, self.attachView.frame.size.height);
            self.bgView.frame = CGRectMake(0, self.attachView.frame.origin.y-131, kScreenWidth, 400);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.toolView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, KEYBOARD_HEIGHT);
            self.attachView.frame = CGRectMake(0, kScreenHeight-self.attachView.frame.size.height, kScreenWidth, self.attachView.frame.size.height);
            self.bgView.frame = CGRectMake(0, self.attachView.frame.origin.y-131, kScreenWidth, 400);
        }];
    }
    
    //更新ToolView显示状态
    if (sender == self.btnAttach)
    {
        self.toolView.viewAttach.hidden = NO;
        self.toolView.scrollViewFacial.hidden = YES;
        self.toolView.pageControlFace.hidden = YES;
    }
    else
    {
        self.toolView.viewAttach.hidden = YES;
        self.toolView.scrollViewFacial.hidden = NO;
        self.toolView.pageControlFace.hidden = NO;
    }
}

#pragma mark - Tool view delegate
//拍照
- (void)cameraButton:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        return;
    }
    UIImagePickerController *photoController = [[UIImagePickerController alloc] init];
    photoController.delegate = self;
    photoController.sourceType = UIImagePickerControllerSourceTypeCamera;
    photoController.mediaTypes = @[(NSString*)kUTTypeImage];
    photoController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    photoController.allowsEditing = NO;
    [self.parentController presentViewController:photoController animated:YES completion:nil];
}

//相册
- (void)photoButton:(id)sender
{
    UIImagePickerController *photoController = [[UIImagePickerController alloc] init];
    photoController.delegate = self;
    photoController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    photoController.mediaTypes = [NSArray arrayWithObjects:@"public.image", nil];
    photoController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    photoController.allowsEditing = NO;
    [self.parentController presentViewController:photoController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //    [navigationController.navigationBar setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor blackColor]}];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSUInteger nAttachAndImageCount = self.attachList.count;
    if (nAttachAndImageCount >= 5) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:[Common localStr:@"Common_Upload_Tip" value:@"最大允许上传附件个数为5个。"]
                                                           delegate:nil
                                                  cancelButtonTitle:[Common localStr:@"Common_OK" value:@"确定"]
                                                  otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (editedImage)
        {
            imageToSave = editedImage;
        }
        else
        {
            imageToSave = originalImage;
        }
        
        // Save the new image (original or edited) to the Camera Roll
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        }
        
        //当图片尺寸过大，进行缩放处理
        CGSize sizeImage = CGSizeMake(imageToSave.size.width, imageToSave.size.height);
        if (sizeImage.width>IMAGE_MAX_SIZE && sizeImage.height>IMAGE_MAX_SIZE)
        {
            sizeImage = CGSizeMake(640, (640*sizeImage.height)/sizeImage.width);
        }
        imageToSave = [ResizeImage imageWithImage:imageToSave scaledToSize:sizeImage];
        
        //保存图片
        NSData *imageData = UIImageJPEGRepresentation(imageToSave, 0.8f);
        NSString *imagePath = [[Utils tmpDirectory] stringByAppendingPathComponent:[Common createImageNameByDateTime]];
        [imageData writeToFile:imagePath atomically:YES];
        
        [self addAttachmentWithPath:imagePath image:imageToSave andType:0];
    }
    else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
    {
        //设置视频的质量
        picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        
        //保存图片
        NSString *videoPath = [[Utils tmpDirectory] stringByAppendingString:[Common createVideoNameByDateTime]];
        NSData *videoData = [NSData dataWithContentsOfURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        [videoData writeToFile:videoPath atomically:YES];
        
        //显示缩略图
        UIImage *thumbnailImage = [ResizeImage imageWithImage:[Common getThumbnailFromVideo:[NSURL fileURLWithPath:videoPath]] scaledToSize:CGSizeMake(64*2.0, 64*2.0)];
        [self addAttachmentWithPath:videoPath image:thumbnailImage andType:1];
    }
    [picker  dismissViewControllerAnimated:YES completion: nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker  dismissViewControllerAnimated:YES completion:nil];
}

//nType,0:图片，1:附件
- (void)addAttachmentWithPath:(NSString *)path image:(UIImage *)image andType:(int)nType
{
    AttachmentVo *attachmentVo = [[AttachmentVo alloc]init];
    attachmentVo.nAttachType = nType;
    attachmentVo.strAttachLocalPath = path;
    NSUInteger count = self.attachList.count;
    [self.attachList addObject:attachmentVo];
    [self.toolView addImageToContent:image index:count target:self action:@selector(previewButton:)];
}

- (void)previewButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    self.previewButton = button;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:[Common localStr:@"Common_Cancel" value:@"取消"]
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:[Common localStr:@"Common_Preview" value:@"预览"], [Common localStr:@"Common_Remove" value:@"移除"], nil];
    actionSheet.tag = button.tag;
    [actionSheet showInView:self];
}

#pragma mark - Action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUInteger tag = self.previewButton.tag;
    if (actionSheet.tag == tag)
    {
        AttachmentVo *attachmentVo = [self.attachList objectAtIndex:tag];
        if (buttonIndex == 0)
        {
            //预览
            if (attachmentVo.nAttachType == 0)
            {
                //图片
                SDWebImageDataSource *dataSource = [[SDWebImageDataSource alloc] init];
                dataSource.images_ = [NSArray arrayWithObject:[NSArray arrayWithObject:[NSURL fileURLWithPath:attachmentVo.strAttachLocalPath]]];
                
                KTPhotoScrollViewController *photoScrollViewController = [[KTPhotoScrollViewController alloc]
                                                                          initWithDataSource:dataSource
                                                                          andStartWithPhotoAtIndex:0];
                photoScrollViewController.bShowToolBarBtn = NO;
                [self.parentController presentViewController:photoScrollViewController animated:YES completion: nil];
            }
            else
            {
                //other attachment
            }
        }
        else if (buttonIndex == 1)
        {
            //移除
            if (attachmentVo.strAttachLocalPath)
            {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                BOOL fileExists = [fileManager fileExistsAtPath:attachmentVo.strAttachLocalPath];
                if (fileExists)
                {
                    [fileManager removeItemAtPath:attachmentVo.strAttachLocalPath error:nil];
                }
                
                [self.attachList removeObjectAtIndex:tag];
                [self.toolView deleteSubView:tag];
            }
        }
    }
}

@end
