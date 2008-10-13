//
//  FireEagleAppDelegate.h
//  FireEagle
//
//  Created by Michael Malone on 7/1/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FireEagleAPI.h"

@class FireEagleViewController;

@interface FireEagleAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet FireEagleViewController *viewController;
	
	FireEagleAPI *fireEagleAPI;
	BOOL		 _showAuthAlert;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) FireEagleViewController *viewController;

@property (nonatomic, retain) FireEagleAPI *fireEagleAPI;

@end

