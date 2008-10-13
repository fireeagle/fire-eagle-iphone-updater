//
//  OAToken_KeychainExtensions.m
//  TouchTheFireEagle
//
//  Created by Jonathan Wight on 04/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "OAToken_KeychainExtensions.h"

@implementation OAToken (OAToken_KeychainExtensions)

#if TARGET_IPHONE_SIMULATOR
- (id)initWithKeychainUsingAppName:(NSString *)name serviceProviderName:(NSString *)provider {
    [super init];
    SecKeychainItemRef item;
	NSString *serviceName = [NSString stringWithFormat:@"%@::OAuth::%@", name, provider];
	OSStatus status = SecKeychainFindGenericPassword(NULL,
													 strlen([serviceName UTF8String]),
													 [serviceName UTF8String],
													 0,
													 NULL,
													 NULL,
													 NULL,
													 &item);
    if (status != noErr) {
        return nil;
    }
    
    // from Advanced Mac OS X Programming, ch. 16
    UInt32 length;
    char *password;
    SecKeychainAttribute attributes[8];
    SecKeychainAttributeList list;
	
    attributes[0].tag = kSecAccountItemAttr;
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[2].tag = kSecLabelItemAttr;
    attributes[3].tag = kSecModDateItemAttr;
    
    list.count = 4;
    list.attr = attributes;
    
    status = SecKeychainItemCopyContent(item, NULL, &list, &length, (void **)&password);
    
    if (status == noErr) {
        self.key = [NSString stringWithCString:list.attr[0].data
                                        length:list.attr[0].length];
        if (password != NULL) {
            char passwordBuffer[1024];
            
            if (length > 1023) {
                length = 1023;
            }
            strncpy(passwordBuffer, password, length);
            
            passwordBuffer[length] = '\0';
			self.secret = [NSString stringWithCString:passwordBuffer];
        }
        
        SecKeychainItemFreeContent(&list, password);
        
    } else {
		// TODO find out why this always works in i386 and always fails on ppc
		NSLog(@"Error from SecKeychainItemCopyContent: %d", status);
        return nil;
    }
    
    NSMakeCollectable(item);
    
    return self;
}


- (int)storeInDefaultKeychainWithAppName:(NSString *)name serviceProviderName:(NSString *)provider {
    return [self storeInKeychain:NULL appName:name serviceProviderName:provider];
}

- (int)storeInKeychain:(SecKeychainRef)keychain appName:(NSString *)name serviceProviderName:(NSString *)provider {
	OSStatus status = SecKeychainAddGenericPassword(keychain,                                     
                                                    [name length] + [provider length] + 9, 
                                                    [[NSString stringWithFormat:@"%@::OAuth::%@", name, provider] UTF8String],
                                                    [self.key length],                        
                                                    [self.key UTF8String],
                                                    [self.secret length],
                                                    [self.secret UTF8String],
                                                    NULL
                                                    );
	return status;
}


#else


- (int)storeInDefaultKeychainWithAppName:(NSString *)name serviceProviderName:(NSString *)provider {
	NSDictionary *result;
	
	NSArray *keys = [[NSArray alloc] initWithObjects:(NSString *)kSecClass, kSecAttrService, kSecAttrLabel, kSecAttrAccount, kSecAttrGeneric, nil];
	NSString *serviceName = [NSString stringWithFormat:@"%@::OAuth::%@", name, provider];
	
	NSLog(@"OAToken::storeInDefaultKeychainWithAppName:serviceProviderName: attempting to store token at %@", serviceName);

	NSArray *objects = [[NSArray alloc] initWithObjects:(NSString *)kSecClassGenericPassword, 
						serviceName, 
						@"Pownce OAuth Token",
						self.key,
						self.secret,
						nil];
	
	NSDictionary *query = [[NSDictionary alloc] initWithObjects:objects
														forKeys:keys];

	OSStatus status = SecItemAdd((CFDictionaryRef)query, (CFTypeRef *)&result);
		
	[keys release];
	[objects release];
	[query release];
	
	return status;
}


- (id)initWithKeychainUsingAppName:(NSString *)name serviceProviderName:(NSString *)provider {
    [super init];
	NSDictionary *result;
	NSString *serviceName = [NSString stringWithFormat:@"%@::OAuth::%@", name, provider];
	
	NSLog(@"OAToken::initWithKeychainUsingAppName:serviceProviderName: attempting to retrieve token at %@", serviceName);

	NSArray *keys = [[NSArray alloc] initWithObjects:(NSString *)kSecClass, kSecAttrService, kSecReturnAttributes, nil];
	NSArray *objects = [[NSArray alloc] initWithObjects:(NSString *)kSecClassGenericPassword, serviceName, kCFBooleanTrue, nil];
	
	NSDictionary *query = [[NSDictionary alloc] initWithObjects:objects
														forKeys:keys];
	
	NSLog(@"OAToken::initWithKeychainUsingAppName:serviceProviderName: copying item");
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&result);
	NSLog(@"OAToken::initWithKeychainUsingAppName:serviceProviderName: item copied");

	if (status != noErr) {
		NSLog(@"ERROR: %d", status);
		return nil;
	}
	NSLog(@"NO ERROR");
	
	self.key = (NSString *)[result objectForKey:(NSString *)kSecAttrAccount];
	self.secret = (NSString *)[result objectForKey:(NSString *)kSecAttrGeneric];

	NSLog(@"Returning");
	
	[keys release];
	[objects release];
	[query release];
	
	return self;
}
#endif

@end
