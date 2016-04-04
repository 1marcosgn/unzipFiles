//
//  OpenDrive.h
//  unzipFiles
//
//  Created by marcosgn1 on 3/31/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnzipFileUtils.h"
#import "ODClient+DefaultConfiguration.h"
#import "ODItemContentRequest.h"
#import "ODDriveRequestBuilder.h"
#import "ODDrive.h"
#import "ODClient+HelperMethods.h"

@interface OpenDrive : NSObject

- (instancetype)initWithViewController:(UIViewController *)view;

- (void)uploadFileToOpenDrive:(NSDictionary *)unzipedFileData fileURL:(NSURL *)fileURL;

@end
