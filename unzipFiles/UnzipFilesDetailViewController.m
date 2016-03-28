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
#define kKeychainItemName     @"Drive API"
#define kClientID             @"536472992283-tdmpthrig9mt3gnq7qlbperp7l2sg2tk.apps.googleusercontent.com"

@interface UnzipFilesDetailViewController ()
{
    NSURL *fileURL;
}

@end

@implementation UnzipFilesDetailViewController

@synthesize unzipedFileData;
@synthesize unzipedFileExtesion;
@synthesize loadData;
@synthesize service;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.detailWebView.scalesPageToFit = YES;
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
    
    //Initialize the Drive API service & load existing credentials from the keychain if available.
    self.service = [[GTLServiceDrive alloc]init];
    self.service.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                    clientID:kClientID
                                                                                clientSecret:nil];
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
    //Drive
    if (!self.service.authorizer.canAuthorize)
    {
        [self presentViewController:[self createAuthController]
                           animated:YES
                         completion:nil];
    }
    else
    {
        [self uploadFileToGoogleDrive];
    }
    
    
    /*
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
     */
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

#pragma mark - Drive Methods
- (GTMOAuth2ViewControllerTouch *)createAuthController
{
    GTMOAuth2ViewControllerTouch *authController;
    
    NSArray *scopes = [NSArray arrayWithObjects:kGTLAuthScopeDrive, kGTLAuthScopeDriveAppdata, kGTLAuthScopeDriveFile,  nil];
    
    authController = [[GTMOAuth2ViewControllerTouch alloc]
                      initWithScope:[scopes componentsJoinedByString:@" "]
                      clientID:kClientID
                      clientSecret:nil
                      keychainItemName:kKeychainItemName
                      delegate:self
                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    return authController;
}


- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)authResult error:(NSError *)error
{
    if (error != nil) {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.service.authorizer = nil;
    }
    else {
        self.service.authorizer = authResult;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//TODO: Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message
{
    NSLog(@"%@, %@", title, message);
}

- (void)uploadFileToGoogleDrive
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:[self temporaryDirectory]];
    
    if (fileHandle)
    {
        GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithFileHandle:fileHandle
                                                                                           MIMEType:unzipedFileData[kMIMEType]];
        
        GTLDriveFile *fileObj = [GTLDriveFile object];
        
        fileObj.title = unzipedFileData[kfileName];
        
        GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:fileObj
                                                           uploadParameters:uploadParameters];
        
        GTLServiceTicket *ticket = [self.service executeQuery:query
                                            completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error)
                                                                {
                                                                    if (error)
                                                                    {
                                                                        NSLog(@"Error: %@", error);
                                                                    }
                                                                    else
                                                                    {
                                                                        NSLog(@"File Uploaded");
                                                                    }
                                                                }];
        
        ticket.uploadProgressBlock = ^(GTLServiceTicket *ticket,
                                       unsigned long long numberOfBytesRead,
                                       unsigned long long dataLength)
                                        {
                                            NSLog(@"%llu", numberOfBytesRead);
                                            NSLog(@"%llu", dataLength);
                                        };
    }
}

- (void)creatingFolder
{
    //Creating folder
    GTLDriveFile *folder = [GTLDriveFile object];
    folder.title = @"unzipFiles";
    folder.mimeType = @"application/vnd.google-apps.folder";
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:folder
                                                       uploadParameters:nil];
    
    [self.service executeQuery:query completionHandler:^(GTLServiceTicket *ticket,
                                                         GTLDriveFile *updatedFile,
                                                         NSError *error) {
        if (error == nil) {
            NSLog(@"Created folder");
        } else {
            NSLog(@"An error occurred: %@", error);
        }
    }];
}

@end
