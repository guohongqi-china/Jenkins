//
//  MeetBookPopupInfo.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 15/9/10.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "MeetBookPopupInfo.h"

@interface MeetBookPopupInfo ()<UIAlertViewDelegate>
{
    UIView *viewContainer;
    UILabel *lblName;
    UIView *viewLine;
    UILabel *lblTitle;
    UILabel *lblDesc;
    
    UIButton *btnCancel;
    
    CancelBookMeeting _cancelBlock;
    MeetingBookVo *_bookVo;
}

@end

@implementation MeetBookPopupInfo

- (instancetype)initWithFrame:(CGRect)frame bookVo:(MeetingBookVo*)bookVo block:(CancelBookMeeting)cancelBLock
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _cancelBlock = cancelBLock;
        _bookVo = bookVo;
        
        self.backgroundColor = COLOR(0, 0, 0, 0.4);
        
        
        viewContainer = [[UIView alloc]init];
        viewContainer.backgroundColor = [UIColor whiteColor];
        viewContainer.layer.cornerRadius = 4;
        viewContainer.layer.masksToBounds = YES;
        viewContainer.layer.borderWidth = 0.5;
        viewContainer.layer.borderColor = COLOR(204, 204, 204, 1.0).CGColor;
        [self addSubview:viewContainer];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackground)];
        [self addGestureRecognizer:tapGesture];
        
        CGFloat fHeight = 7;
        CGFloat fWidth = kScreenWidth - 36;
        
        //title
        lblName = [[UILabel alloc]initWithFrame:CGRectMake(17, fHeight, fWidth-34-75, 38)];
        lblName.lineBreakMode = NSLineBreakByTruncatingTail;
        NSString *strTitle;
        NSInteger nNameLength = 0;
        if (_bookVo.nState == 0)
        {
            strTitle = @"不可预订";
        }
        else
        {
            strTitle = [NSString stringWithFormat:@"%@ 已预订",_bookVo.strUserName];
            nNameLength = _bookVo.strUserName.length;
        }
        
        NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:strTitle];
        if (nNameLength > 0)
        {
            [attriString addAttribute:NSForegroundColorAttributeName value:COLOR(55, 55, 55, 1.0) range:NSMakeRange(0, nNameLength)];
            [attriString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, nNameLength)];
            [attriString addAttribute:NSForegroundColorAttributeName value:COLOR(204, 204, 204, 1.0) range:NSMakeRange(nNameLength, strTitle.length-nNameLength)];
            [attriString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(nNameLength, strTitle.length-nNameLength)];
        }
        else
        {
            [attriString addAttribute:NSForegroundColorAttributeName value:COLOR(55, 55, 55, 1.0) range:NSMakeRange(0, strTitle.length)];
            [attriString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, strTitle.length)];
        }
        lblName.font = [UIFont systemFontOfSize:15];
        lblName.attributedText = attriString;
        [viewContainer addSubview:lblName];
        
        if (_bookVo.nState == 2)
        {
            //cancel button
            btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
            btnCancel.layer.cornerRadius = 4;
            btnCancel.layer.borderWidth = 0;
            btnCancel.layer.masksToBounds = YES;
            btnCancel.frame = CGRectMake(fWidth-17-70, 12, 70, 26);
            [btnCancel setBackgroundImage:[Common getImageWithColor:COLOR(153, 153, 153, 1.0)] forState:UIControlStateNormal];
            [btnCancel setTitle:@"取消预订" forState:UIControlStateNormal];
            [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnCancel.titleLabel.font = [UIFont systemFontOfSize:14];
            [btnCancel addTarget:self action:@selector(cancelBookMeeting) forControlEvents:UIControlEventTouchUpInside];
            [viewContainer addSubview:btnCancel];
        }
        
        fHeight += 38;
        
        viewLine = [[UIView alloc]initWithFrame:CGRectMake(17, fHeight, fWidth-34, 1)];
        viewLine.backgroundColor = COLOR(109, 202, 0, 1.0);
        [viewContainer addSubview:viewLine];
        fHeight += 1+12;
        
        //主题
        lblTitle = [[UILabel alloc]init];
        lblTitle.font = [UIFont systemFontOfSize:14];
        lblTitle.textColor = COLOR(98, 98, 98, 1.0);
        lblTitle.numberOfLines = 0;
        lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
        lblTitle.text = [NSString stringWithFormat:@"主题：%@",_bookVo.strTitle];
        CGSize size = [Common getStringSize:lblTitle.text font:lblTitle.font bound:CGSizeMake(fWidth-34, MAXFLOAT) lineBreakMode:lblTitle.lineBreakMode];
        if(size.height < 15)
        {
            size.height = 15;
        }
        lblTitle.frame = CGRectMake(17, fHeight, fWidth-34, size.height);
        [viewContainer addSubview:lblTitle];
        fHeight += size.height + 10;
        
        //备注
        lblDesc = [[UILabel alloc]init];
        lblDesc.font = [UIFont systemFontOfSize:14];
        lblDesc.textColor = COLOR(98, 98, 98, 1.0);
        lblDesc.numberOfLines = 0;
        lblDesc.lineBreakMode = NSLineBreakByWordWrapping;
        lblDesc.text = [NSString stringWithFormat:@"备注：%@",_bookVo.strRemark];
        size = [Common getStringSize:lblDesc.text font:lblDesc.font bound:CGSizeMake(fWidth-34, MAXFLOAT) lineBreakMode:lblDesc.lineBreakMode];
        if(size.height < 15)
        {
            size.height = 15;
        }
        lblDesc.frame = CGRectMake(17, fHeight, fWidth-34, size.height);
        [viewContainer addSubview:lblDesc];
        fHeight += size.height + 17;
        
        viewContainer.frame = CGRectMake(18, 110+NAV_BAR_HEIGHT, kScreenWidth-36, fHeight);
    }
    
    return self;
}

//取消预订
- (void)cancelBookMeeting
{
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:nil message:@"你确认要取消该会议预订？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认",nil];
    [alertView show];
}

- (void)tapBackground
{
    [self removeFromSuperview];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        _cancelBlock(self,_bookVo);
    }
}

@end
