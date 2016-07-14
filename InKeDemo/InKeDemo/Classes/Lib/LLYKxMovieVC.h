//
//  LLYKxMovieVC.h
//  InKeDemo
//
//  Created by lly on 16/7/11.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KxMovieDecoder;
@class RoomListModel;

extern NSString * const KxMovieParameterMinBufferedDuration;    // Float
extern NSString * const KxMovieParameterMaxBufferedDuration;    // Float
extern NSString * const KxMovieParameterDisableDeinterlacing;   // BOOL

@interface LLYKxMovieVC : UIViewController

+ (id) movieViewControllerWithContentPath: (NSString *) path
                               parameters: (NSDictionary *) parameters;

@property (readonly) BOOL playing;
@property (nonatomic,strong) RoomListModel *roomModel;

- (void) play;
- (void) pause;

@property (nonatomic,strong) UINavigationController *mNav;
@end
