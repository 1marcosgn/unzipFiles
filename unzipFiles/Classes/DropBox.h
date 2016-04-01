//
//  DropBox.h
//  unzipFiles
//
//  Created by marcosgn1 on 3/31/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "UnzipFileUtils.h"

@interface DropBox : UIView <DBRestClientDelegate>
{
    DBRestClient *restClient;
}

@property (nonatomic, strong) NSDictionary *unzipedFileData;
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, readonly) DBRestClient *restClient;
@property (nonatomic, strong) NSString *loadData;

- (instancetype)initWithObjects:(NSDictionary *)unzipedFileData fileURL:(NSURL *)fileURL;
- (DBRestClient *)restClient;
- (void)dropboxLoginDone;
- (void)uploadFileToDropBox;
- (void)fetchAllDropboxData;
- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata;
- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error;
- (void)dropboxLogOut;
- (BOOL)isLinked;

@end
