//
//  AddRecordeView.m
//  NssmcWskProj
//
//  Created by MacBook on 16/5/31.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "AddRecordeView.h"
#import "ScrollView.h"
@interface AddRecordeView ()
{
    CGFloat height;
}

@property (nonatomic, strong) UIImageView *firstView;/** <#注释#> */

@property (nonatomic, strong) NSMutableArray *imageArray;/** <#注释#> */

@property (nonatomic, strong) ScrollView *baseView;/** <#注释#> */
@end

@implementation AddRecordeView
- (NSMutableArray *)imageArray{
    if (_imageArray == nil) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}

- (instancetype)init{
    if (self = [super init]) {
        _baseView = [[ScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _baseView.backgroundColor = [UIColor grayColor];
        
        UILabel *labelll = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 150, 25)];
        labelll.text = @"工单操作记录:";
        labelll.font = [UIFont systemFontOfSize:14];
        labelll.textColor = [UIColor blackColor];
        [self addSubview:labelll];
        self.firstView = [[UIImageView alloc]init];
        [self addSubview:self.firstView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notAction) name:@"cancle" object:nil];
        
    }
    return self;
}
- (void)notAction{
    
}
- (void)setItemsArray:(NSMutableArray *)itemsArray{
    height = 0;
    _itemsArray = itemsArray;

    
    for (int i = 0; i < itemsArray.count; i ++) {
        cellView *cell = [[cellView alloc]initWithFrame:CGRectMake(0, 30 + height, kScreenWidth, 150)];
        cell.delegate = self;
        cell.cellModel = itemsArray[i];
        height = height + [cell getHeight];
        [self addSubview:cell];
    }
    
    
    
    self.height = 30 + height;
    self.width = kScreenWidth;
}
- (void)CellViewUrlImage:(NSString *)urlString{
    
    [self.imageArray addObject:urlString];
    
}
- (void)cellViewiImage:(NSString *)image{
    NSLog(@"%@",_imageArray);
    NSLog(@"%@",image);
    
    _baseView.itemsArray = _imageArray;
    [_baseView scrollViewSetAnimation];
    _baseView.tagNumber = [self.imageArray indexOfObject:image];
    
    
    
    
}

@end
