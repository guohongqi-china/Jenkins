//
//  FaceLabel.m
//  TestFaceProj
//
//  Created by 焱 孙 on 10/14/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import "FaceLabel.h"
#import "UIImage+GIF.h"
#import "Common.h"
#import "AppDelegate.h"

#define BEGIN_FLAG @"["
#define END_FLAG @"]"

//使用注意
//1.使用initWithFrame初始化，frame可以设置为CGRectZero
//2.调用calculateTextHeight,传入有效的size
//3.设置Labell有效的frame
//4.setText,然后会自动调用drawRect

static FaceLabel *faceLabelInstance = nil;

@interface FaceLabel ()
{
    UIColor *colorReplyName;
    NSRange rangeReplyName;
}

@end

@implementation FaceLabel

//建立一个FaceLabel的单例，用于计算表情label的高度
+ (id)getFaceLabelInstanceWithFont:(UIFont*)font
{
    if( faceLabelInstance == nil)
    {
        faceLabelInstance = [[FaceLabel alloc] initWithFrame:CGRectZero andFont:nil];
        faceLabelInstance.bShowGIF = YES;
    }
    faceLabelInstance.font = font;
    return faceLabelInstance;
}

- (id)initWithFrame:(CGRect)frame andFont:(UIFont*)font
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initData:font];
    }
    return self;
}

//从XIB中加载，运行顺序 - 先运行initLabelWithFont，再运行awakeFromNib
- (void)awakeFromNib
{
    // Initialization code
}

- (void)initData:(UIFont*)font
{
    self.aryTextFace = [NSMutableArray array];
    self.aryGifImage = [NSMutableArray array];
    
    self.numberOfLines = 0;
    self.lineBreakMode = NSLineBreakByCharWrapping;
    self.textAlignment = NSTextAlignmentLeft;
    self.userInteractionEnabled = NO;
    self.font = font;
}

- (void)initLabelWithFont:(UIFont *)font
{
    [self initData:font];
}

- (void)setReplyNameColor:(UIColor*)color range:(NSRange)range
{
    colorReplyName = color;
    rangeReplyName = range;
}

 //Only override drawRect: if you perform custom drawing.
 //An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self.textColor set];
    
    //clear buffer image
    for (UIImageView *imgView in self.aryGifImage)
    {
        [imgView removeFromSuperview];
    }
    [self.aryGifImage removeAllObjects];
    
    //如果没有表情数据，直接绘制文本，然后结束
    if( [self.aryTextFace count]==1)
    {
        if (![self.text hasPrefix:BEGIN_FLAG] || ![self.text hasSuffix:END_FLAG])
        {
            //设置回复颜色
            [super drawRect:rect];
            return;
        }
    }
    
    CGFloat upX=0;
    CGFloat upY=0;
    
    CGFloat fTextSize = self.font.lineHeight;
    CGFloat fFaceSize = fTextSize+4;
    CGFloat maxWidth   = self.frame.size.width;
    NSInteger numberOfLines = 1;
    
    for (int i=0;i<[self.aryTextFace count];i++)
    {
        NSString *str=[self.aryTextFace objectAtIndex:i];
        
        NSInteger nFaceIndex = -1;  //是否存在该表情
        if ([str hasPrefix:BEGIN_FLAG]&&[str hasSuffix:END_FLAG])
        {
            //验证表情是否存在
            nFaceIndex = [self checkFaceExist:str];
        }
        
        if (nFaceIndex>=0)
        {
            //表情数据
            NSArray *aryFace = [AppDelegate getSlothAppDelegate].aryFace;
            NSDictionary *dicGif = [aryFace objectAtIndex:nFaceIndex];
            
            //显示GIF或者PNG
            UIImage *imgFace = nil;
            if (self.bShowGIF)
            {
                imgFace = [UIImage sd_animatedGIFNamed:[dicGif objectForKey:@"image"]];
            }
            else
            {
                imgFace = [UIImage imageNamed:[dicGif objectForKey:@"image"]];
            }
            
            if ((upX+fFaceSize) > maxWidth)
            {
                //换行处理
                if (self.numberOfLines != 0 && self.numberOfLines<=numberOfLines)
                {
                    return;
                }
                
                numberOfLines ++;
                upY = upY + fTextSize;
                upX = 0;
            }
            
            //真正需要绘制的时候才加上，有可能指定行数不足,提前return
            UIImageView *imageView = [[UIImageView alloc] initWithImage:imgFace];
            [self addSubview:imageView];
            [self.aryGifImage addObject:imageView];
            
            
            imageView.frame = CGRectMake(upX, upY-2, fFaceSize, fFaceSize);
            upX += fFaceSize;//另起一行
        }
        else
        {
            //绘制普通文本（逐个字符绘制）
            NSRange range;
            for (int j = 0; j < str.length; j+=range.length)
            {
                //解决Emoji Unicode表情（4字节）
                range = [str rangeOfComposedCharacterSequenceAtIndex:j];
                NSString *temp = [str substringWithRange:range];
                if([temp isEqualToString:@"\n"])
                {
                    //换行处理
                    if (self.numberOfLines != 0 && self.numberOfLines<=numberOfLines)
                    {
                        return;
                    }
                    
                    numberOfLines ++;
                    upY += fTextSize;
                    upX = 0;
                }
                else
                {
                    NSDictionary *dicAttributes;
                    if (colorReplyName !=nil && i==0 && j>=0 && j<(rangeReplyName.location+rangeReplyName.length))
                    {
                        //为了设置回复和回复人的颜色
                        if (j==0 || j==1)
                        {
                            dicAttributes = @{NSFontAttributeName:self.font,NSForegroundColorAttributeName:[SkinManage colorNamed:@"Comment_Reply_Color"]};
                        }
                        else
                        {
                            dicAttributes = @{NSFontAttributeName:self.font,NSForegroundColorAttributeName:colorReplyName};
                        }
                    }
                    else
                    {
                        dicAttributes = @{NSFontAttributeName:self.font,NSForegroundColorAttributeName:self.textColor};
                    }
                    
                    CGSize size=[Common getStringSize:temp font:self.font bound:CGSizeMake(MAXFLOAT, fTextSize) lineBreakMode:self.lineBreakMode];
                    if ((upX+size.width) > maxWidth)
                    {
                        //换行处理
                        if (self.numberOfLines != 0 && self.numberOfLines<=numberOfLines)
                        {
                            return;
                        }

                        //当大于一行最大宽度，进行换行
                        numberOfLines ++;
                        upY += size.height;
                        upX = 0;
                    }
                    
                    if (iOSPlatform >= 7)
                    {
                        [temp drawInRect:CGRectMake(upX, upY, size.width, size.height) withAttributes:dicAttributes];
                    }
                    else
                    {
                        NSAttributedString *attributedString = [[NSAttributedString alloc]initWithString:temp attributes:dicAttributes];
                        [attributedString drawInRect:CGRectMake(upX, upY, size.width, size.height)];
                    }
                    upX += size.width;
                }
            }
        }
    }
}

//递归函数：将数据分割成一个数组，表情和普通聊天分开
-(void)getImageRange:(NSString*)message
{
    if(message == nil || message.length == 0)
    {
        return;
    }
    
    //1.找【BEGIN_FLAG】
    NSRange rangeBegin =[message rangeOfString:BEGIN_FLAG];
    if (rangeBegin.length>0)
    {
        //2.从左括号开始的地方向右,进行【END_FLAG】的查找
        NSRange rangeEnd = [message rangeOfString:END_FLAG options:NSCaseInsensitiveSearch range:NSMakeRange(rangeBegin.location, message.length-rangeBegin.location)];
        if(rangeEnd.length>0)
        {
            //3.从右括号开始逆向寻找最近的左括号NSBackwardsSearch（防止出现多个左括号，肯定会找到一个）
            rangeBegin = [message rangeOfString:BEGIN_FLAG options:NSCaseInsensitiveSearch | NSBackwardsSearch range:NSMakeRange(0, rangeEnd.location)];
            
            //A.表情之前的数据
            if (rangeBegin.location>0)
            {
                [self.aryTextFace addObject:[message substringToIndex:rangeBegin.location]];
            }
            
            //B.表情数据
            [self.aryTextFace addObject:[message substringWithRange:NSMakeRange(rangeBegin.location, rangeEnd.location-rangeBegin.location+1)]];
            
            //C.表情之后的数据（需要递归求后面的数据）
            if (rangeEnd.location+1<message.length)
            {
                [self getImageRange:[message substringFromIndex:rangeEnd.location+1]];
            }
        }
        else
        {
            //没有表情 - 递归出口
            [self.aryTextFace addObject:message];
        }
    }
    else
    {
        //没有表情 - 递归出口
        [self.aryTextFace addObject:message];
    }
}

//主要是计算高度，同时赋值文本（用于后面的drawRect）
-(void)setText:(NSString *)text
{
    if (self.aryTextFace.count == 0)
    {
        [self getImageRange:text];
    }
    
    if( [self.aryTextFace count]==1 && colorReplyName !=nil && (![self.text hasPrefix:BEGIN_FLAG] || ![self.text hasSuffix:END_FLAG]))
    {
        //为了设置回复和回复人的颜色
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:text];
        [attriString addAttribute:NSForegroundColorAttributeName value:[SkinManage colorNamed:@"Comment_Reply_Color"] range:NSMakeRange(0, 2)];
        [attriString addAttribute:NSForegroundColorAttributeName value:colorReplyName range:rangeReplyName];
        [attriString addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, text.length)];
        [super setAttributedText:attriString];
    }
    else
    {
        [super setText:text];
    }
}

- (void)setAttributedText:(NSAttributedString*)attributedString
{
    if (self.aryTextFace.count == 0)
    {
        [self getImageRange:attributedString.string];
    }
    [super setAttributedText:attributedString];
}

- (CGSize)calculateTextHeight:(NSString *)text andBound:(CGSize)sizeBound
{
    [self.aryTextFace removeAllObjects];
    //分割文字和表情数组
    [self getImageRange:text];
    
    CGFloat upX=0;
    CGFloat upY=0;
    
    //如果没有表情数据，直接计算文本size，然后结束
    //self.aryTextFace.count == 1说明只有文本，如果只有一个表情则还会有个空字符串""
    if( [self.aryTextFace count]==1)
    {
        CGSize sizeResult = CGSizeZero;
        if (![text hasPrefix:BEGIN_FLAG] || ![text hasSuffix:END_FLAG])
        {
            sizeResult = [Common getStringSize:text font:self.font bound:sizeBound lineBreakMode:self.lineBreakMode];
            return sizeResult;
        }
    }
    
    //字号的最大的大小，有的会小于该大小，最大不超过pointSize （[UIFont systemFontOfSize:20]，pointSize:20）
    CGFloat fTextSize = self.font.lineHeight;
    CGFloat fFaceSize = fTextSize+4;
    CGFloat maxWidth   = sizeBound.width;
    CGFloat fCurMaxWidth = 0;//当前所有行中最大的行宽
    
    for (int i=0;i<[self.aryTextFace count];i++)
    {
        NSString *str=[self.aryTextFace objectAtIndex:i];
        NSInteger nFaceIndex = -1;  //是否存在该表情
        if ([str hasPrefix:BEGIN_FLAG]&&[str hasSuffix:END_FLAG])
        {
            //验证表情是否存在
            nFaceIndex = [self checkFaceExist:str];
        }
        
        if (nFaceIndex>=0)
        {
            //表情
            if ((upX+fFaceSize) > maxWidth)
            {
                //换行时保存最大行宽
                if (upX>fCurMaxWidth)
                {
                    fCurMaxWidth = upX;
                }
                
                upY += fTextSize;
                upX = 0;//换行，则宽度归0
            }
            
            upX += fFaceSize;//另起一行
        }
        else
        {
            //非表情，逐个字符计算
            NSRange range;
            for (int j = 0; j < str.length; j+=range.length)
            {
                //解决Emoji Unicode表情（4字节）
                range = [str rangeOfComposedCharacterSequenceAtIndex:j];
                NSString *temp = [str substringWithRange:range];
                if([temp isEqualToString:@"\n"])
                {
                    //换行时保存最大行宽
                    if (upX>fCurMaxWidth)
                    {
                        fCurMaxWidth = upX;
                    }
                    
                    //换行符号
                    upY += fTextSize;
                    upX = 0;
                }
                else
                {
                    CGSize size=[Common getStringSize:temp font:self.font bound:CGSizeMake(fTextSize, fTextSize) lineBreakMode:self.lineBreakMode];
                    if ((upX+size.width) > maxWidth)
                    {
                        //换行时保存最大行宽
                        if (upX>fCurMaxWidth)
                        {
                            fCurMaxWidth = upX;
                        }
                        
                        //当大于一行最大宽度，进行换行
                        upY += size.height;
                        upX = 0;
                    }
                    
                    upX += size.width;
                }
            }
        }
    }
    
    upY += fTextSize;//加上最后一行高度（高度从0开始）
    if (upX>fCurMaxWidth)
    {
        fCurMaxWidth = upX;
    }
    return CGSizeMake(fCurMaxWidth, upY);
}

-(NSInteger)checkFaceExist:(NSString*)strFace
{
    NSInteger nResult = -1;
    NSArray *aryFace = [AppDelegate getSlothAppDelegate].aryFace;
    if (aryFace != nil)
    {
        for (NSUInteger i=0; i<aryFace.count; i++)
        {
            if ([aryFace[i][@"chs"] isEqualToString:strFace])
            {
                nResult = i;
                break;
            }
        }
    }
    return nResult;
}

@end
