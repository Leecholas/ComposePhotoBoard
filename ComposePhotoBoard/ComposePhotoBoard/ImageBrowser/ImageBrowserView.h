//
//  ImageBrowserView.h
//  ComposePhotoBoard
//
//  Created by Leecholas on 2018/1/8.
//  Copyright © 2018年 Leecholas. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PhotoImageView;

@interface ImageBrowserView : UIView

/**
 present图片浏览器

 @param imageArray composeBoard中的所有image
 @param imageViewArray composeBoard中所有的PhotoImageView
 @param originalView 初始点击的photoImageView
 @param originalIndex 初始点击的photoImageView所在位置
 */
- (void)presentWithImageArray:(NSArray<UIImage *> *)imageArray imageViewArray:(NSArray<PhotoImageView *> *)imageViewArray fromImageView:(UIImageView *)originalView fromIndex:(NSInteger)originalIndex completion:(void(^)(void))completion;

@end
