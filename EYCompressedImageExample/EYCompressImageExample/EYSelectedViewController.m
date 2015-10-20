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
#define TARGET_DIRECTORY @"targetImages"

#define REQUEST_STRING @"https://api.tinify.com/shrink"

NSString *const EYSelectedViewControllerWillAppearNotification = @"EYSelectedViewControllerWillAppearNotification";
NSString *const EYSelectedViewControllerWillDisappearNotification = @"EYSelectedViewControllerWillDisappearNotification";

@interface EYSelectedViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSArray *_selecetedCellName;
    NSMutableArray *_imageArray;
    NSMutableArray *_imageModelArray;
    NSMutableArray *_imageModelCompleteArray;
    NSMutableArray *_imageModelUncompleteArray;
    NSUInteger _imagesDetailNum;
    NSUInteger _completeNum;
    NSUInteger _uncompleteNum;
    
    UIButton *_btn;
    UILabel *_imageNameLabel;
    UIProgressView *_progressView;
    
    NSString *_userName;
    NSString *_password;
}
@end

@implementation EYSelectedViewController

#pragma mark ViewController life circle

/**
 *  初始化方法
 *  @param  userName    tinify注册的用户名
 *  @param  password    tinify注册后返回的key
 *
 *  @return 返回对象实例
 */
-(instancetype)initWithUserName:(NSString *)userName andPassword:(NSString *)password
{
    self = [super init];
    if(self)
    {
        _userName = userName;
        _password = password;
    }
    return self;
}

/**
 *  每次进入都会重新载入图片数据，更新内容
 *  发送通知来隐藏window显示
 */
- (void)viewWillAppear:(BOOL)animated
{
    [self loadImages];
    [[NSNotificationCenter defaultCenter] postNotificationName:EYSelectedViewControllerWillAppearNotification object:nil];
}

/**
 *  加载navigationController相关配置
 *  加载表示图、按钮和进度条视图
 */
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

/**
 *  加载表示图
 */
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

/**
 *  加载按钮
 */
- (void)loadBtn
{
    _btn = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 44, _tableView.frame.size.width - 20, 44)];
    [_btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_btn setTitle:@"全部压缩" forState:UIControlStateNormal];
    [_btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.view addSubview:_btn];
}

/**
 *  加载进度条
 */
- (void)loadProgressView
{
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height / 2, self.view.frame.size.width - 20, 2)];
    [self.view addSubview:_progressView];

    _imageNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height / 2 + 10, self.view.frame.size.width - 20, 30)];
    [_imageNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_imageNameLabel];
}

/**
 *  加载navigationController配置
 */
- (void)loadNavigationController
{
    [self setTitle:@"选择功能"];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewController:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"沙盒路径" style:UIBarButtonItemStylePlain target:self action:@selector(sandPath:)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

/**
 *  设置请求
 *  这里主要针对tinify接口来设置
 *  向HTTP header中添加Authorization字段 对应为base64(userName:password)
 */
-(void)setRequestBaseInfo:(NSMutableURLRequest *)request
{
    NSString *basicAuthUsername = _userName;
    NSString *basicAuthPassword = _password;
    NSData *authorizationData = [[NSString stringWithFormat:@"%@:%@",basicAuthUsername,basicAuthPassword] dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authorizationStr = [NSString stringWithFormat:@"Basic %@",[authorizationData base64EncodedStringWithOptions:0]];
    NSLog(@"%@",authorizationStr);
    [request setHTTPMethod:@"POST"];
    [request addValue:authorizationStr forHTTPHeaderField:@"Authorization"];
    [request addValue:@"*/*" forHTTPHeaderField:@"Accept"];
}

/**
 *  创建配置Connection进行上传图片请求
 */
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

/**
 *  加载图片信息，图片位于沙盒的Documents/images中，
 *  该函数会遍历images文件夹中的所有文件，只要是png格式图片全都会被加载
 */
- (void)loadImages
{
    _imageArray = [[NSMutableArray alloc] initWithCapacity:0];
    _imageModelArray = [[NSMutableArray alloc] initWithCapacity:0];
    _imageModelCompleteArray = [[NSMutableArray alloc] initWithCapacity:0];
    _imageModelUncompleteArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imagesPath = [NSString stringWithFormat:@"%@/%@",path,DEFAULT_DIRECTORY];
    
    NSError *error;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *contents = [manager contentsOfDirectoryAtPath:imagesPath error:&error];
    if(error != nil)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:@"沙盒中不存在images文件夹" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action];
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

/**
 *  递归加载子文件夹图片
 */
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

/**
 *  获取没个图片model的状态
 *  如果在目标文件夹中已经存在该图片，则为完成
 *  如果在日志文件中存在该图片名，则为失败
 *  如果都不存在则为未处理
 */
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
                    [_imageModelCompleteArray addObject:model];
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
        [_tableView reloadData];
    }
}

/**
 *  获取下载后文件保存目录
 */
-(NSString *)loadDownloadPath
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *downloadPath = [documentPath stringByAppendingPathComponent:TARGET_DIRECTORY];
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:downloadPath])
    {
        [manager createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return downloadPath;
}

/**
 *  执行下载任务，当上传完成后，服务器会在response header中返回下载url
 *  @param  key    标示下载的是那张图片，用于下载后重命名图片
 *  @param  urlStr response中得到的下载路径
 */
-(void)doDownloadTaskWithKey:(NSString *)key urlStr:(NSString *)urlStr
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    NSString *downloadPath = [self loadDownloadPath];
    downloadPath = [downloadPath stringByAppendingPathComponent:key];
        
    [self saveFileWithData:data path:downloadPath key:key];
    _imageNameLabel.text = key;
    [self progressValueChanged];
        }];
    
}

/**
 *  创建下载好的文件
 */
-(void)saveFileWithData:(NSData *)data path:(NSString *)path key:(NSString *)key
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if(![manager fileExistsAtPath:path])
    {
        if([manager createFileAtPath:path contents:data attributes:nil])
        {
            EYImageModel *model = [self getModelByKey:key];
            [_imageModelCompleteArray addObject:model];
            _completeNum++;
            _uncompleteNum--;
            NSLog(@"%@ created",[path lastPathComponent]);
        }
    }
}

/**
 *  保存下载失败图片到日志
 */
-(void)saveUnRequestImage:(NSString *)imgName;
{
    __block NSString *tempName = imgName;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *unRequestImageSavePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"unsaveFile"];
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

/**
 *  从_imageModelArray中，根据key来取得对应model
 */
-(EYImageModel *)getModelByKey:(NSString *)key
{
    EYImageModel *getModel;
    for(EYImageModel *model in _imageModelArray)
    {
        if([model.name isEqualToString:key])
        {
            getModel = model;
        }
    }
    return getModel;
}

#pragma mark UIButton Click Event
/**
 *  批量转换按钮
 */
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
/**
 *  dismissVC 发送通知让window显示
 */
- (void)dismissViewController:(UIBarButtonItem *)item
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:EYSelectedViewControllerWillDisappearNotification object:nil];
    }];
}

/**
 *  获取沙河路径
 */
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
    if(indexPath.row == 0)
    {
        EYImageListTableViewController *imageListTableViewController = [[EYImageListTableViewController alloc] initWithImagesArray:_imageModelArray];
        [self.navigationController pushViewController:imageListTableViewController animated:YES];
    }
    else if (indexPath.row == 1)
    {
        EYImageListTableViewController *imageListTableViewController = [[EYImageListTableViewController alloc] initWithImagesArray:_imageModelCompleteArray];
        [self.navigationController pushViewController:imageListTableViewController animated:YES];
    }
    else if(indexPath.row == 2)
    {
        EYImageListTableViewController *imageListTableViewController = [[EYImageListTableViewController alloc] initWithImagesArray:_imageModelUncompleteArray];
        [self.navigationController pushViewController:imageListTableViewController animated:YES];
    }
}

#pragma mark UIURLConnectionDataDelegate

/**
 *  上传图片回调，返回下载地址
 */
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

/**
 *  安全验证，接口基于HTTPS进行，这里绕过证书验证
 */
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
