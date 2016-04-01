//
//  UnzipFileUtils.m
//  unzipFiles
//
//  Created by marcosgn1 on 3/30/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import "UnzipFileUtils.h"

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
    [loadingView setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, 160.0f, 160.0f)];
    [loadingView setCenter:view.center];
    [loadingView setSegmentColor:[UIColor orangeColor]];
    [loadingView setClockwise:YES];
    [loadingView initialize];
    [loadingView startAnimation:BACircleAnimationFullCircle];
    [view addSubview:loadingView];
}

+ (void)stopLoading
{
    [loadingView stopAnimation];
    [loadingView removeFromSuperview];
}

@end
