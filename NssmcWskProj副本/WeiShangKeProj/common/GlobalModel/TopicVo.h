//
//  TopicVo.h
//  Sloth
//
//  Created by 焱 孙 on 13-1-3.
//
//

#import <Foundation/Foundation.h>

@interface TopicVo : NSObject

@property(nonatomic,retain)NSString *strTopicId;
@property(nonatomic,retain)NSString *strTopicName;
@property(nonatomic,assign)int nNoReadNum;              //未读数据
@property(nonatomic,assign)int nIsLocked;               //1:locked,0:unlocked 

@end
