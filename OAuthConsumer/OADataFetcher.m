//
//  OADataFetcher.m
//  OAuthConsumer
//
//  Created by Jon Crosby on 11/5/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "OADataFetcher.h"


@implementation OADataFetcher

- (void)fetchDataWithSynchronousRequest:(OAMutableURLRequest *)aRequest delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
    request = aRequest;
    delegate = aDelegate;
    didFinishSelector = finishSelector;
    didFailSelector = failSelector;
    
    [request prepare];
    
    responseData = [NSMutableData dataWithData:[NSURLConnection sendSynchronousRequest:request
																	 returningResponse:&response
																				 error:&error]];
    if (responseData == nil) {
        OAServiceTicket *ticket= [[OAServiceTicket alloc] initWithRequest:request
                                                                 response:response
                                                               didSucceed:NO];
        [delegate performSelector:didFailSelector
                       withObject:ticket
                       withObject:error];
    } else {
        OAServiceTicket *ticket = [[OAServiceTicket alloc] initWithRequest:request
                                                                  response:response
                                                                didSucceed:[(NSHTTPURLResponse *)response statusCode] < 400];
        [delegate performSelector:didFinishSelector
                       withObject:ticket
                       withObject:responseData];
    }   
}


- (void)fetchDataWithRequest:(OAMutableURLRequest *)aRequest delegate:(id)aDelegate didFinishSelector:(SEL)finishSelector didFailSelector:(SEL)failSelector {
    request = aRequest;
    delegate = aDelegate;
    didFinishSelector = finishSelector;
    didFailSelector = failSelector;
    
    [request prepare];
	
	connection = [[NSURLConnection connectionWithRequest:request 
												delegate:self] retain];
		
	if (connection) {
		// Create the NSMutableData that will hold
		// the received data
		// receivedData is declared as a method instance elsewhere
		responseData = [[NSMutableData data] retain];
	} else {
		// inform the user that the download could not be made
	}
}



/*************************************
 * NSURLConnectionDelegate Methods
 *************************************/

- (void)finishConnection {
	if (connection) {
		// in case cancelling the connection calls this recursively, we want
		// to ensure that we'll only release the connection and delegate once,
		// so first set connection_ to nil
		
		NSURLConnection* oldConnection = connection;
		connection = nil;
		
		// this may be called in a callback from the connection, so use autorelease
		[oldConnection cancel];
		[oldConnection autorelease];
		[responseData release];
	}
}


- (void)connection:(NSURLConnection *)_connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
    [responseData setLength:0];
}


- (void)connection:(NSURLConnection *)_connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    [responseData appendData:data];
}


- (void)connection:(NSURLConnection *)_connection didFailWithError:(NSError *)_error
{
    // release the connection, and the data object
	[self finishConnection];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [_error localizedDescription],
          [[_error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
	OAServiceTicket *ticket= [[OAServiceTicket alloc] initWithRequest:request
															 response:response
														   didSucceed:NO];
	[delegate performSelector:didFailSelector
				   withObject:ticket
				   withObject:_error];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)_connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);
	
	
    if (responseData == nil) {
        OAServiceTicket *ticket= [[OAServiceTicket alloc] initWithRequest:request
                                                                 response:response
                                                               didSucceed:NO];
        [delegate performSelector:didFailSelector
                       withObject:ticket
                       withObject:error];
    } else {
        OAServiceTicket *ticket = [[OAServiceTicket alloc] initWithRequest:request
                                                                  response:response
                                                                didSucceed:[(NSHTTPURLResponse *)response statusCode] < 400];
        [delegate performSelector:didFinishSelector
                       withObject:ticket
                       withObject:responseData];
    } 
	
    // release the connection, and the data object
    [self finishConnection];
}

@end
