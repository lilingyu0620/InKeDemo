//
//  UserCell.m
//  InKeDemo
//
//  Created by lly on 16/7/12.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "UserCell.h"
#import "UserModel.h"

@interface UserCell()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end


@implementation UserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)setCellWithModel:(UserModel *)model{

    [self.imageView setImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://image.scale.inke.com/imageproxy2/dimgm/scaleImage?url=%@&w=72&s=80&h=72&c=0&o=0",[NSString stringWithFormat:@"http://img.meelive.cn/%@",model.portrait]]]];
    self.imageView.layer.cornerRadius = 18;
    self.imageView.layer.borderColor = [UIColor colorWithHexString:@"0xA167A6"].CGColor;
    self.imageView.layer.borderWidth = 1;
    self.imageView.layer.masksToBounds = YES;

}
@end
