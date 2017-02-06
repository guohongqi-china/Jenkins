//
//  SearchContentView.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/27.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchContentView : UIView

- (instancetype)initWithFrame:(CGRect)frame parent:(UIViewController*)controller;

- (void)refreshSearchResult:(NSString *)strResult;

@end
