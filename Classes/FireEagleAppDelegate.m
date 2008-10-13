//
//  FireEagleAppDelegate.m
//  FireEagle
//
//  Created by Michael Malone on 7/1/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "FireEagleAppDelegate.h"
#import "FireEagleViewController.h"
#import "NSURL_Extensions.h"

@implementation FireEagleAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize fireEagleAPI;


- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	
	// Override point for customization after app launch	
    [window addSubview:viewController.view];
	[window makeKeyAndVisible];
	
	fireEagleAPI = [[FireEagleAPI alloc] initWithKey:@"ca8Sx8UmoQ9I"
											  secret:@"ssZpqQD2b0ib4aInlKl9uKPwcsiq6vUa"];

	
	// Schedule -showAuthAlert on the next cycle of the event loop to give the 
    // application:handleOpenURL: delegate method an opportunity to handle an incoming URL.
    // If that delegate method is called, it sets the showAuthAlert to NO, which prevents
    // the auth dialog from being shown.
    _showAuthAlert = YES;
    [self performSelector:@selector(checkAuth) withObject:nil afterDelay:0.0];
}


- (void)checkAuth {
	if(_showAuthAlert && fireEagleAPI.accessToken == nil) {
		NSString *message = @"To get started click to launch Safari and login to your Fire Eagle account.";
		UIAlertView *authAlertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"Login" otherButtonTitles:nil];
		[authAlertView show];
	} else {
		NSLog(@"We have token!");
	}
}


- (void)modalViewCancel:(UIAlertView *)alertView
{
    [alertView release];
}


- (void)modalView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSLog(@"DismissedWithButtonIndex %d", buttonIndex);
	if (buttonIndex != -1) {
		// Open Safari only if the user clicked the 'Launch Safari' button, but not if this
		// delegate method is called by UIKit to cancel it. In that case, buttonIndex is -1.
		
		OAToken *token = [fireEagleAPI getNewRequestToken];
		
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?oauth_callback=fireeagle://oauth/access_token&oauth_token=%@", FE_MOBILE_AUTH_BASEURL, token.key]];
		[[UIApplication sharedApplication] openURL:url];
	}
	[alertView release];
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	NSLog(@"Handled open URL request");
	NSLog(@"URL Path: %@", url.path);
	NSLog(@"URL Host: %@", url.host);
	NSLog(@"URL Query: %@", url.query);
	NSLog(@"URL ResourceSpecifier: %@", url.resourceSpecifier);
	
	_showAuthAlert = NO;
	
    // You should be extremely careful when handling URL requests.
    // You must take steps to validate the URL before handling it.
    
    if (!url) {
        // The URL is nil. There's nothing more to do.
        return NO;
    }
    
    NSString *URLString = [url absoluteString];
    
    if (!URLString) {
        // The URL's absoluteString is nil. There's nothing more to do.
        return NO;
    }
    
    // Your application is defining the new URL type, so you should know the maximum character
    // count of the URL. Anything longer than what you expect is likely to be dangerous.
    NSInteger maximumExpectedLength = 512;
    
    if ([URLString length] > maximumExpectedLength) {
        // The URL is longer than we expect. Stop servicing it.
		NSLog(@"URL Longer than expected");
        return NO;
    }
	
	if([url.host isEqualToString:@"oauth"] && [url.path isEqualToString:@"/access_token"]) {
		NSDictionary *query = url.queryDictionary;
		NSString *tokenKey = [query objectForKey:@"oauth_token"];
		
		if(tokenKey == nil) {
			NSLog(@"No OAuth token... wtf?");
		}
		NSLog(@"OAUTH_TOKEN: %@", tokenKey);
		
		[fireEagleAPI getNewAccessTokenFromKey:tokenKey];		
	} else {
		NSLog(@"A confusing URL was sent... :(");
		return NO;
	}
	
    return YES;
}


- (void)dealloc {
	[fireEagleAPI release];
    [viewController release];
	[window release];
	[super dealloc];
}


@end
