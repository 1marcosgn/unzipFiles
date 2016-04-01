//
//  OpenDrive.m
//  unzipFiles
//
//  Created by marcosgn1 on 3/31/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import "OpenDrive.h"

@implementation OpenDrive

- (instancetype)init
{
    if (self = [super init])
    {
        //initialize something here...
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
                                                                            NSLog(@"Success!!");
                                                                        }
                                                                        else
                                                                        {
                                                                            NSLog(@"one drive upload:%@", error);
                                                                        }
                                                                    }
            ];
         }
     }];
}

@end
