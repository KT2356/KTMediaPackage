//
//  KTQRCodeMaskView.h
//  KTMediaPackageDemo
//
//  Created by KT on 15/12/22.
//  Copyright © 2015年 KT. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height

@protocol KTQRCodeMaskViewDelegate <NSObject>
- (void)KTQRCodeMaskViewWillDiappear;
- (void)KTQRcodeDidClickedMyCode;
- (void)KTQRCodeUserDidChosenPicture:(UIImage *)image;
@end

@interface KTQRCodeMaskView : UIView
@property (nonatomic, weak) id <KTQRCodeMaskViewDelegate> delegate;
- (void)stopAnimation;
- (void)startAnimation;
@end
