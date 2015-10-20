//
//  ViewController.m
//  test
//
//  Created by elvain_yang on 15/9/23.
//  Copyright (c) 2015年 elvain_yang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    EYCompressImage *_compressImage;
}
@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _compressImage = [[EYCompressImage alloc] initWithBaseViewController:self userName:@"guoyang" password:@"7DN1nBxKA0ZYObMFLDvIaA8Srpa2Ikmy"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
