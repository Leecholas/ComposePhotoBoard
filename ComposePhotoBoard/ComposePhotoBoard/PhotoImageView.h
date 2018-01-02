//
//  PhotoImageView.h
//  ComposePhotoDemo
//
//  Created by Leecholas on 2017/12/26.
//  Copyright © 2017年 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PhotoImageView;

@protocol PhotoImageViewDelegate <NSObject>
- (void)deletePhotoImage:(PhotoImageView *)photoImageView;
@end

@interface PhotoImageView : UIImageView

@property (nonatomic, assign) id<PhotoImageViewDelegate> delegate;

@end
