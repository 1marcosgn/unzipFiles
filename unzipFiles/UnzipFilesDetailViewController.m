//
//  UnzipFilesDetailViewController.m
//  unzipFiles
//
//  Created by marcosgn1 on 1/31/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import "UnzipFilesDetailViewController.h"

@interface UnzipFilesDetailViewController ()

@end

@implementation UnzipFilesDetailViewController

@synthesize unzipedFileData;
@synthesize unzipedFileExtesion;
@synthesize loadData;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self displayInfoOnView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLoginDone) name:@"OPEN_DROPBOX_VIEW" object:nil];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:@"share"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self action:@selector(shareMyFile)];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"FM College Team" size:30], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    [shareButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = shareButton;
    
    [self displayInfoOnView];
    
}

-(void)dropboxLoginDone
{
    NSLog(@"User logged in successfully.");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)displayInfoOnView
{
    self.detailWebView.scalesPageToFit = YES;
    
    //Method to parse the data file information regarding extension
    [self.detailWebView loadData:unzipedFileData[@"data"]
                        MIMEType:unzipedFileData[@"MIMEType"]
                textEncodingName:@"utf-8"
                         baseURL:[NSURL URLWithString:@""]];
}

- (void)shareMyFile
{
    //TODO: Detail screen will have the ability to share that document.. dropbox , etc, etc.. (for free)
    
    if (![[DBSession sharedSession] isLinked]) {
        viewName = @"OpenUploadFileView";
        [[DBSession sharedSession] linkFromController:self];
    } else {
        //[self performSegueWithIdentifier:@"OpenUploadFileView" sender:self];
        
        //Uptade the file to Dropbox...
        
        NSLog(@"Uptade the file to Dropbox...");
        
        NSString *destinationPath = @"/";
        
        [restClient uploadFile:<#(NSString *)#>
                        toPath:<#(NSString *)#>
                 withParentRev:<#(NSString *)#>
                      fromPath:<#(NSString *)#>
        
    }
    
}

#pragma mark - Dropbox Methods
- (DBRestClient *)restClient
{
    if (restClient == nil) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

-(void)fetchAllDropboxData
{
    [self.restClient loadMetadata:loadData];
}

#pragma mark - DBRestClientDelegate Methods for Load Data
- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata *)metadata
{
    for (int i = 0; i < [metadata.contents count]; i++)
    {
        //DBMetadata *data = [metadata.contents objectAtIndex:i];
        //[marrDownloadData addObject:data];
    }
    //[tbDownload reloadData];
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
}


@end
