//
//  ScrollView.m
//  NssmcWskProj
//
//  Created by MacBook on 16/6/23.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ScrollView.h"
#import <UIImageView+WebCache.h>
#import "SDWebImageDataSource.h"
@implementation ScrollView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self  = [super initWithFrame:frame]) {
       
        self.pagingEnabled = YES;
        self.delegate = self;
        _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(kScreenWidth / 2 - 30, kScreenHeight - 50, 60, 35)];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
        
    }
    return self;
}
- (void)tapAction{
    [self removeFromSuperview];
    [_textLabel removeFromSuperview];

    [[NSNotificationCenter defaultCenter]postNotificationName:@"cancle" object:nil];
}
- (void)scrollViewSetAnimation{
    _tagView = [[UIImageView alloc]init];
    imageViewe = [[UIImageView alloc]init];
    [self addSubview:_tagView];

    UIWindow *window = [UIApplication sharedApplication].windows.lastObject ;
    [window addSubview:self];
    [window addSubview:_textLabel];
}
- (void)setItemsArray:(NSMutableArray *)itemsArray{
    _itemsArray = itemsArray;

    self.contentSize = CGSizeMake(itemsArray.count * kScreenWidth, 0);
    for (int i = 0; i < itemsArray.count; i ++) {
        
        UIImageView *iamgeView = [[UIImageView alloc]initWithFrame:CGRectMake(i * kScreenWidth,kScreenHeight / 2 - kScreenHeight / 6, kScreenWidth, kScreenHeight / 3)];
        
        [iamgeView sd_setImageWithURL:[NSURL URLWithString:itemsArray[i]] placeholderImage:[UIImage imageNamed:@"picf"]];
        iamgeView.tag = 1000 + i;
        iamgeView.backgroundColor = [UIColor redColor];
        [self addSubview:iamgeView];
        
    }
    
    
    self.showsHorizontalScrollIndicator = NO;
    

}
- (void)setTagNumber:(NSInteger)tagNumber{
    _tagView.frame = CGRectMake(tagNumber * kScreenWidth + kScreenWidth / 2 - 50, kScreenHeight/2 - 50, 100, 100);

    _tagNumber = tagNumber;
    self.contentOffset = CGPointMake(tagNumber * kScreenWidth, 0);
//     UIImageView *viewll = (UIImageView *)[self viewWithTag:1000 + tagNumber];
//     viewll.hidden = YES;
//    _tagView.image = viewll.image;
    _textLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)tagNumber,(unsigned long)(_itemsArray.count - 1)];


//
}
static NSInteger nu;

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSInteger x = (scrollView.contentOffset.x + kScreenWidth / 2) / kScreenWidth;
    if (nu != x) {
        nu = x;
        _textLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)x,(unsigned long)(_itemsArray.count - 1)];
        
    }
    
}


@end
