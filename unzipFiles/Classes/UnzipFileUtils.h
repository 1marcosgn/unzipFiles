//
//  UnzipFileUtils.h
//  unzipFiles
//
//  Created by marcosgn1 on 3/30/16.
//  Copyright © 2016 marcosgn1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BALoadingView.h"

@interface UnzipFileUtils : NSObject

+ (NSString *)temporaryDirectory:(NSDictionary *)unzipedFileData fileURL:(NSURL *)fileURL;

+ (void)cleaningUp:(NSURL *)fileURL;

+ (void)startLoading:(UIView *)view;

+ (void)stopLoading;

+ (BOOL)isLoadingInView;

+ (void)resetLoadingViewFrame;

+ (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message inView:(UIViewController *)view;

@end
