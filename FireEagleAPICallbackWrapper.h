//
//  FireEagleAPICallbackWrapper.h
//  FireEagle
//
//  Created by Michael Malone on 7/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FireEagleAPICallbackWrapper.h"
#import "OAuthConsumer.h"

@interface FireEagleAPICallbackWrapper : NSObject
{
	id delegate;
	SEL finishSelector;
	SEL failSelector;
	
	id cleanupDelegate;
	SEL cleanupCallback;
}

- (id)initWithDelegate:delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector cleanupDelegate:(id)cleanupDelegate cleanupCallback:(SEL)cleanupCallback;
- (void)apiTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)apiTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

@end