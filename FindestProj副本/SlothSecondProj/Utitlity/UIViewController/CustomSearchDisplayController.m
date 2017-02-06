//
//  CustomSearchDisplayController.m
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 4/9/15.
//  Copyright (c) 2015 visionet. All rights reserved.
//

#import "CustomSearchDisplayController.h"

@implementation CustomSearchDisplayController

- (id)initWithSearchBar:(UISearchBar *)searchBar contentsController:(UIViewController *)viewController {
    self = [super initWithSearchBar:searchBar contentsController:viewController];
    if (self) {
        //extra init code necessary?
    }
    
    return self;
}


- (void)setActive:(BOOL)visible animated:(BOOL)animated {
    self.searchBar.frame = CGRectMake(0, 0, kScreenWidth-80, 44);
    [super setActive:visible animated:YES];
    self.searchBar.frame = CGRectMake(0, 0, kScreenWidth-80, 44);
    //always show navigation controller in searchview
    //[self.searchContentsController.navigationController setNavigationBarHidden:NO animated:NO];
}

@end
