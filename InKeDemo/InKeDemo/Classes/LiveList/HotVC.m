//
//  HotVC.m
//  InKeDemo
//
//  Created by lly on 16/7/8.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "HotVC.h"
#import "HttpEngine.h"
#import "RollImageModel.h"
#import "ImageRollView.h"
#import "ODRefreshControl.h"
#import "LLYWebViewVC.h"
#import "RoomListModel.h"
#import "RoomListCell.h"

#import "LLYKxMovieVC.h"

//轮播图
#define RollImageUrl @"http://service.inke.com/api/live/ticker?imsi=&uid=138356378&proto=6&idfa=5C1CE094-7391-4EA1-92A5-3EC643A86725&lc=0000000000000028&cc=TG0001&imei=&sid=20kD2WfjoxdjxkA4RlEmM9zVHMAlkJi0kTPr7aCqXnhAunnVYp5&cv=IK3.2.01_Iphone&devi=ed7173d951db678e862e4e0b87d250c7ca5703d9&conn=Wifi&ua=iPhone%205s&idfv=6F073146-7734-456F-A762-AAE797EE42C1&osversion=ios_9.300000"


#define RoomListUrl @"http://service.inke.com/api/live/simpleall?imsi=&uid=138356378&proto=6&idfa=5C1CE094-7391-4EA1-92A5-3EC643A86725&lc=0000000000000028&cc=TG0001&imei=&sid=20kD2WfjoxdjxkA4RlEmM9zVHMAlkJi0kTPr7aCqXnhAunnVYp5&cv=IK3.2.01_Iphone&devi=ed7173d951db678e862e4e0b87d250c7ca5703d9&conn=Wifi&ua=iPhone%205s&idfv=6F073146-7734-456F-A762-AAE797EE42C1&osversion=ios_9.300000&"


#define TopFiveRoomUrl @"http://service.inke.com/api/live/gettop?imsi=&uid=138356378&proto=6&idfa=5C1CE094-7391-4EA1-92A5-3EC643A86725&lc=0000000000000028&cc=TG0001&imei=&sid=20kD2WfjoxdjxkA4RlEmM9zVHMAlkJi0kTPr7aCqXnhAunnVYp5&cv=IK3.2.01_Iphone&devi=ed7173d951db678e862e4e0b87d250c7ca5703d9&conn=Wifi&ua=iPhone%205s&idfv=6F073146-7734-456F-A762-AAE797EE42C1&osversion=ios_9.300000&count=5&multiaddr=1"

#define RoomInfoUrl(idStr) [NSString stringWithFormat:@"http://service.inke.com/api/live/infos?imsi=&uid=138356378&proto=6&idfa=5C1CE094-7391-4EA1-92A5-3EC643A86725&lc=0000000000000028&cc=TG0001&imei=&sid=20kD2WfjoxdjxkA4RlEmM9zVHMAlkJi0kTPr7aCqXnhAunnVYp5&cv=IK3.2.01_Iphone&devi=ed7173d951db678e862e4e0b87d250c7ca5703d9&conn=Wifi&ua=iPhone%%205s&idfv=6F073146-7734-456F-A762-AAE797EE42C1&osversion=ios_9.300000&id=%.0f%%2C1467707172588804%%2C1467706849560234%%2C1467706745820929%%2C1467706732980641&multiaddr=1",idStr]

@interface HotVC ()<UITableViewDelegate,UITableViewDataSource,ImageRollViewDelegate>{

    NSTimer *_myTimer;
    
}

@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (nonatomic,strong) NSMutableArray *rollImageModelArray;
@property (nonatomic,strong) NSMutableArray *roomListArray;


 @property (nonatomic,strong) ImageRollView *rollView;
@end

@implementation HotVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [self initUI];
    [self initData];
    // 添加下拉刷新
    [self addRefresh];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{

    if ([_myTimer isValid]) {
        [_myTimer invalidate];
    }
}

- (void)initUI{

    [self.mTableView registerNib:[UINib nibWithNibName:@"RoomListCell" bundle:nil] forCellReuseIdentifier:@"RoomListCell"];
    self.mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)initData{

    __weak __typeof(self)weakSelf = self;
    [HttpEngine AfJSONGetRequest:RollImageUrl successfulBlock:^(id object) {
        DLog(@"%@",object);
        NSArray *array = object[@"ticker"];
        if ([array isKindOfClass:[NSArray class]]) {
            @autoreleasepool {
                for (NSDictionary *dic in array) {
                    RollImageModel *model = [RollImageModel modelWithDictionary:dic];
                    [weakSelf.rollImageModelArray addObject:model];
                }
            }
            self.rollView = [[ImageRollView alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 125)];
            self.rollView.delegate = self;
            [self.rollView reloaData:_rollImageModelArray];
            self.mTableView.tableHeaderView = self.rollView;
        }
        
    } failBlock:^(NSError *error) {
        DLog(@"%@",error);
    }];
    
    
    [HttpEngine AfJSONGetRequest:RoomListUrl successfulBlock:^(id object) {
        //
//        DLog(@"%@",object);
        NSArray *array = object[@"lives"];
        if ([array isKindOfClass:[NSArray class]]) {
            @autoreleasepool {
                for (NSDictionary *dic in array) {
                    RoomListModel *model = [RoomListModel modelWithDictionary:dic];
                    
                    CreatorModel *cModel = [[CreatorModel alloc]init];
                    cModel.id = [dic[@"creator"][@"id"] doubleValue];
                    cModel.level = [dic[@"creator"][@"level"] intValue];
                    cModel.nick = [NSString stringWithFormat:@"%@",dic[@"creator"][@"nick"]];
                    cModel.portrait = [NSString stringWithFormat:@"%@",dic[@"creator"][@"portrait"]];
                    model.creator = cModel;
                   
                    [weakSelf.roomListArray addObject:model];
                }
            }
            [weakSelf.mTableView reloadData];
            
            if ([_myTimer isValid]) {
                [_myTimer invalidate];
            }
//            _myTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(loadData) userInfo:nil repeats:YES];
        }
        
    } failBlock:^(NSError *error) {
        //
        DLog(@"%@",error);
    }];
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];

}

#pragma mark - 刷新
- (void)loadData{

    __weak __typeof(self)weakSelf = self;
    __block NSUInteger index = -1;
    [HttpEngine AfJSONGetRequest:TopFiveRoomUrl successfulBlock:^(id object) {
        DLog(@"%@",object);
        NSArray *array = object[@"lives"];
        if ([array isKindOfClass:[NSArray class]]) {
            @autoreleasepool {
                for (int i = array.count-1; i > -1; --i) {
                    
                    NSDictionary *dic = array[i];
                    RoomListModel *model = [RoomListModel modelWithDictionary:dic];
                    
                    CreatorModel *cModel = [CreatorModel modelWithDictionary:dic[@"creator"]];
//                    cModel.id = [dic[@"creator"][@"id"] doubleValue];
//                    cModel.level = [dic[@"creator"][@"level"] intValue];
//                    cModel.nick = [NSString stringWithFormat:@"%@",dic[@"creator"][@"nick"]];
//                    cModel.portrait = [NSString stringWithFormat:@"%@",dic[@"creator"][@"portrait"]];
                    model.creator = cModel;
                    
                    [weakSelf.roomListArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        RoomListModel *m = obj;
                        if (model.id == m.id) {
                            *stop = YES;
                            index = idx;
                        }
                    }];
                    if (index != -1) {
                        [weakSelf.roomListArray removeObjectAtIndex:index];
                    }
                    [weakSelf.roomListArray insertObject:model atIndex:0];
                }
            }
            [self.mTableView reloadData];
        }
        
    } failBlock:^(NSError *error) {
        DLog(@"%@",error);
    }];
}


#pragma mark ---- <添加下拉刷新>
- (void)addRefresh {
    
    ODRefreshControl *refreshController = [[ODRefreshControl alloc] initInScrollView:self.mTableView];
    refreshController.tintColor = [UIColor colorWithHexString:@"0x8FE3D4"];
    [refreshController addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshController {
    
    double delayInSecinds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSecinds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [refreshController endRefreshing];
        [self loadData];
    });
}



#pragma mark - 懒加载
- (NSMutableArray *)rollImageModelArray{

    if (!_rollImageModelArray) {
        _rollImageModelArray = [NSMutableArray array];
    }
    return _rollImageModelArray;
}

- (NSMutableArray *)roomListArray{

    if (!_roomListArray) {
        _roomListArray = [NSMutableArray array];
    }
    return _roomListArray;
}

#pragma mark - UITableView Delegate/DateSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.roomListArray.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    RoomListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RoomListCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.roomListImageViewHeight.constant = kScreenWidth;
    RoomListModel *model = self.roomListArray[indexPath.row];
    [cell setCellWithModel:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    RoomListModel *model = self.roomListArray[indexPath.row];
    if ([model.name isEqualToString:@""] || model.name == nil) {
        return (44+6+kScreenWidth);
    }
    else{
        return (44+27+6+kScreenWidth);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    RoomListModel *m = self.roomListArray[indexPath.row];
    __weak __typeof(self)weakSelf = self;
    [HttpEngine AfJSONGetRequest:RoomInfoUrl(m.id) successfulBlock:^(id object) {
        DLog(@"%@",object);
        NSArray *array = object[@"lives"];
        if ([array isKindOfClass:[NSArray class]]) {
            NSDictionary *dic = array[0];
            RoomListModel *model = [RoomListModel modelWithDictionary:dic];
            CreatorModel *cModel = [CreatorModel modelWithDictionary:dic[@"creator"]];
            model.creator = cModel;
            
            NSString *path = model.stream_addr;
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            // increase buffering for .wmv, it solves problem with delaying audio frames
            if ([path.pathExtension isEqualToString:@"wmv"])
                parameters[KxMovieParameterMinBufferedDuration] = @(5.0);
            // disable deinterlacing for iPhone, because it's complex operation can cause stuttering
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                parameters[KxMovieParameterDisableDeinterlacing] = @(YES);

            LLYKxMovieVC *playVC = [LLYKxMovieVC movieViewControllerWithContentPath:path parameters:parameters];
            playVC.roomModel = model;
            playVC.mNav = self.mNaviagtionCon;
            [weakSelf.mNaviagtionCon pushViewController:playVC animated:NO];

        }
        
    } failBlock:^(NSError *error) {
        DLog(@"%@",error);
    }];

}

#pragma mark - ImageRollView Delegate

- (void)btnClickedWithModel:(RollImageModel *)model{

    LLYWebViewVC *webVC = [[LLYWebViewVC alloc]initWithNibName:@"LLYWebViewVC" bundle:nil];
    webVC.mNavCon = self.mNaviagtionCon;
    webVC.urlStr = model.link;
    [self.mNaviagtionCon pushViewController:webVC animated:YES];
    
}

@end
