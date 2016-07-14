//
//  HttpEngine.h
//  InKeDemo
//
//  Created by lly on 16/7/8.
//  Copyright © 2016年 lly. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessfulBlock)(id object);
typedef void (^FailBlock)(NSError *error);

@interface HttpEngine : NSObject

@property (nonatomic, copy)SuccessfulBlock successfulBlock;// 成功回调属性
@property (nonatomic, copy)FailBlock failBlock;// 失败回调属性
// 成功失败回调方法
//- (id)initWithSuccessfulBlock:(SuccessfulBlock)successfulBlock
//failBlock:(FailBlock)failBlock;
+ (HttpEngine *)shareHttpEngine;
- (void)AFJSONPostRequest:(NSString *)urlString ;
+ (void)AfJSONGetRequest:(NSString *)urlString successfulBlock:(SuccessfulBlock)successfulBlock failBlock:(FailBlock)failBlock;
// 请求队列
@property (nonatomic, strong)NSOperationQueue * operationQueue;
// 取消请求数据
- (void)cancelDataRequest;


@end
