//
//  HttpEngine.m
//  InKeDemo
//
//  Created by lly on 16/7/8.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "HttpEngine.h"
#import "AFNetworking.h"

@interface HttpEngine()

@property (nonatomic, strong) AFHTTPSessionManager * manager;

@end


@implementation HttpEngine

+(HttpEngine *)shareHttpEngine{

    static HttpEngine *engine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        engine = [[HttpEngine alloc]init];
    });
    return engine;
}

// 取消请求数据的方法
- (void)cancelDataRequest
{
    [self.manager.operationQueue cancelAllOperations];
}
// 回调成功失败的方法

// 异步Post数据请求
- (void)AFJSONPostRequest:(NSString *)urlString
{
    NSString * str = [[NSString stringWithFormat:@"%@",urlString]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
    // 格式
    NSDictionary *dic = @{@"format":@"json"};
    NSLog(@"%@",dic);
    self.manager = [[AFHTTPSessionManager alloc] init];
    // 取消请求数据
    [self cancelDataRequest];
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    //成功方法
    [_manager POST:str parameters:dic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        self.successfulBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.failBlock(error);
    }];
}

// 同步Get数据请求
+ (void)AfJSONGetRequest:(NSString *)urlString successfulBlock:(SuccessfulBlock)successfulBlock failBlock:(FailBlock)failBlock;
{
//    NSString * str = [[NSString stringWithFormat:@"%@",urlString]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    [manager GET:urlString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        successfulBlock(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failBlock(error);
    }];

  
}



@end
