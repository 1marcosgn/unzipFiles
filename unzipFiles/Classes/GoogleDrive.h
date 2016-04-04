//
//  GoogleDrive.h
//  unzipFiles
//
//  Created by marcosgn1 on 3/31/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnzipFileUtils.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"

@interface GoogleDrive : NSObject

@property (nonatomic, strong) GTLServiceDrive *service;
@property (nonatomic, strong) NSDictionary *unzipedFileData;
@property (nonatomic, strong) NSURL *fileURL;

- (instancetype)initWithObjects:(NSDictionary *)unzipedFileData fileURL:(NSURL *)fileURL viewController:(UIViewController *)viewController;
- (GTMOAuth2ViewControllerTouch *)createAuthController;
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)authResult error:(NSError *)error;
- (void)uploadFileToGoogleDrive:(NSDictionary *)unzipedFileData fileURL:(NSURL *)fileURL;

@end
