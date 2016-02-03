//
//  UnzipFilesTableViewController.m
//  unzipFiles
//
//  Created by marcosgn1 on 1/31/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import "UnzipFilesTableViewController.h"
#import "UnzipFilesDetailViewController.h"
#import "UnzipFilesTableViewCell.h"

#define kNotificationName @"AppOpeningZipFileNotification"
#define kUINibCellName @"UnzipFilesTableViewCell"
#define kReusableIdentifier @"cellZipFile"
#define kFileName @"fileName"
#define kMACOSXFiles @"__MACOSX"
#define kMIMETypes @"MIMETypes"
#define kData @"data"
#define kMIMEType @"MIMEType"

@interface UnzipFilesTableViewController ()

@end

@implementation UnzipFilesTableViewController

@synthesize arrFiles;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Adding an observer for "AppOpeningZipFileNotification"
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveOpenZipFileNotification:)
                                                 name:kNotificationName
                                               object:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:kUINibCellName bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kReusableIdentifier];
    
    //Open by default this file
    //Get temporal path for test .zip file
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"ArchiveFiles"
                                                         ofType:@"zip"];
    
    [self unzipFileFromUrl:nil orPath:filePath];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrFiles count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Load a table view with a cell for each extracted data to show the content
    UnzipFilesTableViewCell *cellUnzipFile = (UnzipFilesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kReusableIdentifier forIndexPath:indexPath];
    
    cellUnzipFile.preservesSuperviewLayoutMargins = false;
    cellUnzipFile.separatorInset = UIEdgeInsetsZero;
    cellUnzipFile.layoutMargins = UIEdgeInsetsZero;
    cellUnzipFile.lblFileName.text = [self.arrFiles objectAtIndex:indexPath.row][kFileName];
    
    return cellUnzipFile;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Open a new view with the content of the cell (send dictionary with the relevant information asociated to the selected file)
    UnzipFilesDetailViewController *detailView = [[UnzipFilesDetailViewController alloc]init];

    detailView.unzipedFileData = [self.arrFiles objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:detailView animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56.0f;
}

#pragma mark - Unzip Files Methods

- (void)unzipFileFromUrl:(NSURL *)URLFile orPath:(NSString *)filePath
{
    BOOL isCompressedFile = NO;
    UZKArchive *archive;
    NSError *archiveError = nil;
    
    //Initialize temporal array to store all extracted files
    self.arrFiles = [NSMutableArray new];
    
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
                                                                //TODO: Add UIActivity Indicator View
                                                                NSLog(@"Extracting, %f%% complete", percentDecompressed);
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
                    [self.arrFiles addObject:[dataDictionary copy]];
                    
                    //Remove objects to avoid duplicate files
                    [dataDictionary removeAllObjects];
                }
            }
        }];
        
        [self.tableView reloadData];
        
    }
}

- (void)receiveOpenZipFileNotification:(NSNotification *) notification
{
    [self unzipFileFromUrl:notification.object orPath:nil];
}

@end
