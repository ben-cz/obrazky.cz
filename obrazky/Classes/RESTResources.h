//
//  RESTResources.h
//  obrazky
//
//  Created by Jakub Dohnal on 19/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RESTResourcesDelegate.h"

#define CONTENT_TYPE @"Content-Type"
#define CONTENT_LENGHT @"Content-Length"
#define ACCEPT @"Accept"
#define ACCEPT_LANGUAGE @"Accept-Language"
#define LANGUAGE_CS @"cs"
#define REST_DOMAIN @"rest"

#define GET_TYPE @"GET"

#define URLENCODED @"application/x-www-form-urlencoded"
#define APPJSON @"application/json"

typedef NS_ENUM(NSInteger, kHTTPStatusCode) {
    kHTTPStatusCodeOK = 200,
    kHTTPStatusCodeBadRequest = 400,
    kHTTPStatusCodeUnauthorized = 401,
    kHTTPStatusCodeForbidden = 403,
    kHTTPStatusCodeNotFound = 404,
    kHTTPStatusCodeServiceUnavailable = 503
};

@interface RESTResources : NSObject

@property (nonatomic, strong) id<RESTResourceDelegate> delegate;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *recievedData;

- (id)initWithDelegate:(id<RESTResourceDelegate>)delegate;

- (void)startGetRequestWithUrl: (NSString *) url params:(NSDictionary *)params;
- (void)cancelRequest;

@end
