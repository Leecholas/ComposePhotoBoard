//
//  PhotoImageView.m
//  ComposePhotoDemo
//
//  Created by Leecholas on 2017/12/26.
//  Copyright © 2017年 Lee. All rights reserved.
//

#import "PhotoImageView.h"
static CGFloat deleteBtnWH = 23; //删除按钮的宽高

@interface PhotoImageView ()

@property (nonatomic, strong) UIButton *deleteButton; //删除按钮

@end

@implementation PhotoImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(self.width - deleteBtnWH - 3, 3, deleteBtnWH, deleteBtnWH);
        //        [_deleteButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_deleteButton setBackgroundColor:[UIColor redColor]];
        [_deleteButton setTitle:@"×" forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
    }
    return self;
}

#pragma mark - Action
- (void)deleteButtonAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deletePhotoImage:)]) {
        [self.delegate deletePhotoImage:self];
    }
}

@end
