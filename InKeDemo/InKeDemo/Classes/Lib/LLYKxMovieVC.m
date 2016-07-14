//
//  LLYKxMovieVC.m
//  InKeDemo
//
//  Created by lly on 16/7/11.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "LLYKxMovieVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "KxMovieDecoder.h"
#import "KxAudioManager.h"
#import "KxMovieGLView.h"
#import "RoomListModel.h"
#import "LoveView.h"
#import "HttpEngine.h"
#import "UserModel.h"
#import "UserCell.h"
#import "LLYUserFlowLayout.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "MessageModel.h"
#import "MessageCell.h"
#import <BarrageRenderer.h>
#import "NSSafeObject.h"



#define UserUrl(idStr) [NSString stringWithFormat:@"http://218.11.0.112/api/live/users?imsi=&uid=138356378&proto=7&idfa=5C1CE094-7391-4EA1-92A5-3EC643A86725&lc=0000000000000030&cc=TG0001&imei=&sid=20kD2WfjoxdjxkA4RlEmM9zVHMAlkJi0kTPr7aCqXnhAunnVYp5&cv=IK3.2.60_Iphone&devi=ed7173d951db678e862e4e0b87d250c7ca5703d9&conn=Wifi&ua=iPhone%%205s&idfv=6F073146-7734-456F-A762-AAE797EE42C1&osversion=ios_9.300000&count=20&id=%.0f&start=0",idStr]



typedef NS_ENUM(NSUInteger, BottonBtnType) {
    TalkBtn = 0,
    MessageBtn,
    ShareBtn,
    GiftBtn,
    CloseBtn,
};


NSString * const KxMovieParameterMinBufferedDuration = @"KxMovieParameterMinBufferedDuration";
NSString * const KxMovieParameterMaxBufferedDuration = @"KxMovieParameterMaxBufferedDuration";
NSString * const KxMovieParameterDisableDeinterlacing = @"KxMovieParameterDisableDeinterlacing";


////////////////////////////////////////////////////////////////////////////////

enum {
    
    KxMovieInfoSectionGeneral,
    KxMovieInfoSectionVideo,
    KxMovieInfoSectionAudio,
    KxMovieInfoSectionSubtitles,
    KxMovieInfoSectionMetadata,
    KxMovieInfoSectionCount,
};

enum {
    
    KxMovieInfoGeneralFormat,
    KxMovieInfoGeneralBitrate,
    KxMovieInfoGeneralCount,
};

////////////////////////////////////////////////////////////////////////////////

static NSMutableDictionary * gHistory;

#define LOCAL_MIN_BUFFERED_DURATION   0.2
#define LOCAL_MAX_BUFFERED_DURATION   0.4
#define NETWORK_MIN_BUFFERED_DURATION 2.0
#define NETWORK_MAX_BUFFERED_DURATION 4.0

@interface LLYKxMovieVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource>
{
    KxMovieDecoder      *_decoder;
    dispatch_queue_t    _dispatchQueue;
    NSMutableArray      *_videoFrames;
    NSMutableArray      *_audioFrames;
    NSMutableArray      *_subtitles;
    NSData              *_currentAudioFrame;
    NSUInteger          _currentAudioFramePos;
    CGFloat             _moviePosition;
    BOOL                _disableUpdateHUD;
    NSTimeInterval      _tickCorrectionTime;
    NSTimeInterval      _tickCorrectionPosition;
    NSUInteger          _tickCounter;
    BOOL                _fitMode;
    BOOL                _infoMode;
    BOOL                _restoreIdleTimer;
    BOOL                _interrupted;
    
    KxMovieGLView       *_glView;
    UIImageView         *_imageView;


    UITableView         *_tableView;
    UIActivityIndicatorView *_activityIndicatorView;
    
#ifdef DEBUG
    UILabel             *_messageLabel;
    NSTimeInterval      _debugStartTime;
    NSUInteger          _debugAudioStatus;
    NSDate              *_debugAudioStatusTS;
#endif
    
    CGFloat             _bufferedDuration;
    CGFloat             _minBufferedDuration;
    CGFloat             _maxBufferedDuration;
    BOOL                _buffered;
    
    BOOL                _savedIdleTimer;
    
    NSDictionary        *_parameters;
    
    NSTimer *_myTimer,*_myMessageTimer,*_myDanMuTimer;
    BarrageRenderer *_renderer;
}

@property (weak, nonatomic) IBOutlet UIView *bottomBtnView;
@property (strong, nonatomic) IBOutlet UIView *messageView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *headerImageUserView;

@property (strong, nonatomic) IBOutlet UIImageView *headerImageView;
@property (strong, nonatomic) IBOutlet UILabel *userLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *userCollectionView;

@property (strong, nonatomic) IBOutlet UILabel *inkeIdLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;


@property (nonatomic,strong) UIImageView *dimIamge;

@property (nonatomic,strong) NSMutableArray *collectionViewArray;

@property (nonatomic,strong) NSMutableArray *tableViewArray;

@property (strong, nonatomic) IBOutlet UIView *surfaceView;
@property (strong, nonatomic) IBOutlet UITableView *messageTableView;

@property (strong, nonatomic) IBOutlet UIView *danMuView;
@property (nonatomic,strong) NSArray *danMuTextArray;

@property (strong, nonatomic) IBOutlet UIView *userInfoView;
@property (strong, nonatomic) IBOutlet UIView *userInfoDetailView;


@property (readwrite) BOOL playing;
@property (readwrite) BOOL decoding;
@property (nonatomic,assign) BOOL surfaceViewIsShow;
@property (readwrite, strong) KxArtworkFrame *artworkFrame;
@property (nonatomic,strong) LLYUserFlowLayout *userLayout;

@end

@implementation LLYKxMovieVC


#pragma mark - livecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicatorView.center = self.view.center;
    _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    //    [self.view addSubview:_activityIndicatorView];
    
    [self initUI];
    [self initData];
    [self initTableViewArray];
    


}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    if (self.playing) {
        
        [self pause];
        [self freeBufferedFrames];
        
        if (_maxBufferedDuration > 0) {
            
            _minBufferedDuration = _maxBufferedDuration = 0;
            [self play];
            
            NSLog(@"didReceiveMemoryWarning, disable buffering and continue playing");
            
        } else {
            
            // force ffmpeg to free allocated memory
            [_decoder closeFile];
            [_decoder openFile:nil error:nil];
            
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failure", nil)
                                        message:NSLocalizedString(@"Out of memory", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Close", nil)
                              otherButtonTitles:nil] show];
        }
        
    } else {
        
        [self freeBufferedFrames];
        [_decoder closeFile];
        [_decoder openFile:nil error:nil];
    }
    
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.mNav.navigationBarHidden = YES;
    self.mNav.interactivePopGestureRecognizer.enabled = NO;
}


- (void) viewDidAppear:(BOOL)animated
{
    // NSLog(@"viewDidAppear");
    
    [super viewDidAppear:animated];
    
    _savedIdleTimer = [[UIApplication sharedApplication] isIdleTimerDisabled];
    
    if (_decoder) {
        [self restorePlay];
        
    } else {
        [_activityIndicatorView startAnimating];
        [self loadingView];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];
    
    _myTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showLove) userInfo:nil repeats:YES];
    
    _myMessageTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(addMessage) userInfo:nil repeats:YES];
    
    NSSafeObject * safeObj = [[NSSafeObject alloc]initWithObject:self withSelector:@selector(addDanMu)];
    _myDanMuTimer = [NSTimer timerWithTimeInterval:1 target:safeObj selector:@selector(excute) userInfo:nil repeats:YES];
    NSRunLoop *currentRL = [NSRunLoop currentRunLoop];
    [currentRL addTimer:_myDanMuTimer forMode:NSRunLoopCommonModes];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
    
    [_activityIndicatorView stopAnimating];
    
    if (_decoder) {
        
        [self pause];
        
        if (_moviePosition == 0 || _decoder.isEOF)
            [gHistory removeObjectForKey:_decoder.path];
        else if (!_decoder.isNetwork)
            [gHistory setValue:[NSNumber numberWithFloat:_moviePosition]
                        forKey:_decoder.path];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:_savedIdleTimer];
    
    [_activityIndicatorView stopAnimating];
    _buffered = NO;
    _interrupted = YES;
    
    if ([_myTimer isValid]) {
        [_myTimer invalidate];
    }
    
    if ([_myMessageTimer isValid]) {
        [_myMessageTimer invalidate];
    }
    
    if ([_myDanMuTimer isValid]) {
        [_myDanMuTimer invalidate];
    }
    
    [_renderer stop];
    
    NSLog(@"viewWillDisappear %@", self);
}

- (void) applicationWillResignActive: (NSNotification *)notification
{
    [self pause];
    
    NSLog(@"applicationWillResignActive");
}


- (void) dealloc
{
    [self pause];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_dispatchQueue) {
        _dispatchQueue = NULL;
    }
    
    NSLog(@"%@ dealloc", self);
}

#pragma mark - 初始化
+ (void)initialize
{
    if (!gHistory)
        gHistory = [NSMutableDictionary dictionary];
}

+ (id) movieViewControllerWithContentPath: (NSString *) path
                               parameters: (NSDictionary *) parameters
{
    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
    [audioManager activateAudioSession];
    return [[LLYKxMovieVC alloc] initWithContentPath: path parameters: parameters];
}


- (NSMutableArray *)collectionViewArray{

    if (!_collectionViewArray) {
        _collectionViewArray = [NSMutableArray array];
    }
    return _collectionViewArray;
}


- (NSMutableArray *)tableViewArray{

    if (!_tableViewArray) {
        _tableViewArray = [NSMutableArray array];
    }
    return _tableViewArray;
}

- (NSArray *)danMuTextArray
{
    if (!_danMuTextArray) {
        _danMuTextArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"danmu.plist" ofType:nil]];
    }
    return _danMuTextArray;
}


- (id) initWithContentPath: (NSString *) path
                parameters: (NSDictionary *) parameters
{
    NSAssert(path.length > 0, @"empty path");
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        _moviePosition = 0;
        
        _parameters = parameters;
        
        __weak LLYKxMovieVC *weakSelf = self;
        
        KxMovieDecoder *decoder = [[KxMovieDecoder alloc] init];

        decoder.interruptCallback = ^BOOL(){
            
            __strong LLYKxMovieVC *strongSelf = weakSelf;
            return strongSelf ? [strongSelf interruptDecoder] : YES;
        };
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSError *error = nil;
            [decoder openFile:path error:&error];
            
            __strong LLYKxMovieVC *strongSelf = weakSelf;
            if (strongSelf) {
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    [strongSelf setMovieDecoder:decoder withError:error];
                });
            }
        });
    }
    return self;
}

- (void)initUI{

    self.userLayout = [[LLYUserFlowLayout alloc]init];
    [self.userCollectionView registerNib:[UINib nibWithNibName:@"UserCell" bundle:nil] forCellWithReuseIdentifier:@"UserCell"];
    [self.userCollectionView setCollectionViewLayout:_userLayout];
    self.userCollectionView.showsHorizontalScrollIndicator = NO;
    
    
    [self.messageTableView registerNib:[UINib nibWithNibName:@"MessageCell" bundle:nil] forCellReuseIdentifier:@"MessageCell"];
    self.messageTableView.showsVerticalScrollIndicator = NO;
    self.messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    [self.surfaceView setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.view addSubview:self.surfaceView];
    self.surfaceViewIsShow = YES;
    
    [self setHeaderImageView];
    
    self.headerImageUserView.layer.cornerRadius = 22;
    self.headerImageUserView.layer.masksToBounds = YES;
    self.headerImageUserView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.1];
    
    self.userLabel.text = [@(self.roomModel.online_users) stringValue];
    self.inkeIdLabel.text = [@(self.roomModel.creator.id) stringValue];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY.MM.dd"];
    NSString *time = [dateFormatter stringFromDate:date];
    self.timeLabel.text = time;
    
    [self addDanMuView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [self.view addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    [self.userInfoView addGestureRecognizer:tap];
    [self.userInfoView setFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight)];
}


- (void)initData{
    if (self.roomModel) {
        __weak __typeof(self)weakSelf = self;
        [HttpEngine AfJSONGetRequest:UserUrl(self.roomModel.id) successfulBlock:^(id object) {
            NSArray *array = object[@"users"];
            if ([array isKindOfClass:[NSArray class]]) {
                @autoreleasepool {
                    for (NSDictionary *dic in array) {
                        UserModel *model = [UserModel modelWithDictionary:dic];
                        [weakSelf.collectionViewArray addObject:model];
                    }
                }
                [weakSelf.userCollectionView reloadData];
            }
            
        } failBlock:^(NSError *error) {
            
        }];
    }
}

- (void)initTableViewArray{

    for (int i = 0; i < 20; ++i) {
        MessageModel *model = [[MessageModel alloc]init];
        model.userNameStr = @"lllllllly";
        model.messageStr = @"Since iOS8, -tableView:heightForRowAtIndexPath: will be called more times than we expect, we can feel these extra calculations when scrolling. So we provide another API with cache by index path:";
        [self.tableViewArray addObject:model];
    }

    [self.messageTableView reloadData];
}


- (void)addDanMuView{
    _renderer = [[BarrageRenderer alloc] init];
    _renderer.canvasMargin = UIEdgeInsetsMake(kScreenWidth * 0.3, 10, 10, 10);
    [self.danMuView addSubview:_renderer.view];
    
    [_renderer start];
}


#pragma mark - UIGestureRecognizer

- (void)panGesture:(UIGestureRecognizer *)gesture{
    
    __weak typeof(self)weakSelf = self;
    
    static CGPoint beginPoint,endPoint;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            beginPoint = [gesture locationInView:self.view];
            NSLog(@"begin ==x = %f y = %f==",beginPoint.x,beginPoint.y);
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            endPoint = [gesture locationInView:self.view];
            NSLog(@"end ==x = %f y = %f==",endPoint.x,endPoint.y);
            if (self.surfaceViewIsShow) {
                if (endPoint.x > beginPoint.x) {
                    float offsetX = endPoint.x - beginPoint.x;
                    [self moveSurfaceView:offsetX];
                }
            }
            else{
            
                if (beginPoint.x > endPoint.x) {
                    float offsetX = beginPoint.x - endPoint.x;
                    [self moveSurfaceView:(kScreenWidth-offsetX)];
                }
            }
            
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"end ==x = %f y = %f==",endPoint.x,endPoint.y);
            endPoint = [gesture locationInView:self.view];
            if (self.surfaceViewIsShow) {
                float offsetX = endPoint.x - beginPoint.x;
                if (offsetX >= 60) {
                    [UIView animateWithDuration:0.3f animations:^{
                        [weakSelf moveSurfaceView:kScreenWidth];
                    }];
                    self.surfaceViewIsShow = NO;
                }
                else{
                    [UIView animateWithDuration:0.3f animations:^{
                        [weakSelf moveSurfaceView:0];
                    }];
                }
            }
            else{
                float offsetX = beginPoint.x - endPoint.x;
                if (offsetX >= 60) {
                    [UIView animateWithDuration:0.3f animations:^{
                        [weakSelf moveSurfaceView:0];
                    }];
                    self.surfaceViewIsShow = YES;
                }
                else{
                    [UIView animateWithDuration:0.3f animations:^{
                        [weakSelf moveSurfaceView:kScreenWidth];
                    }];
                }
            }
            
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            if (self.surfaceViewIsShow) {
                [self moveSurfaceView:0];
            }
            else{
                [self moveSurfaceView:kScreenWidth];
            }
        }
            break;
            
        default:
            break;
    }
    
}

- (void)tapGesture:(UIGestureRecognizer *)gesture{
    
    CGPoint point = [gesture locationInView:self.userInfoView];
    if ([self.userInfoDetailView pointInside:point withEvent:UIEventTypeTouches]) {
        return;
    }
    [UIView animateWithDuration:0.3f animations:^{
        [self.userInfoView setOrigin:CGPointMake(0, kScreenHeight)];

    } completion:^(BOOL finished) {
        [self.userInfoView removeFromSuperview];
    }];
}



#pragma mark - public

-(void) play
{
    if (self.playing)
        return;
    
    if (!_decoder.validVideo &&
        !_decoder.validAudio) {
        
        return;
    }
    
    if (_interrupted)
        return;
    
    self.playing = YES;
    _interrupted = NO;
    _disableUpdateHUD = NO;
    _tickCorrectionTime = 0;
    _tickCounter = 0;
    
#ifdef DEBUG
    _debugStartTime = -1;
#endif
    
    [self asyncDecodeFrames];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self tick];
    });
    
    if (_decoder.validAudio)
        [self enableAudio:YES];
    
    NSLog(@"play movie");
}

- (void) pause
{
    if (!self.playing)
        return;
    
    self.playing = NO;
    //_interrupted = YES;
    [self enableAudio:NO];
    NSLog(@"pause movie");
}


- (void) setMoviePosition: (CGFloat) position
{
    BOOL playMode = self.playing;
    
    self.playing = NO;
    _disableUpdateHUD = YES;
    [self enableAudio:NO];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self updatePosition:position playMode:playMode];
    });
}


#pragma mark - private

- (void) setMovieDecoder: (KxMovieDecoder *) decoder
               withError: (NSError *) error
{
    NSLog(@"setMovieDecoder");
    
    if (!error && decoder) {
        
        _decoder        = decoder;
        _dispatchQueue  = dispatch_queue_create("KxMovie", DISPATCH_QUEUE_SERIAL);
        _videoFrames    = [NSMutableArray array];
        _audioFrames    = [NSMutableArray array];
        
        if (_decoder.subtitleStreamsCount) {
            _subtitles = [NSMutableArray array];
        }
        
        if (_decoder.isNetwork) {
            
            _minBufferedDuration = NETWORK_MIN_BUFFERED_DURATION;
            _maxBufferedDuration = NETWORK_MAX_BUFFERED_DURATION;
            
        } else {
            
            _minBufferedDuration = LOCAL_MIN_BUFFERED_DURATION;
            _maxBufferedDuration = LOCAL_MAX_BUFFERED_DURATION;
        }
        
        if (!_decoder.validVideo)
            _minBufferedDuration *= 10.0; // increase for audio
        
        // allow to tweak some parameters at runtime
        if (_parameters.count) {
            
            id val;
            
            val = [_parameters valueForKey: KxMovieParameterMinBufferedDuration];
            if ([val isKindOfClass:[NSNumber class]])
                _minBufferedDuration = [val floatValue];
            
            val = [_parameters valueForKey: KxMovieParameterMaxBufferedDuration];
            if ([val isKindOfClass:[NSNumber class]])
                _maxBufferedDuration = [val floatValue];
            
            val = [_parameters valueForKey: KxMovieParameterDisableDeinterlacing];
            if ([val isKindOfClass:[NSNumber class]])
                _decoder.disableDeinterlacing = [val boolValue];
            
            if (_maxBufferedDuration < _minBufferedDuration)
                _maxBufferedDuration = _minBufferedDuration * 2;
        }
        
        NSLog(@"buffered limit: %.1f - %.1f", _minBufferedDuration, _maxBufferedDuration);
        
        if (self.isViewLoaded) {
            
            [self setupPresentView];
            
            if (_activityIndicatorView.isAnimating) {
                
                [_activityIndicatorView stopAnimating];
                // if (self.view.window)
                [self restorePlay];
                [self.dimIamge removeFromSuperview];
            }
        }
        
    } else {
        
        if (self.isViewLoaded && self.view.window) {
            
            [_activityIndicatorView stopAnimating];
            [self.dimIamge removeFromSuperview];

            if (!_interrupted)
                [self handleDecoderMovieError: error];
        }
    }
}

- (void) restorePlay
{
    NSNumber *n = [gHistory valueForKey:_decoder.path];
    if (n)
        [self updatePosition:n.floatValue playMode:YES];
    else
        [self play];
}

- (void) setupPresentView
{
    CGRect bounds = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    
    if (_decoder.validVideo) {
        _glView = [[KxMovieGLView alloc] initWithFrame:bounds decoder:_decoder];
    }
    
    if (!_glView) {
        NSLog(@"fallback to use RGB video frame and UIKit");
        [_decoder setupVideoFrameFormat:KxVideoFrameFormatRGB];
        _imageView = [[UIImageView alloc] initWithFrame:bounds];
    }
    UIView *frameView = [self frameView];
    [self.view insertSubview:frameView atIndex:0];
//    self.view.backgroundColor = [UIColor clearColor];
}


- (UIView *) frameView
{
    return _glView ? _glView : _imageView;
}

- (void) audioCallbackFillData: (float *) outData
                     numFrames: (UInt32) numFrames
                   numChannels: (UInt32) numChannels
{
    
    if (_buffered) {
        memset(outData, 0, numFrames * numChannels * sizeof(float));
        return;
    }
    
    @autoreleasepool {
        
        while (numFrames > 0) {
            
            if (!_currentAudioFrame) {
                
                @synchronized(_audioFrames) {
                    
                    NSUInteger count = _audioFrames.count;
                    
                    if (count > 0) {
                        
                        KxAudioFrame *frame = _audioFrames[0];
                        
                        if (_decoder.validVideo) {
                            
                            const CGFloat delta = _moviePosition - frame.position;
                            
                            if (delta < -2.0) {
                                
                                memset(outData, 0, numFrames * numChannels * sizeof(float));
#ifdef DEBUG
                                NSLog(@"desync audio (outrun) wait %.4f %.4f", _moviePosition, frame.position);
                                _debugAudioStatus = 1;
                                _debugAudioStatusTS = [NSDate date];
#endif
                                break; // silence and exit
                            }
                            
                            [_audioFrames removeObjectAtIndex:0];
                            
                            if (delta > 2.0 && count > 1) {
                                
#ifdef DEBUG
                                NSLog(@"desync audio (lags) skip %.4f %.4f", _moviePosition, frame.position);
                                _debugAudioStatus = 2;
                                _debugAudioStatusTS = [NSDate date];
#endif
                                continue;
                            }
                            
                        } else {
                            
                            [_audioFrames removeObjectAtIndex:0];
                            _moviePosition = frame.position;
                            _bufferedDuration -= frame.duration;
                        }
                        
                        _currentAudioFramePos = 0;
                        _currentAudioFrame = frame.samples;
                    }
                }
            }
            
            if (_currentAudioFrame) {
                
                const void *bytes = (Byte *)_currentAudioFrame.bytes + _currentAudioFramePos;
                const NSUInteger bytesLeft = (_currentAudioFrame.length - _currentAudioFramePos);
                const NSUInteger frameSizeOf = numChannels * sizeof(float);
                const NSUInteger bytesToCopy = MIN(numFrames * frameSizeOf, bytesLeft);
                const NSUInteger framesToCopy = bytesToCopy / frameSizeOf;
                
                memcpy(outData, bytes, bytesToCopy);
                numFrames -= framesToCopy;
                outData += framesToCopy * numChannels;
                
                if (bytesToCopy < bytesLeft)
                    _currentAudioFramePos += bytesToCopy;
                else
                    _currentAudioFrame = nil;
                
            } else {
                
                memset(outData, 0, numFrames * numChannels * sizeof(float));
                //NSLog(@"silence audio");
#ifdef DEBUG
                _debugAudioStatus = 3;
                _debugAudioStatusTS = [NSDate date];
#endif
                break;
            }
        }
    }
}

- (void) enableAudio: (BOOL) on
{
    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
    
    if (on && _decoder.validAudio) {
        
        audioManager.outputBlock = ^(float *outData, UInt32 numFrames, UInt32 numChannels) {
            
            [self audioCallbackFillData: outData numFrames:numFrames numChannels:numChannels];
        };
        
        [audioManager play];
        
        NSLog(@"audio device smr: %d fmt: %d chn: %d",
              (int)audioManager.samplingRate,
              (int)audioManager.numBytesPerSample,
              (int)audioManager.numOutputChannels);
        
    } else {
        
        [audioManager pause];
        audioManager.outputBlock = nil;
    }
}

- (BOOL) addFrames: (NSArray *)frames
{
    if (_decoder.validVideo) {
        
        @synchronized(_videoFrames) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeVideo) {
                    [_videoFrames addObject:frame];
                    _bufferedDuration += frame.duration;
                }
        }
    }
    
    if (_decoder.validAudio) {
        
        @synchronized(_audioFrames) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeAudio) {
                    [_audioFrames addObject:frame];
                    if (!_decoder.validVideo)
                        _bufferedDuration += frame.duration;
                }
        }
        
        if (!_decoder.validVideo) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeArtwork)
                    self.artworkFrame = (KxArtworkFrame *)frame;
        }
    }
    
    if (_decoder.validSubtitles) {
        
        @synchronized(_subtitles) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeSubtitle) {
                    [_subtitles addObject:frame];
                }
        }
    }
    
    return self.playing && _bufferedDuration < _maxBufferedDuration;
}

- (BOOL) decodeFrames
{
    //NSAssert(dispatch_get_current_queue() == _dispatchQueue, @"bugcheck");
    
    NSArray *frames = nil;
    
    if (_decoder.validVideo ||
        _decoder.validAudio) {
        
        frames = [_decoder decodeFrames:0];
    }
    
    if (frames.count) {
        return [self addFrames: frames];
    }
    return NO;
}

- (void) asyncDecodeFrames
{
    if (self.decoding)
        return;
    
    __weak LLYKxMovieVC *weakSelf = self;
    __weak KxMovieDecoder *weakDecoder = _decoder;
    
    const CGFloat duration = _decoder.isNetwork ? .0f : 0.1f;
    
    self.decoding = YES;
    dispatch_async(_dispatchQueue, ^{
        
        {
            __strong LLYKxMovieVC *strongSelf = weakSelf;
            if (!strongSelf.playing)
                return;
        }
        
        BOOL good = YES;
        while (good) {
            
            good = NO;
            
            @autoreleasepool {
                
                __strong KxMovieDecoder *decoder = weakDecoder;
                
                if (decoder && (decoder.validVideo || decoder.validAudio)) {
                    
                    NSArray *frames = [decoder decodeFrames:duration];
                    if (frames.count) {
                        
                        __strong LLYKxMovieVC *strongSelf = weakSelf;
                        if (strongSelf)
                            good = [strongSelf addFrames:frames];
                    }
                }
            }
        }
        
        {
            __strong LLYKxMovieVC *strongSelf = weakSelf;
            if (strongSelf) strongSelf.decoding = NO;
        }
    });
}

- (void) tick
{
    if (_buffered && ((_bufferedDuration > _minBufferedDuration) || _decoder.isEOF)) {
        
        _tickCorrectionTime = 0;
        _buffered = NO;
        [_activityIndicatorView stopAnimating];
        [self.dimIamge removeFromSuperview];

    }
    
    CGFloat interval = 0;
    if (!_buffered)
        interval = [self presentFrame];
    
    if (self.playing) {
        
        const NSUInteger leftFrames =
        (_decoder.validVideo ? _videoFrames.count : 0) +
        (_decoder.validAudio ? _audioFrames.count : 0);
        
        if (0 == leftFrames) {
            
            if (_decoder.isEOF) {
                
                [self pause];
                return;
            }
            
            if (_minBufferedDuration > 0 && !_buffered) {
                
                _buffered = YES;
                [_activityIndicatorView startAnimating];
            }
        }
        
        if (!leftFrames ||
            !(_bufferedDuration > _minBufferedDuration)) {
            
            [self asyncDecodeFrames];
        }
        
        const NSTimeInterval correction = [self tickCorrection];
        const NSTimeInterval time = MAX(interval + correction, 0.01);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self tick];
        });
    }
}

- (CGFloat) tickCorrection
{
    if (_buffered)
        return 0;
    
    const NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    if (!_tickCorrectionTime) {
        
        _tickCorrectionTime = now;
        _tickCorrectionPosition = _moviePosition;
        return 0;
    }
    
    NSTimeInterval dPosition = _moviePosition - _tickCorrectionPosition;
    NSTimeInterval dTime = now - _tickCorrectionTime;
    NSTimeInterval correction = dPosition - dTime;
    
    //if ((_tickCounter % 200) == 0)
    //    NSLog(@"tick correction %.4f", correction);
    
    if (correction > 1.f || correction < -1.f) {
        
        NSLog(@"tick correction reset %.2f", correction);
        correction = 0;
        _tickCorrectionTime = 0;
    }
    
    return correction;
}

- (CGFloat) presentFrame
{
    CGFloat interval = 0;
    
    if (_decoder.validVideo) {
        
        KxVideoFrame *frame;
        
        @synchronized(_videoFrames) {
            
            if (_videoFrames.count > 0) {
                
                frame = _videoFrames[0];
                [_videoFrames removeObjectAtIndex:0];
                _bufferedDuration -= frame.duration;
            }
        }
        
        if (frame)
            interval = [self presentVideoFrame:frame];
        
    } else if (_decoder.validAudio) {
        
        //interval = _bufferedDuration * 0.5;
        
        if (self.artworkFrame) {
            
            _imageView.image = [self.artworkFrame asImage];
            self.artworkFrame = nil;
        }
    }
    
    if (_decoder.validSubtitles)
        [self presentSubtitles];
    
#ifdef DEBUG
    if (self.playing && _debugStartTime < 0)
        _debugStartTime = [NSDate timeIntervalSinceReferenceDate] - _moviePosition;
#endif
    
    return interval;
}

- (CGFloat) presentVideoFrame: (KxVideoFrame *) frame
{
    if (_glView) {
        
        [_glView render:frame];
        
    } else {
        
        KxVideoFrameRGB *rgbFrame = (KxVideoFrameRGB *)frame;
        _imageView.image = [rgbFrame asImage];
    }
    
    _moviePosition = frame.position;
    
    return frame.duration;
}

- (void) presentSubtitles
{
    NSArray *actual, *outdated;
    
    if ([self subtitleForPosition:_moviePosition
                           actual:&actual
                         outdated:&outdated]){
        
        if (outdated.count) {
            @synchronized(_subtitles) {
                [_subtitles removeObjectsInArray:outdated];
            }
        }
        
       
    }
}

- (BOOL) subtitleForPosition: (CGFloat) position
                      actual: (NSArray **) pActual
                    outdated: (NSArray **) pOutdated
{
    if (!_subtitles.count)
        return NO;
    
    NSMutableArray *actual = nil;
    NSMutableArray *outdated = nil;
    
    for (KxSubtitleFrame *subtitle in _subtitles) {
        
        if (position < subtitle.position) {
            
            break; // assume what subtitles sorted by position
            
        } else if (position >= (subtitle.position + subtitle.duration)) {
            
            if (pOutdated) {
                if (!outdated)
                    outdated = [NSMutableArray array];
                [outdated addObject:subtitle];
            }
            
        } else {
            
            if (pActual) {
                if (!actual)
                    actual = [NSMutableArray array];
                [actual addObject:subtitle];
            }
        }
    }
    
    if (pActual) *pActual = actual;
    if (pOutdated) *pOutdated = outdated;
    
    return actual.count || outdated.count;
}


- (void) setMoviePositionFromDecoder
{
    _moviePosition = _decoder.position;
}

- (void) setDecoderPosition: (CGFloat) position
{
    _decoder.position = position;
}

- (void) enableUpdateHUD
{
    _disableUpdateHUD = NO;
}

- (void) updatePosition: (CGFloat) position
               playMode: (BOOL) playMode
{
    [self freeBufferedFrames];
    
    position = MIN(_decoder.duration - 1, MAX(0, position));
    
    __weak LLYKxMovieVC *weakSelf = self;
    
    dispatch_async(_dispatchQueue, ^{
        
        if (playMode) {
            
            {
                __strong LLYKxMovieVC *strongSelf = weakSelf;
                if (!strongSelf) return;
                [strongSelf setDecoderPosition: position];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                __strong LLYKxMovieVC *strongSelf = weakSelf;
                if (strongSelf) {
                    [strongSelf setMoviePositionFromDecoder];
                    [strongSelf play];
                }
            });
            
        } else {
            
            {
                __strong LLYKxMovieVC *strongSelf = weakSelf;
                if (!strongSelf) return;
                [strongSelf setDecoderPosition: position];
                [strongSelf decodeFrames];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                __strong LLYKxMovieVC *strongSelf = weakSelf;
                if (strongSelf) {
                    
                    [strongSelf enableUpdateHUD];
                    [strongSelf setMoviePositionFromDecoder];
                    [strongSelf presentFrame];
                }
            });
        }
    });
}

- (void) freeBufferedFrames
{
    @synchronized(_videoFrames) {
        [_videoFrames removeAllObjects];
    }
    
    @synchronized(_audioFrames) {
        
        [_audioFrames removeAllObjects];
        _currentAudioFrame = nil;
    }
    
    if (_subtitles) {
        @synchronized(_subtitles) {
            [_subtitles removeAllObjects];
        }
    }
    
    _bufferedDuration = 0;
}


- (void) handleDecoderMovieError: (NSError *) error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failure", nil)
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Close", nil)
                                              otherButtonTitles:nil];
    
    [alertView show];
}

- (BOOL) interruptDecoder
{
    return _interrupted;
}

- (void)moveSurfaceView:(float)offsetX{
    
    [self.surfaceView setOrigin:CGPointMake(offsetX, 0)];
    
}

- (void)showLove{
    
    int xx = self.view.frame.size.width;
    int yy = self.view.frame.size.height;
    float x = arc4random()%xx;
    float y = arc4random()%yy;
    
    LoveView *view = [[LoveView alloc]initWithFrame:CGRectMake(x ,y, 40, 40)];
    view.userInteractionEnabled = NO;
    view.backgroundColor = [UIColor clearColor];
    [view animationInView:self.view];
}

- (void)addMessage{

    MessageModel *model = [[MessageModel alloc]init];
    model.userNameStr = @"lllllllly";
    model.messageStr = @"一段文字设置多种字体颜色给定range和需要设置的颜色，就可以给一段文字设置多种不同的字体颜色，使用方法如下";
    [self.tableViewArray addObject:model];
//    [self.messageTableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.tableViewArray.count-1 inSection:0];
    [self.messageTableView insertRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationBottom];
    [self.messageTableView scrollToBottom];
}

- (void)addDanMu{

    NSInteger spriteNumber = [_renderer spritesNumberWithName:nil];
    if (spriteNumber <= 50) { // 限制屏幕上的弹幕量
        [_renderer receive:[self walkTextSpriteDescriptorWithDirection:BarrageWalkDirectionR2L]];
    }
}

- (void)setHeaderImageView{
    
    if (self.roomModel) {
        NSString *imageUrlStr = nil;
        if ([self.roomModel.creator.portrait containsString:@"http"]) {
            imageUrlStr = self.roomModel.creator.portrait;
        }
        else{
            imageUrlStr = [NSString stringWithFormat:@"http://img.meelive.cn/%@",self.roomModel.creator.portrait];
        }
        [self.headerImageView setImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://image.scale.inke.com/imageproxy2/dimgm/scaleImage?url=%@&w=72&s=80&h=72&c=0&o=0",imageUrlStr]]];
        
        self.headerImageView.layer.cornerRadius = 18;
        self.headerImageView.layer.masksToBounds = YES;
    }
}


// 加载图
- (void)loadingView
{
    if (self.roomModel) {
        self.dimIamge = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        if ([self.roomModel.creator.portrait containsString:@"http"]) {
            [_dimIamge setImageURL:[NSURL URLWithString:self.roomModel.creator.portrait]];
        }
        else{
            [_dimIamge setImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://img.meelive.cn/%@",self.roomModel.creator.portrait]]];
        }
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.frame = _dimIamge.bounds;
        [_dimIamge addSubview:visualEffectView];
        _dimIamge.layer.zPosition = 100;
        [self.view addSubview:_dimIamge];
    }
}



#pragma mark - Action

- (IBAction)bottomBtnClicked:(id)sender {
    int tag = ((UIButton *)sender).tag;
    switch (tag) {
        case TalkBtn:
        {}
            break;
        case MessageBtn:
        {}
            break;
        case ShareBtn:
        {}
            break;
        case GiftBtn:
        {}
            break;
        case CloseBtn:
        {
            [self.mNav popViewControllerAnimated:YES];
        }
            break;
            
        default:
            break;
    }
}


- (IBAction)closedUserInfoViewBtnClicked:(id)sender {
    [UIView animateWithDuration:0.3f animations:^{
        [self.userInfoView setOrigin:CGPointMake(0, kScreenHeight)];
        
    } completion:^(BOOL finished) {
        [self.userInfoView removeFromSuperview];
    }];
}



#pragma mark - UICollectionView Delegate/DateSource/Layout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return self.collectionViewArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    UserModel *model = self.collectionViewArray[indexPath.row];
    UserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCell" forIndexPath:indexPath];
    [cell setCellWithModel:model];
    return cell;
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(36, 36);
    
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(2, 0, 2, 2);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    UserModel *model = self.collectionViewArray[indexPath.row];
    [self.view addSubview:self.userInfoView];
    [UIView animateWithDuration:0.5 animations:^{
        [self.userInfoView setCenter:self.view.center];
    } completion:^(BOOL finished) {
        
    }];
    
}



#pragma mark - UITabelView Delegate/Datesource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.tableViewArray.count;

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    MessageModel *model = self.tableViewArray[indexPath.row];
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setCellWithModel:model];
    return cell;

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return [tableView fd_heightForCellWithIdentifier:@"MessageCell" configuration:^(id cell) {
        //
        MessageModel *model = self.tableViewArray[indexPath.row];
        [cell setCellWithModel:model];
    }];
}


#pragma mark - 弹幕描述符生产方法

long _index = 0;
/// 生成精灵描述 - 过场文字弹幕
- (BarrageDescriptor *)walkTextSpriteDescriptorWithDirection:(NSInteger)direction
{
    BarrageDescriptor * descriptor = [[BarrageDescriptor alloc]init];
    descriptor.spriteName = NSStringFromClass([BarrageWalkTextSprite class]);
    descriptor.params[@"text"] = self.danMuTextArray[arc4random_uniform((uint32_t)self.danMuTextArray.count)];
    descriptor.params[@"textColor"] = RGBCOLOR(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256));
    descriptor.params[@"speed"] = @(100 * (double)random()/RAND_MAX+50);
    descriptor.params[@"direction"] = @(direction);
    descriptor.params[@"clickAction"] = ^{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"弹幕被点击" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [alertView show];
    };
    return descriptor;
}



@end
