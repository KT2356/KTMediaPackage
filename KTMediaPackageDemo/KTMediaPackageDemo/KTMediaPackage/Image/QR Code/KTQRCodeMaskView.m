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
    }
    return self;
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
    
    CGRect offsetRect = CGRectOffset(innerRect, 0, 15);
    _overlay.path = [UIBezierPath bezierPathWithRoundedRect:offsetRect cornerRadius:0].CGPath;
    
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
