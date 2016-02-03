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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self displayInfoOnView];
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
    
}


@end
