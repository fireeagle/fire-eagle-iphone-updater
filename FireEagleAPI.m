//
//  FireEagleAPI.m
//  FireEagle
//
//  Created by Michael Malone on 7/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "FireEagleAPI.h"
#import <Security/Security.h>
#import "FireEagleAPICallbackWrapper.h"

#define OAUTH_REALM @"http://fireeagle.yahooapis.com"
#define OAUTH_REQUEST_TOKEN_URL [NSString stringWithFormat:@"%@%@", FE_BASEURL, @"oauth/request_token"]
#define OAUTH_AUTHORIZE_URL [NSString stringWithFormat:@"%@%@", FE_BASEURL, @"oauth/authorize"]
#define OAUTH_ACCESS_TOKEN_URL [NSString stringWithFormat:@"%@%@", FE_BASEURL, @"oauth/access_token"]
#define KEYCHAIN_ACCESS_TOKEN_NAME @"FireEagleOAuthToken"
#define KEYCHAIN_SERVICE_PROVIDER @"fireeagle.com"

#define FE_UPDATE_URL [NSString stringWithFormat:@"%@api/%@%@", FE_BASEURL, FE_API_VERSION, @"/update.json"]

@implementation FireEagleAPI

@synthesize requestToken = _requestToken;
@synthesize accessToken = _accessToken;
@synthesize consumer = _consumer;

- (id)initWithKey:(NSString *)key secret:(NSString *)secret {
	NSLog(@"FireEagleAuth:initWithKey:secret initializing FireEagleAuth object with key:%@ secret:%@", key, secret);
	_consumer = [[OAConsumer alloc] initWithKey:key secret:secret];
	_accessToken = [[OAToken alloc] initWithKeychainUsingAppName:KEYCHAIN_ACCESS_TOKEN_NAME
											 serviceProviderName:KEYCHAIN_SERVICE_PROVIDER];
	
	if(_accessToken != nil) {
		NSLog(@"FireEagleAuth:initWithKey:secret: fetched accessToken from keychain: key:%@ secret:%@", _accessToken.key, _accessToken.secret);
	}
	
	return self;
}


- (void)logout {
#if TARGET_IPHONE_SIMULATOR
	// Don't do jack.
#else
	NSString *serviceName = [NSString stringWithFormat:@"%@::OAuth::%@", KEYCHAIN_ACCESS_TOKEN_NAME, KEYCHAIN_SERVICE_PROVIDER];
	
	NSArray *keys = [[NSArray alloc] initWithObjects:(NSString *)kSecClass, kSecAttrService, nil];
	NSArray *objects = [[NSArray alloc] initWithObjects:(NSString *)kSecClassGenericPassword, serviceName, nil];
	NSDictionary *query = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
	
	OSStatus status = SecItemDelete((CFDictionaryRef)query);
	
	if (status != noErr) {
		NSLog(@"Problem deleting current ditionary: %d", status);
	}
	
	[keys release];
	[objects release];
	[query release];
#endif
}


/**********************************************
 * Asynchronous Requests
 **********************************************/


- (void)sendRequest:(OAToken *)token url:(NSURL *)url method:(NSString*)_method params:(NSArray *)_params data:(OAMultipartData *)data delegate:(id)_delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																   consumer:_consumer
																	  token:token   
																	  realm:OAUTH_REALM
														  signatureProvider:[[OAHMAC_SHA1SignatureProvider alloc] init]]; // use the default method, HMAC-SHA1
	
	// Asynchronous timeout is higher than synchronous
	request.timeoutInterval = 60.0;
	
	[request setHTTPMethod:_method];
	if(nil != _params) {
		[request setParameters:_params];
	}
	
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
		
	request.multipartData = data;
	
	FireEagleAPICallbackWrapper *callbackWrapper = [[FireEagleAPICallbackWrapper alloc] initWithDelegate:_delegate
																				 didFinishSelector:finishSelector
																				   didFailSelector:failSelector
																				   cleanupDelegate:self
																				   cleanupCallback:@selector(callbackComplete:)];
	
	[fetcher fetchDataWithRequest:request
						 delegate:callbackWrapper
				didFinishSelector:@selector(apiTicket:didFinishWithData:)
				  didFailSelector:@selector(apiTicket:didFailWithError:)];
		
	[request autorelease];
	[fetcher autorelease];
}


- (void)callbackComplete:(FireEagleAPICallbackWrapper *)callbackWrapper {
	[callbackWrapper release];
}


- (void)sendRequest:(OAToken *)token url:(NSURL *)url method:(NSString*)_method params:(NSArray *)_params delegate:(id)_delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {	
	[self sendRequest:token
				  url:url
			   method:_method
			   params:_params
				 data:nil
			 delegate:_delegate
	didFinishSelector:finishSelector
	  didFailSelector:failSelector];
}


- (void)sendRequest:(NSURL *)url method:(NSString *)_method params:(NSArray *)_params delegate:(id)_delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
	[self sendRequest:_accessToken url:url method:_method params:_params delegate:_delegate didFinishSelector:finishSelector didFailSelector:failSelector];
}


- (void)getRequest:(NSString *)url params:(NSArray *)_params delegate:(id)_delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
	[self sendRequest:[NSURL URLWithString:url] method:@"GET" params:_params delegate:_delegate didFinishSelector:finishSelector didFailSelector:failSelector];
}


- (void)postRequest:(NSString *)url params:(NSArray *)_params delegate:(id)_delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
	[self sendRequest:[NSURL URLWithString:url] method:@"POST" params:_params delegate:_delegate didFinishSelector:finishSelector didFailSelector:failSelector];
}


- (void)getRequest:(NSString *)url delegate:(id)_delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
	[self getRequest:url params:nil delegate:_delegate didFinishSelector:finishSelector didFailSelector:failSelector];
}


- (void)postRequest:(NSString *)url delegate:(id)_delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
	[self postRequest:url params:nil delegate:_delegate didFinishSelector:finishSelector didFailSelector:failSelector];
}


- (void)postRequest:(NSURL *)url data:(OAMultipartData *)data params:(NSArray *)_params delegate:(id)_delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
	[self sendRequest:_accessToken 
				  url:url 
			   method:@"POST" 
			   params:_params
				 data:data
			 delegate:_delegate
	didFinishSelector:finishSelector
	  didFailSelector:failSelector];
}


/****************************************
 * Synchronous Requests
 ****************************************/

- (void)sendSynchronousRequest:(OAToken *)token url:(NSURL *)url method:(NSString*)_method params:(NSArray *)_params data:(OAMultipartData *)data delegate:(id)_delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {	
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																   consumer:_consumer
																	  token:token   
																	  realm:OAUTH_REALM
														  signatureProvider:[[OAHMAC_SHA1SignatureProvider alloc] init]]; // use the default method, HMAC-SHA1
	
	[request setHTTPMethod:_method];
	if(nil != _params) {
		[request setParameters:_params];
	}
	
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
		
	request.multipartData = data;
	
	[fetcher fetchDataWithSynchronousRequest:request
									delegate:_delegate
						   didFinishSelector:finishSelector
							 didFailSelector:failSelector];
		
	[request autorelease];
	[fetcher autorelease];
}


- (void)sendSynchronousRequest:(OAToken *)token url:(NSURL *)url method:(NSString*)_method params:(NSArray *)_params delegate:(id)_delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {	
	[self sendSynchronousRequest:token
							 url:url
						  method:_method
						  params:_params
							data:nil
						delegate:self
			   didFinishSelector:finishSelector
				 didFailSelector:failSelector];
}


- (NSData *)sendSynchronousRequest:(OAToken *)token url:(NSURL *)url method:(NSString *)_method params:(NSArray *)_params {
	[self sendSynchronousRequest:token
							 url:url
						  method:_method
						  params:_params
						delegate:self
			   didFinishSelector:@selector(apiTicket:didFinishWithData:)
				 didFailSelector:@selector(apiTicket:didFailWithError:)];
	
	return _responseData;
}


- (void)apiTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (ticket.didSucceed) {
		_responseData = data;
	} else {
		// Should never happen
		_responseData = nil;
		NSLog(@"FireEagleAuth:apiTicket:didFinishWithData: REQUEST FAILED (data == nil)");
	}
}


- (void)apiTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	_responseData = nil;
	NSLog(@"FireEagleAuth:apiTicket:didFailWithError: REQUEST FAILED WITH ERROR \"%@\"", error);
}


/************************************************************
 * Auth Methods
 ************************************************************/

- (OAToken *) getNewRequestToken {
	NSLog(@"FireEagleAuth:getNewRequestToken: getting request token from FireEagle URL: %@", OAUTH_REQUEST_TOKEN_URL);
	NSURL *url = [NSURL URLWithString:OAUTH_REQUEST_TOKEN_URL];
	OAToken *token = [[OAToken alloc] init]; // we don't have a Token yet
	
	[self sendSynchronousRequest:token 
							 url:url
						  method:@"GET"
						  params:nil];
	
	NSString *responseBody = [[NSString alloc] initWithData:_responseData
												   encoding:NSUTF8StringEncoding];
	_requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
	NSLog(@"FireEagleAuth:getNewRequestToken: set token key to %@", _requestToken.key);
	
	[_requestToken storeInDefaultKeychainWithAppName:_requestToken.key
								 serviceProviderName:KEYCHAIN_SERVICE_PROVIDER];
	NSLog(@"FireEagleAuth:getNewRequestToken: stored oauth token in keychain: key:%@ secret:%@", _requestToken.key, _requestToken.secret);
	
	return _requestToken;
}


- (OAToken *) getNewAccessToken:(OAToken *)token {
	NSLog(@"FireEagleAuth:getNewAccessToken: getting access token from FireEagle");
	NSURL *url = [NSURL URLWithString:OAUTH_ACCESS_TOKEN_URL];
	
	[self sendSynchronousRequest:token
							 url:url
						  method:@"GET"
						  params:nil];
	
	NSString *responseBody = [[NSString alloc] initWithData:_responseData
												   encoding:NSUTF8StringEncoding];
	_accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
	NSLog(@"FireEagleAuth:getNewAccessToken: set token key to %@", _accessToken.key);
	
	[_accessToken storeInDefaultKeychainWithAppName:KEYCHAIN_ACCESS_TOKEN_NAME
								serviceProviderName:KEYCHAIN_SERVICE_PROVIDER];
	
	NSLog(@"FireEagleAuth:getNewAccessToken: got access token from FireEagle: key:%@ secret:%@", _accessToken.key, _accessToken.secret);
	
	return _accessToken;
}


- (OAToken *) getNewAccessTokenFromKey:(NSString *)tokenKey {
	
	OAToken *token = [[OAToken alloc] initWithKeychainUsingAppName:tokenKey
											   serviceProviderName:KEYCHAIN_SERVICE_PROVIDER];
	
	NSLog(@"FireEagleAuth:getNewAccessToken: fetched request token from keychain: key:%@ secret:%@", token.key, token.secret);
	return [self getNewAccessToken:token];
}


/********************************************
 * API Methods
 ********************************************/

- (void)update:(CLLocation *)location delegate:(id)delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
	OARequestParameter *lon = [[OARequestParameter alloc] initWithName:@"lon"
																 value:[NSString stringWithFormat:@"%f", location.coordinate.longitude]];
	
	OARequestParameter *lat = [[OARequestParameter alloc] initWithName:@"lat"
																 value:[NSString stringWithFormat:@"%f", location.coordinate.latitude]];
		
	NSArray *params = [NSArray arrayWithObjects:lon, lat, nil];
	
	[self postRequest:FE_UPDATE_URL
			   params:params
			 delegate:delegate 
	didFinishSelector:finishSelector
	  didFailSelector:failSelector];
	
	[lon release];
	[lat release];
}


@end

