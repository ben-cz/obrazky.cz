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

-(void) setImageViewWithImageInfo:(ImageInfo *)imageInfo{
    UIImage *image;
    if([imageInfo image] == nil){
        if ([imageInfo imageThb] == nil) {
            image = nil;
        }
        else{
            image = [imageInfo imageThb];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString: imageInfo.url]];
            if (imgData) {
                UIImage *imageDownload = [UIImage imageWithData:imgData];
                if (imageDownload) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [imageInfo setImage:imageDownload];
                        [self setImage:imageDownload];
                        [self setNeedsDisplay];
                        [self.imageView setNeedsDisplay];
                    });
                }
            }
        });
    }
    else{
        image = [imageInfo image];
    }
    
    [self setImage:image];
}

-(void) setImage:(UIImage *)image{
    CGRect frame;
    CGSize size = [self getImageViewSize:image];
    frame.size = size;
    frame.origin.x = 0;
    frame.origin.y = 0;
    [self.imageView setFrame:frame];
    [self.imageView setCenter:self.center];
    
    [self.imageView setImage: image];
    
}

-(CGSize)getImageViewSize: (UIImage *)image{
    return [self sizeThatFitsInSize:[self imageSizeToFit:0] initialSize:image.size];
}

- (CGSize)sizeThatFitsInSize:(CGSize)boundingSize initialSize:(CGSize)initialSize
{
    if (initialSize.width == 0 || initialSize.height == 0 ) {
        return CGSizeZero;
    }
    
    CGSize fittingSize;
    
    CGFloat widthRatio;
    CGFloat heightRatio;
    
    widthRatio = boundingSize.width / initialSize.width;
    heightRatio = boundingSize.height / initialSize.height;
    
    if (widthRatio < heightRatio){
        fittingSize = CGSizeMake(boundingSize.width, floorf(initialSize.height * widthRatio));
    }
    else{
        fittingSize = CGSizeMake(floorf(initialSize.width * heightRatio), boundingSize.height);
    }
    
    return fittingSize;
}

-(CGSize)imageSizeToFit:(float) topBottomPadding{
    return CGSizeMake(self.bounds.size.width, self.bounds.size.height - (2*topBottomPadding));
}

-(void)resetImageZoom {
    NSLog(@"Resetting any image zoom");
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0, 1.0);
    self.transform = transform;
    self.imageView.transform = transform;
    [self setContentSize:CGSizeZero];
    //self.center = self.center;
}

@end
