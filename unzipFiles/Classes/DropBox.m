//
//  DropBox.m
//  unzipFiles
//
//  Created by marcosgn1 on 3/31/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import "DropBox.h"

@implementation DropBox

static UIViewController *currentView;

@synthesize loadData;

- (instancetype)initWithObjects:(NSDictionary *)unzipedFileData fileURL:(NSURL *)fileURL viewController:(UIViewController *)viewController
{
    if (self = [super init])
    {
        currentView = viewController;
        self.unzipedFileData = unzipedFileData;
        self.fileURL = fileURL;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dropboxLoginDone)
                                                     name:kObserverOpenDropBox
                                                   object:nil];
    }
    return self;
}

- (DBRestClient *)restClient
{
    if (restClient == nil)
    {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)dropboxLoginDone
{
    [self uploadFileToDropBox];
}

- (void)uploadFileToDropBox
{
    NSString *destinationPath = kdestinationPath;
    NSString *fileName = self.unzipedFileData[kfileName];
    
    [self.restClient uploadFile:fileName
                         toPath:destinationPath
                  withParentRev:nil
                       fromPath:[UnzipFileUtils temporaryDirectory:self.unzipedFileData fileURL:self.fileURL]];
}

- (void)fetchAllDropboxData
{
    [self.restClient loadMetadata:loadData];
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata
{
    [UnzipFileUtils stopLoading];
    [UnzipFileUtils cleaningUp:self.fileURL];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error
{
    NSString *errorStr = [NSString stringWithFormat:@"%@", error];
    
    [UnzipFileUtils showAlertViewWithTitle:@"Dropbox"
                                andMessage:errorStr
                                    inView:currentView];
}

- (void)dropboxLogOut
{
    [[DBSession sharedSession]unlinkAll];
}

- (BOOL)isLinked
{
    return [[DBSession sharedSession] isLinked];
}

@end
