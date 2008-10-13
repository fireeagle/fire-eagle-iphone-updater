//
//  NSURL_Extensions.m
//  TouchHTTPD
//
//  Created by Jonathan Wight on 04/05/08.
//	Adapted by Michael Malone on 05/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSURL_Extensions.h"

@implementation NSURL (NSURL_Extensions)

- (NSDictionary *)queryDictionary 
{
	NSMutableDictionary *theDictionary = [NSMutableDictionary dictionary];
	for (NSString *theKeyValuePair in [self.query componentsSeparatedByString:@"&"])
	{
		NSArray *theKeyValuePairArray = [theKeyValuePair componentsSeparatedByString:@"="];
		NSString *theKey = [theKeyValuePairArray objectAtIndex:0];
		NSString *theValue = [theKeyValuePairArray objectAtIndex:1];
		[theDictionary setObject:theValue forKey:theKey];
	}
	return(theDictionary);
}

@end
