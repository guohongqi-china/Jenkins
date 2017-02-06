//
//  TicketListCell.m
//  WeiShangKeProj
//
//  Created by 焱 孙 on 15/5/28.
//  Copyright (c) 2015年 visionet. All rights reserved.
//

#import "TicketListCell.h"
#import "UIViewExt.h"
#import "IntrinsicSpaceLabel.h"
#import "GHQTimeToCalculate.h"
@interface TicketListCell ()
{
    UILabel *stateLabel;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgViewRead;
@property (weak, nonatomic) IBOutlet IntrinsicSpaceLabel *lblTicketState;
@property (weak, nonatomic) IBOutlet IntrinsicSpaceLabel *lblTicketType;
@property (weak, nonatomic) IBOutlet IntrinsicSpaceLabel *lblDifficulty;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UILabel *lblDateTime;
@property (weak, nonatomic) IBOutlet UILabel *lblCustomer;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewGrabTicket;

@property (nonatomic, strong) UIView *lineView;/** <#注释#> */

@end

@implementation TicketListCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self.contentView insertSubview:stateLabel belowSubview:_lblPrice];

}
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 1)];
        _lineView.backgroundColor = COLOR(220, 220, 220, 1);
        stateLabel = [[UILabel alloc]init];
        stateLabel.font = [UIFont systemFontOfSize:13];
        stateLabel.backgroundColor = COLOR(155, 46, 32, 1);
        stateLabel.layer.cornerRadius = 3;
        stateLabel.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (NSString *)judgeStyleFromString:(NSString *)nsss{
    
    if ([nsss isEqualToString:@"commonLevel1"]) {
        //分类
        return  @"网络";
    }else if ([nsss isEqualToString:@"commonLevel2"]){
        //分类
        return  @"服务器";
    }else if ([nsss isEqualToString:@"commonLevel3"]){
        //分类
        return  @"PC机";
    }else if ([nsss isEqualToString:@"commonLevel4"]){
        //分类
        return  @"综合布线";
    }else {
        //分类
        return  @"其他";
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
- (NSString *)getStringByString:(NSString *)string{
    if ([string isEqualToString:@"dtlSts33"] || [string isEqualToString:@"dtlSts32"]) {
        return @"已解决";
    }
    return @"未解决";
}
- (NSString *)getStypeForCell:(NSString *)state{
    if ([state isEqualToString:@"dtlSts00"]) {
        return @"可抢";
    }else if([state isEqualToString:@"dtlSts10"]){
        return @"抢单推送中";
    }else if([state isEqualToString:@"dtlSts11"]){
        return @"抢单完毕";
    }else if([state isEqualToString:@"dtlSts21"]){
        return @"指派完毕";
    }else if([state isEqualToString:@"dtlSts30"]){
        return @"出发中";
    }else if([state isEqualToString:@"dtlSts31"]){
        return @"开始维修";
    }else if([state isEqualToString:@"dtlSts32"]){
        return @"正常维修完毕";
    }else{
        return @"没能解决客户问题";
    }
}
- (void)setEntity:(TicketVo *)entity
{
    //已读、未读
    //self.lblDateTime.
    //可抢工单icon
    self.imgViewGrabTicket.hidden = YES;
    if (!entity.isQiang) {
        NSLog(@"%@",entity.orderstatuscontent);
        stateLabel.text = entity.orderstatuscontent;
        stateLabel.textColor = [UIColor whiteColor];
        [stateLabel sizeToFit];
        [stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(5);
            make.right.equalTo(self.contentView.mas_right).offset(-10);
            make.height.equalTo(25);
        }];
        stateLabel.hidden = NO;
    }else{
        stateLabel.hidden = YES;
    }

    //已解决
    self.lblTicketState.text = [self getStringByString:entity.detailStatus];
    if (!entity.isQiang) {
        self.lblTicketState.text = @"可抢";
    }
    //分类
        self.lblTicketType.text = [self judgeStyleFromString:entity.classification];
//    self.lblTicketType.text = entity.classification;


//    self.lblTicketType.text = @"硬件";
    //难
    self.lblDifficulty.text = [self judgeDiffcultByString:[entity.difficulty integerValue]];
    
    //价格
    NSInteger nPrice = [entity.priceEstimation integerValue];
    if (nPrice >= 500)
    {
        self.lblPrice.textColor = COLOR(255, 230, 230, 1.0);
    }
    else
    {
        self.lblPrice.textColor = COLOR(230, 230, 255, 1.0);
    }
    self.lblPrice.text = [NSString stringWithFormat:@"￥ %@",entity.priceEstimation];
    
    //工单号
    self.lblTitle.text = [NSString stringWithFormat:@"工单号：%@_%@",entity.malfunctionId,entity.detailId];
    
    //内容
    self.lblContent.text = [NSString stringWithFormat:@"%@　　　　　　　　　　",entity.malfunctionDetail];
    self.lblCustomer.text = entity.guestName;
    
    //时间
    self.lblDateTime.text = [GHQTimeToCalculate getTimeFromNumberofmilliseconds:entity.orderTime dateFormat:@"yyyy-MM-dd HH:MM:ss"];
    _lineView.y = self.height - 1;
    
    /** 判断pin码验证按钮是否显示 */
   
    
    [self addSubview:_lineView];
}

@end
