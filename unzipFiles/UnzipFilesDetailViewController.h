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

#import <DropboxSDK/DropboxSDK.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
#import "MenuItem.h"
#import "PopMenu.h"

@interface UnzipFilesDetailViewController : UIViewController <DBRestClientDelegate>
{
    NSString  *viewName;
    DBRestClient *restClient;
    OpenDrive *openDriveObj;
}

@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;
@property (nonatomic, assign) NSDictionary *unzipedFileData;
@property (nonatomic, assign) NSString *unzipedFileExtesion;
@property (nonatomic, readonly) DBRestClient *restClient;
@property (nonatomic, strong) NSString *loadData;

//Drive
@property (nonatomic, strong) GTLServiceDrive *service;

//OpenDrive
@property (nonatomic, readonly) OpenDrive *openDriveObj;

@end
