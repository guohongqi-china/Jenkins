//
//  topModelFrame.m
//  NssmcWskProj
//
//  Created by MacBook on 16/5/24.
//  Copyright © 2016年 visionet. All rights reserved.
//

#import "topModelFrame.h"
#import "NSString+NSString_Category.h"
@implementation topModelFrame

- (void)setTopModel:(topModel *)topModel{
    _topModel = topModel;
    
    _progressRect = CGRectMake(5, 5, kScreenWidth - 10, 15);
    
    
    CGSize zieeee1 = [[NSString stringWithFormat:@"制品名称： %@",topModel.productName] sizeWithFont:[UIFont systemFontOfSize:14] maxW:kScreenWidth - 10];
    _titleFrame = (CGRect){{10,CGRectGetMaxY(_progressRect)},zieeee1};

    
    CGSize zieeee = [[NSString stringWithFormat:@"故障分析： %@",topModel.malfunctionDetail] sizeWithFont:[UIFont systemFontOfSize:14] maxW:kScreenWidth - 10];
    _titleContentFrame = (CGRect){{10,CGRectGetMaxY(_titleFrame)},zieeee};
//    _imageFrame = CGRectMake(10, CGRectGetMaxY(_titleContentFrame), (kScreenWidth - 40) / 3 * topModel.count, (kScreenWidth - 40) / 3);
    if (_iamgeArray.count != 0) {
  
    _imageFrame = CGRectMake(10, CGRectGetMaxY(_titleContentFrame) + 10, kScreenWidth - 20, (kScreenWidth - 40) / 3);
    }else{
       _imageFrame = CGRectMake(10, CGRectGetMaxY(_titleContentFrame) + 10, 0, 0);
    }

    _senderFrame = CGRectMake(10, CGRectGetMaxY(_imageFrame) + 10, kScreenWidth - 20, 30);
    _userNameFrame = CGRectMake(0, CGRectGetMaxY(_senderFrame), kScreenWidth , 35);
    _userPhoneFrame = CGRectMake(0, CGRectGetMaxY(_userNameFrame), kScreenWidth, 35);
    _userAdressFrame = CGRectMake(0, CGRectGetMaxY(_userPhoneFrame), kScreenWidth, 35);
    _distinguishUserFrame = CGRectMake(0, CGRectGetMaxY(_userAdressFrame), kScreenWidth, 35);
    _appointTimeFrame = CGRectMake(0, CGRectGetMaxY(_distinguishUserFrame), kScreenWidth, 35);
    _repairTimeFrame = CGRectMake(0, CGRectGetMaxY(_appointTimeFrame), kScreenWidth, 75);
    _classificationForDeafultFrame = CGRectMake(0, CGRectGetMaxY(_repairTimeFrame), kScreenWidth, 35);
    _priceFrame = CGRectMake(0, CGRectGetMaxY(_classificationForDeafultFrame), kScreenWidth, 35);
    _difficultyFrame = CGRectMake(0, CGRectGetMaxY(_priceFrame), kScreenWidth, 35);
    _statusFrame = CGRectMake(0, CGRectGetMaxY(_difficultyFrame), kScreenWidth, 35);
    _pinFrame = CGRectMake(10, CGRectGetMaxY(_statusFrame) + 20, kScreenWidth - 20, 45);
}

- (void)setIamgeArray:(NSMutableArray *)iamgeArray{
    if (iamgeArray.count != 0) {
        _iamgeArray = [NSMutableArray array];
        for (NSDictionary *dic in iamgeArray) {
            topModel *model = [[topModel alloc]init];
            [model setValuesForKeysWithDictionary:dic];
            [_iamgeArray addObject:model];
            
        }
        
        
    }
}

@end
