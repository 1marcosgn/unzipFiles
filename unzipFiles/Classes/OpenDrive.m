//
//  OpenDrive.m
//  unzipFiles
//
//  Created by marcosgn1 on 3/31/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import "OpenDrive.h"

@implementation OpenDrive

static UIViewController *currentView;

- (instancetype)initWithViewController:(UIViewController *)view
{
    if (self = [super init])
    {
        currentView = view;
    }
    return self;
}

- (void)uploadFileToOpenDrive:(NSDictionary *)unzipedFileData fileURL:(NSURL *)fileURL
{
    __block ODClient *odClient = [[ODClient alloc] init];
    
    NSArray *scopes = [NSArray arrayWithObjects:kODSigninScope, kODOfflineScope, kODReadWriteScope,  nil];
    
    [ODClient setMicrosoftAccountAppId:kOneDriveAppId scopes:scopes];
    
    [ODClient clientWithCompletion:^(ODClient *client, NSError *error)
     {
         if (!error)
         {
             odClient = client;
             
             NSString *path = [UnzipFileUtils temporaryDirectory:unzipedFileData fileURL:fileURL];
             
             [[[[[[odClient drive] special:kODAppRoot] itemByPath:unzipedFileData[kfileName]] contentRequest]
                                                     nameConflict:[ODNameConflict replace]]
                                                   uploadFromFile:[NSURL fileURLWithPath:path]
                                                       completion:^(ODItem *response, NSError *error)
                                                                    {
                                                                        if (error == nil)
                                                                        {
                                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                                [UnzipFileUtils stopLoading];
                                                                            });
                                                                        }
                                                                        else
                                                                        {
                                                                            NSString *errorStr = [NSString stringWithFormat:@"%@", error];
                                                                            
                                                                            [UnzipFileUtils showAlertViewWithTitle:kOneDrive
                                                                                                        andMessage:errorStr
                                                                                                            inView:currentView];
                                                                        }
                                                                    }
            ];
         }
     }];
}

@end
