//
//  ComposePhotoView.m
//  ComposePhotoDemo
//
//  Created by Leecholas on 2017/12/26.
//  Copyright © 2017年 Lee. All rights reserved.
//

#import "ComposePhotoView.h"
#import "PhotoImageView.h"
#import "ImageBrowserView.h"

static NSInteger columnCount = 4; //列数，每行有几张照片
static CGFloat photoWH = 84; //photoView的宽高
static CGFloat photoMargin = 10; //左右边距

@interface ComposePhotoView ()<PhotoImageViewDelegate>

@property (nonatomic, strong) NSMutableArray<UIImage *> *photos; //照片数
@property (nonatomic, strong) NSMutableArray<PhotoImageView *> *photoImageViewArray;
@property (nonatomic, strong) UIButton *addButton;

@end

@implementation ComposePhotoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setBackgroundColor:[UIColor whiteColor]];
        [_addButton setTitle:@"+" forState:UIControlStateNormal];
        [_addButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //        [_addButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_addButton];
        
        _photos = [NSMutableArray array];
        _photoImageViewArray = [NSMutableArray array];
        [self setupSubViews];
        self.height = [ComposePhotoView heightForComposePhotoViewWithPhotoCount:_photos.count];
    }
    return self;
}

// 根据照片的多少布局（可以多选的情况）
- (void)setupSubViews {
    if (self.subviews.count > 0) {
        for (UIView *subView in self.subviews) {
            if ([subView isKindOfClass:[PhotoImageView class]]) {
                [subView removeFromSuperview];
            }
        }
    }
    
    if (_photoImageViewArray.count > 0) {
        [_photoImageViewArray removeAllObjects];
    }
    
    // 有照片就重新布局
    if (_photos.count > 0) {
        NSInteger remainderColumnCount = _photos.count % columnCount; //照片布局后最后一行的张数
        NSInteger rowCount = _photos.count / columnCount; //照片布局后的行数
        
        CGFloat photoSpacing = (self.width - (photoWH * columnCount) - 2*photoMargin) / (columnCount - 1); //照片之间的间距
        CGFloat addButtonX = photoMargin + (photoWH + photoSpacing) * remainderColumnCount; //加号按钮的X
        CGFloat addButtonY = photoMargin + (photoWH + photoSpacing) * rowCount; //加号按钮的Y
        _addButton.frame = CGRectMake(addButtonX, addButtonY, photoWH, photoWH);
        
        for (NSInteger i = 0; i < _photos.count; i ++) {
            //照片所在的行
            NSInteger photoRow = i / columnCount;
            //照片所在的列
            NSInteger photoColumn = i % columnCount;
            
            PhotoImageView *photoView = [[PhotoImageView alloc] initWithFrame:CGRectMake(photoMargin + (photoWH + photoSpacing) * photoColumn, photoMargin + (photoWH + photoSpacing) * photoRow, photoWH, photoWH)];
            photoView.image = _photos[i];
            photoView.delegate = self;
            photoView.tag = i;
            photoView.userInteractionEnabled = YES; //不开交互照片上的删除按钮无法点击
            [self addSubview:photoView];
            [_photoImageViewArray addObject:photoView];
        }
    }
    // 没有照片就只布局加号按钮
    else {
        _addButton.frame = CGRectMake(photoMargin, photoMargin, photoWH, photoWH);
    }
}

// 添加照片
- (void)addPhoto:(UIImage *)photo {
    [_photos addObject:photo];
    [self setupSubViews];
    self.height = [ComposePhotoView heightForComposePhotoViewWithPhotoCount:_photos.count];
}

// 计算ComposePhotoView的高度
+ (CGFloat)heightForComposePhotoViewWithPhotoCount:(NSInteger)photoCount {
    NSInteger row = photoCount/columnCount + 1;
    return row * photoWH + (row - 1) * photoMargin + 2 * photoMargin;
}

// 照片张数，用于计算ComposePhotoView的高度
- (NSInteger)photoCount {
    return _photos.count;
}

#pragma mark - Action
- (void)addButtonAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addButtonClicked:)]) {
        [self.delegate addButtonClicked:sender];
    }
}

#pragma mark - PhotoImageViewDelegate
- (void)photoImageDeleteAction:(PhotoImageView *)photoImageView {
    [_photos removeObjectAtIndex:photoImageView.tag];
    [self setupSubViews];
    self.height = [ComposePhotoView heightForComposePhotoViewWithPhotoCount:_photos.count];
}

- (void)photoImageTapAction:(PhotoImageView *)photoImageView {
    photoImageView.userInteractionEnabled = NO;
    ImageBrowserView *browserView = [[ImageBrowserView alloc] init];
    [browserView presentWithImageArray:_photos imageViewArray:_photoImageViewArray fromImageView:photoImageView fromIndex:photoImageView.tag completion:^{
        photoImageView.userInteractionEnabled = YES;
    }];
}

@end
