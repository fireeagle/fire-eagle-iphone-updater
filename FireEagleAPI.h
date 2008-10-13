//
//  FireEagleAPI.h
//  FireEagle
//
//  Created by Michael Malone on 7/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "OAuthConsumer.h"
#import "OAToken_KeychainExtensions.h"
#import "OAMultipartData.h"

#define FE_API_VERSION @"0.1"
#define FE_HOSTNAME @"fireeagle.yahooapis.com"
#define FE_BASEURL [NSString stringWithFormat:@"https://%@/", FE_HOSTNAME]
#define FE_MOBILE_AUTH_BASEURL @"http://fireeagle.yahoo.net/oauth/authorize"

@interface FireEagleAPI : NSObject {
	
@private
	OAToken *_requestToken;
	OAToken *_accessToken;
	OAConsumer *_consumer;
	NSData *_responseData;
}

@property (nonatomic, retain) OAToken *requestToken;
@property (nonatomic, retain) OAToken *accessToken;
@property (nonatomic, retain) OAConsumer *consumer;

- (id)initWithKey:(NSString *)key secret:(NSString *)aSecret;

- (void)logout;

// Asynchronous
- (void)getRequest:(NSString *)url params:(NSArray *)_params delegate:(id)_delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;
- (void)getRequest:(NSString *)url delegate:(id)_delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;
- (void)postRequest:(NSString *)url params:(NSArray *)_params delegate:(id)_delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;
- (void)postRequest:(NSString *)url delegate:(id)_delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;
- (void)postRequest:(NSURL *)url data:(OAMultipartData *)data params:(NSArray *)_params delegate:(id)_delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;

// Authentication
- (OAToken *)getNewRequestToken;
- (OAToken *)getNewAccessToken:(OAToken *)token;
- (OAToken *)getNewAccessTokenFromKey:(NSString *)tokenKey;

// API Methods
- (void)update:(CLLocation *)location delegate:(id)delegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector;

@end
