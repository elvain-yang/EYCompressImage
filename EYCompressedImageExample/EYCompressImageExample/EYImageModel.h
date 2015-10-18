//
//  EYImageModel.h
//  EYCompressImageExample
//
//  Created by elvain_yang on 15/10/18.
//  Copyright (c) 2015年 elvain_yang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, EYImageModelStatus)
{
    EYImageModelStatusDefault,
    EYImageModelStatusError,
    EYImageModelStatusComplate
};

@interface EYImageModel : NSObject

@property (nonatomic, copy)NSString *path;
@property (nonatomic, copy)NSString *name;

@property (nonatomic, assign)EYImageModelStatus status;

-(instancetype)initWithDictionary:(NSDictionary *)dic;
+(NSArray *)modelArrayWithDicArray:(NSArray *)array;

@end
