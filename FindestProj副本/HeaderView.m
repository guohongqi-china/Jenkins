//
//  HeaderView.m
//  FindestProj
//
//  Created by MacBook on 16/7/18.
//  Copyright © 2016年 visionet. All rights reserved.
//
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#import "HeaderView.h"
#import "Common.h"
#import "UIView+Extension.h"
#import "PraiseModel.h"
@implementation HeaderView

- (instancetype)init{
    if (self = [super init]) {
        [self setUpUI];
    }
    return self;
}
- (void)setUpUI{
    _titleLabel = [self setUpLabel:14 color:RGBACOLOR(40, 40, 40, 1)];
    _contentLabel = [self setUpLabel:14 color:RGBACOLOR(180, 180, 180, 1)];
    _contentLabel.numberOfLines = 0;
    _zanLabel = [self setUpLabel:13 color:RGBACOLOR(120, 120, 120, 1)];
    _zanLabel.numberOfLines = 0;
    
    [self addSubview:_titleLabel];
    [self addSubview:_contentLabel];
    [self addSubview:_zanLabel];
}
- (void)setModel:(ManListModel *)model{
    _model = model;
    _titleLabel.text = model.titleName;
    _titleLabel.x = 10;
    _titleLabel.y = 15;
    _titleLabel.width = kScreenWidth - 20;
    _titleLabel.height = 25;
   
    if (model.tagVoList.count) {
        for (int i = 0; i < model.tagVoList.count; i ++) {
            UILabel *label = [self setUpLabel:14 color:[UIColor whiteColor]];
            label.font = [UIFont boldSystemFontOfSize:14];
            label.layer.masksToBounds = YES;
            label.layer.cornerRadius = 3;
            label.backgroundColor = RGBACOLOR(58, 108, 174, 1);
            [self addSubview:label];
            Model *mo = model.tagVoList[i];
            label.text = mo.tagName;
            label.textAlignment = NSTextAlignmentCenter;
            label.tag = 1000 + i;
            [label sizeToFit];
            label.height = 25;
            label.width = label.width + 10;
            label.y = CGRectGetMaxY(_titleLabel.frame) + 5;
            label.x =  i == 0 ? 10 : CGRectGetMaxX([self viewWithTag:(1000 + i - 1)].frame) + 5;
        }
      
        _contentLabel.y = CGRectGetMaxY([self viewWithTag:1000].frame) + 5;
    }else{
        _contentLabel.y = CGRectGetMaxY(_titleLabel.frame) + 5;

    }
    _contentLabel.x = 10;
    _contentLabel.width = kScreenWidth - 20;
    _contentLabel.text = model.streamText;
    [_contentLabel sizeToFit];
    
    
    NSString *zanStr = @"" ;
  
    for (int i = 0; i < model.mentionList.count; i ++) {
        PraiseModel *mo = model.mentionList[i];
        if (i != model.mentionList.count - 1) {
           zanStr = [zanStr stringByAppendingString:[NSString stringWithFormat:@"%@、",mo.loginName]];
        }else{
           zanStr = [zanStr stringByAppendingString:mo.loginName];
        }
    }
    _zanLabel.text = [NSString stringWithFormat:@"赞 :%@",zanStr];
    _zanLabel.x = 10;
    _zanLabel.width = kScreenWidth - 20;
    _zanLabel.y = CGRectGetMaxY(_contentLabel.frame) + 5;
    [_zanLabel sizeToFit];
    self.height = CGRectGetMaxY(_zanLabel.frame) + 10;
}
/**
 *  指定label的某些属性，并返回一个label
 */
- (UILabel *)setUpLabel:(CGFloat )font color:(UIColor *)color{
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:font];
    label.textColor = color;
    return label;
}
@end
