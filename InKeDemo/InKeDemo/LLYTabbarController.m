//
//  LLYTabbarController.m
//  InKeDemo
//
//  Created by lly on 16/7/7.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "LLYTabbarController.h"
#import "LiveListVC.h"
#import "UserInfoVC.h"
#import "LivingVC.h"
#import "MainNavigationController.h"

@interface LLYTabbarController ()

@end

@implementation LLYTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // 添加所有的子控制器
    [self setupAllViewController];
    
    // 设置tabBar上按钮的内容
    [self setupAllTabBarButton];
    
    // 添加视频采集按钮
    [self addLivingButton];
    
    // 设置顶部tabBar背景图片
    [self setupTabBarBackgroundImage];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ---- <添加视频采集按钮>
- (void)addLivingButton {
    
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [cameraBtn setImage:[UIImage imageNamed:@"tab_room"] forState:UIControlStateNormal];
    [cameraBtn setImage:[UIImage imageNamed:@"tab_room_p"] forState:UIControlStateHighlighted];
    
    // 自适应,自动根据按钮图片和文字计算按钮尺寸
    [cameraBtn sizeToFit];
    
    cameraBtn.center = CGPointMake(self.tabBar.frame.size.width * 0.5+1, self.tabBar.frame.size.height * 0.5+7);
    [cameraBtn addTarget:self action:@selector(clickLivingBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tabBar addSubview:cameraBtn];
}


#pragma mark ---- <点击了CameraBtn>
- (void)clickLivingBtn {
    
//    LivingVC *livingVc = [[LivingVC alloc] init];
//    [self presentViewController:livingVc animated:YES completion:nil];
    
}


#pragma mark ---- <设置tabBar背景图片>
- (void)setupTabBarBackgroundImage {
    
    UIImage *image = [UIImage imageNamed:@"tab_bg"];
    
    CGFloat top = 0; // 顶端盖高度
    CGFloat bottom = 0 ; // 底端盖高度
    CGFloat left = 0; // 左端盖宽度
    CGFloat right = 0; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    UIImage *TabBgImage = [image resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    self.tabBar.backgroundImage = TabBgImage;
    
    [[UITabBar appearance] setShadowImage:[UIImage new]];
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc]init]];
}

//自定义TabBar高度
- (void)viewWillLayoutSubviews {
    
    CGRect tabFrame = self.tabBar.frame;
    tabFrame.size.height = 60;
    tabFrame.origin.y = self.view.frame.size.height - 60;
    self.tabBar.frame = tabFrame;
    
}

#pragma mark ---- <设置tabBar上按钮的内容>
- (void)setupAllTabBarButton {
    
    //设置TabBar按钮的内容
    LiveListVC *liveVc = self.childViewControllers[0];
    liveVc.tabBarItem.image = [[UIImage imageNamed:@"tab_live"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    liveVc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_live_p"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    LivingVC *livingVc = self.childViewControllers[1];
    livingVc.tabBarItem.enabled = NO;
    
    UserInfoVC *mineVc = self.childViewControllers[2];
    mineVc.tabBarItem.image = [[UIImage imageNamed:@"tab_me"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mineVc.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_me_p"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 调整TabBarItem位置
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 0, -10, 0);
    
    liveVc.tabBarItem.imageInsets = insets;
    mineVc.tabBarItem.imageInsets = insets;
    
    //隐藏阴影线
    [[UITabBar appearance] setShadowImage:[UIImage new]];
    [[UITabBar appearance] setBackgroundImage:[[UIImage alloc]init]];
}

#pragma mark ---- <添加所有的子控制>
- (void)setupAllViewController {
    
    //Live
    LiveListVC *liveVc = [[LiveListVC alloc] init];
    MainNavigationController *liveNav = [[MainNavigationController alloc] initWithRootViewController:liveVc];
    
    [self addChildViewController:liveNav];
    
    //Camera
    LivingVC *livingVc = [[LivingVC alloc] init];
    MainNavigationController *livingNav= [[MainNavigationController alloc] initWithRootViewController:livingVc];
    
    [self addChildViewController:livingNav];
    
    //Main
    UserInfoVC *mineVc = [[UserInfoVC alloc] init];
    MainNavigationController *mineNav = [[MainNavigationController alloc] initWithRootViewController:mineVc];
    
    [self addChildViewController:mineNav];
    
    
    
}

@end
