//
//  ImageDetailView.h
//  obrazky
//
//  Created by Jakub Dohnal on 25/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageInfo.h"

@interface ImageDetailView : UIScrollView <UIScrollViewDelegate>{
     CGRect imageViewFrame;
}

@property (nonatomic, strong) UIImageView *imageView;

-(void)resetImageZoom;
-(void) setImageViewWithImageInfo:(ImageInfo *)imageInfo;
-(CGSize)imageSizeToFit;
-(CGSize)getImageViewSize: (UIImage *)image;
@end
