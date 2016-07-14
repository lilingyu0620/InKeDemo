//
//  UserModel.h
//  InKeDemo
//
//  Created by lly on 16/7/12.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

//{
//    "emotion": "ä¿å¯",
//    "inke_verify": 0,
//    "verified": 0,
//    "description": "èªåªä½å°æ¯å¤§éæªæ¥çä¸»æµåªä½\n",
//    "gender": 0,
//    "profession": "LJ CEO",
//    "id": 57116510,
//    "verified_reason": "",
//    "nick": "S TÂ·é¨å£°",
//    "location": "",
//    "birth": "1980-08-04",
//    "hometown": "ä¸æµ·å¸&",
//    "portrait": "NTM1MzIxNDY4MjkxNDU1.jpg",
//    "gmutex": 1,
//    "third_platform": "0",
//    "level": 186,
//    "rank_veri": 22,
//    "veri_info": "å»ºå®å
//    ¬ä¸»"
//}

@interface UserModel : NSObject

@property (nonatomic,assign) double id;
@property (nonatomic,copy) NSString *portrait;
@property (nonatomic,copy) NSString *emotion;
@property (nonatomic,assign) int inke_verify;
@property (nonatomic,assign) int verified;
@property (nonatomic,copy) NSString *description;
@property (nonatomic,assign) int gender;
@property (nonatomic,copy) NSString *profession;
@property (nonatomic,copy) NSString *verified_reason;
@property (nonatomic,copy) NSString *nick;
@property (nonatomic,copy) NSString *location;
@property (nonatomic,copy) NSString *birth;
@property (nonatomic,copy) NSString *hometown;
@property (nonatomic,assign) int gmutex;
@property (nonatomic,copy) NSString *third_platform;
@property (nonatomic,assign) int level;
@property (nonatomic,assign) int rank_veri;
@property (nonatomic,copy) NSString *veri_info;





@end
