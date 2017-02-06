//
//  ImageViewForPickImage.m
//  NssmcWskProj
//
//  Created by MacBook on 16/5/31.
//  Copyright © 2016年 visionet. All rights reserved.
//
#define kWith [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#import "ImageViewForPickImage.h"
#import <UIImageView+WebCache.h>
#import "GHQlineView.h"
@implementation ImageViewForPickImage
- (UIWindow *)baseWindow{
    if (_baseWindow == nil) {
        _baseWindow = [UIApplication sharedApplication].windows.lastObject;
        grayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        grayView.backgroundColor = [UIColor blackColor];
        [_baseWindow addSubview:grayView];
        

    }
    return _baseWindow;
}
- (instancetype)init{
    if (self = [super init]) {
        [self setUPUI];
        
    }
    return self;
}
- (void)setUPUI{
    self.delegate = self;
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.userInteractionEnabled = YES;
    self.frame = [UIScreen mainScreen].bounds;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tapGesture];
    
    _numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(kWith / 2 - 30, kHeight - 70, 60, 35)];
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    
    
}

- (void)setItemsArray:(NSArray *)itemsArray{
    _itemsArray = itemsArray;
    self.contentSize = CGSizeMake(kWith * itemsArray.count, kHeight);
    
    for (int i = 0; i < itemsArray.count; i++) {
        UIImageView *iamgeView = [[UIImageView alloc]initWithFrame:CGRectMake(0 + kWith * i, kHeight / 3, kWith, kHeight / 3)];
        if ([[itemsArray[i] class]  isKindOfClass:[UIImage class]]) {
            iamgeView.image = itemsArray[i];
        }else{
            NSString *urlStr = itemsArray[i];
            if ([urlStr hasSuffix:@"jpg"] || [urlStr hasSuffix:@"png"]) {
                GHQlineView *PView = [[GHQlineView alloc]initWithFrame:CGRectMake(0, 0, iamgeView.width, iamgeView.height)];
                PView.lineWidth = 5;
                [iamgeView sd_setImageWithURL:itemsArray[i]];
//                [iamgeView sd_setImageWithURL:itemsArray[i] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                    
//                    PView.progress = 1.0 * receivedSize / expectedSize;
//                    NSLog(@"%f",1.0 * receivedSize / expectedSize);
//                    
//                    
//                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                    
//                }];
                
                
            }else{
                iamgeView.image = [UIImage imageNamed:itemsArray[i]];
            }
            
        }
       
        [self addSubview:iamgeView];
    }
    _numberLabel.text = [NSString stringWithFormat:@"%ld/%u",(long)_tagImage,itemsArray.count - 1];
    [self.baseWindow addSubview:self];
    [self.baseWindow addSubview:_numberLabel];
    [self setContentOffset:CGPointMake(_tagImage * kWith, 0) animated:YES];
    
}
- (void)tapAction{
    [self removeFromSuperview];
    [_numberLabel removeFromSuperview];
    [grayView removeFromSuperview];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger page = (scrollView.contentOffset.x + kWith / 2) / kWith;
    _numberLabel.text = [NSString stringWithFormat:@"%ld/%u",(long)page,self.itemsArray.count - 1];

}

@end
