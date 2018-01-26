//
//  ImageBrowserView.m
//  ComposePhotoBoard
//
//  Created by Leecholas on 2018/1/8.
//  Copyright © 2018年 Leecholas. All rights reserved.
//

#import "ImageBrowserView.h"
#import "PhotoImageView.h"
#import "ImageBrowserViewCell.h"

#define kSpacing 20 //图片间隔
@interface ImageBrowserView ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *pageLabel; //显示图片总数和当前页数

@property (nonatomic, strong) NSArray<UIImage *> *imageArray; //composeBoard中的所有image
@property (nonatomic, strong) NSArray<PhotoImageView *> *imageViewArray; //composeBoard中所有的PhotoImageView
@property (nonatomic, strong) UIImageView *originalView; //初始点击的photoImageView
@property (nonatomic, assign) NSInteger originalIndex; //初始点击的photoImageView所在位置

@property (nonatomic, strong) NSMutableArray<ImageBrowserViewCell *> *cellsArray; //存储imageCell,最多3个
@property (nonatomic, assign) NSInteger currentIndex; //当前浏览图片所在的位置

@end

@implementation ImageBrowserView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor blackColor];
        self.hidden = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)]];
        [self addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandle:)]];
        
        _cellsArray = [NSMutableArray array];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(-kSpacing, 0, kScreenWith + kSpacing, kScreenHeight)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight - 50, kScreenWith, 20)];
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.font = [UIFont systemFontOfSize:16];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_pageLabel];
    }
    return self;
}

- (void)presentWithImageArray:(NSArray<UIImage *> *)imageArray imageViewArray:(NSArray<PhotoImageView *> *)imageViewArray fromImageView:(UIImageView *)originalView fromIndex:(NSInteger)originalIndex completion:(void(^)(void))completion {
    if (!imageArray || imageArray.count == 0) {
        return;
    }
    self.userInteractionEnabled = NO;
    
    _imageArray = imageArray;
    _imageViewArray = imageViewArray;
    _originalView = originalView;
    _originalIndex = originalIndex;
    _currentIndex = originalIndex;
    
    // 设置contentSize并滚动scrollView至指定位置
    _scrollView.contentSize = CGSizeMake(_scrollView.width * _imageArray.count, _scrollView.height);
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.width * _originalIndex, 0, _scrollView.width, _scrollView.height) animated:NO];
    [self scrollViewDidScroll:_scrollView];
    
    // 点击放大图片的temp动画效果图片
    UIImageView *tempImageView = [[UIImageView alloc] init];
    tempImageView.frame = [_originalView convertRect:_originalView.bounds toView:[UIApplication sharedApplication].keyWindow];
    tempImageView.contentMode = UIViewContentModeScaleAspectFill;
    tempImageView.image = _imageArray[_originalIndex];
    [self addSubview:tempImageView];
    
    self.hidden = NO;
    _scrollView.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    // 动画
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        tempImageView.frame = [self frameForZoomInTempImageViewWithImage:_imageArray[_originalIndex]];
    } completion:^(BOOL finished) {
        tempImageView.hidden = YES;
        [tempImageView removeFromSuperview];
        _scrollView.hidden = NO;
        self.userInteractionEnabled = YES;
        completion();
    }];
}

#pragma mark - Action
- (void)dismiss:(UITapGestureRecognizer *)tapGesture {
    self.userInteractionEnabled = NO;
    
    _pageLabel.hidden = YES;
    
    // dismiss动画时隐藏board上的小图片
    PhotoImageView *currentPhotoImageView = _imageViewArray[_currentIndex];
    if (!currentPhotoImageView.hidden) {
        currentPhotoImageView.hidden = YES;
    }
    
    // 隐藏cell上的图片imageView,用temp动画图片代替
    ImageBrowserViewCell *currentCell = [self dequeueReusableCellWithIndex:_currentIndex];
    currentCell.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    
    // temp动画图片
    UIImageView *tempImageView = [[UIImageView alloc] init];
    tempImageView.frame = currentCell.imageView.frame;//[self frameForZoomInTempImageViewWithImage:_imageArray[_currentIndex]];
    tempImageView.image = _imageArray[_currentIndex];
    tempImageView.contentMode = UIViewContentModeScaleAspectFill;
    tempImageView.clipsToBounds = YES;
    [self addSubview:tempImageView];
    
    // 动画
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        tempImageView.frame = [currentPhotoImageView convertRect:currentPhotoImageView.bounds toView:[UIApplication sharedApplication].keyWindow];;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        [self removeFromSuperview];
        currentPhotoImageView.hidden = NO;
    }];
}

- (void)panGestureHandle:(UIPanGestureRecognizer *)panGesture {
    ImageBrowserViewCell *cell = [self dequeueReusableCellWithIndex:_currentIndex];
    // 图片有缩放时,不响应滑动手势
    if (cell.isZoomed) {
        return;
    }
    
    // 滑动时隐藏board上的小图片
    PhotoImageView *currentPhotoImageView = _imageViewArray[_currentIndex];
    if (!currentPhotoImageView.hidden) {
        currentPhotoImageView.hidden = YES;
    }
    
    // 手指在self上的偏移量(center为中心点),向下和向右为正，向上和向左为负
    CGPoint fingerPoint = [panGesture translationInView:self];
    // 手指的移动速度
    CGPoint fingerVelocity = [panGesture velocityInView:self];
    
    // 手势处理
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat percent  = MAX(1 - fabs(fingerPoint.y) / self.height, 0); //比率
            CGFloat scaleRate = MAX(percent, 0.5); //最小缩放0.5
            // 图片随手指的移动而移动
            CGAffineTransform translation = CGAffineTransformMakeTranslation(fingerPoint.x/MAX(percent, 0.6), fingerPoint.y/MAX(percent, 0.6));
            // 图片随手指的移动而缩小
            CGAffineTransform scale = CGAffineTransformMakeScale(scaleRate, scaleRate);
            cell.imageView.transform = CGAffineTransformConcat(translation, scale);
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:{
            // 当手指滑动超过一定距离或者一定速度时,dismiss
            if (fabs(fingerPoint.y) > kScreenHeight/3 || fabs(fingerVelocity.y) > 500) {
                [self dismiss:nil];
            }
            // 否则还原图片
            else {
                [UIView animateWithDuration:0.3 animations:^{
                    cell.imageView.transform = CGAffineTransformIdentity;
                    self.backgroundColor = [UIColor blackColor];
                }];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 计算当前的index(滑过一半宽度时index将会改变)
    NSInteger index = (scrollView.contentOffset.x + scrollView.width/2) / scrollView.width;
    // 当index改变时更改page、更新图片
    if (_currentIndex != index || (_currentIndex == _originalIndex && _pageLabel.text.length == 0)) {
        _currentIndex = index;
        
        for (ImageBrowserViewCell *cell in _cellsArray) {
            // 遍历iamgeCell数组，将其中不符合要求的cell从scrollView移除
            if (cell.superview) {
                // 手指向右滑动(即scrollVeiw向左滑动)超过一半宽度时移除第一张图
                // 手指向左滑动(即scrollView向右滑动)超过一半距离时移除第三张图
                if (cell.x > _scrollView.contentOffset.x + 3*_scrollView.width/2 || cell.right < _scrollView.contentOffset.x - _scrollView.width/2) {
                    [cell removeFromSuperview];
                    cell.index = -1;
                    cell.imageView.image = nil;
                    if (cell.zoomScale != 1) {
                        cell.zoomScale = 1;
                    }
                    if (cell.isZoomed) {
                        cell.isZoomed = NO;
                    }
                }
            }
        }
        
        // 滑动超过一半距离时改变page
        _pageLabel.text = [NSString stringWithFormat:@"%zd/%zd",_currentIndex + 1,_imageArray.count];
        
        // 重新设置左中右三张图片
        for (NSInteger i = _currentIndex - 1; i <= _currentIndex + 1; i ++) {
            if (i >= 0 && i <= _imageArray.count - 1) {
                // 从cellArray取出已有cell
                ImageBrowserViewCell *cell = [self dequeueReusableCellWithIndex:i];
                // 取到cell,找到已经从scrollView移除的cell,刷新图片,重新添加
                if (cell) {
                    if (!cell.superview) {
                        cell.origin = CGPointMake(i*kScreenWith + (i + 1)*kSpacing, 0);
                        cell.index = i;
                        cell.imageView.image = _imageArray[i];
                        cell.imageView.frame = [self frameForZoomInTempImageViewWithImage:cell.imageView.image];
                        cell.contentSize = cell.imageView.size;
                        [_scrollView addSubview:cell];
                    }
                }
                // 没取到cell,重新创建cell
                else {
                    cell = [[ImageBrowserViewCell alloc] init];
                    cell.origin = CGPointMake(i*kScreenWith + (i + 1)*kSpacing, 0);
                    cell.index = i;
                    cell.isZoomed = NO;
                    cell.imageView.image = _imageArray[i];
                    cell.imageView.frame = [self frameForZoomInTempImageViewWithImage:cell.imageView.image];
                    cell.contentSize = cell.imageView.size;
                    [_cellsArray addObject:cell];
                    [_scrollView addSubview:cell];
                }
            }
        }
    }
    
    // 在滑到整页时调用,如果上一页有图片缩放,还原缩放
    if (scrollView.contentOffset.x == _currentIndex * scrollView.width) {
        // 遍历左中右三张图片
        for (NSInteger i = _currentIndex - 1; i <= _currentIndex + 1; i ++) {
            if (i >= 0 && i <= _imageArray.count - 1) {
                ImageBrowserViewCell *cell = [self dequeueReusableCellWithIndex:i];
                // 如果图片有缩放,并且确定滑过了这一页
                if (cell.zoomScale != 1 && i != _currentIndex) {
                    cell.zoomScale = 1;
                }
                if (cell.isZoomed) {
                    cell.isZoomed = NO;
                }
            }
        }
    }
}

#pragma mark - Private
// 重用cellArray中的cell
- (ImageBrowserViewCell *)dequeueReusableCellWithIndex:(NSInteger)index {
    for (ImageBrowserViewCell *cell in _cellsArray) {
        if (cell.index == index) {
            return cell;
        }
    }
    for (ImageBrowserViewCell *cell in _cellsArray) {
        if (!cell.superview) {
            return cell;
        }
    }
    return nil;
}

// 动画效果图片放大后的实际frame
- (CGRect)frameForZoomInTempImageViewWithImage:(UIImage *)image {
    
    CGFloat iWidth = image.size.width;
    CGFloat iHeight = image.size.height;
    
    //若图片宽度比高度长,按照图片宽高比计算实际放大后tempImageView的高度
    if (iWidth > iHeight) {
        CGFloat height = (kScreenWith * iHeight) / iWidth;
        return CGRectMake(0, (kScreenHeight - height)/2, kScreenWith, height);
    }
    // 若图片宽度比图片高度短或者相等,则tempImageView放大后取边长为屏幕宽度的正方形(这样实际图片在tempImageView上是显示不全的,但是由于UIViewContentModeScaleAspectFill的原因,会将图片补全)
    else {
        return CGRectMake(0, (kScreenHeight - kScreenWith)/2, kScreenWith, kScreenWith);
    }
}

@end
