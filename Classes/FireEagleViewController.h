//
//  FireEagleViewController.h
//  FireEagle
//
//  Created by Michael Malone on 7/1/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCLController.h"

@interface FireEagleViewController : UIViewController <MyCLControllerDelegate> {
	IBOutlet UITextView *updateTextView;
	
	BOOL isCurrentlyUpdating;
	BOOL firstUpdate;
}

@property (nonatomic, retain) IBOutlet UITextView *updateTextView;

@end

