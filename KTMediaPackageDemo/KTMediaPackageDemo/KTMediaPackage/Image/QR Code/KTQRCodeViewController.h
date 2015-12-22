//
//  KTQRCodeViewController.h
//  KTMediaPackageDemo
//
//  Created by KT on 15/12/22.
//  Copyright © 2015年 KT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ScanFinishBlock)(NSString *scanResult);
@interface KTQRCodeViewController : UIViewController

- (instancetype)initWithFinishBlock:(ScanFinishBlock)finishBlock;
- (void)startScanning;
- (void)stopScanning;

@end
