//
//  KTQRCodeMaskView.h
//  KTMediaPackageDemo
//
//  Created by KT on 15/12/22.
//  Copyright © 2015年 KT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KTQRCodeMaskViewDelegate <NSObject>
- (void)QRCodeMaskViewWillDiappear;
@end

@interface KTQRCodeMaskView : UIView
@property (nonatomic, weak) id <KTQRCodeMaskViewDelegate> delegate;
- (void)stopAnimation;
@end
