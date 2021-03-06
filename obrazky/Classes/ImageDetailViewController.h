//
//  ImageDetailViewController.h
//  obrazky
//
//  Created by Jakub Dohnal on 24/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageInfo.h"
#import "ImageDetailView.h"
#import "ImageListViewController.h"
#import "ImageTVCell.h"
#import "ImageDetailScrollerView.h"

#define NAVBAR_HEIGHT 60

@interface ImageDetailViewController : UIViewController<UIScrollViewDelegate>

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) ImageDetailScrollerView *scrollView;

@property (strong, nonatomic) NSArray *imagesInfoList;
@property (strong, nonatomic) NSMutableArray *imageDetailViews;

@property (strong, nonatomic) UIImage *imageThb;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) ImageDetailView *animateImageDetailView;
@property (strong, nonatomic) UIImageView *imageView;


-(instancetype)initWithImageInfoList:(NSArray *) imagesInfoList;

-(void)showWithParentView:(id) parentViewController
                           imageThbView:(UIImageView *) imageThbView
                              imageInfo:(ImageInfo *) imageInfo;
@end