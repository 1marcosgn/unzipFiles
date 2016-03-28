//
//  AppDelegate.h
//  unzipFiles
//
//  Created by marcosgn1 on 1/30/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, DBSessionDelegate, DBNetworkRequestDelegate>
{
    NSString *relinkUserId;
}

@property (strong, nonatomic) UIWindow *window;


@end

