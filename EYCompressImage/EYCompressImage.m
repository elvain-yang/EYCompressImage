//
//  EYCompressImage.m
//  EYCompressImageExample
//
//  Created by elvain_yang on 15/10/18.
//  Copyright (c) 2015年 elvain_yang. All rights reserved.
//

#import "EYCompressImage.h"
#import "EYSelectedViewController.h"

#define EYCOMPRESSIMAGE_WIDTH 60
#define EYCOMPRESSIMAGE_HEIGHT 60

@interface EYCompressImage()
{
    UIWindow *_window;
    UIButton *_btn;
    UIViewController *_baseViewController;
    
    EYSelectedViewController *_selectedViewController;
}
@end

@implementation EYCompressImage

-(instancetype)initWithBaseViewController:(UIViewController *)viewController
{
    self = [super init];
    if(self)
    {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        _window = [[UIWindow alloc] initWithFrame:CGRectMake(screenBounds.size.width - EYCOMPRESSIMAGE_WIDTH, screenBounds.size.height - EYCOMPRESSIMAGE_HEIGHT - 66, EYCOMPRESSIMAGE_WIDTH, EYCOMPRESSIMAGE_HEIGHT)];
        _window.windowLevel = UIWindowLevelAlert;
        
        _window.layer.cornerRadius = EYCOMPRESSIMAGE_HEIGHT / 2;
        _window.backgroundColor = [UIColor lightGrayColor];
        
        [_window makeKeyAndVisible];
        
        _btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, EYCOMPRESSIMAGE_WIDTH, EYCOMPRESSIMAGE_HEIGHT)];
        _btn.layer.cornerRadius = EYCOMPRESSIMAGE_HEIGHT / 2;
        [_btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_btn setTitle:@"压缩图片" forState:UIControlStateNormal];
        [_btn.titleLabel setFont:[UIFont fontWithName:@"Arial" size:13]];
        [_btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        
        _baseViewController = viewController;
        
        [_window addSubview:_btn];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedViewControllerStatusNotification:) name:EYSelectedViewControllerWillAppearNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedViewControllerStatusNotification:) name:EYSelectedViewControllerWillDisappearNotification object:nil];
    }
    return self;
}

-(void)btnClick:(id)sender
{
    _selectedViewController = [[EYSelectedViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_selectedViewController];
    [_baseViewController presentViewController:navigationController animated:YES completion:nil];
    _window.hidden = YES;
}

-(void)selectedViewControllerStatusNotification:(NSNotification *)notification
{
    if([notification.name isEqualToString:EYSelectedViewControllerWillAppearNotification])
    {
        _window.hidden = YES;
    }
    else if([notification.name isEqualToString:EYSelectedViewControllerWillDisappearNotification])
    {
        _window.hidden = NO;
    }
}

@end
