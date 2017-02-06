//
//  ToolView.m
//  ChinaMobileSocialProj
//
//  Created by dne on 13-11-20.
//
//

#import "ToolView.h"
#import "Utils.h"
#import "UIImage+UIImageScale.h"
#import "SYTextAttachment.h"

@implementation ToolView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGRect rect = CGRectMake(0, 0, kScreenWidth, TOOL_VIEW_HEIGHT);
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:rect];
        bgImgView.image = [UIImage imageNamed:@"tool_bg"];
        [self addSubview:bgImgView];
        
        //表情视图
        self.scrollViewFacial = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, TOOL_VIEW_HEIGHT)];
        [self.scrollViewFacial setShowsVerticalScrollIndicator:NO];
        [self.scrollViewFacial setShowsHorizontalScrollIndicator:NO];
        self.scrollViewFacial.pagingEnabled=YES;
        self.scrollViewFacial.delegate=self;
        [self addSubview:self.scrollViewFacial];
        self.scrollViewFacial.hidden = YES;
        
        int i=0;
        self.nPage = 0;
        CGFloat fOffsetW = 9;
        CGFloat fOffsetH = 16;
        CGFloat fFaceW = 28;
        CGFloat fFaceH = 28;
        NSArray *aryFace = [AppDelegate getSlothAppDelegate].aryFace;
        while (i<aryFace.count)
        {
            NSDictionary *dicFace = [aryFace objectAtIndex:i];
            if (i==0 || i%20!=0)
            {
                //1.计算该表情坐标
                
                CGFloat fX = fOffsetW+(i%20%7)*(fFaceW+18);
                CGFloat fY = fOffsetH+(i%20/7)*(fFaceH+14);
                
                UIButton *btnFaceIcon = [UIButton buttonWithType:UIButtonTypeCustom];
                btnFaceIcon.tag = i;
                btnFaceIcon.frame = CGRectMake(self.nPage*kScreenWidth+fX, fY, fFaceW, fFaceH);
                [btnFaceIcon setBackgroundImage:[UIImage imageNamed:[dicFace objectForKey:@"image"]] forState:UIControlStateNormal];
                [btnFaceIcon addTarget:self action:@selector(selectFace:) forControlEvents:UIControlEventTouchUpInside];
                [self.scrollViewFacial addSubview:btnFaceIcon];
            }
            else
            {
                CGFloat fX = fOffsetW+6*(fFaceW+18);
                CGFloat fY = fOffsetH+2*(fFaceH+14);
                
                //1.一页中最后一个元素，显示删除按钮
                UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
                btnDelete.tag = 10000; //delete button tag
                btnDelete.frame = CGRectMake(self.nPage*kScreenWidth+fX, fY, 30, 30);
                [btnDelete setBackgroundImage:[UIImage imageNamed:@"aio_face_delete"] forState:UIControlStateNormal];
                [btnDelete addTarget:self action:@selector(selectFace:) forControlEvents:UIControlEventTouchUpInside];
                [self.scrollViewFacial addSubview:btnDelete];
                
                //2.绘制第二页中第一个元素
                self.nPage++;//页码
                UIButton *btnFaceIcon = [UIButton buttonWithType:UIButtonTypeCustom];
                btnFaceIcon.tag = i;
                btnFaceIcon.frame = CGRectMake(self.nPage*kScreenWidth+fOffsetW, fOffsetH, fFaceW, fFaceH);
                [btnFaceIcon setBackgroundImage:[UIImage imageNamed:[dicFace objectForKey:@"image"]] forState:UIControlStateNormal];
                [btnFaceIcon addTarget:self action:@selector(selectFace:) forControlEvents:UIControlEventTouchUpInside];
                [self.scrollViewFacial addSubview:btnFaceIcon];
            }
            i++;
        }
        
        //绘制最后一页的删除按钮
        if (i>0)
        {
            CGFloat fX = fOffsetW+6*(fFaceW+18);
            CGFloat fY = fOffsetH+2*(fFaceH+14);
            UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
            btnDelete.tag = 10000; //delete button tag
            btnDelete.frame = CGRectMake(self.nPage*kScreenWidth+fX, fY, 30, 30);
            [btnDelete setBackgroundImage:[UIImage imageNamed:@"aio_face_delete"] forState:UIControlStateNormal];
            [btnDelete addTarget:self action:@selector(selectFace:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollViewFacial addSubview:btnDelete];
        }
        
        //分页控件
        self.pageControlFace = [[SMPageControl alloc]initWithFrame:CGRectMake(0, 145, kScreenWidth, 6)];//6
        [self.pageControlFace setPageIndicatorImage:[UIImage imageNamed:@"white_gray"]];
        [self.pageControlFace setCurrentPageIndicatorImage:[UIImage imageNamed:@"page_gray"]];
        self.pageControlFace.numberOfPages = self.nPage+1;
        [self addSubview:self.pageControlFace];
        self.pageControlFace.hidden = YES;
        
        self.scrollViewFacial.contentSize=CGSizeMake(kScreenWidth*(self.nPage+1), TOOL_VIEW_HEIGHT);
        
        //附件视图
        self.viewAttach = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, TOOL_VIEW_HEIGHT)];
        self.viewAttach.backgroundColor = [UIColor clearColor];
        [self addSubview:self.viewAttach];
        
        rect = CGRectMake(0, 50, kScreenWidth, 1);
        UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:rect];
        lineImgView.image = [UIImage imageNamed:@"tool_line"];
        [self.viewAttach addSubview:lineImgView];
        
        rect = CGRectMake(0, 0, kScreenWidth, 50);
        UIView *topView = [[UIView alloc] initWithFrame:rect];
        [self.viewAttach addSubview:topView];
        
        //相机
        int padding = 31;
        rect = CGRectMake(padding, 13, 27, 22);
        UIButton *cameraButton = [Utils buttonWithImageName:[UIImage imageNamed:@"camera"] frame:rect target:self action:@selector(cameraButton:)];
        [topView addSubview:cameraButton];
        //相册
        rect.origin.x += rect.size.width + padding;
        UIButton *photoButton = [Utils buttonWithImageName:[UIImage imageNamed:@"photo"] frame:rect target:self action:@selector(photoButton:)];
        [topView addSubview:photoButton];
        //        //视频
        //        rect.origin.x += rect.size.width + padding;
        //        UIButton *videoButton = [Utils buttonWithImageName:[UIImage imageNamed:@"video"] frame:rect target:self action:@selector(videoButton:)];
        //        [topView addSubview:videoButton];
        //        //文档
        //        rect.origin.x += rect.size.width + padding;
        //        UIButton *fileButton = [Utils buttonWithImageName:[UIImage imageNamed:@"file"] frame:rect target:self action:nil];
        //        [topView addSubview:fileButton];
        //        //网盘
        //        rect.origin.x += rect.size.width + padding;
        //        UIButton *diskButton = [Utils buttonWithImageName:[UIImage imageNamed:@"disk"] frame:rect target:self action:nil];
        //        [topView addSubview:diskButton];
        
        //创建ScrollView存放附件
        contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 51, kScreenWidth, 238)];
        contentView.pagingEnabled = YES;
        contentView.showsVerticalScrollIndicator = NO;
        [contentView setContentSize:CGSizeMake(kScreenWidth, 238)];
        [self.viewAttach addSubview:contentView];
    }
    return self;
}

//输入表情
- (void)selectFace:(UIButton*)sender
{
    if (iOSPlatform>=7)
    {
        NSMutableAttributedString *strMutable = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
        if (sender.tag == 10000)
        {
            //删除按钮
            if (strMutable.length>0)
            {
                [strMutable deleteCharactersInRange:NSMakeRange(strMutable.length-1, 1)];
            }
        }
        else
        {
            //点击表情
            NSArray *aryFace = [AppDelegate getSlothAppDelegate].aryFace;
            NSDictionary *dicFace = [aryFace objectAtIndex:sender.tag];
            
            SYTextAttachment *textAttachment = [[SYTextAttachment alloc] init];
            
            //给附件添加图片
            textAttachment.image = [UIImage imageNamed:[dicFace objectForKey:@"image"]];
            textAttachment.strFaceCHS = [dicFace objectForKey:@"chs"];
            textAttachment.bounds = CGRectMake(0, -5, 25, 25);
            
            //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
            NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
            [strMutable appendAttributedString:imageStr];
        }
        //添加字体
        [strMutable addAttributes:@{NSFontAttributeName:self.textView.font} range:NSMakeRange(0, strMutable.length)];
        self.textView.attributedText = strMutable;
    }
    else
    {
        //支持iOS 6
        if (sender.tag == 10000)
        {
            //删除按钮
            NSMutableString *strText = [NSMutableString stringWithString:self.textView.text];
            if (strText.length>0)
            {
                [strText deleteCharactersInRange:NSMakeRange(strText.length-1, 1)];
                self.textView.text = strText;
            }
        }
        else
        {
            //点击表情
            NSArray *aryFace = [AppDelegate getSlothAppDelegate].aryFace;
            NSDictionary *dicFace = [aryFace objectAtIndex:sender.tag];
            
            NSMutableString *strText = [NSMutableString stringWithString:self.textView.text];
            [strText appendString:[dicFace objectForKey:@"chs"]];
            self.textView.text = strText;
        }
    }
}

//添加照片、视频和文档
- (void)addImageToContent:(UIImage *)image index:(NSUInteger)index target:(id)target action:(SEL)action
{
    UIButton *attachButton = [Utils buttonWithImageName:image frame:CGRectMake(26+((64 + 26)*index), 18, 64, 64) target:target action:action];
    attachButton.tag = index;
    attachButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [attachButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:attachButton];
    
    [contentView setContentSize:CGSizeMake(attachButton.frame.origin.x + attachButton.frame.size.width + 26, 64)];
}

//重置布局
- (void)deleteSubView:(NSUInteger)index
{
    NSMutableArray *resultList = [[NSMutableArray alloc] init];
    for (UIView *subView in contentView.subviews)
    {
        if ([subView isKindOfClass:[UIButton class]])
        {
            if (subView.tag != index)
            {
                [resultList addObject:subView];
            }
        }
    }
    
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for ( int i = 0 ; i < [resultList count] ; i++ )
    {
        UIView *subView = [resultList objectAtIndex:i];
        subView.frame = CGRectMake(26+((64 + 26)*i), 18, 64, 64);
        subView.tag = i;
        [contentView addSubview:subView];
    }
    [contentView setContentSize:CGSizeMake((64 + 26)*[resultList count] + 26, 64)];
}

//移除所有文件视图
- (void)deleteAllSubView
{
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark - UIScrollView delegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControlFace.currentPage = self.scrollViewFacial.contentOffset.x/(kScreenWidth-12);
}

#pragma mark - ToolViewDelegate
- (IBAction)cameraButton:(id)sender{
    if (self.toolViewDelegate && [self.toolViewDelegate respondsToSelector:@selector(cameraButton:)]) {
        [self.toolViewDelegate cameraButton:sender];
    }
}

- (IBAction)photoButton:(id)sender{
    if (self.toolViewDelegate && [self.toolViewDelegate respondsToSelector:@selector(photoButton:)]) {
        [self.toolViewDelegate photoButton:sender];
    }
}

- (IBAction)videoButton:(id)sender{
    if (self.toolViewDelegate && [self.toolViewDelegate respondsToSelector:@selector(videoButton:)]) {
        [self.toolViewDelegate videoButton:sender];
    }
}

@end
