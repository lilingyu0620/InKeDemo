//
//  RoomListCell.m
//  InKeDemo
//
//  Created by lly on 16/7/9.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "RoomListCell.h"
#import "RoomListModel.h"

@interface RoomListCell()



@property (weak, nonatomic) IBOutlet UIImageView *portraitImageView;
@property (weak, nonatomic) IBOutlet UIImageView *roomImageView;

@property (weak, nonatomic) IBOutlet UILabel *liveLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineLabel;

@property (weak, nonatomic) IBOutlet UIView *nameView;


@end

@implementation RoomListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setCellWithModel:(RoomListModel *)model{
    
    if ([model.creator.portrait containsString:@"http"]) {
        [self.portraitImageView setImageURL:[NSURL URLWithString:model.creator.portrait]];
        [self.roomImageView setImageURL:[NSURL URLWithString:model.creator.portrait]];
    }
    else{
        [self.portraitImageView setImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.meelive.cn/%@",model.creator.portrait]]];
        [self.roomImageView setImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.meelive.cn/%@",model.creator.portrait]]];
    }
    self.portraitImageView.layer.cornerRadius = 22;
    self.portraitImageView.layer.borderColor = [UIColor colorWithHexString:@"0xA167A6"].CGColor;
    self.portraitImageView.layer.borderWidth = 2;
    self.portraitImageView.layer.masksToBounds = YES;
    
    NSString *locationStr;
    if ([model.city isEqualToString:@""] || model.city == nil) {
        locationStr = model.creator.location;
    }
    else{
        locationStr = model.city;
    }
    if (locationStr == nil || [locationStr isEqualToString:@""]) {
        self.locationLabel.text = @"难道在火星？";
    }
    else{
        self.locationLabel.text = locationStr;
    }
    
    self.nickNameLabel.text = model.creator.nick;
    self.onlineLabel.text = [@(model.online_users) stringValue];
    
    if ([model.name isEqualToString:@""] || model.name == nil) {
        self.nameView.hidden = YES;
    }
    else{
        self.nameView.hidden = NO;
        if ([model.name containsString:@"#"]) {
            self.nameLabel.textColor = [UIColor colorWithHexString:@"0x8FE3D4"];
        }
        else {
            self.nameLabel.textColor = [UIColor colorWithHexString:@"0xaaaaaa"];
        }
        self.nameLabel.text = model.name;
    }
    
    self.liveLabel.layer.cornerRadius = 10;
    self.liveLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.liveLabel.layer.borderWidth = 1;
    self.liveLabel.layer.masksToBounds = YES;
    self.liveLabel.textColor = [UIColor whiteColor];
    self.liveLabel.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.1];
}


@end
