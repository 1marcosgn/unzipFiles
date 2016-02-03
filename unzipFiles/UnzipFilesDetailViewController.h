//
//  UnzipFilesDetailViewController.h
//  unzipFiles
//
//  Created by marcosgn1 on 1/31/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnzipFilesDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;
@property (nonatomic, assign) NSDictionary *unzipedFileData;
@property (nonatomic, assign) NSString *unzipedFileExtesion;

@end
