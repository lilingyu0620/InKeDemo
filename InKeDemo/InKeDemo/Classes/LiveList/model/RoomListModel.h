//
//  RoomListModel.h
//  InKeDemo
//
//  Created by lly on 16/7/9.
//  Copyright © 2016年 lly. All rights reserved.
//


//{
//    "city": "本溪市",
//    "creator": {
//        "id": 2213035,
//        "level": 50,
//        "nick": "平模.bobi",
//        "portrait": "Mjk0NDkxNDY3Mzk4Njkw.jpg"
//    },
//    "group": 0,
//    "id": "1468033950384744",
//    "link": 0,
//    "multi": 0,
//    "name": "",
//    "online_users": 18774,
//    "optimal": 0,
//    "rotate": 0,
//    "share_addr": "http://live3.a8.com/s/?uid=2213035&liveid=1468033950384744&ctime=1468033950",
//    "slot": 2,
//    "stream_addr": "http://pull99.a8.com/live/1468033950384744.flv?ikHost=ws&ikOp=1&CodecInfo=8192",
//    "version": 0		
//}

#import <Foundation/Foundation.h>


@interface CreatorModel : NSObject
@property (nonatomic,assign) double id;
@property (nonatomic,assign) int level;
@property (nonatomic,copy) NSString *nick;
@property (nonatomic,copy) NSString *portrait;
@property (nonatomic,copy) NSString *location;
@end


@interface RoomListModel : NSObject
@property (nonatomic,copy) NSString *city;
@property (nonatomic,strong) CreatorModel *creator;
@property (nonatomic,assign) double id;
@property (nonatomic,assign) double online_users;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *share_addr;
@property (nonatomic,assign) int slot;
@property (nonatomic,copy) NSString *stream_addr;
@property (nonatomic,assign) double room_id;

@end
