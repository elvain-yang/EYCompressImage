//
//  ViewController.m
//  test
//
//  Created by elvain_yang on 15/9/23.
//  Copyright (c) 2015年 elvain_yang. All rights reserved.
//

#import "ViewController.h"

#define DIRECTORY_PATH @"images"
#define REQUEST_URL @"https://api.tinify.com/shrink"
#define BASIC_AUTH_USERNAME @"iBlock"
#define BASIC_AUTH_PASSWORD @"CyQKq6wNovgACDimtmC_6Iqdx4wfDYXa"

@interface ViewController ()
{
    NSMutableDictionary *_imageDic;
    NSArray *_imageArray;
    int count;
    
    EYCompressImage *_compressImage;
}
@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    count = 0;
    NSLog(@"%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]);
    NSLog(@"%@",[[NSBundle mainBundle] resourcePath]);
    
    _imageArray = [[NSArray alloc] init];
    NSURL *url = [NSURL URLWithString:@"http://10.58.38.85:8080/TestDemo/api/guest/getactiveimg"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [self setRequestBaseInfo:request];
    [self onRequestConnection:request];
    
    
    _compressImage = [[EYCompressImage alloc] initWithBaseViewController:self];
}

-(NSArray *)ImageNameArrayWithDirectoryPath:(NSString *)directoryPath
{
    NSString *resourcePath = [self loadResourcePath];
    NSFileManager *manager = [[NSFileManager alloc] init];
    _imageArray = [manager subpathsOfDirectoryAtPath:resourcePath error:nil];
    _imageDic = [[NSMutableDictionary alloc] initWithObjects:_imageArray forKeys:_imageArray];
    NSLog(@"%@",_imageArray);
    return _imageArray;
}

-(NSString *)loadResourcePath
{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingPathComponent:DIRECTORY_PATH];
    return resourcePath;
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
    NSArray *nameArray = [self ImageNameArrayWithDirectoryPath:DIRECTORY_PATH];
    NSString *resourcePath = [self loadResourcePath];
    
    NSURLConnection *connection;
    
    //NSString *path = [nameArray objectAtIndex:0];
    for(NSString *path in nameArray)
    {
        NSMutableURLRequest *forRequest = [request mutableCopy];
        NSString *imgName =[path lastPathComponent];
        [forRequest addValue:imgName forHTTPHeaderField:@"img_name"];
        NSString *filePath = [resourcePath stringByAppendingPathComponent:path];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        UIImage *image = [UIImage imageWithData:data];
        NSLog(@"%@",image);
        [forRequest setHTTPBodyStream:[[NSInputStream alloc] initWithData:data]];
        connection = [[NSURLConnection alloc] initWithRequest:forRequest delegate:self];
        [connection start];
    }
}

-(void)progressValueChanged
{
    double additionValue = 1.0 / [_imageArray count];
    [_progress setProgress:[_progress progress] + additionValue animated:YES];
    if([_progress progress] >= 0.9999999 && [_progress progress] <= 1.000001)
    {
        [self doDownloadTask];
    }
}

-(NSString *)loadDownloadPath
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *downloadPath = [documentPath stringByAppendingPathComponent:@"images"];
    return downloadPath;
}

-(void)doDownloadTask
{
    for(NSString *key in _imageDic)
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[_imageDic objectForKey:key]]];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSString *downloadPath = [self loadDownloadPath];
            downloadPath = [downloadPath stringByAppendingPathComponent:key];
            
            [self saveFileWithData:data path:downloadPath];
        }];
    }
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

#pragma mark UIURLConnectionDataDelegate

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSURLRequest *request = connection.originalRequest;
    NSString *key = [request valueForHTTPHeaderField:@"img_name"];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *responseHeaderDic = [httpResponse allHeaderFields];
    if(![responseHeaderDic objectForKey:@"Location"])
    {
        [self saveUnRequestImage:key];
    }
    else
    {
        [_imageDic setObject:[responseHeaderDic objectForKey:@"Location"] forKey:key];
    }
    [self progressValueChanged];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",s);
    count++;
    NSLog(@"%d",count);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
