//
//  UnzipFileUtils.m
//  unzipFiles
//
//  Created by marcosgn1 on 3/30/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import "UnzipFileUtils.h"

#define kSizeForLoadingView 100.0f

@implementation UnzipFileUtils

static BALoadingView *loadingView;

+ (void)initialize
{
    loadingView = [[BALoadingView alloc] init];
}

+ (NSString *)temporaryDirectory:(NSDictionary *)unzipedFileData fileURL:(NSURL *)fileURL;
{
    //Generating a Unique Directory or File Name
    NSString *fileName = unzipedFileData[kfileName];
    fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
    
    //Creating a Temporary Directory
    NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] isDirectory:YES];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error];
    
    fileURL = [directoryURL URLByAppendingPathComponent:fileName];
    
    NSData *data = unzipedFileData[kData];
    
    [data writeToURL:fileURL options:NSDataWritingAtomic error:&error];
    
    NSString *fileURLString = [fileURL path];
    
    return fileURLString;
}

+ (void)cleaningUp:(NSURL *)fileURL
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
}

+ (void)startLoading:(UIView *)view
{
    BOOL addView = [self isLoadingInView];
    
    [loadingView setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, kSizeForLoadingView, kSizeForLoadingView)];
    
    if (!addView)
    {
        [loadingView setTag:100];
        [loadingView setCenter:view.center];
        [loadingView setSegmentColor:[UIColor orangeColor]];
        [loadingView setClockwise:YES];
        [loadingView initialize];
        [loadingView startAnimation:BACircleAnimationFullCircle];
        [view addSubview:loadingView];
    }
}

+ (void)stopLoading
{
    [loadingView stopAnimation];
    [self resetLoadingViewFrame];
    [loadingView removeFromSuperview];
}

+ (BOOL)isLoadingInView
{
    return (loadingView.frame.origin.x == 0) ? NO : YES;
}

+ (void)resetLoadingViewFrame
{
    [loadingView setFrame:CGRectMake(0.0f, 0.0f, kSizeForLoadingView, kSizeForLoadingView)];
}

+ (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message inView:(UIViewController *)view
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [view presentViewController:alert animated:YES completion:nil];
}

@end
