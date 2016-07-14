//
//  MessageCell.m
//  InKeDemo
//
//  Created by lly on 16/7/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "MessageCell.h"
#import "MessageModel.h"

@interface MessageCell()

@property (strong, nonatomic) IBOutlet UILabel *messageLabel;


@end

@implementation MessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellWithModel:(MessageModel *)model{

    self.messageLabel.preferredMaxLayoutWidth = (kScreenWidth-8);
    NSString *str = [NSString stringWithFormat:@"%@:%@",model.userNameStr,model.messageStr];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:str];
    //设置文字颜色
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range:[str rangeOfString:model.userNameStr]];
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:[str rangeOfString:model.messageStr]];
    self.messageLabel.attributedText = attStr;

}

@end
