//
//  KTQRCodeViewController.m
//  KTMediaPackageDemo
//
//  Created by KT on 15/12/22.
//  Copyright © 2015年 KT. All rights reserved.
//

#import "KTQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface KTQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (copy, nonatomic) ScanFinishBlock scanFinishBlock;

@property (strong, nonatomic) UIView *backView;
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
        [self configureDefaultComponents];
        [self setupBackGroundView];
         self.modalPresentationStyle = UIModalPresentationFormSheet;
        [_backView.layer insertSublayer:self.previewLayer atIndex:0];
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopScanning];
}

#pragma mark - public methods
- (void)startScanning {
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
}

- (void)stopScanning {
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
}

#pragma mark - setup
- (void)setupBackGroundView {
    self.backView  = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                              0,
                                                              [UIScreen mainScreen].bounds.size.width,
                                                              [UIScreen mainScreen].bounds.size.height)];
    _backView.translatesAutoresizingMaskIntoConstraints = NO;
    _backView.clipsToBounds                             = YES;
    [self.view addSubview:_backView];
}

- (void)setupAVComponents {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (self.device) {
        self.input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
        self.output     = [[AVCaptureMetadataOutput alloc] init];
        self.session            = [[AVCaptureSession alloc] init];
        self.previewLayer       = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    }
}

- (void)configureDefaultComponents {
    [_session addOutput:_output];
    
    if (_device) {
        [_session addInput:_input];
    }
    
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    if ([[_output availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeQRCode]) {
        [_output setMetadataObjectTypes:@[ AVMetadataObjectTypeQRCode ]];
    }
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_previewLayer setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    for(AVMetadataObject *current in metadataObjects) {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]
            && [current.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];
            if (self.scanFinishBlock) {
                self.scanFinishBlock(scannedResult);
            }
            [self stopScanning];
            break;
        }
    }
}

@end
