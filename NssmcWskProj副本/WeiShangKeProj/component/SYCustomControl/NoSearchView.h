//
//  NoSearchView.h
//  DYRSProj
//
//  Created by 焱 孙 on 9/16/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoSearchView : UIView

@property(nonatomic,strong)UIImageView *imgViewIcon;
@property(nonatomic,strong)UILabel *lblDescription;

- (id)initWithFrame:(CGRect)frame andDes:(NSString*)strDescription;

@end
