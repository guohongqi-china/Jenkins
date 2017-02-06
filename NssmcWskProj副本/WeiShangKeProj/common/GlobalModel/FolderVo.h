//
//  FolderVo.h
//  SlothSecondProj
//
//  Created by 焱 孙 on 14-6-17.
//  Copyright (c) 2014年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FolderVo : NSObject

@property(nonatomic,strong)NSString *strID;//文件夹ID
@property(nonatomic,strong)NSString *strName;//文件夹名称
@property(nonatomic,strong)NSString *strRemark;//备注
@property(nonatomic)NSInteger nIsDefault;//是否为默认文件夹	如果为1,则不允许删除
@property(nonatomic,strong)NSString *strCreatorID;//创建人id
@property(nonatomic,strong)NSString *strHeaderImgUrl;//封面URL

@end
