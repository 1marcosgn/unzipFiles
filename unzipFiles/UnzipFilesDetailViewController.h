//
//  UnzipFilesDetailViewController.h
//  unzipFiles
//
//  Created by marcosgn1 on 1/31/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UnzipFileUtils.h"
#import "OpenDrive.h"
#import "GoogleDrive.h"
#import "DropBox.h"

#import "MenuItem.h"
#import "PopMenu.h"

@interface UnzipFilesDetailViewController : UIViewController
{
    NSString  *viewName;
    
    OpenDrive *openDriveObj;
    GoogleDrive *googleDriveObj;
    DropBox *dropBoxObj;
}

@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;
@property (nonatomic, assign) NSDictionary *unzipedFileData;
@property (nonatomic, assign) NSString *unzipedFileExtesion;

//OpenDrive
@property (nonatomic, readonly) OpenDrive *openDriveObj;

//Google Drive
@property (nonatomic, readonly) GoogleDrive *googleDriveObj;

//Dropbox
@property (nonatomic, readonly) DropBox *dropBoxObj;

@end
