//
//  VoteOptionVo.h
//  Sloth
//
//  Created by 焱 孙 on 12-12-27.
//
//

#import <Foundation/Foundation.h>

@interface VoteOptionVo : NSObject

@property(nonatomic,assign)int nOptionId;                   //投票项ID
@property(nonatomic,retain)NSString *strOptionName;         //投票项内容	
@property(nonatomic,retain)NSString *strVoterName;          //投票人员姓名（格式:姓名#姓名）
@property(nonatomic,assign)int nCount;                      //this vote option count
@property(nonatomic,assign)BOOL bAlreadyVote;               //当前用户是否投过该项
@property(nonatomic,strong)NSString *strImage;
//编程使用
@property(nonatomic,assign)int nSelected;                   //是否选中
@property(nonatomic,assign)BOOL bExpansion;                    //是否展开

@end
