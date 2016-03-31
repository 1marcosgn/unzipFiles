//
//  UnzipFilesDetailViewController.m
//  unzipFiles
//
//  Created by marcosgn1 on 1/31/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import "UnzipFilesDetailViewController.h"

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
            if (!self.googleDriveObj.service.authorizer.canAuthorize)
            {
                [self presentViewController:[self.googleDriveObj createAuthController]
                                   animated:YES
                                 completion:nil];
            }
            else
            {
                [self.googleDriveObj uploadFileToGoogleDrive:unzipedFileData fileURL:fileURL];
            }
            break;
            
        case 2:
            //Open Drive
            [self.openDriveObj uploadFileToOpenDrive:unzipedFileData
                                             fileURL:fileURL];
            break;
            
        default:
        break;
    }
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
                       fromPath:[UnzipFileUtils temporaryDirectory:unzipedFileData fileURL:fileURL]];
}

- (void)fetchAllDropboxData
{
    [self.restClient loadMetadata:loadData];
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata
{
    [UnzipFileUtils cleaningUp:fileURL];
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error
{
    NSLog(@"File upload failed with error: %@", error);
}

- (void)dropboxLogOut
{
    [[DBSession sharedSession]unlinkAll];
}


#pragma mark - Initializers 

- (OpenDrive *)openDriveObj
{
    if (openDriveObj == nil)
    {
        openDriveObj = [[OpenDrive alloc]init];
    }
    return openDriveObj;
}

- (GoogleDrive *)googleDriveObj
{
    if (googleDriveObj == nil)
    {
        googleDriveObj = [[GoogleDrive alloc] initWithObjects:unzipedFileData fileURL:fileURL];
    }
    return googleDriveObj;
}

@end
