//
//  RESTResourcesDelegate.h
//  obrazky
//
//  Created by Jakub Dohnal on 19/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RESTResources;

@protocol RESTResourceDelegate <NSObject>

@required
- (void)request:(RESTResources *)request didFinishWithData:(NSData *)resourceData;

@optional
- (void)request:(RESTResources *)request didReceiveHeader:(NSDictionary *)header statusCode:(NSInteger)statusCode;
- (void)requestDidFailLoading:(RESTResources *)request;
- (void)requestDidStart:(RESTResources *)request;
- (void)request:(RESTResources *)request didFinishWithError:(NSError *)error;

@end
