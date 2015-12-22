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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
        KTQRCodeViewController *qrCode = [[KTQRCodeViewController alloc] initWithFinishBlock:^(NSString *scanResult) {
        NSLog(@"----%@",scanResult);
    }];
    
    [qrCode startScanning];


    [self presentViewController:qrCode animated:YES completion:nil];
    
}



@end
