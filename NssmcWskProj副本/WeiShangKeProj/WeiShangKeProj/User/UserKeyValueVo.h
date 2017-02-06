//
//  UserKeyValueVo.h
//  NssmcWskProj
//
//  Created by 焱 孙 on 15/12/9.
//  Copyright © 2015年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserKeyValueVo : NSObject

- (instancetype)initWithKey:(NSString*)strKey title:(NSString *)strTitle;

@property (nonatomic,strong) NSString *strKey;
@property (nonatomic,strong) NSString *strTitle;
@property (nonatomic,strong) id value;

@end
