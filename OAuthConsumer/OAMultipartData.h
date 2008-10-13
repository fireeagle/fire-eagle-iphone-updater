//
//  OAMultipartData.h
//  Pownce
//
//  Created by Michael Malone on 6/23/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OAMultipartData : NSObject {
	NSString *mimetype;
	NSString *filename;
	NSString *name;
	NSData   *data;
}

@property(copy, readwrite) NSString *mimetype;
@property(copy, readwrite) NSString *filename;
@property(copy, readwrite) NSString *name;
@property(copy, readwrite) NSData *data;

- initWithName:(NSString *)_name filename:(NSString *)_filename mimetype:(NSString *)_mimetype data:(NSData *)_data;


@end