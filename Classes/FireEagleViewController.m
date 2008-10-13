//
//  FireEagleAppDelegate.m
//  FireEagle
//
//  Created by Michael Malone on 7/1/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "FireEagleViewController.h"

@implementation FireEagleViewController

@synthesize updateTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		isCurrentlyUpdating = NO;
		firstUpdate = YES;
	}
	return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[updateTextView release];
	[super dealloc];
}


// Appends some text to the main text view
// If this is the first update, it will replace the existing text
-(void)addTextToLog:(NSString *)text {
	if (firstUpdate) {
		updateTextView.text = [NSString stringWithFormat:@"\n%@", text];
		firstUpdate = NO;
	} else {
		updateTextView.text = [NSString stringWithFormat:@"%@\n\n%@", updateTextView.text, text];
		[updateTextView scrollRangeToVisible:NSMakeRange([updateTextView.text length], 0)]; // scroll to the bottom on updates
	}
}


// Called when the view is loading for the first time only
// If you want to do something every time the view appears, use viewWillAppear or viewDidAppear
- (void)viewDidLoad {
	[MyCLController sharedInstance].delegate = self;
	
    // Check to see if the user has disabled location services all together
    // In that case, we just print a message and disable the "Start" button
    if ( ! [MyCLController sharedInstance].locationManager.locationServicesEnabled ) {
        [self addTextToLog:NSLocalizedString(@"NoLocationServices", @"User disabled location services")];
    } else {
		isCurrentlyUpdating = YES;
		[[MyCLController sharedInstance].locationManager startUpdatingLocation];
	}
}


#pragma mark ---- delegate methods for the MyCLController class ----

-(void)newLocationUpdate:(NSString *)text {
	[self addTextToLog:text];
}

-(void)newError:(NSString *)text {
	[self addTextToLog:text];
}

@end
