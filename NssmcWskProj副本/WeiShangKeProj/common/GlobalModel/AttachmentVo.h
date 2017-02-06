//
//  AttachmentVo.h
//  ChinaMobileSocialProj
//
//  Created by 焱 孙 on 13-12-2.
//
//

#import <Foundation/Foundation.h>

@interface AttachmentVo : NSObject

@property(nonatomic,strong) NSString *strID;                    //附件ID
@property(nonatomic,strong) NSString *strAttachmentName;        //附件名称
@property(nonatomic,strong) NSString *strAttachmentURL;         //附件URL
@property(nonatomic) long long lAttachmentSize;                 //附件大小

@property(nonatomic) int nAttachType;                           //附件类型(0:图片,1:其他附件)
@property(nonatomic,strong) NSString *strAttachLocalPath;       //附件本地路径

@end
