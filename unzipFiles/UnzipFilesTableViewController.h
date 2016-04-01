//
//  UnzipFilesTableViewController.h
//  unzipFiles
//
//  Created by marcosgn1 on 1/31/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UZKArchive.h"
#import "UnzipFileUtils.h"

@interface UnzipFilesTableViewController : UITableViewController

@property (nonatomic, retain) NSMutableArray *arrFiles;

//Unzip files using either a URL or Path
- (void)unzipFileFromUrl:(NSURL *)URLFile orPath:(NSString *)filePath;

@end
