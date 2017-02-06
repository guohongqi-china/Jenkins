//
//  ReportUserVo.h
//  TaoZhiHuiProj
//
//  Created by 焱 孙 on 16/3/14.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReportUserVo : NSObject

@property (nonatomic,strong) NSString *strReportUserID;//被举报用户ID
@property (nonatomic,strong) NSString *strReportRefID;//被举报数据ID
@property (nonatomic,strong) NSString *strReportRefType;//分享：B；提问：Q；回答：A；消息：S
@property (nonatomic,strong) NSString *strReasonID;//1:广告或垃圾信息; 2:色情暴露内容; 3:政治敏感话题; 4:人身攻击等不实内容;
@property (nonatomic,strong) NSString *strReason;//举报原因描述

@end
