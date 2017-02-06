//
//  HomeTableViewCell.m
//  FindestProj
//
//  Created by MacBook on 16/7/15.
//  Copyright © 2016年 visionet. All rights reserved.
//
#define KscreenWidth [UIScreen mainScreen].bounds.size.width
#define KscreenHeight [UIScreen mainScreen].bounds.size.height
#import "HomeTableViewCell.h"
#import "UIView+Extension.h"
#import "FaceToolBar.h"
#import "Common.h"
#import "MBProgressHUD+GHQ.h"
#import <AFNetworking.h>
#import "FaceModel.h"
#import "RegexKitLite.h"
#import "HWTextPart.h"
@implementation HomeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpUI];
        self.contentView.backgroundColor = RGBACOLOR(220, 220, 220, 1);
    }
    return  self;
}
- (void)setUpUI{
    
    _firstView = [[UIView alloc]init];
    _firstView.backgroundColor = [UIColor whiteColor];
    _auditLabel = [self setUpLabel:13 color:RGBACOLOR(58, 108, 174, 1)];
    _auditLabel.text = @"待审核";

    //头像
    _iconImage = [[UIImageView alloc]init];
    _iconImage.image = [UIImage imageNamed:@"default_m@2x"];
    _iconImage.layer.masksToBounds = YES;
    _iconImage.layer.cornerRadius = 7.5;
    
    //创始人
    _createLabel = [self setUpLabel:14 color:RGBACOLOR(1, 1, 1, 1)];
    
    //时间、推荐语、内容、图片
    _timeLabel = [self setUpLabel:13 color:RGBACOLOR(192, 192, 192, 1)];
    _subtitleLabel = [self setUpLabel:13 color:RGBACOLOR(192, 192, 192, 1)];
    _titileLabel = [self setUpLabel:14 color:RGBACOLOR(110, 110, 110, 120)];
    _contntLabel = [self setUpLabel:13 color:RGBACOLOR(150, 150, 150, 1)];
    _contntLabel.numberOfLines = 0;
    _contentImage = [[UIImageView alloc]init];
    
    [_firstView addSubview:_auditLabel];
    [_firstView addSubview:_iconImage];
    [_firstView addSubview:_createLabel];
    [_firstView addSubview:_timeLabel];
    [_firstView addSubview:_subtitleLabel];
    [_firstView addSubview:_titileLabel];
    [_firstView addSubview:_contntLabel];
    [_firstView addSubview:_contentImage];
    
    
    _secondView = [[UIView alloc]init];
    _secondView.backgroundColor = [UIColor whiteColor];
    
    _praiseButton = [[UIButton alloc]init];
    [_praiseButton setTitleColor:RGBACOLOR(192, 192, 192, 1) forState:(UIControlStateNormal)];
//    [_praiseButton setTitle:@"赞1" forState:(UIControlStateSelected)];
    [_praiseButton setImage:[UIImage imageNamed:@"share_unpraise_icon@2x"] forState:(UIControlStateNormal)];
    [_praiseButton setImage:[UIImage imageNamed:@"share_praise_icon@2x"] forState:(UIControlStateSelected)];
    [_praiseButton addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    _praiseButton.titleLabel.font = [UIFont systemFontOfSize:14];
    
    
    _commentButton = [[UIButton alloc]init];
    [_commentButton setTitleColor:RGBACOLOR(192, 192, 192, 1) forState:(UIControlStateNormal)];
    [_commentButton setImage:[UIImage imageNamed:@"message_selected"] forState:(UIControlStateNormal)];
    [_commentButton addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    _commentButton.titleLabel.font = [UIFont systemFontOfSize:14];
    
    [_secondView addSubview:_praiseButton];
    [_secondView addSubview:_commentButton];
    
    _thirdView = [[UIView alloc]init];
    _thirdView.backgroundColor = [UIColor yellowColor];
    
    
    [self.contentView addSubview:_firstView];
    [self.contentView addSubview:_secondView];
    [self.contentView addSubview:_thirdView];
    
}

- (void)setDataModel:(ManListModel *)dataModel{
    _dataModel = dataModel;
    _firstView.frame = CGRectMake(0, 8,[UIScreen mainScreen].bounds.size.width, 0);

    _iconImage.x = 10;
    _iconImage.y = 10;
    _iconImage.width = 30;
    _iconImage.height = 30;
    
    _createLabel.text = dataModel.createName;
    _createLabel.x = CGRectGetMaxX(_iconImage.frame) + 10;
    _createLabel.y = 10;
    _createLabel.height = 15;
    [_createLabel sizeToFit];
    
    //待审核
    if ([dataModel.isDraft isEqualToString:@"2"]) {
        _auditLabel.y = _createLabel.y;
        _auditLabel.width = 50;
        _auditLabel.height = 20;
        _auditLabel.x = KscreenWidth - 60;
    }
    
    _timeLabel.text = dataModel.createDate;
    _timeLabel.x = _createLabel.x;
    _timeLabel.y = CGRectGetMaxY(_createLabel.frame);
    _timeLabel.height = _createLabel.height;
    [_timeLabel sizeToFit];
    
    _subtitleLabel.text = dataModel.subtitle;
    _subtitleLabel.x = _iconImage.x;
    _subtitleLabel.y = CGRectGetMaxY(_iconImage.frame) + 5;
    _subtitleLabel.width = KscreenWidth - 20;
    _subtitleLabel.height = 15;
    
    _titileLabel.text = dataModel.titleName;
    _titileLabel.x = _iconImage.x;
    _titileLabel.y = CGRectGetMaxY(_subtitleLabel.frame) + 2;
    _titileLabel.width = KscreenWidth - 20;
    _titileLabel.height = 15;
    
    _contntLabel.text = dataModel.streamText;
    _contntLabel.x = _iconImage.x;
    _contntLabel.y = CGRectGetMaxY(_titileLabel.frame) + 2;
    _contntLabel.width = _titileLabel.width;
    CGFloat lable2Rect = [dataModel.streamText boundingRectWithSize:CGSizeMake(_contntLabel.width, 80) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]} context:nil].size.height;
    _contntLabel.height = lable2Rect;
    
    //设置frame
    _firstView.height = CGRectGetMaxY(_contntLabel.frame) + 2;
    _secondView.frame = CGRectMake(0,CGRectGetMaxY(_firstView.frame) + 1, KscreenWidth, 30);
    
    //判断第三个视图是否显示出来
    if (!(dataModel.commentVoList.count == 0 || dataModel.commentVoList == nil)) {
        NSLog(@"=======%ld",(unsigned long)_thirdView.subviews.count);
        FaceModel *emo = [FaceModel sharedManager];
        
        NSLog(@"%@",emo.modelArr);
        
        for (id mod in _thirdView.subviews) {
            if ([mod isKindOfClass:[UILabel class]]) {
                [mod removeFromSuperview];
            }
        }
        for (int i = 0; i < dataModel.commentVoList.count; i ++) {
            Model *mo = dataModel.commentVoList[i];
            UILabel *textLabel = [[UILabel alloc]init];
            
            textLabel.font = [UIFont systemFontOfSize:13];
            textLabel.textColor = RGBACOLOR(200, 200, 200, 1);
            
            
            NSMutableAttributedString *strm = [[NSMutableAttributedString alloc]init];
            NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc]initWithString:mo.commentText];
            NSAttributedString *textStr;
//            if ([mo.commentText hasPrefix:@"回复"]) {
//                NSAttributedString *str1 = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ :",mo.userName]];
//                [str2 addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(58, 108, 174, 1) range:NSMakeRange(0, 2)];
//                [str2 addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(40, 40, 40, 1) range:NSMakeRange(2, str2.length - 2)];
//                [strm appendAttributedString:str1];
//                [strm appendAttributedString:str2];
//                textStr = strm;
//            }else{
//                NSAttributedString *str1 = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ :",mo.userName]];
//                [str2 addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(40, 40, 40, 1) range:NSMakeRange(0, str2.length)];
//                [strm appendAttributedString:str1];
//                [strm appendAttributedString:str2];
//                textStr = strm;
//            }
            NSMutableAttributedString *string = [self attributedTextWithText:mo.commentText];
            if ([mo.commentText hasPrefix:@"回复"]) {
                NSAttributedString *str1 = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ :",mo.userName]];
                [string addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(58, 108, 174, 1) range:NSMakeRange(0, 2)];
                [string addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(40, 40, 40, 1) range:NSMakeRange(2, string.length - 2)];
                [strm appendAttributedString:str1];
                [strm appendAttributedString:string];
                textStr = strm;
            }else{
                NSAttributedString *str1 = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ :",mo.userName]];
                [string addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(40, 40, 40, 1) range:NSMakeRange(0, string.length)];
                [strm appendAttributedString:str1];
                [strm appendAttributedString:string];
                textStr = strm;
            }
            textLabel.attributedText = textStr;
            
            [self.thirdView  addSubview:textLabel];
            textLabel.x = 10;
            textLabel.width = KscreenWidth - 20;
            textLabel.height = 15;
            textLabel.y = 5 + i * 17;
        }
        self.thirdView.hidden = NO;
        _thirdView.frame = CGRectMake(0, CGRectGetMaxY(_secondView.frame) + 1, KscreenWidth, dataModel.commentVoList.count * 17 + 10 );

    }else{
        self.thirdView.hidden = YES;
        _thirdView.height = 0;
    }
    _thirdView.backgroundColor = [UIColor whiteColor];
    
    [_commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_secondView.mas_right).offset(-10);
        make.centerY.equalTo(_secondView.mas_centerY);
        make.width.equalTo(@90);
        make.height.equalTo(@28);
    }];
    [_praiseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_commentButton.mas_left).offset(-5);
        make.centerY.equalTo(_secondView.mas_centerY);
        make.width.equalTo(_commentButton.mas_width);
        make.height.equalTo(_commentButton.mas_height);
    }];
    [_commentButton setTitle:[NSString stringWithFormat:@"评论%@",dataModel.commentCount] forState:(UIControlStateNormal)];
    [_praiseButton setTitle:[NSString stringWithFormat:@"赞%@",dataModel.praiseCount] forState:(UIControlStateNormal)];

    _commentButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    _commentButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 50);
    _praiseButton.titleEdgeInsets = _commentButton.titleEdgeInsets;
    _praiseButton.imageEdgeInsets = UIEdgeInsetsMake(-5, 5, -5, 50);

    [self layoutIfNeeded];

}
/**
 *  普通文字 --> 属性文字
 *
 *  @param text 普通文字
 *
 *  @return 属性文字
 */
- (NSMutableAttributedString *)attributedTextWithText:(NSString *)text
{
    
//    if ([text hasPrefix:@"回复"]) {
//        
//                        [text addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(58, 108, 174, 1) range:NSMakeRange(0, 2)];
////                        [str2 addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(40, 40, 40, 1) range:NSMakeRange(2, str2.length - 2)];
////                        [strm appendAttributedString:str1];
////                        [strm appendAttributedString:str2];
////                        textStr = strm;
//                    }else{
////                        NSAttributedString *str1 = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ :",mo.userName]];
////                        [str2 addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(40, 40, 40, 1) range:NSMakeRange(0, str2.length)];
////                        [strm appendAttributedString:str1];
////                        [strm appendAttributedString:str2];
////                        textStr = strm;
//                    }

    
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    
    // 表情的规则
    NSString *emotionPattern = @"\\[[0-9a-zA-Z\\u4e00-\\u9fa5]+\\]";
    // @的规则
    NSString *atPattern = @"@[0-9a-zA-Z\\u4e00-\\u9fa5-_]+";
    // #话题#的规则
    NSString *topicPattern = @"#[0-9a-zA-Z\\u4e00-\\u9fa5]+#";
    // url链接的规则
    NSString *urlPattern = @"\\b(([\\w-]+://?|www[.])[^\\s()<>]+(?:\\([\\w\\d]+\\)|([^[:punct:]\\s]|/)))";
    NSString *pattern = [NSString stringWithFormat:@"%@|%@|%@|%@", emotionPattern, atPattern, topicPattern, urlPattern];
    
    // 遍历所有的特殊字符串
    NSMutableArray *parts = [NSMutableArray array];
    [text enumerateStringsMatchedByRegex:pattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        if ((*capturedRanges).length == 0) return;
        
        HWTextPart *part = [[HWTextPart alloc] init];
        part.special = YES;
        part.text = *capturedStrings;
        part.emotion = [part.text hasPrefix:@"["] && [part.text hasSuffix:@"]"];
        part.range = *capturedRanges;
        [parts addObject:part];
    }];
    // 遍历所有的非特殊字符
    [text enumerateStringsSeparatedByRegex:pattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        if ((*capturedRanges).length == 0) return;
        
        HWTextPart *part = [[HWTextPart alloc] init];
        part.text = *capturedStrings;
        part.range = *capturedRanges;
        [parts addObject:part];
    }];
    
    // 排序
    // 系统是按照从小 -> 大的顺序排列对象
    [parts sortUsingComparator:^NSComparisonResult(HWTextPart *part1, HWTextPart *part2) {
        // NSOrderedAscending = -1L, NSOrderedSame, NSOrderedDescending
        // 返回NSOrderedSame:两个一样大
        // NSOrderedAscending(升序):part2>part1
        // NSOrderedDescending(降序):part1>part2
        if (part1.range.location > part2.range.location) {
            // part1>part2
            // part1放后面, part2放前面
            return NSOrderedDescending;
        }
        // part1<part2
        // part1放前面, part2放后面
        return NSOrderedAscending;
    }];
    FaceModel *arr = [FaceModel sharedManager];

    UIFont *font = [UIFont systemFontOfSize:14];
    // 按顺序拼接每一段文字
    for (HWTextPart *part in parts) {
        // 等会需要拼接的子串
        NSAttributedString *substr = nil;
        if (part.isEmotion) { // 表情
            NSLog(@"%@",part.text);
            NSTextAttachment *attch = [[NSTextAttachment alloc] init];
            for (FaceModel *face in arr.modelArr) {
                if ([face.chs isEqualToString:part.text]) {
            attch.image = [UIImage imageNamed:face.image];
                    NSLog(@"=======%@",face.image);
            attch.bounds = CGRectMake(0, -3, font.lineHeight, font.lineHeight);
            substr = [NSAttributedString attributedStringWithAttachment:attch];
                }
            }

        } else if (part.special) { // 非表情的特殊文字
            substr = [[NSAttributedString alloc] initWithString:part.text attributes:@{
                                                                                       NSForegroundColorAttributeName : [UIColor redColor]
                                                                                       }];
        } else { // 非特殊文字
            substr = [[NSAttributedString alloc] initWithString:part.text];
        }
        [attributedText appendAttributedString:substr];
    }
    
    // 一定要设置字体,保证计算出来的尺寸是正确的
    [attributedText addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributedText.length)];
    
    return attributedText;
}


/**
 *  点击事件
 */
- (void)buttonAction:(UIButton *)sender{
    if (sender == _praiseButton) {
        
        NSString *strBody = [NSString stringWithFormat:@"http://vn-functional.chinacloudapp.cn/vx//mobile/blog/mentionBlog/%@",_dataModel.ID];

        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        //申明请求的数据格式（json格式）
        manager.requestSerializer=[AFJSONRequestSerializer serializer];
        [manager GET:strBody parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSString *strID = [NSString stringWithFormat:@"%@",responseObject[@"id"]];
            if (strID.length == 0||strID == nil || [strID isEqualToString:@"<null>"]) {
                [MBProgressHUD showSuccess:@"取消点赞成功" toView:nil];
//                [_praiseButton setTitle:[NSString stringWithFormat:@"赞%d",([_dataModel.praiseCount integerValue] - 1)] forState:(UIControlStateNormal)];


            }else{
                [MBProgressHUD showSuccess:@"点赞成功" toView:nil];
//                [_praiseButton setTitle:[NSString stringWithFormat:@"赞%d",([_dataModel.praiseCount integerValue] + 1)] forState:(UIControlStateNormal)];


            }
             sender.selected = !sender.isSelected;
            if (self.delegate && [self.delegate respondsToSelector:@selector(homeTableViewCellPraiseButton:)]) {
                [self.delegate homeTableViewCellPraiseButton:_dataModel.ID];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [MBProgressHUD showSuccess:@"失败" toView:nil];

        }];
        }else{
            
        }

}
/**
 *  指定label的某些属性，并返回一个label
 */
- (UILabel *)setUpLabel:(CGFloat )font color:(UIColor *)color{
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:font];
    label.textColor = color;
    return label;
}


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
