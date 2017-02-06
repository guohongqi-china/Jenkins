//
//  FaceLabel.h
//  TestFaceProj
//
//  Created by 焱 孙 on 10/14/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaceLabel : UILabel

@property(nonatomic)BOOL bShowGIF;//是否显示GIF
@property(nonatomic,strong)NSMutableArray *aryTextFace; //文字和表情数组

@property(nonatomic,strong)NSMutableArray *aryGifImage;

+ (id)getFaceLabelInstanceWithFont:(UIFont*)font;
- (id)initWithFrame:(CGRect)frame andFont:(UIFont*)font;
- (CGSize)calculateTextHeight:(NSString *)text andBound:(CGSize)sizeBound;

@end
