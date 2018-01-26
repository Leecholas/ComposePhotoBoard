//
//  ImageBrowserViewCell.m
//  ComposePhotoBoard
//
//  Created by Leecholas on 2018/1/19.
//  Copyright © 2018年 Leecholas. All rights reserved.
//

#import "ImageBrowserViewCell.h"

@interface ImageBrowserViewCell ()<UIScrollViewDelegate>

@end

@implementation ImageBrowserViewCell

- (instancetype)init {
    self = [super init];
    if (self) {
        self.size = [UIScreen mainScreen].bounds.size;
        self.delegate = self;
        self.bouncesZoom = YES;
        self.minimumZoomScale = 1.0f;
        self.maximumZoomScale = 2.0f;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.frame = CGRectMake(0, 0, self.width, self.height);
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
//        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        
        self.index = -1;
        self.isZoomed = NO;
    }
    return self;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGSize scrollBoundsSize = scrollView.bounds.size; //缩放中,bounds.size是不变的,origin随缩放变化
    CGRect imageViewFrame = self.imageView.frame; //imageView的origin不变,size随缩放变化,与scrollView的contentSize相等(scrollView的contentSize随缩放变化)
    CGPoint centerPoint = CGPointMake(imageViewFrame.size.width/2, imageViewFrame.size.height/2);
    
    // 当宽或者高缩小到不超过屏幕时,宽或高的中心固定在屏幕中间
    if (imageViewFrame.size.width <= scrollBoundsSize.width) {
        centerPoint.x = scrollBoundsSize.width/2;
    }
    if (imageViewFrame.size.height <= scrollBoundsSize.height) {
        centerPoint.y = scrollBoundsSize.height/2;
    }

    self.imageView.center = centerPoint;
    
    // 如果缩放率为1，当做未缩放
    if (self.zoomScale == 1) {
        _isZoomed = NO;
    }
    
    // 记录是否缩放过
    if (!_isZoomed) {
        _isZoomed = YES;
    }
}

@end
