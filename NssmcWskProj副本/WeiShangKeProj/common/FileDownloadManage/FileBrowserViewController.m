//
//  FileBrowserViewController.m
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-6-19.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import "FileBrowserViewController.h"
#import "Utils.h"
#import "Common.h"
#import <WebKit/WebKit.h>

@interface FileBrowserViewController ()<MFMailComposeViewControllerDelegate,UIActionSheetDelegate,DownloadManagerDelegate,UIWebViewDelegate,WKNavigationDelegate,UIDocumentInteractionControllerDelegate>
{
    UIWebView *webViewDoc;
    WKWebView *wkWebViewDoc;
}

@end

@implementation FileBrowserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"hideDocTabBar" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [self refreshView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    self.view.backgroundColor = COLOR(239, 239, 244, 1.0);
    [self setTopNavBarTitle:self.m_fileVo.strName];
    
    UIButton *addTeamItem = [Utils buttonWithTitle:[Common localStr:@"Common_More" value:@"更多"] frame:[Utils getNavRightBtnFrame:CGSizeMake(102,76)] target:self action:@selector(doMore)];
    [self setRightBarButton:addTeamItem];
    
    //1.webView 显示内容
//    if (iOSPlatform >= 8)
//    {
//        //WKWebView 没有内存泄露，性能提高
//        wkWebViewDoc = [[WKWebView alloc]initWithFrame:CGRectZero];
//        wkWebViewDoc.navigationDelegate = self;
//        [self.view addSubview:wkWebViewDoc];
//    }
//    else
    {
        webViewDoc = [[UIWebView alloc]initWithFrame:CGRectZero];
        [webViewDoc setAutoresizesSubviews:YES];
        [webViewDoc setAutoresizingMask:UIViewAutoresizingNone];
        [webViewDoc setUserInteractionEnabled:YES];
        [webViewDoc setOpaque:YES ];
        webViewDoc.delegate = self;
        webViewDoc.backgroundColor=[UIColor clearColor];
        webViewDoc.scalesPageToFit = YES;
        [self.view addSubview:webViewDoc];
    }
    
    //2.下载文档
    self.m_scrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
    self.m_scrollView.backgroundColor = [UIColor clearColor];
    self.m_scrollView.autoresizingMask = NO;
    self.m_scrollView.clipsToBounds = YES;
    [self.view addSubview:self.m_scrollView];
    
    //icon
    self.imgViewFileIcon = [[UIImageView alloc]initWithFrame:CGRectZero];
    self.imgViewFileIcon.contentMode = UIViewContentModeScaleAspectFill;
    [self.m_scrollView addSubview:self.imgViewFileIcon];
    
    //name
    self.lblFileName = [[UILabel alloc] initWithFrame:CGRectZero];
    self.lblFileName.backgroundColor = [UIColor clearColor];
    self.lblFileName.font = [UIFont boldSystemFontOfSize:15];
    self.lblFileName.numberOfLines = 0;
    self.lblFileName.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.lblFileName.textColor = COLOR(0,0,0,1);
    self.lblFileName.textAlignment = NSTextAlignmentCenter;
    [self.m_scrollView addSubview:self.lblFileName];
    
    //size
    self.lblFileSize = [[UILabel alloc] initWithFrame:CGRectZero];
    self.lblFileSize.backgroundColor = [UIColor clearColor];
    self.lblFileSize.font = [UIFont boldSystemFontOfSize:14];
    self.lblFileSize.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.lblFileSize.textColor = COLOR(120,120,120,1);
    self.lblFileSize.textAlignment = NSTextAlignmentCenter;
    [self.m_scrollView addSubview:self.lblFileSize];
    
    //download button
    self.btnDownload = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnDownload.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
    [self.btnDownload setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnDownload setTitleColor:COLOR(136, 136, 136, 1.0) forState:UIControlStateHighlighted];
    [self.btnDownload setBackgroundImage:[Common getImageWithColor:THEME_COLOR] forState:UIControlStateNormal];
    [self.btnDownload.layer setBorderWidth:1.0];
    [self.btnDownload.layer setCornerRadius:3];
    self.btnDownload.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.btnDownload.layer setMasksToBounds:YES];
    [self.btnDownload addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.m_scrollView addSubview:self.btnDownload];
    
    //download view
    self.viewDownloadContainer = [[UIView alloc]initWithFrame:CGRectZero];
    self.viewDownloadContainer.backgroundColor = [UIColor clearColor];
    [self.m_scrollView addSubview:self.viewDownloadContainer];
    self.viewDownloadContainer.hidden = YES;
    
    self.lblDownloadProgress = [[UILabel alloc] initWithFrame:CGRectZero];
    self.lblDownloadProgress.backgroundColor = [UIColor clearColor];
    self.lblDownloadProgress.font = [UIFont boldSystemFontOfSize:15];
    self.lblDownloadProgress.textColor = COLOR(128,128,128,1);
    self.lblDownloadProgress.textAlignment = NSTextAlignmentCenter;
    [self.viewDownloadContainer addSubview:self.lblDownloadProgress];
    
    self.progressViewDownload = [[UIProgressView alloc]initWithFrame:CGRectZero];
    self.progressViewDownload.progressViewStyle = UIProgressViewStyleDefault;
    self.progressViewDownload.progressTintColor = COLOR(101, 213, 33, 1.0);
    self.progressViewDownload.trackTintColor = COLOR(221, 221, 224, 1.0);
    [self.viewDownloadContainer addSubview:self.progressViewDownload];
    
    self.btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnCancel setImage:[UIImage imageNamed:@"btn_cancel_download"] forState:UIControlStateNormal];
    [self.btnCancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.viewDownloadContainer addSubview:self.btnCancel];
}

- (void)refreshView
{
    //检查文件是否已经存在
    NSString *strFilePath = [SYDownloadManager getFilePathByURL:self.m_fileVo.strFileURL];
    BOOL fileExists = [SYDownloadManager checkFileExist:self.m_fileVo.strFileURL];
    BOOL bSupportByWebView = [Common checkDoSupportByWebView:[self.m_fileVo.strFileURL lastPathComponent]];
    self.btnRightNav.hidden = YES;
    if (fileExists && bSupportByWebView)
    {
        //解决显示TXT中文乱码问题
        if([strFilePath hasSuffix:@".txt"])
        {
            NSString *strEncodeName = @"utf-8";
            NSData* data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:strFilePath]];
            NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            //识别不到，按GBK编码再解码一次.这里不能先按GB18030解码，否则会出现整个文档无换行bug。
            if (!strTemp)
            {
                strEncodeName = @"gbk";
                strTemp = [NSString stringWithContentsOfFile:strFilePath encoding:0x80000632 error:nil];
            }
            
            //还是识别不到，按GB18030编码再解码一次.
            if (!strTemp)
            {
                strEncodeName = @"GB18030";
                strTemp = [NSString stringWithContentsOfFile:strFilePath encoding:0x80000631 error:nil];
            }
            
            //显示，使用loadData，为了保留text的字体大小和换行格式
            if (strTemp)
            {
//                if (iOSPlatform >= 8)
//                {
//                    [wkWebViewDoc loadData:data MIMEType:@"text/plain" characterEncodingName:strEncodeName baseURL:[NSURL fileURLWithPath:strFilePath]];
//                }
//                else
                {
                    [webViewDoc loadData:data MIMEType:@"text/plain" textEncodingName:strEncodeName baseURL:[NSURL fileURLWithPath:strFilePath]];
                }
            }
        }
        else
        {
            //非TXT文件
            NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL fileURLWithPath:strFilePath]];
//            if (iOSPlatform >= 8)
//            {
//                [wkWebViewDoc loadRequest:request];
//            }
//            else
            {
                [webViewDoc loadRequest:request];
            }
        }
        
//        if (iOSPlatform >= 8)
//        {
//            wkWebViewDoc.hidden = NO;
//            wkWebViewDoc.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT);
//        }
//        else
        {
            webViewDoc.hidden = NO;
            webViewDoc.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT);
        }
        self.m_scrollView.hidden = YES;
        self.btnRightNav.hidden = NO;
    }
    else
    {
//        if (iOSPlatform >= 8)
//        {
//            wkWebViewDoc.hidden = YES;
//        }
//        else
        {
            webViewDoc.hidden = YES;
        }
        self.m_scrollView.hidden = NO;
        
        //不存在或者不支持打开
        CGFloat fHeight = 67.5;
        self.m_scrollView.frame = CGRectMake(0, NAV_BAR_HEIGHT, kScreenWidth,kScreenHeight-NAV_BAR_HEIGHT);
        
        //icon
        self.imgViewFileIcon.frame = CGRectMake((kScreenWidth-75)/2, fHeight, 75, 75);
        self.imgViewFileIcon.image = [UIImage imageNamed:[Common getFileIconImageByName:self.m_fileVo.strName]];
        fHeight += 75 + 10;
        
        //name
        self.lblFileName.text = self.m_fileVo.strName;
        CGSize sizeTitle = [Common getStringSize:self.lblFileName.text font:self.lblFileName.font bound:CGSizeMake(kScreenWidth-20, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        self.lblFileName.frame = CGRectMake(10, fHeight, kScreenWidth-20, sizeTitle.height);
        fHeight += sizeTitle.height +12;
        
        //size
        self.lblFileSize.frame = CGRectMake(10, fHeight, kScreenWidth-20, 20);
        self.lblFileSize.text = [Common getFileSizeFormatString:self.m_fileVo.lFileSize];
        fHeight += 20 +20;
        
        //download UI
        self.viewDownloadContainer.frame = CGRectMake(0, fHeight, kScreenWidth, 55);
        self.lblDownloadProgress.frame = CGRectMake(10, 8, kScreenWidth-20, 20);
        //iOS7 和 iOS6不同版本的UIProgressView不同
        if(iOSPlatform == 7)
        {
            self.progressViewDownload.frame = CGRectMake(15, 8+20+5, kScreenWidth-76, 3);
            self.progressViewDownload.transform = CGAffineTransformMakeScale(1, 1.5);
        }
        else
        {
            self.progressViewDownload.frame = CGRectMake(15, 8+20+5, kScreenWidth-76, 20);
        }
        
        self.btnCancel.frame = CGRectMake(kScreenWidth-55, 9, 50, 50);
        
        if (fileExists)
        {
            self.btnDownload.tag = 1000;
            self.btnDownload.frame = CGRectMake(30, fHeight, kScreenWidth-60, 44);
            [self.btnDownload setTitle:[Common localStr:@"Documents_OpenFile_WithOtherApp" value:@"用其他应用打开"] forState:UIControlStateNormal];
            
            self.btnDownload.hidden = NO;
            self.viewDownloadContainer.hidden = YES;
            self.btnRightNav.hidden = NO;
        }
        else if([SYDownloadManager checkTempFileExist:self.m_fileVo.strFileURL])
        {
            self.btnDownload.tag = 3000;
            self.btnDownload.frame = CGRectMake(30, fHeight, kScreenWidth-60, 44);
            [self.btnDownload setTitle:[Common localStr:@"Documents_ResumeDownload" value:@"恢复下载"] forState:UIControlStateNormal];
            
            self.btnDownload.hidden = NO;
            self.viewDownloadContainer.hidden = YES;
        }
        else
        {
            //download button
            self.btnDownload.tag = 2000;
            self.btnDownload.frame = CGRectMake(30, fHeight, kScreenWidth-60, 44);
            [self.btnDownload setTitle:[Common localStr:@"Documents_DownloadFile" value:@"下载文件"] forState:UIControlStateNormal];//恢复下载
           
            self.btnDownload.hidden = NO;
            self.viewDownloadContainer.hidden = YES;
        }
        
        fHeight += 100;
        if (fHeight<kScreenHeight-NAV_BAR_HEIGHT)
        {
            fHeight = kScreenHeight-NAV_BAR_HEIGHT + 0.5;
        }
        self.m_scrollView.contentSize = CGSizeMake(kScreenWidth, fHeight);
    }
}

//启动下载
- (void)downloadAction:(UIButton *)sender
{
    if (sender.tag == 1000)
    {
        //用其他应用打开
        NSString *strFilePath = [SYDownloadManager getFilePathByURL:self.m_fileVo.strFileURL];
        NSURL *urlFile = [NSURL fileURLWithPath:strFilePath];
        if (urlFile != nil)
        {
            self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:urlFile];
            self.documentInteractionController.delegate = self;
            [self.documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view  animated:YES];
            //presentOptionsMenuFromRect 提供预览
        }
    }
    else if (sender.tag == 2000)
    {
        //下载文件
        self.btnDownload.hidden = YES;
        self.viewDownloadContainer.hidden = NO;
        
        [[SYDownloadManager sharedDownloadManager] downloadFile:self.m_fileVo.strFileURL delegate:self];
    }
    else if (sender.tag == 3000)
    {
        //恢复下载
        self.btnDownload.hidden = YES;
        self.viewDownloadContainer.hidden = NO;

        //由于AFNetworking的暂停和恢复下载有问题，所以恢复下载采用重新生成 Request 断点下载方案
        if (self.m_request != nil)
        {
            [[SYDownloadManager sharedDownloadManager]stopDownload:self.m_request];
            self.m_request = nil;
        }
        [[SYDownloadManager sharedDownloadManager] downloadFile:self.m_fileVo.strFileURL delegate:self];
    }
}

//暂停下载
- (void)cancelAction
{
    if (self.m_request != nil)
    {
        [[SYDownloadManager sharedDownloadManager] pauseDownload:self.m_request];
    }
    [self refreshView];
}

//返回则停止下载
- (void)backButtonClicked
{
    if (self.m_request != nil)
    {
        [[SYDownloadManager sharedDownloadManager] stopDownload:self.m_request];
        self.m_request = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//更多
- (void)doMore
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[Common localStr:@"Common_More" value:@"更多"] delegate:self cancelButtonTitle:[Common localStr:@"Common_Cancel" value:@"取消"] destructiveButtonTitle:[Common localStr:@"Documents_Download_Again" value:@"重新下载"] otherButtonTitles:[Common localStr:@"Documents_Send_Email" value:@"发送邮件"],[Common localStr:@"Documents_OpenWithApplication" value:@"用其他应用打开"],nil];
    [actionSheet showInView:self.view];
}

//发送邮件
-(void)sendMail
{
    NSString *strFilePath = [SYDownloadManager getFilePathByURL:self.m_fileVo.strFileURL];
    NSData *data = [NSData dataWithContentsOfFile:strFilePath];
    if (data != nil)
    {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc]init];
        if([MFMailComposeViewController canSendMail])
        {
            [controller setSubject:self.m_fileVo.strName];
            
            [controller addAttachmentData:data mimeType:@"" fileName:self.m_fileVo.strName];
            
            controller.mailComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *msg;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            msg = [Common localStr:@"Documents_Email_Cancel" value:@"邮件发送取消"];
            break;
        case MFMailComposeResultSaved:
            msg = [Common localStr:@"Documents_Email_Save" value:@"邮件保存成功"];
            break;
        case MFMailComposeResultSent:
            msg = [Common localStr:@"Documents_Email_Sent" value:@"邮件发送成功"];
            break;
        case MFMailComposeResultFailed:
            msg = [Common localStr:@"Documents_Email_Failure" value:@"邮件发送失败"];
            break;
        default:
            msg = [Common localStr:@"Documents_Email_Finished" value:@"邮件发送完毕"];
            break;
    }
    [Common bubbleTip:msg andView:self.view];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //重新下载
        NSString *strFilePath = [SYDownloadManager getFilePathByURL:self.m_fileVo.strFileURL];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL fileExists = [fileManager fileExistsAtPath:strFilePath];
        if(fileExists)
        {
            [fileManager removeItemAtPath:strFilePath error:nil];
            [self refreshView];
            self.btnDownload.tag = 2000;
            [self downloadAction:self.btnDownload];
        }
    }
    else if (buttonIndex == 1)
    {
        [self sendMail];
    }
    else if (buttonIndex == 2)
    {
        //用其他应用打开
        NSString *strFilePath = [SYDownloadManager getFilePathByURL:self.m_fileVo.strFileURL];
        NSURL *urlFile = [NSURL fileURLWithPath:strFilePath];
        if (urlFile != nil)
        {
            self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:urlFile];
            self.documentInteractionController.delegate = self;
            [self.documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view  animated:YES];
        }
    }
}

#pragma mark FileDownloadManage Delegate
//开始下载
-(void)startDownload:(SYHTTPRequestOperation *)request;
{
    self.m_request = request;
}

//更新下载进度
-(void)updateDownloadProgress:(SYHTTPRequestOperation *)request bytesOfRead:(unsigned long long)totalBytesRead bytesOfExpected:(unsigned long long)totalBytesExpectedToRead;
{
    //label progress
    NSString *strTotalSize = [Common getFileSizeFormatString:totalBytesExpectedToRead];
    NSString *strCurrentSize = [Common getFileSizeFormatString:totalBytesRead];
    self.lblDownloadProgress.text = [NSString stringWithFormat:@"%@...(%@/%@)",[Common localStr:@"Documents_Downloading" value:@"下载中"],strCurrentSize,strTotalSize];

    //set progress
    if (totalBytesExpectedToRead == 0)
    {
        self.progressViewDownload.progress = 0;
    }
    else
    {
        self.progressViewDownload.progress = (double)totalBytesRead/totalBytesExpectedToRead;
    }
}

//完成下载
-(void)finishedDownload:(SYHTTPRequestOperation *)request error:(NSError *)error
{
    //判断文件是否能够打开，能够打开，直接使用UIWebView,不能打开则显示使用其他应用打开按钮
    [self refreshView];
    
    //完成下载后是否对象
    if (self.m_request != nil)
    {
        [[SYDownloadManager sharedDownloadManager] stopDownload:self.m_request];
        self.m_request = nil;
    }
}

#pragma mark UIWebView delegate
- (void) webViewDidStartLoad:(UIWebView *)webView
{
	[self isHideActivity:NO];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
	[self isHideActivity:YES];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self isHideActivity:YES];
}

#pragma mark WKNavigationDelegate delegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self isHideActivity:NO];
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self isHideActivity:YES];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
{
    [self isHideActivity:YES];
}

#pragma mark UIDocumentInteractionControllerDelegate delegate (选择其他应用打开代理)
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}

-(UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller
{
    return self.view.frame;
}

@end
