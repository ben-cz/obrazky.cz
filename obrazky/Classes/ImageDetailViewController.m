//
//  ImageDetailViewController.m
//  obrazky
//
//  Created by Jakub Dohnal on 24/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import "ImageDetailViewController.h"

@interface ImageDetailViewController (){
    NSUInteger _currentShowPage, _prevShowPage;
    UINavigationController *_navController;
}

@end

@implementation ImageDetailViewController

-(instancetype)initWithImageInfoList:(NSArray *) imagesInfoList{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.imagesInfoList = imagesInfoList;
        self.imageDetailViews = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)loadView{
    
    self.view = [[UIView alloc] init];
    self.contentView = [[UIView alloc] init];
    
    [self.view addSubview:self.contentView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIBarButtonItem appearance].tintColor = [UIColor whiteColor];
    [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void) setControllView{
    UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 50)];
    [self.contentView addSubview:navBar];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self action:@selector(dismissModalButtonAction:)];
    
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                  target:self
                                  action:@selector(shareAction:)];
    
    
    
    UINavigationItem *navigItem = [[UINavigationItem alloc] initWithTitle:@""];
    navigItem.rightBarButtonItem = shareItem;
    navigItem.leftBarButtonItem = doneItem;
    navBar.items = [NSArray arrayWithObjects: navigItem,nil];
}

-(void)startAnimationShowWithParentView:(UIViewController *) parentViewController
                           imageThbView:(UIImageView *) imageThbView
                              imageInfo:(ImageInfo *) imageInfo{
    _currentShowPage = [self.imagesInfoList indexOfObject:imageInfo];
    
    CGSize size;
    CGRect finalImageFrame;
    CGPoint center;
    
    NSUInteger index = [self.imagesInfoList indexOfObject:imageInfo];
    CGRect screenFrame = parentViewController.view.bounds;
    CGRect contentFrame = CGRectMake(0, 10, screenFrame.size.width, screenFrame.size.height - 10);
    
    self.view.frame = screenFrame;
    self.contentView.frame = contentFrame;
    
    self.view.hidden = NO;
    self.view.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    [parentViewController addChildViewController:self];
    [parentViewController.view addSubview:self.view];
    
    self.animateImageDetailView = [[ImageDetailView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.animateImageDetailView];
    
    center = [self.animateImageDetailView convertPoint:imageThbView.center fromView:imageThbView.superview];
    self.animateImageDetailView.imageView.frame = imageThbView.bounds;
    self.animateImageDetailView.imageView.center = center;
    self.animateImageDetailView.imageView.image = imageThbView.image;

    finalImageFrame = self.contentView.bounds;
    size = [self sizeThatFitsInSize:finalImageFrame.size initialSize:imageThbView.image.size];
    finalImageFrame.size = size;
    finalImageFrame.origin.x = 0;
    finalImageFrame.origin.y = 0;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         CGRect frame;
                         
                         frame = finalImageFrame;
                         self.animateImageDetailView.imageView.frame = finalImageFrame;
                         self.animateImageDetailView.imageView.center = self.animateImageDetailView.center;
                         self.view.layer.backgroundColor = [UIColor blackColor].CGColor;
                     }
                     completion:^(BOOL finished) {
                         [self createImageSlideView];
                         [self.scrollView setContentOffset:CGPointMake((index)*self.contentView.frame.size.width, 0) animated:NO];
                         self.animateImageDetailView.hidden = YES;
                         [self setControllView];
                     }];
    
    
}

-(void) createImageSlideView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    
    [self.contentView addSubview:self.scrollView];
    
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    for (ImageInfo *imageInfo in self.imagesInfoList) {
        CGRect rec = self.contentView.bounds;
        ImageDetailView *idv = [[ImageDetailView alloc]initWithFrame: rec];
        [self.imageDetailViews addObject:idv];
        [self setImage:[[UIImage alloc] init] toImageDetailView:idv];
        [self cacheImage:imageInfo setToImageDetailView:idv];
        [self addRightToScrollListView:idv];
    }
}

-(void) setImage:(UIImage *)image toImageDetailView:(ImageDetailView *)imageDetailView{
    CGRect frame;
    CGSize size = [self sizeThatFitsInSize:imageDetailView.frame.size initialSize:image.size];
    frame.size = size;
    frame.origin.x = 0;
    frame.origin.y = 0;
    [imageDetailView setImageViewFrame:frame];
    
    [imageDetailView.imageView setImage: image];

}

-(void) addRightToScrollListView:(UIView *)view{
    
    CGRect frame = CGRectMake(self.scrollView.contentSize.width, 0, view.frame.size.width, view.frame.size.height);
    view.frame = frame;
    
    [self.scrollView addSubview:view];
    
    CGSize sizeScrollView = CGSizeMake(self.scrollView.contentSize.width + view.frame.size.width, self.scrollView.bounds.size.height);
    self.scrollView.contentSize = sizeScrollView;
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

#pragma mark button actions

-(void)dismissModalButtonAction:(id)sender{
    if ([self.delegate respondsToSelector:@selector(imageDetailViewControllerWillClose:)]) {
        [self.delegate imageDetailViewControllerWillClose:self];
    }
    
    ImageListViewController *ilvc = (ImageListViewController *)self.parentViewController;
    [ilvc.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_currentShowPage inSection:0]
                          atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    
    self.view.hidden = YES;
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    /*
    ImageTVCell *cell = (ImageTVCell *)[ilvc.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentShowPage inSection:0]];
    
    ImageDetailView *imageDetailView = [self.imageDetailViews objectAtIndex:_currentShowPage];
    
    CGRect finalImageFrame;
    CGPoint center = [self.contentView convertPoint:cell.imageView.center fromView:cell.imageView.superview];
    CGSize size = cell.imageView.frame.size;
    finalImageFrame.size = size;
    finalImageFrame.origin.x = 0;
    finalImageFrame.origin.y = 0;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         CGRect frame;
                         
                         frame = finalImageFrame;
                         imageDetailView.imageView.frame = finalImageFrame;
                         imageDetailView.imageView.center = center;
                         self.view.layer.backgroundColor = [UIColor clearColor].CGColor;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
     */
}

- (void) shareAction:(id) sender{
    ImageInfo *imageInfo = [self.imagesInfoList objectAtIndex:_currentShowPage];
    
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    [sharingItems addObject:imageInfo.image];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark detection page

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    static NSUInteger previousPage = 0;
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    if (previousPage != page) {
        // Page has changed, do your thing!
        if(previousPage < [self.imageDetailViews count]){
            _currentShowPage = page;
            ImageDetailView *idv = [self.imageDetailViews objectAtIndex:previousPage];
            //[idv zoomBack];
        }
        // Finally, update previous page
        previousPage = page;
    }
}

#pragma mark cache

- (void) cacheImage:(ImageInfo *) imageInfo setToImageDetailView:(ImageDetailView *)imageDetailView{
    __block NSUInteger idx = [self.imageDetailViews indexOfObject:imageDetailView];
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
                        idx = [[self.scrollView subviews] indexOfObject:imageDetailView];
                        if (idx) {
                            [imageDetailView.imageView setImage:imageDownload];
                        }
                    });
                }
            }
        });
    }
    else{
        image = [imageInfo image];
    }
    
    if (image != nil) {
        [self setImage:image toImageDetailView:imageDetailView];
    }
}


@end
