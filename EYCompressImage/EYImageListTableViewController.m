//
//  EYImageListTableViewController.m
//  EYCompressImageExample
//
//  Created by elvain_yang on 15/10/18.
//  Copyright (c) 2015年 elvain_yang. All rights reserved.
//

#import "EYImageListTableViewController.h"
#import "EYImageDetailViewController.h"

@interface EYImageListTableViewController ()
{
    NSMutableArray *_modelArray;
}
@end

@implementation EYImageListTableViewController

-(id)initWithImagesArray:(NSMutableArray *)modelArray
{
    self = [super init];
    if(self)
    {
        _modelArray = modelArray;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"图片列表";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_modelArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"reuseableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [[_modelArray objectAtIndex:indexPath.row] name];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EYImageDetailViewController *imageDetailView = [[EYImageDetailViewController alloc] initWithImageModel:[_modelArray objectAtIndex:indexPath.row]];

    [self.navigationController pushViewController:imageDetailView animated:YES];
}

@end
