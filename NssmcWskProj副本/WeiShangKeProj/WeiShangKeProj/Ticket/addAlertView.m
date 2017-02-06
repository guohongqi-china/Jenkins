//
//  addAlertView.m
//  NssmcWskProj
//
//  Created by MacBook on 16/5/25.
//  Copyright © 2016年 visionet. All rights reserved.
//


typedef enum _hadStartSubmit{
   noStartSubmitAction, //没有发送提交请求
    hadStartSubmitAction//已经发送提交请求
}hadStartSubmit;


#import "addAlertView.h"
#import "MBProgressHUD+GHQ.h"
#import "GHQTimeToCalculate.h"
#import "ServerURL.h"
#import "TichetServise.h"
#import "TijiaoModel.h"
#import "RecordModel.h"
#import "WorkOrderDetailsViewControll.h"
@interface addAlertView ()<RecordModelDelegate>
    {
        hadStartSubmit actionType;
    }
@property (nonatomic, strong) RecordModel *RDModel;/** <#注释#> */
@end
@implementation addAlertView
//phone_icon.png
//Vo@2x.png

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_judgeTextField resignFirstResponder];
}
- (BOOL)isNullToString:(id)string
    {
        if ([string isEqual:@"NULL"] || [string isKindOfClass:[NSNull class]] || [string isEqual:[NSNull null]] || [string isEqual:NULL] || [[string class] isSubclassOfClass:[NSNull class]] || string == nil || string == NULL || [string isKindOfClass:[NSNull class]] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0 || [string isEqualToString:@"<null>"] || [string isEqualToString:@"(null)"])
        {
            return YES;
            
            
        }else
        {
            
            return NO;
        }
    }
- (IBAction)tijioabutton:(UIButton *)sender {
    NSString *text = _judgeTextField.text;
    if ([self isNullToString:text]) {
        [MBProgressHUD showSuccess:@"内容不能为空" toView:nil];
        return;
    }
    if (actionType == hadStartSubmitAction) {
        [MBProgressHUD showSuccess:@"请勿重复提交" toView:nil];
        return;
    }
    sender.enabled = NO;
    dispatch_async(dispatch_get_global_queue(0,0),^{
        ServerReturnInfo *retInfo;
        TijiaoModel *model = [[TijiaoModel alloc]init];
        model.malfunctionId = _malfunctionId;
        model.detailId = _detailId;
        model.detailStatus = _buttonString;
        model.content = _judgeTextField.text;
        model.guestId = _guestId;
        _no += 1;
        model.no = [NSString stringWithFormat:@"%ld",(long)_no ];
        actionType = hadStartSubmitAction;
        retInfo = [ServerProvider setTicketTypeListDetail:_malfunctionId detailId:_detailId detailStatus:_buttonString percentage:_percentage judgement:_judgeTextField.text boolJudge:_normalbutton.selected guestId:_guestId model:model PINCD:_pinCd];
        actionType = noStartSubmitAction;
        if (retInfo.bSuccess)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showSuccess:@"提交成功" toView:self];
                self.judgeTextField.text = nil;
                [self.tijiaoButton setBackgroundColor:COLOR(142, 142, 142, 1)];
                [self.normalbutton setTitleColor:COLOR(142, 142, 142, 1) forState:(UIControlStateNormal)];
                [self.abnomalbutton setTitleColor:COLOR(142, 142, 142, 1) forState:(UIControlStateNormal)];
                [WorkOrderDetailsViewControll cancelLocalNotificationWithKey:_malfunctionId];
                [WorkOrderDetailsViewControll cancelLocalNotificationWithKey:[NSString stringWithFormat:@"%@key",_malfunctionId]];

                [[NSNotificationCenter defaultCenter]postNotificationName:@"NSNotificationCenterNameForCell" object:nil];
                [[NSNotificationCenter defaultCenter]postNotificationName:NSNotificationCenterToStopTime object:nil];
                self.userInteractionEnabled = NO;
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showSuccess:@"提交失败" toView:nil];
                sender.enabled = YES;
            });
        }
        
    });
}

//滑块
- (IBAction)uislider:(UISlider *)sender {
    
    _percentage = [NSString stringWithFormat:@"%ld",(long)(sender.value * 100)];
    float number = sender.value ;
    if (number == 1) {
        _judgeView.hidden = NO;
        _baseview.hidden = YES;
        _inputView.hidden = YES;
    }else{
        _judgeView.hidden = YES;
        _baseview.hidden = NO;
        _inputView.hidden = NO;
    }
    
 

    if (0.19<= number && number <= 0.22) {
        _textColor = _label1.textColor;
        _tagLabel = _label1;

        _label1.textColor = [UIColor greenColor];
        NSLog(@"%@",_textColor);
   
        return;
    }
    else if (0.39<=number && number <= 0.42) {
        _textColor = _label2.textColor;
        _tagLabel = _label2;
        
        _label2.textColor = [UIColor greenColor];
        
        return;
    }
   else if (0.59<=number && number <= 0.62) {
        _textColor = _label3.textColor;
        _tagLabel = _label3;
        
        _label3.textColor = [UIColor greenColor];
        
        return;
    }
   else if (0.79<=number && number <= 0.82) {
        _textColor = _label4.textColor;
        _tagLabel = _label4;
        
        _label4.textColor = [UIColor greenColor];
        
        return;
    }
   else{
    _tagLabel.textColor = [UIColor blackColor];

   }
    if (sender.value == 1) {
        _abnomalbutton.selected = NO;
        _normalbutton.selected = YES;
    }
    

}

//声音
- (IBAction)soundButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.selected) {
        _soundButton.hidden = NO;
    }else{
        _soundButton.hidden = YES;
        
    }
    
}
//发送按钮
- (IBAction)senderButton:(id)sender {
    _isAdd = YES;
    if (self.inputTextField.text.length == 0 || self.inputTextField.text == nil) {
        [MBProgressHUD showSuccess:@"请输入内容" toView:self];
        return;
    }
    [self updataTextContent:addAlertViewTypeForText bodDic:nil data:nil];
    [self textFieldShouldReturn:_inputTextField];
    
}
- (void)updataTextContent:(addAlertViewType)type bodDic:(NSDictionary *)bodyDic data:(id)data{
    dispatch_async(dispatch_get_global_queue(0,0),^{
        NSString *userID = [Common getCurrentUserVo].strUserID;
        ServerReturnInfo *retInfo;
        if (_isAdd) {
            _no += 1;
        }
        
        retInfo = [ServerProvider setTicketTypeListRecord:_malfunctionId detailId:_detailId  percentage:_percentage detailContent:[GHQTimeToCalculate checkStrValue:self.inputTextField.text] no:[NSString stringWithFormat:@"%ld",(long)(_no )]  updateUserCd:userID guestId:_guestId];
        if (retInfo.bSuccess)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //纯粹文本提示
                if ( type == addAlertViewTypeForText) {
                    [MBProgressHUD showSuccess:retInfo.data[@"message"] toView:nil];
                    [[NSNotificationCenter defaultCenter]postNotificationName:NSNotificationCenterName object:nil];

                }
                
                self.inputTextField.text = nil;
                if (type == addAlertViewTypeForImage) {
                    [TichetServise uploadImageToServer:bodyDic imageData:data result:^(ServerReturnInfo *retInfo) {
                        [Common hideProgressView:self];
                        if (retInfo.bSuccess) {
                            
                            [MBProgressHUD showSuccess:@"上传成功" toView:nil];
                            [[NSNotificationCenter defaultCenter]postNotificationName:NSNotificationCenterName object:nil];

                        }else {
                            [MBProgressHUD showSuccess:retInfo.strErrorMsg toView:nil];
                        }
                        
                    }];

                }else if (type == addAlertViewTypeForSound){
                    [TichetServise uploadSound:data body:bodyDic numberOfTimer:self.RecordModel.audioRecorder.currentTime result:^(ServerReturnInfo *retInfo) {
                        [Common hideProgressView:self];
                        if (retInfo.bSuccess) {
                            NSLog(@"--%@",retInfo.data);
                            [[NSNotificationCenter defaultCenter]postNotificationName:NSNotificationCenterName object:nil];
                            [MBProgressHUD showSuccess:@"成功" toView:nil];
                            _timer.fireDate =  [NSDate distantFuture];

                        } else {
                            [Common tipAlert:retInfo.strErrorMsg];
                        }
                    }];

                }
                
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showSuccess:retInfo.strErrorMsg toView:nil];
            });
        }
        
    });

}

//正常完成
- (IBAction)normalButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender == _normalbutton) {
        if (sender.selected) {
            _buttonString = @"dtlSts32";

            _abnomalbutton.selected = NO;
        }
    }
    if (sender == _abnomalbutton) {
        if (sender.selected) {
            _buttonString = @"dtlSts33";

            _normalbutton.selected = NO;
        }
    }
}
- (void)updateUI{
    _inputView.y = _judgeView.y;
    _baseview.y = CGRectGetMaxY(_inputView.frame);
}


-(void)awakeFromNib
{
     actionType = noStartSubmitAction;
    _judgeView.hidden = YES;
    _inputLine.constant = -200;
   _vvvv.constant = 33;
    _judgeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    _soundButton.backgroundColor = [UIColor whiteColor];
   _buttonString = @"dtlSts32";
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    UITapGestureRecognizer *get = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];

    [_CamerView addGestureRecognizer:get];
    [_pickerView addGestureRecognizer:tapGesture];
     _RecordModel = [AVAudioRecorderModel shareInstance];
    _soundView = [[[NSBundle mainBundle]loadNibNamed:@"RecordView" owner:nil options:nil] lastObject];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeView) name:@"remove" object:nil];
     self.RecordModel.timerAudio = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerAudioSignal) userInfo:nil repeats:YES];
    self.RecordModel.timerAudio.fireDate = [NSDate distantFuture];
    _isAdd = YES;

    

}
- (void)setIsNormalEnd:(BOOL)isNormalEnd{
    _isNormalEnd = isNormalEnd;
    _abnomalbutton.selected = !_isNormalEnd;
    _normalbutton.selected = _isNormalEnd;

}
- (void)setPercentage:(NSString *)percentage{
    _percentage = percentage;
     _ProgressSlide.value = [_percentage  floatValue] / 100;
}

- (void)removeView{
    [_soundView removeFromSuperview];
}
- (void)notificationAction{
    _soundView.width = 100;
    _soundView.height = 100;
    _soundView.x = kScreenWidth / 2 - 50;
    _soundView.y = kScreenHeight / 2 - 50;
    UIWindow *topWindow = [UIApplication sharedApplication].windows.lastObject;
    [topWindow addSubview:_soundView];
    
    
}

/**相机相册点击事件*/
- (void)tapAction:(UITapGestureRecognizer *)sender{
    UIImageView *baseImageView = (UIImageView *)sender.view;
    UIImagePickerController *iamgePickerController = [[UIImagePickerController alloc]init];
    iamgePickerController.delegate = self;
    iamgePickerController.allowsEditing = YES;
    UIViewController *controlel = [self getCurrentViewController];
    

    if (baseImageView == _CamerView) {
        //模拟器是不支持相机拍照的
    if ([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypeCamera)]) {
        iamgePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [controlel presentViewController:iamgePickerController animated:YES completion:nil];
    }else{
        [MBProgressHUD showSuccess:@"模拟器不支持该操作" toView:nil];
    }
        
    }else if(baseImageView == _pickerView){
       
        iamgePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [controlel presentViewController:iamgePickerController animated:YES completion:nil];

    }
    
    
}
-(UIViewController *)getCurrentViewController{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}
//非正常完成
- (IBAction)abnomalButton:(UIButton *)sender {
     sender.selected = !sender.isSelected;
   
}
#pragma MARK =====================pickerView代理方法=================================
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *picImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    _dickerImageView = picImage;
    _pickerView.image = picImage;
    _no += 1;
    _isAdd = NO;
    NSMutableDictionary *bodyDic1 = [[NSMutableDictionary alloc] init];
//    [bodyDic1 setObject:@"ios" forKey:@"client_flag"];
    [bodyDic1 setObject:_malfunctionId forKey:@"malfunctionId"];
    [bodyDic1 setObject:_detailId forKey:@"detailId"];
    [bodyDic1 setObject:@(_no ) forKey:@"no"];
    [bodyDic1 setObject:@"10" forKey:@"type"];
    
    NSData *imageData = UIImagePNGRepresentation(picImage);
    [Common showProgressView:@"上传中..." view:self modal:NO];
    
    [self updataTextContent:addAlertViewTypeForImage bodDic:bodyDic1 data:imageData];
    
   
    
#pragma MARK=========================上传图片到服务器========================================

}


//语音按钮一直处于down状态执行，可以一直执行
- (IBAction)addSoundButton:(UIButton *)sender {
    [self.RDModel recordStart];

}
//刷新音量大小的定时函数
-(void)timerAudioSignal
{
    [self updateAudioSignal:-1];
}
//刷新音量大小以及10秒倒计时
-(void)updateAudioSignal:(NSInteger)nType
{
    NSTimeInterval timeInterval = self.RecordModel.audioRecorder.currentTime;
    if (timeInterval>60)
    {
        //当大于60秒停止录音
        [self.RecordModel.audioRecorder stop];
        _timer.fireDate = [NSDate distantFuture];
        [MBProgressHUD showMessage:@"时间过长请重启录制(60)" toView:nil];
        return;
    }
    
    [self.RecordModel.audioRecorder updateMeters];
    //获取音量的值,然后转化到0~1的值
    float vol = pow(10, (0.05 * [self.RecordModel.audioRecorder peakPowerForChannel:0]));

        if(vol>=1)
        {
            vol = 0.99999;//防止与倒计时冲突，音量值会超过1
        }
    self.soundView.soundImageView.image = [UIImage imageNamed:[self getSignalImage:vol]];
    

}
-(NSString*)getSignalImage:(CGFloat)fSignal
{
    //音量范围为0~1,分为八个等级(1/8=0.125),0.3为微调常数
    return [NSString stringWithFormat:@"RecordingSignal00%li",(long)(fSignal/0.125+0.3)+1];
}


//当我们松开语音按钮时，执行瞬间的
- (IBAction)addSoundUpSide:(UIButton *)sender {
    [_RDModel recordStop];
     _RDModel = nil;
    [_RDModel.timerAudio invalidate];
    _RDModel.timerAudio = nil;

    NSLog(@"%@",_RDModel);
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}

//down
- (IBAction)record:(UIButton *)sender {
    
    [self.RDModel recordStart];
    
    
}

//up
- (IBAction)sender2:(UIButton *)sender {
    [self.RDModel recordStop];
    _RDModel = nil;
    NSLog(@"%@",_RDModel);
   
}
- (void)RecordModelRecordURLPath:(NSString *)path{
    //将wav文件 转为 amr文件
    _no += 1;
    _isAdd = NO;
    NSDictionary *dicf = @{@"malfunctionId":_malfunctionId,@"detailId":_detailId,@"type":@"10",@"no":@(_no ),@"fileName":path};
    ;
    [self updataTextContent:addAlertViewTypeForSound bodDic:dicf data:path];
    [Common showProgressView:@"上传中..." view:self modal:NO];

    NSLog(@"==================%@",path);
}
- (RecordModel *)RDModel{
    if (!_RDModel) {
        _RDModel = [[RecordModel alloc]initWith:self voiceView:self.SDView];
    }
    return _RDModel;
}
@end
