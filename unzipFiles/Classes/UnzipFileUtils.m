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

+ (NSMutableArray *)unzipFileFromUrl:(NSURL *)URLFile orPath:(NSString *)filePath
{
    BOOL isCompressedFile = NO;
    UZKArchive *archive;
    NSError *archiveError = nil;
    
    //Initialize temporal array to store all extracted files
    NSMutableArray *arrFiles = [NSMutableArray new];
    
    //Container for each extracted file
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
    
    if (URLFile)
    {
        //Reading zip contents from URL
        isCompressedFile = [UZKArchive urlIsAZip:URLFile];
        archive = [[UZKArchive alloc] initWithURL:URLFile error:&archiveError];
    }
    else if (filePath)
    {
        //Reading zip contents from Path
        isCompressedFile = [UZKArchive pathIsAZip:filePath];
        archive = [[UZKArchive alloc] initWithPath:filePath error:&archiveError];
    }
    
    if (isCompressedFile)
    {
        __block NSError *error = nil;
        __block NSData *extractedData;
        
        NSArray <NSString *> *filesInArchive = [archive listFilenames:&error];
        
        //List the content of the archive
        [filesInArchive enumerateObjectsUsingBlock:^(NSString *element, NSUInteger idx, BOOL * _Nonnull stop) {
            
            //Discard default __MACOSX files included on zip files created by MAC OS
            if (![element containsString:kMACOSXFiles])
            {
                //Extracting data
                extractedData = [archive extractDataFromFile:element
                                                    progress:^(CGFloat percentDecompressed)
                                 {
                                     if (percentDecompressed == 1.000000)
                                     {
                                         //NSLog(@"File uploaded!");
                                     }
                                 }
                                                       error:&error];
                //Data has been extracted correctly??
                if (extractedData)
                {
                    //Get the extension based the "MIMETypes.plist" and store that as "MIMEType" on dataDictionary
                    NSDictionary *MIMETypesInfo = [[NSDictionary alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kMIMETypes ofType:@"plist"]];
                    
                    NSString *MIMEType = MIMETypesInfo[[[element pathExtension] lowercaseString]];
                    
                    [dataDictionary setObject:extractedData forKey:kData];
                    [dataDictionary setObject:element forKey:kFileName];
                    [dataDictionary setObject:MIMEType forKey:kMIMEType];
                    
                    //Store the dictionary in the main array of files
                    [arrFiles addObject:[dataDictionary copy]];
                    
                    //Remove objects to avoid duplicate files
                    [dataDictionary removeAllObjects];
                }
            }
        }];
        
        return arrFiles;
        
    }
    
    return arrFiles;
}

@end
