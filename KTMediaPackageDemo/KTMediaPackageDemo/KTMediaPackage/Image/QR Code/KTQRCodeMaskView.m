//
//  KTQRCodeMaskView.m
//  KTMediaPackageDemo
//
//  Created by KT on 15/12/22.
//  Copyright © 2015年 KT. All rights reserved.
//
#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height
#define kMaskCornerLineWidth 30
#import "KTQRCodeMaskView.h"

typedef enum : NSUInteger {
    TopLeft,
    TopRight,
    BottomLeft,
    BottomRight,
} CornerPosition;

@interface KTQRCodeMaskView ()
@property (nonatomic, strong) CALayer *imageLayer;

@end

@implementation KTQRCodeMaskView

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    if (self) {
        [self adddNavigationBar];
        [self generateMaskView];
    }
    return self;
}

- (void)adddNavigationBar {
    UINavigationBar *naviba = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,
                                                                                0,
                                                                                [UIScreen mainScreen].bounds.size.width,
                                                                                64)];
    [self addSubview:naviba];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(dismissScanner)];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"相册"
                                                              style:UIBarButtonItemStyleDone
                                                             target:self
                                                             action:@selector(showAlbum)];
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"二维码/条码"];
    item.leftBarButtonItem = left;
    item.rightBarButtonItem = right;
    
    [naviba pushNavigationItem:item animated:YES];
}

- (void)dismissScanner {
    if ([self.delegate respondsToSelector:@selector(QRCodeMaskViewWillDiappear)]) {
        [self.delegate QRCodeMaskViewWillDiappear];
    }
}

- (void)showAlbum {
    
}

- (void)generateMaskView {
    CALayer *mask = [[CALayer alloc] init];
    mask.anchorPoint = CGPointMake(0, 0);
    mask.backgroundColor = [UIColor clearColor].CGColor;
    mask.position = CGPointMake(0, 0);
    mask.bounds = self.bounds;
    [self drawMaskRectInLayer:mask];
    [self.layer addSublayer:mask];
}

- (void)drawMaskRectInLayer:(CALayer *)layer {
    float lineLength = SCREEN_WIDTH *0.4;
    CGPoint center = CGPointMake(SCREEN_WIDTH/2, 0);
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, center.x - lineLength, 64 + center.x - lineLength);
    CGContextAddLineToPoint(context, center.x + lineLength, 64 + center.x - lineLength);
    CGContextAddLineToPoint(context, center.x + lineLength, 64 + center.x + lineLength);
    CGContextAddLineToPoint(context, center.x - lineLength, 64 + center.x + lineLength);
    CGContextClosePath(context);
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextStrokePath(context);
    
    CGRect rect = CGRectMake(0, 64, SCREEN_WIDTH,center.x - lineLength);
    [self drawMaskViewInContext:context withRect:rect];
    
    rect = CGRectMake(0, 64 + center.x - lineLength, center.x - lineLength, SCREEN_HEIGHT - center.x + lineLength);
    [self drawMaskViewInContext:context withRect:rect];
    
    rect = CGRectMake(0, SCREEN_WIDTH - center.x + lineLength,center.x - lineLength, SCREEN_HEIGHT - center.x + lineLength);
    [self drawMaskViewInContext:context withRect:rect];
    
    rect = CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH,center.x - lineLength);
    [self drawMaskViewInContext:context withRect:rect];
    
    CGPoint startP = CGPointMake(center.x - lineLength, 64 + center.x - lineLength);
    [self drawCornerWithStartPoint:startP inContext:context withPosition:TopLeft];
    
    startP = CGPointMake(center.x + lineLength, 64 + center.x - lineLength);
    [self drawCornerWithStartPoint:startP inContext:context withPosition:TopRight];
    
    startP = CGPointMake(center.x - lineLength, 64 + center.x + lineLength);
    [self drawCornerWithStartPoint:startP inContext:context withPosition:BottomLeft];
    
    startP = CGPointMake(center.x + lineLength, 64 + center.x + lineLength);
    [self drawCornerWithStartPoint:startP inContext:context withPosition:BottomRight];
    
    [self addAnimationLineInLayer:layer centerPoint:CGPointMake(center.x, 64 + center.x - lineLength) rectHeight:lineLength];
    layer.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
    UIGraphicsEndImageContext();
}
- (void)drawMaskViewInContext:(CGContextRef)context withRect:(CGRect)rect {
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetAlpha(context, 0.5);
    CGContextFillRect(context, rect);
}


//画拐角
- (void)drawCornerWithStartPoint:(CGPoint)point inContext:(CGContextRef)context withPosition:(CornerPosition)position{
    if (position == TopLeft || position == BottomLeft) {
        CGContextMoveToPoint(context, point.x + kMaskCornerLineWidth, point.y);
    } else {
        CGContextMoveToPoint(context, point.x - kMaskCornerLineWidth, point.y);
    }
    CGContextAddLineToPoint(context, point.x, point.y);
    if (position == BottomLeft || position == BottomRight) {
        CGContextAddLineToPoint(context, point.x, point.y - kMaskCornerLineWidth);
    } else {
        CGContextAddLineToPoint(context, point.x, point.y + kMaskCornerLineWidth);
    }
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextSetLineWidth(context, 4);
    CGContextStrokePath(context);
    
}


- (void)stopAnimation {
    [self.imageLayer removeAnimationForKey:@"moveLineAnimation"];
    [self.imageLayer removeFromSuperlayer];
}


- (void)addAnimationLineInLayer:(CALayer *)layer centerPoint:(CGPoint)center rectHeight:(float)lineLength{
    UIImage *image = [UIImage imageNamed:@"CodeScan.bundle/qrcode_Scan_weixin_Line@2x"];

    self.imageLayer.frame = CGRectMake(center.x - image.size.width/2 ,center.y, image.size.width, 6);
    self.imageLayer.contents = (id) image.CGImage;
    [layer addSublayer:self.imageLayer];
    
    CABasicAnimation *animation   = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.fromValue           = [NSNumber numberWithFloat:(64 + center.x - lineLength)];
    animation.toValue             = [NSNumber numberWithFloat:(64 + center.x + lineLength)];
    animation.duration            = 3.0f;
    animation.repeatCount         = FLT_MAX;
    animation.removedOnCompletion = NO;
    // animation.fillMode            = kCAFillModeForwards;
    [self.imageLayer addAnimation:animation forKey:@"moveLineAnimation"];
}

#pragma mark - setter/getter
- (CALayer *)imageLayer {
    if (!_imageLayer) {
        _imageLayer = [[CALayer alloc] init];
    }
    return _imageLayer;
}


@end
