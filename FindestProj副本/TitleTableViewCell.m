//
//  TitleTableViewCell.m
//  FindestProj
//
//  Created by MacBook on 16/7/13.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "TitleTableViewCell.h"
#import "DrawView.h"
@interface TitleTableViewCell ()
{
    DrawView *drawView;
}
@end
@implementation TitleTableViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    drawView = [[DrawView alloc]initWithFrame:CGRectMake(0, 0, 17, 17)];
    drawView.backgroundColor = [UIColor clearColor];
    [self.statusLabel addSubview:drawView];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    NSLog(@"%hhd",selected);
    drawView.lineColor =  selected ? [UIColor redColor] : [UIColor whiteColor];
   

}

@end
