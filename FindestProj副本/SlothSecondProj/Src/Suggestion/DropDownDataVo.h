//
//  DropDownDataVo.h
//  DYRSProj
//
//  Created by 焱 孙 on 8/27/14.
//  Copyright (c) 2014 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DropDownDataVo : NSObject

@property(nonatomic) NSInteger nIndex;
          
@property(nonatomic,strong)NSString *strID;
@property(nonatomic,strong)NSString *strName;

@property(nonatomic)NSInteger nType;//(分公司:1)、(状态:2)

@end
