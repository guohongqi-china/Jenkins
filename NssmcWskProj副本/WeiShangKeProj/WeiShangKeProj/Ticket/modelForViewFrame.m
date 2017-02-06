//
//  modelForViewFrame.m
//  NssmcWskProj
//
//  Created by MacBook on 16/5/23.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "modelForViewFrame.h"
#import "NSString+NSString_Category.h"
@implementation modelForViewFrame

- (void)setModelForView:(modelForView *)modelForView{
    _modelForView = modelForView;
    _timeRect = CGRectMake(24, 0, 260, 25);
    CGSize contesize = [modelForView.contentString sizeWithFont:[UIFont systemFontOfSize:14] maxW:kScreenWidth - 50];
//    CGSize contesize = [modelForView.contentString sizeWithFont:[UIFont systemFontOfSize:14]];
    _contentRect = (CGRect){CGPointMake(24, CGRectGetMaxY(_timeRect)),{contesize.width, contesize.height + 20}};
    _imageFrame = CGRectMake(0, 0, 20, CGRectGetMaxY(_contentRect));
    
}
@end
