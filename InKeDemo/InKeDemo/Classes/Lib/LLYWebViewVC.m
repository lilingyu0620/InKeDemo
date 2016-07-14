//
//  LLYWebViewVC.m
//  InKeDemo
//
//  Created by lly on 16/7/9.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "LLYWebViewVC.h"

@interface LLYWebViewVC ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *mWebview;

@end

@implementation LLYWebViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initData];
    [self leftNaviagtionBar];
}


- (void)initData{

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]];
    [self.mWebview loadRequest:request];
    [self.mWebview reload];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftNaviagtionBar{
    
    //返回
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setFrame:CGRectMake(0, 0, 64, 44)];
    [searchBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [searchBtn setImage:[UIImage imageNamed:@"global_back"] forState:UIControlStateNormal];
    [searchBtn setImage:[UIImage imageNamed:@"global_back"] forState:UIControlStateHighlighted];
    [searchBtn setImage:[UIImage imageNamed:@"global_back"] forState:UIControlStateSelected];
    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 20)];
    [searchBtn addTarget:self action:@selector(clickedLeftBarButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
}


- (void)clickedLeftBarButton:(id)sender{

    [self.mNavCon popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
