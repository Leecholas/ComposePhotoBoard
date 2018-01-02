//
//  ViewController.m
//  ComposePhotoBoard
//
//  Created by Leecholas on 2018/1/2.
//  Copyright © 2018年 Leecholas. All rights reserved.
//

#import "ViewController.h"
#import "ComposePhotoView.h"

@interface ViewController ()<ComposePhotoViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) ComposePhotoView *photoView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _photoView = [[ComposePhotoView alloc] initWithFrame:CGRectMake(0, 100, kScreenWith, 200)];
    _photoView.delegate = self;
    [self.view addSubview:_photoView];
    
}

#pragma mark - ComposePhotoViewDelegate
- (void)addButtonClicked:(UIButton *)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark -- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [_photoView addPhoto:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
