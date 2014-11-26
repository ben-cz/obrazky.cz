//
//  RESTResources.h
//  obrazky
//
//  Created by Jakub Dohnal on 19/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, kHTTPStatusCode) {
    kHTTPStatusCodeOK = 200,
    kHTTPStatusCodeBadRequest = 400,
    kHTTPStatusCodeUnauthorized = 401,
    kHTTPStatusCodeForbidden = 403,
    kHTTPStatusCodeNotFound = 404,
    kHTTPStatusCodeServiceUnavailable = 503
};

@interface RESTResources : NSObject

- (id)initWithDelegate:(id<RESTResourceDelegate>)delegate;

- (void)startGetRequestWithParams:(NSDictionary *)params;
- (void)cancelRequest;

@end
