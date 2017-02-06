//
//  ManListModel.m
//  FindestProj
//
//  Created by MacBook on 16/7/13.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "ManListModel.h"

@implementation ManListModel
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
}
-(void)setValue:(id)value forKey:(NSString *)key{
  
    if ([key isEqualToString:@"id"]) {
        _ID = value;
        return;
    }
    if ([key isEqualToString:@"commentVoList"]) {
        _commentVoList = [NSMutableArray array];
        for (id mod in value) {
            Model *mo = [[Model alloc]init];
            [mo setValuesForKeysWithDictionary:mod];
            [_commentVoList addObject:mo];
        }
        return;
    }
    if ([key isEqualToString:@"tagVoList"]) {
        _tagVoList = [NSMutableArray array];
        for (id mod in value) {
            Model *mo = [[Model alloc]init];
            [mo setValuesForKeysWithDictionary:mod];
            [_tagVoList addObject:mo];
        }
        return;
    }
    if ([key isEqualToString:@"mentionList"]) {
        _mentionList = [NSMutableArray array];
        for (id mod in value) {
            PraiseModel *mo = [[PraiseModel alloc]init];
            [mo setValuesForKeysWithDictionary:mod];
            [_mentionList addObject:mo];
        }
        return;
    }
    if (![value isKindOfClass:[NSString class]]) {
        value = [NSString stringWithFormat:@"%@",value];
    }
    [super setValue:value forKey:key];
    
}
- (CGFloat)returenCellHeight{
    NSLog(@"%f---%lu",[self.streamText boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, 80) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]} context:nil].size.height,(unsigned long)self.commentVoList.count);
    CGFloat he;
    if (!(self.commentVoList.count == 0 || self.commentVoList == nil)) {
        he = 121 +  [self.streamText boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, 80) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]} context:nil].size.height + self.commentVoList.count * 17 + 10;
    }else{
        he = 121 +  [self.streamText boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, 80) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]} context:nil].size.height ;
    }
    return he;
}
- (CGFloat)getHeight{
    return 27 + [self.noticeTitle boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, 80) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil].size.height;
}

@end
