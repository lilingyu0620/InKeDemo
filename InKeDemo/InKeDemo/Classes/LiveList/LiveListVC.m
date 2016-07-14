//
//  LiveListVC.m
//  InKeDemo
//
//  Created by lly on 16/7/6.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "LiveListVC.h"
#import "SwipeView.h"

#import "FollowVC.h"
#import "HotVC.h"
#import "LatestVC.h"

#import "YYKit.h"
#import "HttpEngine.h"

typedef NS_ENUM(NSUInteger, TitleBtnType) {
    FollowBtn = 0,
    HotBtn,
    NewBtn,
};

@interface LiveListVC ()<SwipeViewDataSource,SwipeViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIView *sliderView;
@property (weak, nonatomic) IBOutlet UIButton *followBtn;
@property (weak, nonatomic) IBOutlet UIButton *hotBtn;
@property (weak, nonatomic) IBOutlet UIButton *latestBtn;

@property (weak, nonatomic) IBOutlet SwipeView *swipeView;

@property (nonatomic, strong) NSArray *btnArrays;
@property (nonatomic, strong) NSArray *viewArrays;

@end

@implementation LiveListVC

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initUI];
    [self initDate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 初始化
- (void)initUI{

    self.navigationItem.titleView = self.titleView;
    [self leftNaviagtionBar];
    [self rightNavigationBar];
}

- (void)leftNaviagtionBar{

    //搜索
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setFrame:CGRectMake(0, 0, 64, 44)];
    [searchBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [searchBtn setImage:[UIImage imageNamed:@"global_search"] forState:UIControlStateNormal];
    [searchBtn setImage:[UIImage imageNamed:@"global_search"] forState:UIControlStateHighlighted];
    [searchBtn setImage:[UIImage imageNamed:@"global_search"] forState:UIControlStateSelected];
    [searchBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 20)];
    [searchBtn addTarget:self action:@selector(clickedLeftBarButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.leftBarButtonItem = leftItem;

    
}

- (void)rightNavigationBar{

    //消息
    UIButton *messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [messageBtn setFrame:CGRectMake(0, 0, 64, 44)];
    [messageBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [messageBtn setImage:[UIImage imageNamed:@"me_new_sixin_live"] forState:UIControlStateNormal];
    [messageBtn setImage:[UIImage imageNamed:@"me_new_sixin_live"] forState:UIControlStateHighlighted];
    [messageBtn setImage:[UIImage imageNamed:@"me_new_sixin_live"] forState:UIControlStateSelected];
    [messageBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, -20)];
    [messageBtn addTarget:self action:@selector(clickRightBarButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:messageBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

- (void)initDate{

    self.swipeView.delegate = self;
    self.swipeView.dataSource = self;
    self.swipeView.wrapEnabled = YES;
    
    FollowVC *followVC = [[FollowVC alloc]init];
//    bankVC.mNaviagtionCon = self.navigationController;
    
    HotVC *hotVC = [[HotVC alloc]init];
    hotVC.mNaviagtionCon = self.navigationController;
    
    LatestVC *latestVC = [[LatestVC alloc]init];
    self.viewArrays = @[followVC,hotVC,latestVC];
    self.btnArrays = @[_followBtn,_hotBtn,_latestBtn];
    self.swipeView.currentItemIndex = 1;
    [self.swipeView reloadData];
    
}

#pragma mark - Action
- (IBAction)titleBtnClicked:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    [self updateSliderViewFrame:btn.tag];
    
    switch (btn.tag) {
        case FollowBtn:
            self.swipeView.currentItemIndex = 0;
            break;
            
        case HotBtn:
            self.swipeView.currentItemIndex = 1;
            break;
            
        case NewBtn:
            self.swipeView.currentItemIndex = 2;
            break;
        default:
            break;
    }

}

#pragma mark - private method
- (void)updateSliderViewFrame:(NSInteger)index{
    
    UIButton *btn = self.btnArrays[index];
    [UIView  animateWithDuration:0.2 animations:^{
        self.sliderView.centerX = btn.centerX;
    }];
}

- (void)clickedLeftBarButton:(id)sender{

}

- (void)clickRightBarButton:(id)sender{


}


#pragma mark - SwipeViewDateDelegate
- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView{
    
    return _viewArrays.count;
}
- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view{
    
    return [_viewArrays[index] view];
}


#pragma mark - SwipeViewDelegate
- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return self.swipeView.bounds.size;
}


- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView{
    
    NSLog(@"======%ld=======",(long)swipeView.currentItemIndex);
    [self updateSliderViewFrame:swipeView.currentItemIndex];
    
}



@end
