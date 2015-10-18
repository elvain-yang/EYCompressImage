//
//  EYImageModel.m
//  EYCompressImageExample
//
//  Created by elvain_yang on 15/10/18.
//  Copyright (c) 2015年 elvain_yang. All rights reserved.
//

#import "EYImageModel.h"

@implementation EYImageModel

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    if(self)
    {
        _name = [dic objectForKey:@"name"];
        _path = [dic objectForKey:@"path"];
        _status = [[dic objectForKey:@"status"] integerValue];
    }
    return self;
}

+(NSArray *)modelArrayWithDicArray:(NSArray *)array
{
    NSMutableArray *modelArray = [[NSMutableArray alloc] init];
    for(NSDictionary *dic in array)
    {
        EYImageModel *model = [[EYImageModel alloc] initWithDictionary:dic];
        [modelArray addObject:model];
    }
    return modelArray;
}

@end
