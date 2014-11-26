//
//  ImageListResources.h
//  obrazky
//
//  Created by Jakub Dohnal on 19/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageListResourcesDelegate.h"
#import "RESTResourcesDelegate.h"
#import "RESTResources.h"
#import "TFHpple.h"
#import "ImageInfo.h"

#define URL_OBRAZKY @"http://obrazky.cz/searchAjax"

@interface ImageListResources : NSObject <RESTResourceDelegate>

@property (nonatomic, strong) id<ImageListResourcesDelegate> delegate;

-(id) initWithDelegate: (id<ImageListResourcesDelegate>) delegate;
-(void)getImagesInfoListFilterName: (NSString *)filterName from: (NSInteger)from step: (NSInteger) step;
@end
