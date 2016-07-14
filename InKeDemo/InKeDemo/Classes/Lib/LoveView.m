//
//  LoveView.m
//  DianZanAnimation
//
//  Created by lly on 16/6/16.
//  Copyright © 2016年 lly. All rights reserved.
//

#import "LoveView.h"

@interface LoveView()

@property(nonatomic,strong) UIColor *strokeColor;
@property(nonatomic,strong) UIColor *fillColor;

@end

@implementation LoveView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init{

    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _strokeColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
//        self.layer.anchorPoint = CGPointMake(0.5, 1);
    }
    return self;
}


- (void)drawRect:(CGRect)rect{

    //Creat path
    UIBezierPath *heartPath = [UIBezierPath bezierPath];
    [heartPath moveToPoint:CGPointMake(20, 10)];
    [heartPath addCurveToPoint:CGPointMake(20, 38) controlPoint1:CGPointMake(-10, -5) controlPoint2:CGPointMake(8, 40)];
    [heartPath addCurveToPoint:CGPointMake(20, 10) controlPoint1:CGPointMake(32, 40) controlPoint2:CGPointMake(50, -5)];

    float fColorRedBase   = random()%10/10.0;
    float fColorGreenBase = random()%10/10.0;
    float fColorBlueBase  = random()%10/10.0;
    self.fillColor = [UIColor colorWithRed:fColorRedBase green:fColorGreenBase blue:fColorBlueBase alpha:1.0];
    
    [_strokeColor setStroke];
    [_fillColor setFill];
    
    [heartPath fill];
    
    heartPath.lineWidth = 1.0;
    heartPath.lineCapStyle = kCGLineCapRound;
    heartPath.lineJoinStyle = kCGLineJoinRound;
    [heartPath stroke];

//    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    
//    //画爱心
//    CGContextMoveToPoint(ctx, 20, 10);
//    CGContextAddCurveToPoint(ctx, -10, -5, 5, 40, 20, 40);
//    CGContextAddCurveToPoint(ctx, 35, 40, 50, -5, 20, 10);
//
//    CGContextSetRGBFillColor(ctx, fColorRedBase, fColorGreenBase, fColorBlueBase, 1);
//    CGContextFillPath(ctx);
//
//    
//    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
//    CGContextSetLineWidth(ctx, 2);
//    CGContextSetLineCap(ctx, kCGLineCapRound);
//    CGContextSetLineJoin(ctx, kCGLineJoinRound);
//    CGContextStrokePath(ctx);

}


static CGFloat PI = M_PI;

- (void)animationInView:(UIView *)view{
    
    [view addSubview:self];
    
    NSTimeInterval totalAnimationDuration = 6;
    CGFloat heartSize = CGRectGetWidth(self.bounds);
    CGFloat heartCenterX = self.center.x;
    CGFloat viewHeight = CGRectGetHeight(view.bounds);
    
    //Pre-Animation setup
    self.transform = CGAffineTransformMakeScale(0, 0);
    self.alpha = 0;
    
    
    //Bloom
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformIdentity;
        self.alpha = 0.9;
    } completion:NULL];
    
    NSInteger i = arc4random_uniform(2);
    NSInteger rotationDirection = 1- (2*i);// -1 OR 1
    NSInteger rotationFraction = arc4random_uniform(10);
    [UIView animateWithDuration:totalAnimationDuration animations:^{
        self.transform = CGAffineTransformMakeRotation(rotationDirection * PI/(16 + rotationFraction*0.2));
    } completion:NULL];
    
    UIBezierPath *heartTravelPath = [UIBezierPath bezierPath];
    [heartTravelPath moveToPoint:self.center];
    
    //random end point
    CGPoint endPoint = CGPointMake(heartCenterX + (rotationDirection) * arc4random_uniform(2*heartSize), viewHeight/6.0 + arc4random_uniform(viewHeight/4.0));
    
    //random Control Points
    NSInteger j = arc4random_uniform(2);
    NSInteger travelDirection = 1- (2*j);// -1 OR 1
    
    //randomize x and y for control points
    CGFloat xDelta = (heartSize/2.0 + arc4random_uniform(2*heartSize)) * travelDirection;
    CGFloat yDelta = MAX(endPoint.y ,MAX(arc4random_uniform(8*heartSize), heartSize));
    CGPoint controlPoint1 = CGPointMake(heartCenterX + xDelta, viewHeight - yDelta);
    CGPoint controlPoint2 = CGPointMake(heartCenterX - 2*xDelta, yDelta);
    
    [heartTravelPath addCurveToPoint:endPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    
    CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    keyFrameAnimation.path = heartTravelPath.CGPath;
    keyFrameAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    keyFrameAnimation.duration = totalAnimationDuration + endPoint.y/viewHeight;
    [self.layer addAnimation:keyFrameAnimation forKey:@"positionOnPath"];
    
    //Alpha & remove from superview
    [UIView animateWithDuration:totalAnimationDuration animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}


@end
