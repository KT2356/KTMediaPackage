//
//  KTQRCodeViewController.m
//  KTMediaPackageDemo
//
//  Created by KT on 15/12/22.
//  Copyright © 2015年 KT. All rights reserved.
//

#import "KTQRCodeViewController.h"
#import "KTQRCodeMaskView.h"
#import <AVFoundation/AVFoundation.h>

@interface KTQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate,KTQRCodeMaskViewDelegate>

@property (copy, nonatomic) ScanFinishBlock scanFinishBlock;

@property (strong, nonatomic) KTQRCodeMaskView           *maskView;
@property (strong, nonatomic) AVCaptureDevice            *device;
@property (strong, nonatomic) AVCaptureDeviceInput       *input;
@property (strong, nonatomic) AVCaptureMetadataOutput    *output;
@property (strong, nonatomic) AVCaptureSession           *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation KTQRCodeViewController
 
#pragma mark - life cycle
- (instancetype)initWithFinishBlock:(ScanFinishBlock)finishBlock {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor blackColor];
        self.scanFinishBlock = finishBlock;
        
        [self setupAVComponents];
        
        [self.maskView.layer insertSublayer:self.previewLayer atIndex:0];
         self.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startScanning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopScanning];
}

#pragma mark - public methods
- (void)startScanning {
    if (![self.session isRunning]) {
        [self.session startRunning];
        [self.maskView startAnimation];
    }
}

- (void)stopScanning {
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
}


#pragma mark - setup
- (void)setupAVComponents {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (self.device) {
        self.input   = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
        self.output  = [[AVCaptureMetadataOutput alloc] init];
        self.session = [[AVCaptureSession alloc] init];
        if ([self.session canAddInput:_input]) {
            [_session addInput:_input];
        }
        if ([self.session canAddOutput:_output]) {
            [_session addOutput:_output];
        }
        
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        [_output setMetadataObjectTypes:@[ AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code ]];
        //扫码区域
        float lineLength = SCREEN_WIDTH *0.4;
        CGPoint center = CGPointMake(SCREEN_WIDTH/2, 0);
        [_output setRectOfInterest:CGRectMake ((center.x - lineLength + 64)/ SCREEN_HEIGHT ,(center.x - lineLength)/ SCREEN_WIDTH , (2*lineLength )/SCREEN_HEIGHT , (2*lineLength)/SCREEN_WIDTH )];
        
        self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [_previewLayer setFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    }
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    for(AVMetadataObject *current in metadataObjects) {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];
            if (self.scanFinishBlock) {
                self.scanFinishBlock(scannedResult);
                [self.maskView stopAnimation];
            }
            [self stopScanning];
            break;
        }
    }
}

#pragma mark - KTQRCodeMaskViewDelegate
- (void)KTQRCodeMaskViewWillDiappear {
    [self dismissViewControllerAnimated:YES completion:^{
        [self stopScanning];
    }];
}

- (void)KTQRcodeDidClickedMyCode {
    NSLog(@"My Code");
}

- (void)KTQRCodeUserDidChosenPicture:(UIImage *)image {
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                              context:context
                                              options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *ciImage = [CIImage imageWithData:UIImageJPEGRepresentation(image, 0.5)];
    NSArray *features        = [detector featuresInImage:ciImage];
    CIQRCodeFeature *feature = [features firstObject];
    NSString *result         = feature.messageString;
    NSLog(@"%@",result);
}

#pragma mark - setter/getter
- (KTQRCodeMaskView *)maskView {
    if (!_maskView) {
        _maskView = [[KTQRCodeMaskView alloc] init];
        _maskView.translatesAutoresizingMaskIntoConstraints = NO;
        _maskView.clipsToBounds                             = YES;
        _maskView.delegate = self;
        [self.view addSubview:_maskView];
    }
    
    return _maskView;
}

@end
