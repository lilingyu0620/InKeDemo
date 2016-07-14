//
//  DeviceMacro.h
//  SohuHouse
//
//  Created by sohu on 16/3/15.
//  Copyright © 2016年 focus.cn. All rights reserved.
//

#ifndef DeviceMacro_h
#define DeviceMacro_h


//*********************************应用程序托管*******************************************//
#define AppDelegateInstance	     ((AppDelegate*)([UIApplication sharedApplication].delegate))
#define DBMgr [DataBaseManager sharedInstance]
#define SocketDispenserInstance [SocketDispenser sharedInstance]
#define USER_DEFAULT                [NSUserDefaults standardUserDefaults]
#define CurNetworkStatus [AppDelegateInstance getNetworkReachabilityStatus] //当前网络状态


//*********************************设备屏幕参数及尺寸*******************************************//
#define kDeviceWidth                [UIScreen mainScreen].bounds.size.width
#define kDeviceHeight               [UIScreen mainScreen].bounds.size.height

#define getOriginX(view)        view.frame.origin.x
#define getOriginY(view)        view.frame.origin.y
#define getViewWidth(view)      view.frame.size.width
#define getViewHeight(view)     view.frame.size.height

#define kScreen_Height   ([UIScreen mainScreen].bounds.size.height)
#define kScreen_Width    ([UIScreen mainScreen].bounds.size.width)
#define kScreen_Frame    (CGRectMake(0, 0 ,kScreen_Width,kScreen_Height))
#define kScreen_CenterX  (kScreen_Width/2)
#define kScreen_CenterY  (kScreen_Height/2)

//应用尺寸(不包括状态栏,通话时状态栏高度不是20，所以需要知道具体尺寸)
#define kContent_Height   ([UIScreen mainScreen].applicationFrame.size.height)
#define kContent_Width    ([UIScreen mainScreen].applicationFrame.size.width)
#define kContent_Frame    (CGRectMake(0, 0 ,kContent_Width,kContent_Height))
#define kContent_CenterX  kContent_Width/2
#define kContent_CenterY  kContent_Height/2

//屏幕物理宽度
#define iPhone6P_ScreenWidth 414
#define iPhone6_ScreenWidth 375
#define OtherDevice_ScreenWidth 320

/*
 类似九宫格的九个点
 
 p1 --- p2 --- p3
 |      |      |
 p4 --- p5 --- p6
 |      |      |
 p7 --- p8 --- p9
 
 */
#define kP1 CGPointMake(0                 ,0)
#define kP2 CGPointMake(kContent_Width/2  ,0)
#define kP3 CGPointMake(kContent_Width    ,0)
#define kP4 CGPointMake(0                 ,kContent_Height/2)
#define kP5 CGPointMake(kContent_Width/2  ,kContent_Height/2)
#define kP6 CGPointMake(kContent_Width    ,kContent_Height/2)
#define kP7 CGPointMake(0                 ,kContent_Height)
#define kP8 CGPointMake(kContent_Width/2  ,kContent_Height)
#define kP9 CGPointMake(kContent_Width    ,kContent_Height)


//*********************************设备字体字号定义*******************************************//
#define HelveticaNeueFONT(fontSize)       [UIFont fontWithName:@"HelveticaNeue" size:fontSize]
#define HelveticaNeueBoldFONT(fontSize)   [UIFont fontWithName:@"HelveticaNeue-Bold" size:fontSize]


//*********************************设备系统版本定义*******************************************//
#define isIOS7                 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
//判断系统版本
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
//判断是否大于 IOS7
#define IS_IOS7 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")

//判断是否是iphone5
#define IS_WIDESCREEN                              ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - (double)568 ) < __DBL_EPSILON__ )
#define IS_IPHONE                                  ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] || [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone Simulator" ])
#define IS_IPOD                                    ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )
#define IS_IPHONE_5                                ( IS_IPHONE && IS_WIDESCREEN )

#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)\

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)\

#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)\

#define iPhone6plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)  || CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) : NO)\

//#define iPhone6plus CGSizeEqualToSize(CGSizeMake(1242, 2208), [UIScreen mainScreen].bounds.size) ? YES :NO

#define NAV7                                                                                \
if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)                              \
{                                                                                           \
[self.navigationController.navigationBar setBarTintColor:[UIColor clearColor]];             \
self.edgesForExtendedLayout = UIRectEdgeNone;                                               \
}                                                                                           \
else                                                                                        \
{                                                                                           \
[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bg.png"] forBarMetrics:UIBarMetricsDefault];                                                     \
}


//*********************************RGB色值及图片定义*******************************************//
#define RGBCOLOR(r,g,b)             [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a)          [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define RGBCOLORS(a)                [UIColor colorWithRed:(a)/255.0 green:(a)/255.0 blue:(a)/255.0 alpha:1]

#define HexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define HexRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

#define HexRGBSTR(hexString)  [UIColor colorWithHexString:hexString]

#define HexRGBSTRAlpha(hexString,a)  [UIColor colorWithHexString:hexString alpha:a]


//Image可拉伸的图片
#define ResizableImage(name,top,left,bottom,right) [[UIImage imageNamed:name] resizableImageWithCapInsets:UIEdgeInsetsMake(top,left,bottom,right)]
#define ResizableImageWithMode(name,top,left,bottom,right,mode) [[UIImage imageNamed:name] resizableImageWithCapInsets:UIEdgeInsetsMake(top,left,bottom,right) resizingMode:mode]


//*********************************LOG日志定义*******************************************//
// 其它的宏定义
#ifdef DEBUG
#define                                         LOG(...) NSLog(__VA_ARGS__)
#define                                         LOG_METHOD NSLog(@"%s", __func__)
#define                                         LOGERROR(...) NSLog(@"%@传入数据有误",__VA_ARGS__)
#else
#define                                         LOG(...)
#define                                         LOG_METHOD
#define                                         LOGERROR(...) NSLog(@"%@传入数据有误",__VA_ARGS__)
#endif

//目的是 屏蔽 release 版本的 NSLog
#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...) {}
#endif

// DLog is almost a drop-in replacement for NSLog
// DLog();
// DLog(@"here");
// DLog(@"value: %d", x);
// Unfortunately this doesn't work DLog(aStringVariable); you have to do this instead DLog(@"%@", aStringVariable);

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);


//*********************************类型初始化定义*******************************************//
//判断字符串是否为空
#define IFISNIL(v)                                 (v = (v != nil) ? v : @"")
//判断NSNumber是否为空
#define IFISNILFORNUMBER(v)                        (v = (v != nil) ? v : [NSNumber numberWithInt:0])
//判断是否是字符串
#define IFISSTR(v)                                 (v = ([v isKindOfClass:[NSString class]]) ? v : [NSString stringWithFormat:@"%@",v])

//将字符串初始化为空串@""
#define  TextNilToEmpty(text)  \
do{\
if ([text isKindOfClass:[NSString class]]) {\
if(text == nil)\
{text = @"";}\
}\
}while (0)

//将字符串转为颜色值


//图片辅助宏定义
//保存图片 imageId:图片id，imageData：图片data流
#define SaveImgData(imageId, imageData) [kFileUtil saveImage:imageId data:imageData]
//保存图片 imageId:图片id，image：图片UIImage对象
#define SaveImgObj(imageId, image)  [kFileUtil saveImageId:imageId image:image]
//从图片id获取UIImage对象，imageId:图片id
#define UIImageFrom(imageId) [kFileUtil imageWithImageId:imageId]
//从图片id获取图片data流，imageId:图片id
#define ImageDataFrom(imageId) [kFileUtil dataWithImageId:imageId]
//删除图片，imageId:图片id
#define DeleteImage(imageId) [kFileUtil deleteImage:imageId]

//时间戳字符串，毫秒级
#define MSEC_Timestamp [NSString stringWithFormat:@"%lld",(long long)([[NSDate date] timeIntervalSince1970]*1000)]

#endif /* DeviceMacro_h */
