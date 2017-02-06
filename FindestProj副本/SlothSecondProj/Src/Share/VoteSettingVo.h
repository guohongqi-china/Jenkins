//
//  VoteSettingVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/2.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoteSettingVo : NSObject

@property (nonatomic) NSInteger nID;    //0:支持多选、1:最少需投票项、2:最多可投票项、3:投票有效期
@property (nonatomic,strong) NSString *strTitle;
@property (nonatomic,strong) NSString *strValue;
@property (nonatomic) NSInteger nNumValue;
@property (nonatomic) NSInteger nRow;

@end
