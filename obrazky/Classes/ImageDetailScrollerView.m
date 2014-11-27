//
//  ImageDetailScrollerView.m
//  obrazky
//
//  Created by Jakub Dohnal on 27/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import "ImageDetailScrollerView.h"

@implementation ImageDetailScrollerView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.pagingEnabled = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

-(void) addImageDetailView:(ImageDetailView *) view{
    CGRect frame = CGRectMake(self.contentSize.width, 0, view.frame.size.width, view.frame.size.height);
    view.frame = frame;
    
    [self addSubview:view];
    
    CGSize sizeScrollView = CGSizeMake(self.contentSize.width + view.frame.size.width, self.bounds.size.height);
    self.contentSize = sizeScrollView;
}

@end
