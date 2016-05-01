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
#import "UnzipFilesDetailViewController.h"
#import "UnzipFilesTableViewCell.h"

#import "YSTutorialViewController.h"
#import "YSTutorialPageSerializer.h"

@interface UnzipFilesTableViewController : UITableViewController <YSTutorialViewControllerDelegate, YSTutorialViewControllerDataSource>

@property (nonatomic, retain) NSMutableArray *arrFiles;

@property (nonatomic, retain) NSMutableArray *tutorialPages;

@property (nonatomic, strong) YSTutorialViewController *tutorialViewController;

@end
