//
//  OAMultipartData.m
//  Pownce
//
//  Created by Michael Malone on 6/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "OAMultipartData.h"


@implementation OAMultipartData

@synthesize name, filename, mimetype, data;

- initWithName:(NSString *)_name filename:(NSString *)_filename mimetype:(NSString *)_mimetype data:(NSData *)_data {
	self = [super init];
	self.name = _name;
	self.filename = _filename;
	self.mimetype = _mimetype;
	self.data = _data;
	
	return self;
}

- (void)dealloc {
	[name release];
	[filename release];
	[mimetype release];
	[data release];
	
	[super dealloc];
}

@end
