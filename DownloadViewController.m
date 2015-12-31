//
//  DownloadViewController.m
//  allenPlayVideo
//
//  Created by allen_hsu on 2015/12/28.
//  Copyright © 2015年 allen_hsu. All rights reserved.
//

#import "DownloadViewController.h"
#import "DaiYoutubeParser.h"
#import "DaiYoutubeParser.h"
#import "UIView+AnimationExtensions.h"

@interface DownloadViewController () <NSURLSessionDownloadDelegate>

@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;

@property (strong, nonatomic) NSString *youtubeVideoID;
@property (strong, nonatomic) NSString *videoTitle;
@end

@implementation DownloadViewController

#pragma mark - UIButton Action

- (IBAction)downLoadButtonAction:(id)sender {
    [self downLoadVideo];
}

- (IBAction)loadWebPage:(id)sender {
    [self setupWebView];
}

#pragma mark - UIWebView Deleage

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // 第一種
    // https://www.youtube.com/watch?v=ce_MeFj_BWE
    // webView 回的格式為
    // https://m.youtube.com/watch?v=ce_MeFj_BWE

    // 第二種
    // http://youtu.be/ce_MeFj_BWE
    // webView 回的格式為
    // https://m.youtube.com/watch?feature=youtu.be&v=ce_MeFj_BWE

    // 第三種
    // https://m.youtube.com/watch?v=ce_MeFj_BWE
    // webView 回的格式為
    // https://m.youtube.com/watch?v=ce_MeFj_BWE

    NSString *urlString = webView.request.URL.absoluteString;
    NSArray *splitUsingEqual = [urlString componentsSeparatedByString:@"="];
    NSLog(@"urlString = %@",urlString);
    self.youtubeVideoID = [splitUsingEqual lastObject];
}

#pragma mark - instance private method

- (void)downLoadVideo {
    CGSize videoSize = self.webView.frame.size;
    [DaiYoutubeParser parse:self.youtubeVideoID screenSize:videoSize videoQuality:DaiYoutubeParserQualityLarge completion: ^(DaiYoutubeParserStatus status, NSString *url, NSString *videoTitle, NSNumber *videoDuration) {
         NSURL *videoUrl = [NSURL URLWithString:url];
         if (status) {
             self.videoTitle = videoTitle;
             NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
             NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
             NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:[NSURLRequest requestWithURL:videoUrl]];
             [task resume];
         }
         else {
             NSLog(@"please check url or network !!");
         }
     }];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
    didWriteData:(int64_t)bytesWritten
    totalBytesWritten:(int64_t)totalBytesWritten
    totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown) {
        float percent = (float)totalBytesWritten / totalBytesExpectedToWrite;
        NSLog(@"%f", percent);
    }
    else {

    }
}

- (void)URLSession:(NSURLSession *)session
    downloadTask:(NSURLSessionDownloadTask *)downloadTask
    didFinishDownloadingToURL:(NSURL *)location {
    if (location) {
        NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        NSString *fileName = [NSString stringWithFormat:@"%@.m4v", self.videoTitle];
        NSURL *tempURL = [documentsURL URLByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:tempURL error:nil];
    }
}

#pragma mark - init

- (void)setupWebView {
    self.webView.scalesPageToFit = YES;
    NSURL *url = [NSURL URLWithString:self.urlTextField.text];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:requestObj];
}

- (void)setupInitValue {
    self.title = @"下載";
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupInitValue];
    [self setupWebView];
    [self.downloadButton pulseToSize:1.2f duration:0.4f repeat:YES];
}

@end