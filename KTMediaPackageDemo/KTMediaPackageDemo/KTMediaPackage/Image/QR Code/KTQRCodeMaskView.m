//
//  KTQRCodeMaskView.m
//  KTMediaPackageDemo
//
//  Created by KT on 15/12/22.
//  Copyright © 2015年 KT. All rights reserved.
//

#define kMaskCornerLineWidth 30
#import "KTQRCodeMaskView.h"

typedef enum : NSUInteger {
    TopLeft,
    TopRight,
    BottomLeft,
    BottomRight,
} CornerPosition;

@interface KTQRCodeMaskView ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong) CALayer *imageLayer;
@property (nonatomic, strong) CABasicAnimation *LineAnimation;
@property (nonatomic, assign) NSTimeInterval timeStamp;

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
    if ([self.delegate respondsToSelector:@selector(KTQRCodeMaskViewWillDiappear)]) {
        [self.delegate KTQRCodeMaskViewWillDiappear];
    }
}

- (void)showAlbum {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [[self superViewController] presentViewController:picker animated:YES completion:nil];
}

#pragma mark - findViewController
- (UIViewController*)superViewController {
    UIResponder *responder = [self nextResponder];
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}


#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //修改imagePicker bar 的颜色
    if([navigationController isKindOfClass:[UIImagePickerController class]]) {
        // navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        navigationController.navigationBar.backgroundColor = self.window.rootViewController.navigationController.navigationBar.backgroundColor;
    }
}
# pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController  *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *myimage = [info objectForKey:UIImagePickerControllerOriginalImage];
    if ([self.delegate respondsToSelector:@selector(KTQRCodeUserDidChosenPicture:)]) {
        [self.delegate KTQRCodeUserDidChosenPicture:myimage];
    }
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
    
    rect = CGRectMake(center.x + lineLength, 64 + center.x - lineLength ,center.x - lineLength, SCREEN_HEIGHT - 64 -center.x + lineLength);
    [self drawMaskViewInContext:context withRect:rect];
    
    rect = CGRectMake(center.x - lineLength, 64 + center.x + lineLength, SCREEN_WIDTH - 2*(center.x - lineLength),SCREEN_HEIGHT - center.x - lineLength - 64);
    [self drawMaskViewInContext:context withRect:rect];
    
    //
    CGPoint startP = CGPointMake(center.x - lineLength, 64 + center.x - lineLength);
    [self drawCornerWithStartPoint:startP inContext:context withPosition:TopLeft];
    
    startP = CGPointMake(center.x + lineLength, 64 + center.x - lineLength);
    [self drawCornerWithStartPoint:startP inContext:context withPosition:TopRight];
    
    startP = CGPointMake(center.x - lineLength, 64 + center.x + lineLength);
    [self drawCornerWithStartPoint:startP inContext:context withPosition:BottomLeft];
    
    startP = CGPointMake(center.x + lineLength, 64 + center.x + lineLength);
    [self drawCornerWithStartPoint:startP inContext:context withPosition:BottomRight];
    
    [self addAnimationLineInLayer:layer centerPoint:CGPointMake(center.x, 64 + center.x - lineLength) rectHeight:lineLength];
    
    [self drawTextLabelInLayer:layer WithString:@"将二维码/条码放入框内，即可自动扫描" inRect:CGRectMake(center.x - lineLength, center.x + 64 + lineLength + 10, lineLength * 2, 20) color:[UIColor whiteColor] fontSize:12.0f];
    [self drawTextLabelInLayer:layer WithString:@"我的二维码" inRect:CGRectMake(center.x - 50, center.x + 64 + lineLength + 30, 100, 30) color:[UIColor greenColor] fontSize:14.0f];
    
    layer.contents = (id)UIGraphicsGetImageFromCurrentImageContext().CGImage;
    UIGraphicsEndImageContext();
}
- (void)drawMaskViewInContext:(CGContextRef)context withRect:(CGRect)rect {
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetAlpha(context, 0.6);
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

- (void)startAnimation {
    [self.imageLayer addAnimation:self.LineAnimation forKey:@"moveLineAnimation"];
    [self.layer addSublayer:self.imageLayer];
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
    self.LineAnimation = animation;
    // animation.fillMode            = kCAFillModeForwards;
}


- (void)drawTextLabelInLayer:(CALayer *)layer
                  WithString:(NSString *)string
                      inRect:(CGRect)rect
                       color:(UIColor *)color
                    fontSize:(float)fontSize
{
    CATextLayer *textLayer = [CATextLayer layer];
    
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.fontSize = fontSize;
    textLayer.frame = rect;
    textLayer.string = string;
    textLayer.foregroundColor = color.CGColor;
    textLayer.alignmentMode = @"center";
    [layer addSublayer:textLayer];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    float lineLength = SCREEN_WIDTH *0.4;
    CGPoint center = CGPointMake(SCREEN_WIDTH/2, 0);
    if ([self pointIsInRect:point rect:CGRectMake(center.x - 50, center.x + 64 + lineLength + 30, 100, 30)]) {
        if (event.timestamp != self.timeStamp) {
            if ([self.delegate respondsToSelector:@selector(KTQRcodeDidClickedMyCode)]) {
                [self.delegate KTQRcodeDidClickedMyCode];
            }
            self.timeStamp = event.timestamp;
        }
    }
    return YES;
}

- (BOOL)pointIsInRect:(CGPoint)point rect:(CGRect)rect {
    if (point.x >= rect.origin.x && point.x <= rect.origin.x + rect.size.width && point.y >= rect.origin.y && point.y <= rect.size.height + rect.origin.y) {
        return YES;
    } else {
        return NO;
    }
}



#pragma mark - setter/getter
- (CALayer *)imageLayer {
    if (!_imageLayer) {
        _imageLayer = [[CALayer alloc] init];
    }
    return _imageLayer;
}


@end
