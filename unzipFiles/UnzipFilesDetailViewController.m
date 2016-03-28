//
//  UnzipFilesDetailViewController.m
//  unzipFiles
//
//  Created by marcosgn1 on 1/31/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import "UnzipFilesDetailViewController.h"

#define kObserverOpenDropBox  @"OPEN_DROPBOX_VIEW"
#define kData                 @"data"
#define kfileName             @"fileName"
#define kMIMEType             @"MIMEType"
#define kEncoding             @"utf-8"
#define kViewName             @"OpenUploadFileView"
#define kdestinationPath      @"/unzipFiles"

@interface UnzipFilesDetailViewController ()
{
    NSURL *fileURL;
}

@end

@implementation UnzipFilesDetailViewController

@synthesize unzipedFileData;
@synthesize unzipedFileExtesion;
@synthesize loadData;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self displayInfoOnView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dropboxLoginDone)
                                                 name:kObserverOpenDropBox
                                               object:nil];
    
    //::
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:@"share"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self action:@selector(shareMyFile)];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"FM College Team" size:30], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    [shareButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = shareButton;
    //::
    
    self.detailWebView.scalesPageToFit = YES;
    [self displayInfoOnView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)displayInfoOnView
{
    [self.detailWebView loadData:unzipedFileData[kData]
                        MIMEType:unzipedFileData[kMIMEType]
                textEncodingName:kEncoding
                         baseURL:[NSURL URLWithString:@""]];
}

//TODO: Detail screen will have the ability to share that document.. dropbox , etc, etc.. (for free)
- (void)shareMyFile
{
    //Dropbox
    if (![[DBSession sharedSession] isLinked])
    {
        viewName = kViewName;
        [[DBSession sharedSession] linkFromController:self];
    }
    else
    {
        //Uptade the file to Dropbox...
        [self uploadFileToDropBox];
    }
}

- (NSString *)temporaryDirectory
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

//Remove temporal file after upload
- (void)cleaningUp
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
}

#pragma mark - Dropbox Methods
- (DBRestClient *)restClient
{
    if (restClient == nil)
    {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

//User logged in successfully
-(void)dropboxLoginDone
{
    [self uploadFileToDropBox];
}

- (void)uploadFileToDropBox
{
    NSString *destinationPath = kdestinationPath;
    NSString *fileName = unzipedFileData[kfileName];
    
    [self.restClient uploadFile:fileName
                         toPath:destinationPath
                  withParentRev:nil
                       fromPath:[self temporaryDirectory]];
}

-(void)fetchAllDropboxData
{
    [self.restClient loadMetadata:loadData];
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata
{
    //File uploaded successfully to path: metadata.path
    [self cleaningUp];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error
{
    NSLog(@"File upload failed with error: %@", error);
}

- (void)dropboxLogOut
{
    [[DBSession sharedSession]unlinkAll];
}

@end
