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
#define kFolderTitle          @"unzipFiles"
#define kFolderMimeType       @"application/vnd.google-apps.folder"
#define kDropbox              @"Dropbox"
#define kGoogleDrive          @"Google Drive"
#define kOneDrive             @"OneDrive"
#define kOneDriveAppId        @"000000004818FA51"
#define kODSigninScope        @"wl.signin"
#define kODOfflineScope       @"wl.offline_access"
#define kODReadWriteScope     @"onedrive.readwrite"
#define kODAppRoot            @"approot"

@interface UnzipFilesDetailViewController ()
{
    NSURL *fileURL;
}

@property (nonatomic, strong) PopMenu *popMenu;

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
                                                                   target:self action:@selector(showPopMenu)];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"FM College Team" size:30], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    [shareButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = shareButton;
    //::
    
    //Initialize the Drive API service & load existing credentials from the keychain if available.
    self.service = [[GTLServiceDrive alloc] init];
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

- (void)shareMyFile:(NSInteger)selectedElement
{
    switch (selectedElement)
    {
        case 0:
            //Dropbox
            if (![[DBSession sharedSession] isLinked])
            {
                viewName = kViewName;
                [[DBSession sharedSession] linkFromController:self];
            }
            else
            {
                [self uploadFileToDropBox];
            }
            break;
            
        case 1:
            //Google Drive
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
            break;
            
        case 2:
            //Open Drive
            [self uploadFileToOpenDrive];
            break;
            
        default:
        break;
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

- (void)cleaningUp
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
}

#pragma mark - Pop Menu Implementation

- (void)showPopMenu
{
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:3];
    MenuItem *menuItem = [[MenuItem alloc] initWithTitle:kDropbox iconName:@"dropboxIcon" glowColor:[UIColor whiteColor] index:0];
    [items addObject:menuItem];
    
    menuItem = [[MenuItem alloc] initWithTitle:kGoogleDrive iconName:@"driveIcon" glowColor:[UIColor whiteColor] index:1];
    [items addObject:menuItem];
    
    menuItem = [[MenuItem alloc] initWithTitle:kOneDrive iconName:@"oneDrive" glowColor:[UIColor whiteColor] index:2];
    [items addObject:menuItem];
    
    if (!self.popMenu)
    {
        self.popMenu = [[PopMenu alloc] initWithFrame:self.view.bounds items:items];
    }
    
    if (self.popMenu.isShowed)
    {
        return;
    }
    
    __block UnzipFilesDetailViewController *safeViewController = self;
    self.popMenu.didSelectedItemCompletion = ^(MenuItem *selectedItem)
    {
        [safeViewController shareMyFile:selectedItem.index];
    };
    
    [self.popMenu showMenuAtView:self.view];
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

- (void)dropboxLoginDone
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

- (void)fetchAllDropboxData
{
    [self.restClient loadMetadata:loadData];
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata
{
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

#pragma mark - Google Drive Methods

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
        [self uploadFileToGoogleDrive];
    }
}

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

#pragma mark - OpenDrive Methods

- (void)uploadFileToOpenDrive
{
    self.odClient = [[ODClient alloc] init];
    
    NSArray *scopes = [NSArray arrayWithObjects:kODSigninScope, kODOfflineScope, kODReadWriteScope,  nil];
    
    [ODClient setMicrosoftAccountAppId:kOneDriveAppId scopes:scopes];
    
    [ODClient clientWithCompletion:^(ODClient *client, NSError *error)
     {
         if (!error)
         {
             self.odClient = client;
             
             NSString *path = [self temporaryDirectory];
             
             [[[[[[self.odClient drive] special:kODAppRoot]
                                     itemByPath:unzipedFileData[kfileName]] contentRequest]
                                   nameConflict:[ODNameConflict replace] ]
                                 uploadFromFile:[NSURL fileURLWithPath:path]
                                     completion:^(ODItem *response, NSError *error)
                                                    {
                                                        if (error == nil)
                                                        {
                                                            NSLog(@"Success!!");
                                                        }
                                                        else
                                                        {
                                                            NSLog(@"one drive upload:%@", error);
                                                        }
                                                    }
             ];
         }
     }];
}

@end
