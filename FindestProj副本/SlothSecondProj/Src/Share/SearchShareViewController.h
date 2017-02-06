//
//  SearchShareViewController.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/1/28.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonViewController.h"
#import "TagVo.h"

@interface SearchShareViewController : CommonViewController

//页面类型,categoryBlog:分类查询（分享、投票、问答）、essence:精华区、hotSearch:热门搜索、hotTag:热门话题
@property (nonatomic, strong) NSString *strPageType;

@property (nonatomic, strong) TagVo *tagVo;

@end
