//
//  ViewController.m
//  KTMediaPackageDemo
//
//  Created by KT on 15/12/22.
//  Copyright © 2015年 KT. All rights reserved.
//

#import "ViewController.h"
#import "KTQRCodeViewController.h"

@interface ViewController ()
@property (nonatomic ,strong) KTQRCodeViewController *qrCode;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)showQRCodel:(UIButton *)sender {
    [self presentViewController:self.qrCode animated:YES completion:nil];
    [self.qrCode startScanning];
}



- (KTQRCodeViewController *)qrCode {
    if (!_qrCode) {
        _qrCode = [[KTQRCodeViewController alloc] initWithFinishBlock:^(NSString *scanResult) {
            NSLog(@"----%@",scanResult);
        }];
    }
    return _qrCode;
}

@end
