//
//  KTQRCodeMaskView.m
//  KTMediaPackageDemo
//
//  Created by KT on 15/12/22.
//  Copyright © 2015年 KT. All rights reserved.
//

#import "KTQRCodeMaskView.h"

@interface KTQRCodeMaskView ()
@property (nonatomic, strong) CAShapeLayer *overlay;

@end

@implementation KTQRCodeMaskView

- (instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    if (self) {
        [self addOverlay];
        [self adddNavigationBar];
    }
    return self;
}

- (void)adddNavigationBar {
    UINavigationBar *naviba = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    [self addSubview:naviba];
}


- (void)drawRect:(CGRect)rect {
    CGRect innerRect = CGRectInset(rect, 50, 50);
    
    CGFloat minSize = MIN(innerRect.size.width, innerRect.size.height);
    if (innerRect.size.width != minSize) {
        innerRect.origin.x   += (innerRect.size.width - minSize) / 2;
        innerRect.size.width = minSize;
    }
    else if (innerRect.size.height != minSize) {
        innerRect.origin.y    += (innerRect.size.height - minSize) / 2;
        innerRect.size.height = minSize;
    }
    _overlay.path = [UIBezierPath bezierPathWithRoundedRect:innerRect cornerRadius:0].CGPath;
    
    [self addMaskViewWithRect:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, innerRect.origin.y-65)];
    [self addMaskViewWithRect:CGRectMake(0, innerRect.origin.y + innerRect.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - innerRect.origin.y + innerRect.size.height )];
    [self addMaskViewWithRect:CGRectMake(0, innerRect.origin.y-1, innerRect.origin.x, innerRect.size.height+1)];
    [self addMaskViewWithRect:CGRectMake(innerRect.origin.x + innerRect.size.width, innerRect.origin.y-1, innerRect.origin.x, innerRect.size.height+1)];

    [self.layer setNeedsDisplay];
}

- (void)addMaskViewWithRect:(CGRect)rect {
    CALayer *mask = [[CALayer alloc] init];
    mask.anchorPoint = CGPointMake(0, 0);
    mask.backgroundColor = [UIColor blackColor].CGColor;
    mask.bounds = rect;
    mask.position = rect.origin;
    mask.opacity = 0.5;
    [self.layer addSublayer:mask];
}

- (void)addAnimationLine {
    
}

#pragma mark - Private Methods
- (void)addOverlay {
    _overlay = [[CAShapeLayer alloc] init];
    _overlay.backgroundColor = [UIColor clearColor].CGColor;
    _overlay.fillColor       = [UIColor clearColor].CGColor;
    _overlay.strokeColor     = [UIColor whiteColor].CGColor;
    _overlay.lineWidth       = 2;
    [self.layer addSublayer:_overlay];
}

@end
