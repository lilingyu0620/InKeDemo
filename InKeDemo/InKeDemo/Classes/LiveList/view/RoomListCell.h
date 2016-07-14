//
//  RoomListCell.h
//  InKeDemo
//
//  Created by lly on 16/7/9.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RoomListModel;
@interface RoomListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roomListImageViewHeight;

- (void)setCellWithModel:(RoomListModel *)model;
@end
