//
//  ImageRollView.m
//  InKeDemo
//
//  Created by lly on 16/7/8.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "ImageRollView.h"
#import "RollImageModel.h"
@interface ImageRollView()<UIScrollViewDelegate>
{
    NSTimer *_myTimer;
}
@property (nonatomic,strong) UIScrollView *mScrollView;
 @property (nonatomic,strong) UIPageControl *mPageControl;

@end


@implementation ImageRollView

- (instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        self.mScrollView = [[UIScrollView alloc]initWithFrame:self.frame];
        self.mScrollView.delegate = self;
        self.mScrollView.pagingEnabled = YES;
        self.mScrollView.showsHorizontalScrollIndicator = NO;
        self.mScrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_mScrollView];

        
        self.mPageControl = [[UIPageControl alloc]init];
        [_mPageControl setBackgroundColor:[UIColor clearColor]];
        [_mPageControl setCurrentPageIndicatorTintColor:[UIColor colorWithHexString:@"0x8FE3D4"]];
        [_mPageControl setPageIndicatorTintColor:[UIColor blackColor]];
        [self addSubview:_mPageControl];
        
        [self setBackgroundColor:[UIColor blackColor]];
    }
    return self;
}


- (void)initUI{

    self.mScrollView.contentSize = CGSizeMake((self.imageArray.count+2)*self.frame.size.width, self.frame.size.height);
    
    //注意此方法可以根据页数返回UIPageControl合适的大小
    CGSize size= [_mPageControl sizeForNumberOfPages:_imageArray.count];
    [_mPageControl setFrame:CGRectMake(0, 0, size.width, 37)];
    [_mPageControl setCenter:CGPointMake(self.centerX, self.centerY+50)];
    //设置总页数
    _mPageControl.numberOfPages=_imageArray.count;
    
    if ([_myTimer isValid]) {
        [_myTimer invalidate];
    }
     _myTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(runTimerTurnPage:) userInfo:nil repeats:YES];

}


#pragma mark - 懒加载

- (NSMutableArray *)imageArray{

    if (!_imageArray) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}

#pragma mark - 专题轮循

- (void)runTimerTurnPage:(id)sender{

    NSInteger page = _mPageControl.currentPage;
    page ++;
    [_mScrollView setContentOffset:CGPointMake( (page + 1)* getViewWidth(_mScrollView), 0) animated:YES];
    if (page == _mPageControl.numberOfPages) {
        [self performSelector:@selector(gotoFirstPageBackground) withObject:self afterDelay:0.5f];
        page = 0;
    }
    _mPageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //整个页面滑动，手动滑动轮播图的时候都要停掉timer
    if ([_myTimer isValid]) {
        [_myTimer invalidate];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _mScrollView)
    {
        CGFloat xOffset = _mScrollView.contentOffset.x;
        int currentPage = floor( (xOffset - getViewWidth(_mScrollView)/ _imageArray.count) / getViewWidth(_mScrollView) );
        if (currentPage == -1) {
            _mScrollView.contentOffset = CGPointMake( _mPageControl.numberOfPages * getViewWidth(_mScrollView), 0);
            _mPageControl.currentPage = _mPageControl.numberOfPages - 1;
            
        }else if (currentPage == self.imageArray.count ) {
            _mScrollView.contentOffset = CGPointMake( getViewWidth(_mScrollView) , 0);
            _mPageControl.currentPage = 0;
        }
        else {
            _mPageControl.currentPage = currentPage;
        }
    }
}

- (void)gotoFirstPageBackground{

    [_mScrollView setContentOffset:CGPointMake(getViewWidth(_mScrollView), 0) animated:NO];

}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //整个页面滑动，手动滑动轮播图的时候都要停掉timer
    if ([_myTimer isValid] == NO && self.imageArray.count > 1) {
        _myTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(runTimerTurnPage:) userInfo:nil repeats:YES];
    }
    
}

- (void)initButtons{
    
    {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        RollImageModel *model = _imageArray[self.imageArray.count-1];
        [imageView setImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.meelive.cn/%@",model.image]]];
        [self.mScrollView addSubview:imageView];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 0;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setFrame:CGRectMake(0, 0, self.width, self.height)];
        [self.mScrollView addSubview:btn];
    }
    
    for (int i = 0; i < _imageArray.count; ++i) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((i+1)*self.width, 0, self.width, self.height)];
        RollImageModel *model = _imageArray[i];
        [imageView setImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.meelive.cn/%@",model.image]]];
        DLog(@"====%f %f %f %f====",imageView.frame.origin.x,imageView.frame.origin.y,imageView.width,imageView.height);
        [self.mScrollView addSubview:imageView];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i+1;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setFrame:CGRectMake((i+1)*self.width, 0, self.width, self.height)];
        [self.mScrollView addSubview:btn];
    }
    
    {
        if (_imageArray.count == 0) {
            return;
        }
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.imageArray.count+1)*self.width, 0, self.width, self.height)];
        RollImageModel *model = _imageArray[0];
        [imageView setImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.meelive.cn/%@",model.image]]];
        [self.mScrollView addSubview:imageView];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = self.imageArray.count+1;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setFrame:CGRectMake((self.imageArray.count+1)*self.width, 0, self.width, self.height)];
        [self.mScrollView addSubview:btn];
        
    }
    _mPageControl.currentPage = 0;
    _mScrollView.contentOffset = CGPointMake( getViewWidth(_mScrollView) , 0);
    
}

- (void)btnClicked:(id)sender{
    
    int count = (int)self.imageArray.count;
    UIButton *btn = (UIButton *)sender;
    int index;
    if (btn.tag == 0) {
        index = count-1;
    }
    else if (btn.tag == count + 1){
        index = 0;
    }
    else{
        index = (int)btn.tag-1;
    }
    
    RollImageModel *model = _imageArray[index];
    
    if ([self.delegate respondsToSelector:@selector(btnClickedWithModel:)]) {
        [self.delegate btnClickedWithModel:model];
    }
}


- (void)reloaData:(NSMutableArray *)array{

    [self.imageArray addObjectsFromArray:array];
    [self initUI];
    [self initButtons];
}


@end
