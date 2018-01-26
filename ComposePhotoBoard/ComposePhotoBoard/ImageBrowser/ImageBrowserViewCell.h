//
//  ImageBrowserViewCell.h
//  ComposePhotoBoard
//
//  Created by Leecholas on 2018/1/19.
//  Copyright © 2018年 Leecholas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageBrowserViewCell : UIScrollView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) NSInteger index; //记录浏览图片在所有图片中的位置
@property (nonatomic, assign) BOOL isZoomed; //记录时候缩放过

@end
