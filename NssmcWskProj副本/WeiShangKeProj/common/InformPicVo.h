//
//  InformPicVo.h
//  assistant
//
//  Created by Apple on 15/7/29.
//  Copyright (c) 2015年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InformPicVo : NSObject
@property(nonatomic,assign)NSInteger strID;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *msg;

@property(nonatomic,copy)NSString *prefix;
//@property(nonatomic,copy)NSString *code;
@property(nonatomic,copy)NSString *img;

@property(nonatomic,copy)NSString *midImg;
@property(nonatomic,copy)NSString *minImg;
@property(nonatomic,copy)NSString *strCode;

//@property(nonatomic,copy)NSString *absoluteImagePath;
@property(nonatomic,copy)NSString *midUrl;
@property(nonatomic,copy)NSString *maxUrl;
@property(nonatomic,copy)NSString *minUrl;




@end
