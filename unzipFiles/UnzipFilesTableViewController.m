//
//  UnzipFilesTableViewController.m
//  unzipFiles
//
//  Created by marcosgn1 on 1/31/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import "UnzipFilesTableViewController.h"

#define kHeightForRow 56.0f;
#define kNumberOfSections 1;

@interface UnzipFilesTableViewController ()

@end

@implementation UnzipFilesTableViewController

@synthesize arrFiles, tutorialPages;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showTutorial];
    
    //:::::
    CGRect frame = CGRectMake(0, 0, 70, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Avenir" size:20];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = @"UnzipFiles";
    self.navigationItem.titleView = label;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    
    
    UIColor *topBarColor = [UIColor colorWithRed:253.0f/255.0f green:128.0f/255.0f blue:14.0f/255.0f alpha:1.0f];
    self.navigationController.navigationBar.barTintColor = topBarColor;
    
    //:::
    
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
    
    [self initArrFiles:[UnzipFileUtils unzipFileFromUrl:nil orPath:filePath]];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)initArrFiles:(NSMutableArray *)arrFilesNew
{
    self.arrFiles = arrFilesNew;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSections;
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
    return kHeightForRow;
}

#pragma mark - Unzip Files Notification

- (void)receiveOpenZipFileNotification:(NSNotification *) notification
{
    [self initArrFiles:[UnzipFileUtils unzipFileFromUrl:notification.object orPath:nil]];
}

#pragma mark - Tutorial Methods

- (void)showTutorial
{
    [self pagesForTutorial];
    
    self.tutorialViewController = [[YSTutorialViewController alloc]init];
    
    [self.tutorialViewController.view setTag:100];
    [self.tutorialViewController setDataSource:self];
    [self.tutorialViewController setDelegate:self];
    [self.tutorialViewController reloadTutorialViewController];
    
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:self.tutorialViewController.view];
}
     
- (NSArray *)pagesForTutorial
{
    self.tutorialPages = [[NSMutableArray alloc] initWithArray:[YSTutorialPageSerializer tutorialPageViewsWithJSONFile:@"tutorialPages"]];
    return self.tutorialPages;
}

- (NSInteger)numberOfPagesInTutorialViewController:(YSTutorialViewController *)viewController
{
    return self.tutorialPages.count;
}

- (YSTutorialPageView *)tutorialViewController:(YSTutorialViewController *)viewController tutorialPageViewForIndex:(NSInteger)index
{
    return (YSTutorialPageView *)self.tutorialPages[index];
}

-(UIImage *)tutorialViewControllerBackgroundImageForIndex:(NSInteger)index
{
    if (index == 0) {
        return [UIImage imageNamed:@"tut1Background.png"];
    } else if (index == 1) {
        return [UIImage imageNamed:@"tut2Background.png"];
    } else if (index == 2) {
        return [UIImage imageNamed:@"tut3Background.png"];
    }
    return nil;
}

- (void)tutorialViewControllerDidPressedCloseButton: (YSTutorialViewController *)viewController
{
    [self.tutorialViewController.view removeFromSuperview];
}

- (void)tutorialViewController:(YSTutorialViewController *)viewController didScrollToPageAtIndex:(NSInteger)index
{
    
}

@end
