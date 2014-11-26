//
//  ImageListResourcesDelegate.h
//  obrazky
//
//  Created by Jakub Dohnal on 19/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageListResources;

@protocol ImageListResourcesDelegate <NSObject>

- (void)request:(ImageListResources *)request didFinishWithImageList:(NSArray *)imageList;

@optional
- (void)requestDidFailLoading:(ImageListResources *)request;
- (void)request:(ImageListResources *)request didFinishWithError:(NSError *)error;

@end
