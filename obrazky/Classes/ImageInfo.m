//
//  ImageInfo.m
//  obrazky
//
//  Created by Jakub Dohnal on 21/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import "ImageInfo.h"


@implementation ImageInfo

-(id)initWithName: (NSString *)name
                        sizeStr: (NSString *)sizeStr
                            url:(NSString *)url
                         urlThb: (NSString *)urlThb{
    self = [super init];
    if (self) {
        self.name = name;
        self.sizeStr = sizeStr;
        self.url = url;
        self.urlThb = urlThb;
        
        self.imageThb = nil;
        self.image = nil;
    }
    
    return self;
}

@end
