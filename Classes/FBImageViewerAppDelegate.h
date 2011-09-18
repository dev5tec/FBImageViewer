//
//  EasyGalleryAppDelegate.h
//  EasyGallery
//
//  Created by Hiroshi Hashiguchi on 10/09/28.
//  Copyright 2010 . All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBImageViewerViewController;

@interface FBImageViewerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    FBImageViewerViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet FBImageViewerViewController *viewController;

@end

