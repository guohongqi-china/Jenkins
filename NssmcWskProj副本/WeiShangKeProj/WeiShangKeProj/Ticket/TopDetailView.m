//
//  TopDetailView.m
//  郭红旗
//
//  Created by MacBook on 16/6/5.
//  Copyright © 2016年 MacBook. All rights reserved.
//
//#define COLOR(R,G,B,A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
//#define kScreenWidth [UIScreen mainScreen].bounds.size.width
//#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#import "TopDetailView.h"
#import "UIView+Extension.h"
#import "viewToShowInformation.h"
#import "TicketVo.h"
#import "GHQTimeToCalculate.h"
#import "TichetServise.h"
@implementation TopDetailView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _titlLabel = [[UILabel alloc]init];
        _titlLabel.font = [UIFont systemFontOfSize:14];
        _titlLabel.numberOfLines = 0;
        _titlLabel.textColor = [UIColor grayColor];
        
        _contentLabel = [[UILabel alloc]init];
        _contentLabel.numberOfLines = 0;
        
        _contentLabel.textColor = [UIColor grayColor];
        
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

        
        _view1 = [self loadViewByXIB:@"故障分类:" TEXTSTRING:@" NSLA"];
        _view2 = [self loadViewByXIB:@"价格估算:" TEXTSTRING:@" 13767676777"];
        _view3 = [self loadViewByXIB:@"难       度:" TEXTSTRING:@" 延安西路1134号"];
        _view4 = [self loadViewByXIB:@"状       态:" TEXTSTRING:@" 2016、1、1"];
//        _view5 = [self loadViewByXIB:@"可维修时间:" TEXTSTRING:@" PC"];
        
        NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"RepairView" owner:nil options:nil];
        _view5 = nibContents.lastObject;
        
        _view5.informationLabel.text = @"可维修时间:";
        _view5.width = kScreenWidth;
        _view5.informationLabel.textColor = COLOR(108, 108, 108, 1);
        _view5.textContentLabel.textColor = COLOR(159, 159, 159, 1);

        
        
        
        
        _view6 = [self loadViewByXIB:@"客户名称:" TEXTSTRING:@" PC"];
        _view7 = [self loadViewByXIB:@"客户地址:" TEXTSTRING:@" PC"];
        _view8 = [self loadViewByXIB:@"距    离:" TEXTSTRING:@" PC"];
        _view9 = [self loadViewByXIB:@"客户公司名称:" TEXTSTRING:@" PC"];
        _view0 = [self loadViewByXIB:@"客户电话:" TEXTSTRING:@"PC"];
        _view10 = [self loadViewByXIB:@"客户区分:" TEXTSTRING:@"PC"];
        _view11 = [self loadViewByXIB:@"预约上门时间:" TEXTSTRING:@"PC"];

        
        [self addSubview:_titlLabel];
        [self addSubview:_contentLabel];
        [self addSubview:_view1];
        [self addSubview:_view2];
        [self addSubview:_view3];
        [self addSubview:_view4];
        [self addSubview:_view6];
        [self addSubview:_view7];
        [self addSubview:_view8];
        [self addSubview:_view9];
        [self addSubview:_view10];
        [self addSubview:_view11];


        
    }
    return self;
}

- (viewToShowInformation *)loadViewByXIB:(NSString *)STRING1 TEXTSTRING:(NSString *)STRING2{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"viewToShowInformation" owner:nil options:nil];
    viewToShowInformation *VIEW = nibContents.lastObject;
    VIEW.informationLabel.text = STRING1;
    VIEW.textContentLabel.text = STRING2;
    VIEW.width = kScreenWidth;
    VIEW.informationLabel.textColor = COLOR(108, 108, 108, 1);
    VIEW.textContentLabel.textColor = COLOR(159, 159, 159, 1);
    
    VIEW.height = 40;
    [self addSubview:VIEW];
    return VIEW;
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

- (void)setModel:(TicketVo *)Model{
    _Model = Model;
    
    _titlLabel.frame = CGRectMake(15,5, kScreenWidth - 20, 0);
    _titlLabel.text = [NSString stringWithFormat:@"制品名称：%@",Model.malfunctionDetail];
    [_titlLabel sizeToFit];
    
    _contentLabel.text = [NSString stringWithFormat:@"故障现象：%@",Model.productName];
    _contentLabel.width = kScreenWidth - 20;
    _contentLabel.font = [UIFont systemFontOfSize:14];
    [_contentLabel sizeToFit];
    _contentLabel.y = CGRectGetMaxY(_titlLabel.frame) + 10;
    _contentLabel.x = 15;

    _describeImage.frame = _itemArray.count > 0 ? CGRectMake(0, CGRectGetMaxY(_contentLabel.frame),kScreenWidth - 20, (kScreenWidth - 40) / 3) : CGRectMake(0, CGRectGetMaxY(_contentLabel.frame),0, 0);
    _describeImage.itemsArrayt = _itemArray;

    _view1.frame = CGRectMake(0, CGRectGetMaxY(_describeImage.frame), kScreenWidth, 40);
    _view1.textContentLabel.text = [self classificationString:Model.classification];
    
    _view2.frame = CGRectMake(0, CGRectGetMaxY(_view1.frame), kScreenWidth, 40);
    _view2.textContentLabel.text = [NSString stringWithFormat:@"%@元",Model.priceEstimation];
    
    _view3.frame = CGRectMake(0, CGRectGetMaxY(_view2.frame), kScreenWidth, 40);
    _view3.textContentLabel.text = [self judgeDiffcultByString:[Model.difficulty integerValue]];
    
    _view4.frame = CGRectMake(0, CGRectGetMaxY(_view3.frame), kScreenWidth, 40);
    _view4.textContentLabel.text = [self EnumGetString:Model.orderstatus];
    
    _view5.frame = CGRectMake(0, CGRectGetMaxY(_view4.frame), kScreenWidth, 75);
    [_view5 layoutIfNeeded];
    for (int i = 0 ; i < _timeArray.count; i ++) {
        timeModel *mo = _timeArray[i];
        if (i == 0) {
            if (mo.typename1 == nil || mo.typename1.length == 0) {
                _view4.textContentLabel.text = @" ";
                return;
            }
            _view5.textContentLabel.text = [NSString stringWithFormat:@"%@-%@-%@",mo.typename1,mo.timeFrom,mo.timeTo];
        }else if(i == 1){
            if (mo.typename1 == nil || mo.typename1.length == 0) {
                _view4.textContentLabel.text = @" ";
                return;
            }
            _view5.textLabel1.text = [NSString stringWithFormat:@"%@-%@-%@",mo.typename1,mo.timeFrom,mo.timeTo];
        }else{
            if (mo.typename1 == nil || mo.typename1.length == 0) {
                _view4.textContentLabel.text = @" ";
                return;
            }
            _view5.textLabel2.text = [NSString stringWithFormat:@"%@-%@-%@",mo.typename1,mo.timeFrom,mo.timeTo];
            
        }
    }

    
    _view6.frame = CGRectMake(0, CGRectGetMaxY(_view5.frame), kScreenWidth, 40);
    _view6.textContentLabel.text = Model.guestName;

    _view7.frame = CGRectMake(0, CGRectGetMaxY(_view6.frame), kScreenWidth, 40);
    _view7.textContentLabel.text = [NSString stringWithFormat:@"%@-%@",Model.guestArea,Model.guestAddress];

    _view8.frame = CGRectMake(0, CGRectGetMaxY(_view7.frame), kScreenWidth, 40);
    _view8.textContentLabel.text = [NSString stringWithFormat:@"%@km",Model.distance];

    _view9.frame = CGRectMake(0, CGRectGetMaxY(_view8.frame), kScreenWidth, 40);
    _view9.textContentLabel.text = Model.guestCompanyName;
    
    
    _view0.frame = CGRectMake(0, CGRectGetMaxY(_view9.frame), kScreenWidth, 40);
    _view0.textContentLabel.text = Model.guest_Mobile;
    
    _view10.frame = CGRectMake(0, CGRectGetMaxY(_view0.frame), kScreenWidth, 40);
    _view10.textContentLabel.text =[self userdistinguish:Model.customType];;

    _view11.frame = CGRectMake(0, CGRectGetMaxY(_view10.frame), kScreenWidth, 40);
    _view11.textContentLabel.text = [GHQTimeToCalculate getTimeFromNumberofmilliseconds:[GHQTimeToCalculate checkStrValue:Model.confirmTime] dateFormat:@"yyyy-MM-dd HH:mm:ss"];;



//    _view5.textContentLabel.text = [GHQTimeToCalculate getTimeFromNumberofmilliseconds:Model.applyTime dateFormat:@"yyyy-MM-dd HH:MM:ss"];
    
    self.height = CGRectGetMaxY(_view11.frame);
    [self addSubview:_view5];

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

- (NSString *)EnumGetString:(NSString *)string{
  
    if ([string isEqualToString:@"20"]) {
        return @"可抢工单";
    }else if ([string isEqualToString:@"21"]){
        return @"已抢工单";

    }else if ([string isEqualToString:@"22"]){
        return @"抢单成功";

    }else if ([string isEqualToString:@"23"]){
        return @"抢单失败";

    }else {
        return @"抢单被取消";

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
