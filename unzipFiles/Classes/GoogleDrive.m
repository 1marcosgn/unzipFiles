//
//  GoogleDrive.m
//  unzipFiles
//
//  Created by marcosgn1 on 3/31/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import "GoogleDrive.h"

@implementation GoogleDrive
{
    GTMOAuth2ViewControllerTouch *authController;
}

- (instancetype)initWithObjects:(NSDictionary *)unzipedFileData fileURL:(NSURL *)fileURL
{
    if (self = [super init])
    {
        self.unzipedFileData = unzipedFileData;
        self.fileURL = fileURL;
        self.service = [[GTLServiceDrive alloc] init];
        self.service.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                                                        clientID:kClientID
                                                                                    clientSecret:nil];
    }
    return self;
}

- (GTMOAuth2ViewControllerTouch *)createAuthController
{
    NSArray *scopes = [NSArray arrayWithObjects:kGTLAuthScopeDrive, kGTLAuthScopeDriveAppdata, kGTLAuthScopeDriveFile,  nil];
    
    authController = [[GTMOAuth2ViewControllerTouch alloc] initWithScope:[scopes componentsJoinedByString:@" "]
                                                                clientID:kClientID
                                                            clientSecret:nil
                                                        keychainItemName:kKeychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    return authController;
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController finishedWithAuth:(GTMOAuth2Authentication *)authResult error:(NSError *)error
{
    if (error != nil)
    {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.service.authorizer = nil;
    }
    else
    {
        self.service.authorizer = authResult;
        [authController dismissViewControllerAnimated:YES completion:nil];
        [self uploadFileToGoogleDrive:self.unzipedFileData fileURL:self.fileURL];
    }
}

- (void)showAlert:(NSString *)title message:(NSString *)message
{
    NSLog(@"%@, %@", title, message);
}

- (void)uploadFileToGoogleDrive:(NSDictionary *)unzipedFileData fileURL:(NSURL *)fileURL
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:[UnzipFileUtils temporaryDirectory:unzipedFileData fileURL:fileURL]];
    
    if (fileHandle)
    {
        GTLUploadParameters *uploadParameters = [GTLUploadParameters uploadParametersWithFileHandle:fileHandle
                                                                                           MIMEType:unzipedFileData[kMIMEType]];
        
        GTLDriveFile *fileObj = [GTLDriveFile object];
        
        fileObj.title = unzipedFileData[kfileName];
        
        GTLQueryDrive *query = [GTLQueryDrive queryForFilesInsertWithObject:fileObj
                                                           uploadParameters:uploadParameters];
        
        GTLServiceTicket *ticket = [self.service executeQuery:query
                                            completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error)
                                    {
                                        if (error)
                                        {
                                            NSLog(@"Error: %@", error);
                                        }
                                        else
                                        {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [UnzipFileUtils stopLoading];
                                            });
                                        }
                                    }];
        
        ticket.uploadProgressBlock = ^(GTLServiceTicket *ticket,
                                       unsigned long long numberOfBytesRead,
                                       unsigned long long dataLength)
        {
            NSLog(@"%llu", numberOfBytesRead);
            NSLog(@"%llu", dataLength);
        };
    }
}

@end
