//
//  ImageDetailView.m
//  obrazky
//
//  Created by Jakub Dohnal on 25/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import "ImageDetailView.h"

@implementation ImageDetailView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.bouncesZoom = YES;
        self.zoomScale = 1.0;
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = 4.0;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.delegate = self;
        self.contentMode = UIViewContentModeCenter;
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        [self addSubview:self.imageView];
    }
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

-(void)zoomBack{
    CGRect rec = self.imageView.frame;
    imageViewFrame = rec;
    [self resetImageZoom];
    //[self zoomToRect:imageViewFrame animated:NO];
}

-(void) setImageViewFrame: (CGRect) frame{
    [self.imageView setFrame: frame];
    [self.imageView setCenter: self.center];
}

-(void)resetImageZoom {
    NSLog(@"Resetting any image zoom");
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0, 1.0);
    self.transform = transform;
    self.imageView.transform = transform;
    [self setContentSize:CGSizeZero];
    //self.center = self.center;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
