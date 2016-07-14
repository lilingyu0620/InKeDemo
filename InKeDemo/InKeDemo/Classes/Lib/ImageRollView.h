//
//  ImageRollView.h
//  InKeDemo
//
//  Created by lly on 16/7/8.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RollImageModel;

@protocol ImageRollViewDelegate <NSObject>

- (void)btnClickedWithModel:(RollImageModel *)model;

@end


@interface ImageRollView : UIView

@property (nonatomic,weak) id<ImageRollViewDelegate> delegate;

@property (nonatomic,strong) NSMutableArray *imageArray;

- (void)reloaData:(NSMutableArray *)array;

@end
