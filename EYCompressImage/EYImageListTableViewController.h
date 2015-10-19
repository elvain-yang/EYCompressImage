//
//  EYImageListTableViewController.h
//  EYCompressImageExample
//
//  Created by elvain_yang on 15/10/18.
//  Copyright (c) 2015年 elvain_yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EYImageListTableViewController : UITableViewController

/**
 *  图片列表视图根据传入Model显示
 */

-(id)initWithImagesArray:(NSMutableArray *)modelArray;

@end
