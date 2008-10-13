//
//  FireEagleAPICallbackWrapper.m
//  FireEagle
//
//  Created by Michael Malone on 7/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FireEagleAPICallbackWrapper.h"
#import "NSDictionary_JSONExtensions.h"

@implementation FireEagleAPICallbackWrapper

- (id)initWithDelegate:_delegate didFinishSelector:(SEL)_finishSelector didFailSelector:(SEL)_failSelector cleanupDelegate:(id)_cleanupDelegate cleanupCallback:(SEL)_cleanupCallback {
	if(self = [super init]) {
		delegate = _delegate;
		finishSelector = _finishSelector;
		failSelector = _failSelector;
		cleanupDelegate = _cleanupDelegate;
		cleanupCallback = _cleanupCallback;
	}
	return self;
}


- (void)apiTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	
	if(!ticket.didSucceed) {
		NSLog(@"### Ticket error");
		[self apiTicket:ticket didFailWithError:[NSError errorWithDomain:@"PownceAPICallbackWrapperErrorDomain" code:-1 userInfo:NULL]];
		return;
	}
	
	if(data == nil) {
		NSLog(@"### Data error");
		[self apiTicket:ticket didFailWithError:[NSError errorWithDomain:@"PownceAPICallbackWrapperErrorDomain" code:-2 userInfo:NULL]];
		return;
	}
	
	NSLog(@"Got response: %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
	
	NSError *error = [[NSError alloc] init];
	NSDictionary *dict = [NSDictionary dictionaryWithJSONData:data error:&error];
	
	if([error code] != 0) {
		NSLog(@"### Dictionary error %d", [error code]);
		[self apiTicket:ticket didFailWithError:error];
		return;
	}
	[error release];
	
	[delegate performSelector:finishSelector
				   withObject:ticket
				   withObject:dict];
	
	[cleanupDelegate performSelector:cleanupCallback withObject:self];
}


- (void)apiTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	NSLog(@"PownceAPICallbackWrapper:apiTicket:didFailWithError: REQUEST FAILED WITH ERROR");
	
	[delegate performSelector:failSelector
				   withObject:ticket
				   withObject:error];
	
	[cleanupDelegate performSelector:cleanupCallback withObject:self];
}

@end
