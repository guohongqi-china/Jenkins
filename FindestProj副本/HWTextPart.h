//
//  HWTextPart.h
//  FindestProj
//
//  Created by MacBook on 16/7/21.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HWTextPart : NSObject
/** 这段文字的内容 */
@property (nonatomic, copy) NSString *text;
/** 这段文字的范围 */
@property (nonatomic, assign) NSRange range;
/** 是否为特殊文字 */
@property (nonatomic, assign, getter = isSpecical) BOOL special;
/** 是否为表情 */
@property (nonatomic, assign, getter = isEmotion) BOOL emotion;
@end
