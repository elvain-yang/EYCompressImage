//
//  EYImageDetailViewController.h
//  EYCompressImageExample
//
//  Created by guoyang on 15/10/18.
//  Copyright (c) 2015年 elvain_yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EYImageModel.h"
@interface EYImageDetailViewController : UIViewController

/**
 *  图片显示视图，可以查看具体为哪一张图片
 */

-(instancetype)initWithImageModel:(EYImageModel *)model;

@end
