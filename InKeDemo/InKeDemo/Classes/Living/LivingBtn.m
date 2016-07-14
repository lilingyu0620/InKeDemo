//
//  LivingBtn.m
//  InKeDemo
//
//  Created by lly on 16/7/6.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "LivingBtn.h"

@implementation LivingBtn{

    CGFloat *_buttonImageHeight;
}


+ (void)load {
    [super registerSubclass];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.adjustsImageWhenHighlighted = NO;
    }
    return self;
}

//上下结构的 button
- (void)layoutSubviews {
    [super layoutSubviews];
    
}

#pragma mark -
#pragma mark - CYLPlusButtonSubclassing Methods

/*
 *
 Create a custom UIButton without title and add it to the center of our tab bar
 *
 */
+ (id)plusButton
{

    UIImage *buttonImage = [UIImage imageNamed:@"tab_room"];
    UIImage *highlightImage = [UIImage imageNamed:@"tab_room_p"];

    LivingBtn* button = [LivingBtn buttonWithType:UIButtonTypeCustom];

    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [button addTarget:button action:@selector(clickLivingBtn) forControlEvents:UIControlEventTouchUpInside];

    return button;
}


- (void)clickLivingBtn{


    
}


#pragma mark - CYLPlusButtonSubclassing

+ (CGFloat)multiplerInCenterY {
    return  0.3;
}

@end
