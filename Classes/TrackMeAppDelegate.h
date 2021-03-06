//
//  TrackMeAppDelegate.h
//  TrackMe
//
//  Created by Steve Baker on 2/15/10.
//  Copyright Beepscore LLC 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TrackMeViewController;

@interface TrackMeAppDelegate : NSObject <UIApplicationDelegate> {
    // Xcode will automatically add instance variables to back properties
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TrackMeViewController *viewController;

@end

