//
//  TopView.m
//  NssmcWskProj
//
//  Created by MacBook on 16/5/24.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "TopView.h"
#import "viewToShowInformation.h"
#import "ImageScrollview.h"
#import "ImageCollectionView.h"
#import "GHQTimeToCalculate.h"
#import "timeModel.h"
#import "ServerURL.h"

@implementation TopView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
//        self.backgroundColor = [UIColor greenColor];
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(10, 10, kScreenWidth - 70, 15)];
        _progressView.progressTintColor = COLOR(87, 195, 192, 1);
        _progressView.trackTintColor = COLOR(191, 192, 191, 1);
        _progressView.transform = CGAffineTransformMakeScale(1.0, 3.0);
        _progressView.layer.cornerRadius = 3;
        _progressView.layer.masksToBounds = YES;
        _progressView.progress = 0.5;
        [self addSubview:_progressView];
        
        progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth - 47, 5, kScreenWidth - 5, 15)];
        progressLabel.textColor = COLOR(87, 195, 192, 1);
        progressLabel.text = @"50%";
        progressLabel.font = [UIFont boldSystemFontOfSize:13];
        [self addSubview:progressLabel];
        
        //**工单标题*/
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"路由器故障";
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = COLOR(108, 108, 108, 1);
        [self addSubview:_titleLabel];
        self.userInteractionEnabled = YES;
        _contentLabel = [[UILabel alloc]init];
        _contentLabel.numberOfLines = 0;
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = COLOR(159, 159, 159, 1);
        _contentLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_contentLabel];
        
        
                //创建布局对象
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        //设置单元格的尺寸
        flowLayout.itemSize = CGSizeMake((kScreenWidth - 20)/3, (kScreenWidth - 20)/3);
        flowLayout.minimumInteritemSpacing = 20;
        flowLayout.minimumLineSpacing = 10;
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        //flowlaout的属性，横向滑动
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //接下来就在创建collectionView的时候初始化，就很方便了（能直接带上layout）
        
        _describeImage = [[ImageCollectionView alloc]initWithFrame:CGRectMake(0, 0, 0 , 0) collectionViewLayout:flowLayout];
        _describeImage.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:_describeImage];

  
        NSArray *viewArray = [[NSBundle mainBundle]loadNibNamed:@"buttonAndLabel" owner:nil options:nil];
        buttonAndLabel *buttonlA = [viewArray lastObject];
        buttonlA.height = 20;
        buttonlA.hidden = YES;
        _soundeButton = buttonlA;
        [self addSubview:_senderButton];
        

        _view1 = [self loadViewByXIB:@"客户名称:" TEXTSTRING:@" NSLA"];
        _view2 = [self loadViewByXIB:@"客户电话:" TEXTSTRING:@" 13767676777"];
        _view3 = [self loadViewByXIB:@"客户地址:" TEXTSTRING:@" 延安西路1134号"];
        NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"RepairView" owner:nil options:nil];
        _view4 = nibContents.lastObject;
        
        _view4.informationLabel.text = @"可维修时间:";
        _view4.width = kScreenWidth;
        _view4.informationLabel.textColor = COLOR(108, 108, 108, 1);

        _view5 = [self loadViewByXIB:@"故障分类:" TEXTSTRING:@" PC"];
        _view6 = [self loadViewByXIB:@"价格估算:" TEXTSTRING:@" 500元"];
        _view7 = [self loadViewByXIB:@"难       度:" TEXTSTRING:@" 难"];
        _view8 = [self loadViewByXIB:@"状       态:" TEXTSTRING:@" 终止付费"];
        _view9 = [self loadViewByXIB:@"客户区分:" TEXTSTRING:@" 123"];
        _view10 = [self loadViewByXIB:@"约定上门时间:" TEXTSTRING:@" 12:00:00"];

        
    }
    return self;
}

- (viewToShowInformation *)loadViewByXIB:(NSString *)STRING1 TEXTSTRING:(NSString *)STRING2{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"viewToShowInformation" owner:nil options:nil];
    viewToShowInformation *VIEW = nibContents.lastObject;
    VIEW.size = CGSizeMake(0, 0);
    VIEW.informationLabel.text = STRING1;
    VIEW.textContentLabel.text = STRING2;
    VIEW.width = kScreenWidth;
    VIEW.informationLabel.textColor = COLOR(108, 108, 108, 1);
    VIEW.textContentLabel.textColor = COLOR(159, 159, 159, 1);
    VIEW.height = 40;
    [self addSubview:VIEW];
    return VIEW;
}
- (NSString *)cancleString:(NSString *)preogre{
    if ([preogre isEqualToString:@"(null)"] || preogre == NULL || preogre == nil) {
        return @"0";
    }
    return preogre;
}
- (NSString *)userdistinguish:(NSString *)str{
    if ([str isEqualToString:@"1"]) {
        return  @"NTT";
    }else if ([str isEqualToString:@"2"]){
        return  @"SoftBank";
    }else{
    return  @"其他";
    }
}
- (NSString *)classificationString:(NSString *)class{
    if ([class isEqualToString:@"commonLevel1"]) {
        return  @"网络";
    }else if ([class isEqualToString:@"commonLevel2"]){
        return @"服务器";
    }else if ([class isEqualToString:@"commonLevel3"]){
        return @"PC";
    }
    else if ([class isEqualToString:@"commonLevel4"]){
        return @"综合布线";
    }else{
        return @"其他";
    }

}
- (void)setTopModelFrame:(topModelFrame *)topModelFrame{
    _topModelFrame = topModelFrame;
    
    
    topModel *model = topModelFrame.topModel;
    _progressView.progress = [model.percentage floatValue] / 100;
    progressLabel.text = [NSString stringWithFormat:@"%@%%",[self cancleString:model.percentage]];
    _describeImage.itemsArrayt = topModelFrame.iamgeArray;
    _titleLabel.text = [NSString stringWithFormat:@"制品名称： %@",model.productName];
    _titleLabel.frame = topModelFrame.titleFrame;
    [_titleLabel sizeToFit];
    
    _contentLabel.frame = topModelFrame.titleContentFrame;
    _contentLabel.text = [NSString stringWithFormat:@"故障现象： %@",model.malfunctionDetail];

    
    _describeImage.frame = topModelFrame.imageFrame;

    _soundeButton.SOUNDbUTTON.transform = CGAffineTransformRotate(_soundeButton.SOUNDbUTTON.transform, M_PI);
    _soundeButton.frame = topModelFrame.senderFrame;
    _soundeButton.x = topModelFrame.senderFrame.origin.x;
    _soundeButton.y = topModelFrame.senderFrame.origin.y;
    
    _view1.frame = topModelFrame.userNameFrame;
    _view1.textContentLabel.text = model.guestName;
    
    _view2.frame = topModelFrame.userPhoneFrame;
    _view2.textContentLabel.text = model.guestMobile;
    
    _view3.frame = topModelFrame.userAdressFrame;
    _view3.textContentLabel.text = [NSString stringWithFormat:@"%@-%@",model.guestArea,model.guestAddress];
    
    _view9.frame= topModelFrame.distinguishUserFrame;
    _view9.textContentLabel.text = [self userdistinguish:model.customType];
    
    _view10.frame= topModelFrame.appointTimeFrame;
    _view10.textContentLabel.text = [GHQTimeToCalculate getTimeFromNumberofmilliseconds:[GHQTimeToCalculate checkStrValue:model.confirmTime] dateFormat:@"yyyy-MM-dd HH:mm:ss"];;
    
    _view4.frame = topModelFrame.repairTimeFrame;
    [_view4 layoutIfNeeded];
//    _view4.backgroundColor = [UIColor grayColor];
//    _view4.textContentLabel.text = [GHQTimeToCalculate getTimeFromNumberofmilliseconds:model.orderTime dateFormat:@"yyyy-MM-dd HH:MM:ss"];
    for (int i = 0 ; i < _timeArray.count; i ++) {
        timeModel *mo = _timeArray[i];
        if (i == 0) {
            if (mo.typename1 == nil || mo.typename1.length == 0) {
                _view4.textContentLabel.text = @" ";
                return;
            }
            _view4.textContentLabel.text = [NSString stringWithFormat:@"%@-%@-%@",mo.typename1,mo.timeFrom,mo.timeTo];
        }else if(i == 1){
            if (mo.typename1 == nil || mo.typename1.length == 0) {
                _view4.textContentLabel.text = @" ";
                return;
            }
            _view4.textLabel1.text = [NSString stringWithFormat:@"%@-%@-%@",mo.typename1,mo.timeFrom,mo.timeTo];
        }else{
            if (mo.typename1 == nil || mo.typename1.length == 0) {
                _view4.textContentLabel.text = @" ";
                return;
            }
            _view4.textLabel2.text = [NSString stringWithFormat:@"%@-%@-%@",mo.typename1,mo.timeFrom,mo.timeTo];

        }
    }
    _view5.frame = topModelFrame.classificationForDeafultFrame;
    _view5.textContentLabel.text = [self classificationString:model.classification];
    
    _view6.frame = topModelFrame.priceFrame;
    _view6.textContentLabel.text = [NSString stringWithFormat:@"%@元",model.priceEstimation];
    
    _view7.frame = topModelFrame.difficultyFrame;
    _view7.textContentLabel.text = [self judgeDiffcultByString:[model.difficulty integerValue]];
    
    _view8.frame = topModelFrame.statusFrame;
    _view8.textContentLabel.text = [self getStringForStatue:model.detailStatus];
    
    /** Pin码验证button */
    _pinCodeButton = [[UIButton alloc]init];
    [_pinCodeButton setTitle:@"PIN码验证" forState:(UIControlStateNormal)];
    [_pinCodeButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    _pinCodeButton.layer.masksToBounds = YES;
    _pinCodeButton.layer.cornerRadius = 7;
    _pinCodeButton.titleLabel.font = [UIFont systemFontOfSize:18];
    _pinCodeButton.frame = topModelFrame.pinFrame;
    [_pinCodeButton addTarget:self action:@selector(pinAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:_pinCodeButton];

    
   
    
    /** 判断pin码验证按钮是否显示 */
    if ([model.detailStatus isEqualToString:@"dtlSts33"] || [model.detailStatus isEqualToString:@"dtlSts32"]) {
         self.height = CGRectGetMaxY(_pinCodeButton.frame);
        if (![self isNullToString:model.pincdConfirmStatus] && [model.pincdConfirmStatus isEqualToString:@"1"]) {
            if ([model.pincdConfirmStatus isEqualToString:@"1"]) {
                [_pinCodeButton setTitle:@"PIN码已验证" forState:(UIControlStateNormal)];
                _pinCodeButton.enabled = NO;
                [_pinCodeButton setBackgroundColor:COLOR(138, 138, 138, 1)];

            }
            
        }else{
            [_pinCodeButton setBackgroundColor:COLOR(71, 160, 131, 1)];
            _pinCodeButton.enabled = YES;
        }
    }else{
         self.height = CGRectGetMaxY(_view8.frame);
        _pinCodeButton.hidden = YES;
    }
    
    
    
    
    [self addSubview:_soundeButton];
    [self addSubview:_view4];


}
/**
 * 字符串判空，如果为空返回yes
 */
- (BOOL )isNullToString:(id)string
{
    if ([string isEqual:@"NULL"] || [string isKindOfClass:[NSNull class]] || [string isEqual:[NSNull null]] || [string isEqual:NULL] || [[string class] isSubclassOfClass:[NSNull class]] || string == nil || string == NULL || [string isKindOfClass:[NSNull class]] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0 || [string isEqualToString:@"<null>"] || [string isEqualToString:@"(null)"])
    {
        return YES;
        
        
    }else
    {
        
        return NO;
    }
}
- (void)pinAction{
    if (self.delegate && ([self.delegate respondsToSelector:@selector(pinCodeVerification:)])) {
        [self.delegate pinCodeVerification:^(NSString *pinText) {
            /** 验证pin码 */
            if ([pinText isEqualToString:_topModelFrame.topModel.pinCd]) {
                
//
                VNetworkFramework *networkFramework = [[VNetworkFramework alloc]initWithURLString:[ServerURL setWODetailURL]];
                [networkFramework startRequestToServer:@"POST" parameter:@{@"pinCdConfirmed":@"1",@"malfunctionId":_topModelFrame.topModel.malfunctionId,@"detailId":_topModelFrame.topModel.detailId,@"guestId":_topModelFrame.topModel.guestId,@"pinCd":_topModelFrame.topModel.pinCd} result:^(id responseObject, NSError *error) {
                    
                    if ([responseObject[@"message"] isEqualToString:@"成功"]) {
            
                        [self showAlert:@"PIN码状态修改成功"];
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"PinCodeverification" object:self];
                    }else{
                      
                        [self showAlert:@"PIN码状态修改失败"];
                    }
                }];
                
            }else{
                [self showAlert:@"输入的PIN码不正确"];
          }
        }];
    }
}
- (void)showAlert:(NSString *)string{
    UIWindow *keyWindow = [UIApplication sharedApplication].windows.lastObject;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:keyWindow animated:YES];
    /** 文本模式 */
    hud.mode = MBProgressHUDModeText;
    hud.labelText = string;
    [hud hide:YES afterDelay:1];

}
- (NSString *)timeString:(timeModel *)arr{
    return [NSString stringWithFormat:@"%@  %@-%@/n",arr.date,arr.timeFrom,arr.timeTo];
;
}
- (NSString *)getStringForStatue:(NSString *)statue{
    if ([statue isEqualToString:@"dtlSts00"]) {
        return @"新建";
    }else if ([statue isEqualToString:@"dtlSts30"]) {
        return @"工程师出发中";
    }else if ([statue isEqualToString:@"dtlSts31"]) {
        return @"工程师到达现场开始维修";
    }else if ([statue isEqualToString:@"dtlSts32"]) {
        return @"工程正常维修完毕";
    }else if ([statue isEqualToString:@"dtlSts11"]) {
            return @"抢单完毕";
    }else if ([statue isEqualToString:@"dtlSts21"]) {
            return @"指派完毕";
    }else if ([statue isEqualToString:@"dtlSts33"]) {
            return @"工程师没能解决客户问题";
    }else{
        return @" ";
    }
}
- (NSString *)judgeDiffcultByString:(NSInteger)number{
    if (number == 10) {
        return @"简单";
    }
    if (number == 20) {
        return @"普通";
    }
    if (number == 30) {
        return @"困难";
    }
    return @" ";
}









@end
