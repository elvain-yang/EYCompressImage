//
//  EYCompressImage.h
//  EYCompressImageExample
//
//  Created by elvain_yang on 15/10/18.
//  Copyright (c) 2015年 elvain_yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EYCompressImage : NSObject

/**
 *  本类为控件入口，控件是基于UIWindow设计，所以使用时需要该对象的所有类对该对象保持引用。
 */

-(instancetype)initWithBaseViewController:(UIViewController *)viewController userName:(NSString *)userName password:(NSString *)password;

@end
