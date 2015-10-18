//
//  EYSelectedViewController.h
//  EYCompressImageExample
//
//  Created by elvain_yang on 15/10/18.
//  Copyright (c) 2015年 elvain_yang. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const EYSelectedViewControllerWillAppearNotification;
extern NSString *const EYSelectedViewControllerWillDisappearNotification;

@interface EYSelectedViewController : UIViewController<NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@end
