//
//  EYSelectedViewController.m
//  EYCompressImageExample
//
//  Created by elvain_yang on 15/10/18.
//  Copyright (c) 2015年 elvain_yang. All rights reserved.
//

#import "EYSelectedViewController.h"
#import "EYImageListTableViewController.h"
#import "EYImageModel.h"

#define DEFAULT_DIRECTORY @"images"
#define TARGET_DIRECTORY @"target_images"

#define REQUEST_STRING @"https://api.tinify.com/shrink"
#define BASIC_AUTH_USERNAME @"iBlock"
#define BASIC_AUTH_PASSWORD @"CyQKq6wNovgACDimtmC_6Iqdx4wfDYXa"

NSString *const EYSelectedViewControllerWillAppearNotification = @"EYSelectedViewControllerWillAppearNotification";
NSString *const EYSelectedViewControllerWillDisappearNotification = @"EYSelectedViewControllerWillDisappearNotification";

@interface EYSelectedViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSArray *_selecetedCellName;
    NSMutableArray *_imageArray;
    NSMutableArray *_imageModelArray;
    NSUInteger _imagesDetailNum;
    NSUInteger _completeNum;
    NSUInteger _uncompleteNum;
    
    UIButton *_btn;
    UILabel *_imageNameLabel;
    UIProgressView *_progressView;
}
@end

@implementation EYSelectedViewController

#pragma mark ViewController life circle

- (void)viewWillAppear:(BOOL)animated
{
    [self loadImages];
    [[NSNotificationCenter defaultCenter] postNotificationName:EYSelectedViewControllerWillAppearNotification object:nil];
}

- (void)viewDidLoad
{
    [self loadNavigationController];
    [self loadTableView];
    [self loadBtn];
    [self loadProgressView];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadTableView
{
    _imagesDetailNum = 0;
    _completeNum = 0;
    _uncompleteNum = 0;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 200) style:UITableViewStylePlain];
    _tableView.scrollEnabled = NO;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    
    
    _selecetedCellName = @[@"全部图片",@"已压缩",@"未压缩"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)loadBtn
{
    _btn = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 44, _tableView.frame.size.width - 20, 44)];
    [_btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_btn setTitle:@"全部压缩" forState:UIControlStateNormal];
    [_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.view addSubview:_btn];
}

- (void)loadProgressView
{
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height / 2, self.view.frame.size.width - 20, 2)];
    [self.view addSubview:_progressView];

    _imageNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height / 2 + 10, self.view.frame.size.width - 20, 30)];
    [_imageNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_imageNameLabel];
}


- (void)loadNavigationController
{
    [self setTitle:@"选择功能"];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewController:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"沙盒路径" style:UIBarButtonItemStylePlain target:self action:@selector(sandPath:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

-(void)setRequestBaseInfo:(NSMutableURLRequest *)request
{
    NSString *basicAuthUsername = BASIC_AUTH_USERNAME;
    NSString *basicAuthPassword = BASIC_AUTH_PASSWORD;
    NSData *authorizationData = [[NSString stringWithFormat:@"%@:%@",basicAuthUsername,basicAuthPassword] dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authorizationStr = [NSString stringWithFormat:@"Basic %@",[authorizationData base64EncodedStringWithOptions:0]];
    NSLog(@"%@",authorizationStr);
    [request setHTTPMethod:@"POST"];
    [request addValue:authorizationStr forHTTPHeaderField:@"Authorization"];
    [request addValue:@"*/*" forHTTPHeaderField:@"Accept"];
}

-(void)onRequestConnection:(NSMutableURLRequest *)request
{
    NSURLConnection *connection;

    for(EYImageModel *model in _imageModelArray)
    {
        NSMutableURLRequest *forRequest = [request mutableCopy];
        NSString *imgName = model.name;
        [forRequest addValue:imgName forHTTPHeaderField:@"img_name"];
        NSString *filePath = model.path;
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        UIImage *image = [UIImage imageWithData:data];
        NSLog(@"%@",image);
        [forRequest setHTTPBodyStream:[[NSInputStream alloc] initWithData:data]];
        connection = [[NSURLConnection alloc] initWithRequest:forRequest delegate:self];
        [connection start];
    }
}

- (void)loadImages
{
    _imageArray = [[NSMutableArray alloc] initWithCapacity:0];
    _imageModelArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imagesPath = [NSString stringWithFormat:@"%@/%@",path,DEFAULT_DIRECTORY];
    
    NSError *error;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *contents = [manager contentsOfDirectoryAtPath:imagesPath error:&error];
    if(error != nil)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:@"沙盒中不存在images文件夹" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if([contents count] > 0)
    {
        for(NSString *path in contents)
        {
            BOOL isDir = NO;
            NSString *ext = [path pathExtension];
            [manager fileExistsAtPath:path isDirectory:&isDir];
            if(isDir || [ext isEqualToString:@"xcassets"])
            {
                NSString *directoryPath = [NSString stringWithFormat:@"%@/%@",imagesPath,path];
                [self addImagesFormPath:directoryPath];
            }
            else if([ext isEqualToString:@"png"])
            {
                NSMutableDictionary *imageDic = [[NSMutableDictionary alloc] init];
                [imageDic setObject:path forKey:@"name"];
                [imageDic setObject:[NSString stringWithFormat:@"%@/%@",imagesPath,path] forKey:@"path"];
                [imageDic setObject:@(EYImageModelStatusDefault) forKey:@"status"];
                [_imageArray addObject:imageDic];
            }
        }
    }
    _imagesDetailNum = [_imageArray count];
    _imageModelArray = [[EYImageModel modelArrayWithDicArray:_imageArray] mutableCopy];
    [self getStatus];
    [_imageNameLabel setText:@"点击按钮开始"];
    [_tableView reloadData];
}

- (void)addImagesFormPath:(NSString *)directoryPath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *contents = [manager contentsOfDirectoryAtPath:directoryPath error:nil];
    if([contents count] > 0)
    {
        for(NSString *path in contents)
        {
            BOOL isDir;
            NSString *ext = [path pathExtension];
            [manager fileExistsAtPath:path isDirectory:&isDir];
            if(isDir || [ext isEqualToString:@"imageset"])
            {
                NSString *nextDirectoryPath = [NSString stringWithFormat:@"%@/%@",directoryPath,path];
                [self addImagesFormPath:nextDirectoryPath];
            }
            else if([ext isEqualToString:@"png"])
            {
                NSMutableDictionary *imageDic = [[NSMutableDictionary alloc] init];
                [imageDic setObject:path forKey:@"name"];
                [imageDic setObject:[NSString stringWithFormat:@"%@/%@",directoryPath,path] forKey:@"path"];
                [imageDic setObject:@(EYImageModelStatusDefault) forKey:@"status"];
                [_imageArray addObject:imageDic];
            }
        }
    }
}

- (void)getStatus
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *targetImages = [NSString stringWithFormat:@"%@/%@",path,TARGET_DIRECTORY];
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:targetImages])
    {
        NSError *error;
        [manager createDirectoryAtPath:targetImages withIntermediateDirectories:NO attributes:nil error:&error];
        if(error)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:@"路径有误" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else
    {
        NSArray *contents = [manager contentsOfDirectoryAtPath:targetImages error:nil];
        for(NSString *image in contents)
        {
            for(EYImageModel *model in _imageModelArray)
            {
                if([image isEqualToString:model.name])
                {
                    model.status = EYImageModelStatusComplate;
                    _completeNum++;
                }
            }
        }
    }
    _uncompleteNum = _imagesDetailNum - _completeNum;
}

-(void)progressValueChanged
{
    double additionValue = 0.5 / [_imageModelArray count];
    [_progressView setProgress:[_progressView progress] + additionValue animated:YES];
    if([_progressView progress] >= 0.9999999 && [_progressView progress] <= 1.000001)
    {
        [_btn setEnabled:YES];
    }
}

-(NSString *)loadDownloadPath
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *downloadPath = [documentPath stringByAppendingPathComponent:@"targetImages"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:downloadPath])
    {
        [manager createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return downloadPath;
}

-(void)doDownloadTaskWithKey:(NSString *)key urlStr:(NSString *)urlStr
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    NSString *downloadPath = [self loadDownloadPath];
    downloadPath = [downloadPath stringByAppendingPathComponent:key];
        
    [self saveFileWithData:data path:downloadPath];
    _imageNameLabel.text = key;
    [self progressValueChanged];
        }];
    
}

-(void)saveFileWithData:(NSData *)data path:(NSString *)path
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:path])
    {
        if([manager createFileAtPath:path contents:data attributes:nil])
        {
            NSLog(@"%@ created",[path lastPathComponent]);
        }
    }
}

-(void)saveUnRequestImage:(NSString *)imgName;
{
    __block NSString *tempName = imgName;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *unRequestImageSavePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"unsaveFile"];
    if(![manager fileExistsAtPath:unRequestImageSavePath])
    {
        [manager createFileAtPath:unRequestImageSavePath contents:nil attributes:nil];
    }
    dispatch_barrier_async(dispatch_get_main_queue(), ^{
        NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:unRequestImageSavePath];
        [file seekToEndOfFile];
        tempName = [tempName stringByAppendingString:@"\n"];
        [file writeData:[imgName dataUsingEncoding:NSASCIIStringEncoding]];
        [file closeFile];
    });
}

#pragma mark UIButton Click Event
- (void)clickBtn:(UIButton *)btn
{
    NSURL *url = [NSURL URLWithString:REQUEST_STRING];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [btn setEnabled:NO];
    [_imageNameLabel setText:@"上传中..."];
    [self setRequestBaseInfo:request];
    [self onRequestConnection:request];
}

#pragma mark UIBarButtonItem ClickEvent
- (void)dismissViewController:(UIBarButtonItem *)item
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:EYSelectedViewControllerWillDisappearNotification object:nil];
    }];
}

- (void)sandPath:(UIBarButtonItem *)item
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"sandbox path:%@",path);
}

#pragma mark UITableViewDelegateAndDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"reuseableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier] ;
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.textLabel.text = [_selecetedCellName objectAtIndex:indexPath.row];
    if(indexPath.row == 0)
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"全部：%ld",_imagesDetailNum];
    }
    else if(indexPath.row == 1)
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"已压缩：%ld",_completeNum];
    }
    else if(indexPath.row == 2)
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"未压缩：%ld",_uncompleteNum];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_selecetedCellName count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EYImageListTableViewController *imageListTableViewController = [[EYImageListTableViewController alloc] initWithImagesArray:_imageModelArray];
    [self.navigationController pushViewController:imageListTableViewController animated:YES];
}

#pragma mark UIURLConnectionDataDelegate

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSURLRequest *request = connection.originalRequest;
    NSString *key = [request valueForHTTPHeaderField:@"img_name"];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *responseHeaderDic = [httpResponse allHeaderFields];
    [self progressValueChanged];
    if(![responseHeaderDic objectForKey:@"Location"])
    {
        [self saveUnRequestImage:key];
    }
    [self doDownloadTaskWithKey:key urlStr:[responseHeaderDic objectForKey:@"Location"]];
    
}

#pragma mark UIURLConnectionDelegate

-(BOOL)connection:(NSURLConnection*)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace*)protectionSpace
{
    NSLog(@"%@",protectionSpace.authenticationMethod);
    return[protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

-(void)connection:(NSURLConnection*)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge
{
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end
