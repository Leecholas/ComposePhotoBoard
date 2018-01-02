//
//  ComposePhotoView.h
//  ComposePhotoDemo
//
//  Created by Leecholas on 2017/12/26.
//  Copyright © 2017年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ComposePhotoViewDelegate <NSObject>

- (void)addButtonClicked:(UIButton *)sender; //加号按钮点击

@end


@interface ComposePhotoView : UIView

@property (nonatomic, assign, readonly) NSInteger photoCount; //照片张数，用于计算ComposePhotoView的高度，只读
@property (nonatomic, assign) id<ComposePhotoViewDelegate> delegate;

- (void)addPhoto:(UIImage *)photo; //添加照片
+ (CGFloat)heightForComposePhotoViewWithPhotoCount:(NSInteger)photoCount; //计算ComposePhotoView的高度

@end
