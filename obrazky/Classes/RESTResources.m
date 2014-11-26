//
//  RESTResources.m
//  obrazky
//
//  Created by Jakub Dohnal on 19/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import "RESTResources.h"

@implementation RESTResources

- (id)initWithDelegate:(id<RESTResourceDelegate>)delegate{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.recievedData = [[NSMutableData alloc]init];
    }
    return self;
}

- (void)startGetRequestWithUrl: (NSString *) url params:(NSDictionary *)params{
    NSURL *requestURL;
    NSMutableString *urlString = [[NSMutableString alloc] init];
    NSString *fullURLString = url;
    if (params != nil) {
        for (NSString *key in params.allKeys) {
            id val = [params valueForKey:key];
            NSString *value = [val isKindOfClass:[NSString class]]?val:[val stringValue];
            NSString *keyValuePair = [key stringByAppendingFormat:@"=%@", [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [urlString appendFormat:@"&%@", keyValuePair];
        }
    }
    
    if (urlString.length > 0) { // Trim the initial '&'
        [urlString deleteCharactersInRange:NSMakeRange(0, 1)];
        fullURLString = [fullURLString stringByAppendingFormat:@"?%@", urlString];
    }
    
    requestURL = [NSURL URLWithString:fullURLString];
    
    [self startRequestWithUrl: requestURL];
}

-(void)startRequestWithUrl: (NSURL *) url{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:GET_TYPE];
    [request setValue:URLENCODED forHTTPHeaderField:CONTENT_TYPE];
    [request setValue:APPJSON forHTTPHeaderField:ACCEPT];
    [request addValue:LANGUAGE_CS forHTTPHeaderField:ACCEPT_LANGUAGE];
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    if ([self.delegate respondsToSelector:@selector(requestDidStart:)]) {
        [self.delegate performSelector:@selector(requestDidStart:) withObject:self];
    }
}

- (void)cancelRequest{
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    @synchronized (self) {
        if([self.delegate respondsToSelector:@selector(request:didFinishWithData:)]){
            [self.delegate request:self didFinishWithData: self.recievedData];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if([self.delegate respondsToSelector:@selector(requestDidFailLoading:)]){
        [self.delegate requestDidFailLoading:self];
    }
    NSLog(@"Connection error %@", error);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    @synchronized (self) {
        [self.recievedData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    @synchronized (self) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = httpResponse.statusCode;
        NSLog(@"StatusCode: %d", statusCode);
        
        switch (statusCode) {
            case kHTTPStatusCodeBadRequest:
            case kHTTPStatusCodeForbidden:
            case kHTTPStatusCodeNotFound:
            case kHTTPStatusCodeServiceUnavailable:
            case kHTTPStatusCodeUnauthorized:
                if([self.delegate respondsToSelector:@selector(request:didFinishWithError:)]){
                    [self.delegate request:self didFinishWithError:[NSError errorWithDomain:REST_DOMAIN code:statusCode userInfo:nil]];
                }
                break;
                
            default:
                break;
        }
    }
}

@end
