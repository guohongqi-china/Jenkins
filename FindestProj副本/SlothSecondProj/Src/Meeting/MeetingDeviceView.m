//
//  MeetingDeviceView.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/19.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "MeetingDeviceView.h"
#import "MeetingDeviceVo.h"

@interface MeetingDeviceView ()
{
    NSMutableArray *aryDevice;
}

@property (weak, nonatomic) IBOutlet UILabel *lblDevice;

@property (weak, nonatomic) IBOutlet UIButton *btnButton1;
@property (weak, nonatomic) IBOutlet UIButton *btnButton2;
@property (weak, nonatomic) IBOutlet UIButton *btnButton3;
@property (weak, nonatomic) IBOutlet UIButton *btnButton4;
@property (weak, nonatomic) IBOutlet UIButton *btnButton5;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottom;
@property (weak, nonatomic) IBOutlet UIView *viewDeviceContainer;
@property (weak, nonatomic) IBOutlet UIView *bottomVIew;
@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@end

@implementation MeetingDeviceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:@"MeetingDeviceView" owner:self options:nil];
        self.view.frame = frame;
        
        [self initData];
        [self initView];
    }
    return self;
}

- (void)initView
{
    
    [_btnButton1 setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"deveice_btnColor"]] forState:UIControlStateNormal];
    [_btnButton1 setBackgroundImage:[Common getImageWithColor:COLOR(239, 111, 88, 1.0)] forState:UIControlStateSelected];
    
    [_btnButton2 setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"deveice_btnColor"]] forState:UIControlStateNormal];
    [_btnButton2 setBackgroundImage:[Common getImageWithColor:COLOR(239, 111, 88, 1.0)] forState:UIControlStateSelected];
    
    [_btnButton3 setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"deveice_btnColor"]] forState:UIControlStateNormal];
    [_btnButton3 setBackgroundImage:[Common getImageWithColor:COLOR(239, 111, 88, 1.0)] forState:UIControlStateSelected];
    
    [_btnButton4 setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"deveice_btnColor"]] forState:UIControlStateNormal];
    [_btnButton4 setBackgroundImage:[Common getImageWithColor:COLOR(239, 111, 88, 1.0)] forState:UIControlStateSelected];
    
    [_btnButton5 setBackgroundImage:[Common getImageWithColor:[SkinManage colorNamed:@"deveice_btnColor"]] forState:UIControlStateNormal];
    [_btnButton5 setBackgroundImage:[Common getImageWithColor:COLOR(239, 111, 88, 1.0)] forState:UIControlStateSelected];
    
    
    _deviceLabel.textColor = [SkinManage colorNamed:@"Tab_Item_Color"];
    _viewDeviceContainer.backgroundColor = [SkinManage colorNamed:@"other_other_color"];
    self.bottomVIew.backgroundColor = [SkinManage colorNamed:@"other_other_color"];
    self.backgroundView.backgroundColor = [SkinManage colorNamed:@"Wire_Frame_Color"];
}

- (void)initData
{
    aryDevice = [NSMutableArray array];
    MeetingDeviceVo *deviceVo = [[MeetingDeviceVo alloc]init];
    deviceVo.strName = @"投影仪";
    deviceVo.bChecked = NO;
    [aryDevice addObject:deviceVo];
    
    deviceVo = [[MeetingDeviceVo alloc]init];
    deviceVo.strName = @"电视";
    deviceVo.bChecked = NO;
    [aryDevice addObject:deviceVo];
    
    deviceVo = [[MeetingDeviceVo alloc]init];
    deviceVo.strName = @"电话";
    deviceVo.bChecked = NO;
    [aryDevice addObject:deviceVo];
    
    deviceVo = [[MeetingDeviceVo alloc]init];
    deviceVo.strName = @"麦克风";
    deviceVo.bChecked = NO;
    [aryDevice addObject:deviceVo];
    
    deviceVo = [[MeetingDeviceVo alloc]init];
    deviceVo.strName = @"视频会议系统";
    deviceVo.bChecked = NO;
    [aryDevice addObject:deviceVo];
}

- (void)refreshView
{
    for (int i=0;i<5;i++)
    {
        MeetingDeviceVo *deviceVo = aryDevice[i];
        UIButton *btn = [_viewDeviceContainer viewWithTag:101+i];
        btn.selected = deviceVo.bChecked;
    }
    
    _lblDevice.text = [self getDeviceString];
}

- (void)showWithAnimation
{
    self.view.alpha = 0;
    [UIView animateWithDuration:0.1 animations:^{
        self.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.constraintBottom.constant = 0;
            [self.view layoutIfNeeded];
        } completion:nil];
    }];
}

- (void)dismissWithAnimation
{
    [UIView animateWithDuration:0.2 animations:^{
        self.constraintBottom.constant = -320;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.view.alpha = 1.0;
        [UIView animateWithDuration:0.1 animations:^{
            self.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
        }];
    }];
}

- (IBAction)buttonAction:(UIButton *)sender
{
    if (sender.tag == 100)
    {
        [self dismissWithAnimation];
    }
    else if (sender.tag >= 101 && sender.tag <= 105)
    {
        sender.selected = !sender.selected;
        _lblDevice.text = [self getDeviceString];
    }
    else if (sender.tag == 106)
    {
        //完成
        NSMutableString *strDevice = [[NSMutableString alloc]init];
        for (int i=0;i<5;i++)
        {
            MeetingDeviceVo *deviceVo = aryDevice[i];
            UIButton *btn = [_viewDeviceContainer viewWithTag:101+i];
            if (btn.selected)
            {
                [strDevice appendString:@"1,"];
                deviceVo.bChecked = YES;
            }
            else
            {
                [strDevice appendString:@"0,"];
                deviceVo.bChecked = NO;
            }
        }
        
        NSString *strResult;
        if (strDevice.length > 0)
        {
            strResult = [strDevice substringToIndex:strDevice.length-1];
        }
        else
        {
            strResult = nil;
        }
        
        [self.delegate completedChooseDevice:strResult name:_lblDevice.text];
        [self dismissWithAnimation];
    }
}

- (NSString *)getDeviceString
{
    NSMutableString *strDevice = [[NSMutableString alloc]init];
    for (int i=0;i<5;i++)
    {
        MeetingDeviceVo *deviceVo = aryDevice[i];
        UIButton *btn = [_viewDeviceContainer viewWithTag:101+i];
        if (btn.selected)
        {
            [strDevice appendFormat:@"%@、",deviceVo.strName];
        }
    }
    
    NSString *strResult;
    if (strDevice.length > 0)
    {
        strResult = [strDevice substringToIndex:strDevice.length-1];
    }
    else
    {
        strResult = @"不限";
    }
    return strResult;
}

@end
