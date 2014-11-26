//
//  ImageInfo.h
//  obrazky
//
//  Created by Jakub Dohnal on 21/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageInfo : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *urlThb;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *sizeStr;
@property (nonatomic, retain) UIImage *imageThb;
@property (nonatomic, retain) UIImage *image;

-(id)initWithName: (NSString *)name sizeStr: (NSString *)sizeStr url:(NSString *)url urlThb: (NSString *)urlThb;

@end
