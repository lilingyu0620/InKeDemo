//
//  MessageCell.h
//  InKeDemo
//
//  Created by lly on 16/7/13.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MessageModel;
@interface MessageCell : UITableViewCell

- (void)setCellWithModel:(MessageModel *)model;

@end
