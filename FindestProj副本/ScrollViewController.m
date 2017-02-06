//
//  ScrollViewController.m
//  FindestProj
//
//  Created by MacBook on 16/7/20.
//  Copyright © 2016年 visionet. All rights reserved.
//
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#import "UIBarButtonItem+Extension.h"
#import "ScrollViewController.h"
#import "UIView+Extension.h"
@interface ScrollViewController ()
{
    UIScrollView *scrollView;
    UILabel *contentLabel;
    UILabel *timeLabel;

}
@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}
- (void)setUpUI{
    self.title = @"公告详情";
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:19],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(buttonAction) image:@"3 (6)" highImage:nil];

    
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KscreenWidth, KscreenHeight)];
    scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.showsVerticalScrollIndicator = NO;
    
 
    contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, KscreenWidth - 20, 0)];
    contentLabel.font = [UIFont systemFontOfSize:15];
    contentLabel.textColor = [UIColor grayColor];
    contentLabel.text = _dataModel.noticeTitle;
    CGFloat lable2Rect = [_dataModel.noticeTitle boundingRectWithSize:CGSizeMake(contentLabel.width, 80) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil].size.height;
    contentLabel.height = lable2Rect;
    
    timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(KscreenWidth - 110, CGRectGetMaxY(contentLabel.frame), 100, 20)];
    timeLabel.font = [UIFont systemFontOfSize:15];
    timeLabel.textColor = RGBACOLOR(61, 112, 141, 1);
    timeLabel.text = _dataModel.createDate;
    
    
    scrollView.contentSize = CGSizeMake(0, KscreenHeight);

    if (CGRectGetMaxY(timeLabel.frame) > KscreenHeight) {
        scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(timeLabel.frame));
    }
    

    [self.view addSubview:scrollView];
    [scrollView addSubview:contentLabel];
    [scrollView addSubview:timeLabel];
    
}
- (void)buttonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
