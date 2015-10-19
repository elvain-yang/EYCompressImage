//
//  EYImageDetailViewController.m
//  EYCompressImageExample
//
//  Created by guoyang on 15/10/18.
//  Copyright (c) 2015年 elvain_yang. All rights reserved.
//

#import "EYImageDetailViewController.h"

@interface EYImageDetailViewController ()
{
    UIImage *_image;
}
@end

@implementation EYImageDetailViewController


-(instancetype)initWithImageModel:(EYImageModel *)model
{
    self = [super init];
    if(self)
    {
        _image = [UIImage imageWithContentsOfFile:model.path];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"图片详情";
}

/**
 *  处理图片高度、宽度超出屏幕逻辑，如果高度超出按高度为屏高的比例来缩放宽度，对宽度同理
 */
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGSize imageSize = _image.size;
    CGRect rect = [[UIScreen mainScreen] bounds];
    if(imageSize.width > rect.size.width)
    {
        CGFloat rate = rect.size.width / imageSize.width;
        imageSize = CGSizeMake(imageSize.width * rate,imageSize.height *rate);
    }
    else if(imageSize.height > rect.size.height - 64)
    {
        CGFloat rate = (rect.size.height - 64) / imageSize.height;
        imageSize = CGSizeMake(imageSize.width * rate,imageSize.height *rate);
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:_image];
    imageView.frame = CGRectMake((rect.size.width - imageSize.width)/2,64 + (rect.size.height - imageSize.height)/2, imageSize.width, imageSize.height);
    [self.view addSubview:imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
