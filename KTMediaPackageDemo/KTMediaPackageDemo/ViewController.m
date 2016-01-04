//
//  ViewController.m
//  KTMediaPackageDemo
//
//  Created by KT on 15/12/22.
//  Copyright © 2015年 KT. All rights reserved.
//

#import "ViewController.h"
#import "KTQRCodeViewController.h"
#import "KTVideoPlayer.h"

@interface ViewController ()<KTQRCodeDelegate>
@property (nonatomic ,strong) KTQRCodeViewController *qrCode;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)showVideoPlayer:(UIButton *)sender {
    NSString *urlString = @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";
    KTVideoPlayer *videoView = [[KTVideoPlayer alloc] initWithFrame:CGRectMake(0, 300, 320, 160) urlString:urlString];
    
    [self.view addSubview:videoView];
}

#pragma mark - QRCode
- (IBAction)showQRCodel:(UIButton *)sender {
    [self presentViewController:self.qrCode animated:YES completion:nil];
    [self.qrCode startScanning];
}

- (KTQRCodeViewController *)qrCode {
    if (!_qrCode) {
        _qrCode = [[KTQRCodeViewController alloc] initWithFinishBlock:^(NSString *scanResult) {
            NSLog(@"----%@",scanResult);
        }];
        _qrCode.delegate = self;
    }
    return _qrCode;
}

- (void)ktQRcodeDidClickMyCode {
    NSLog(@"click my code");
}

@end
