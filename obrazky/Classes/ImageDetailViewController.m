//
//  ImageDetailViewController.m
//  obrazky
//
//  Created by Jakub Dohnal on 24/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import "ImageDetailViewController.h"

@interface ImageDetailViewController (){
    NSUInteger _currentShowPage;
    UINavigationBar *_navBar;
    BOOL _navBarShow;
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
    
    UITapGestureRecognizer *singleTapOnImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapDetected:)];
    singleTapOnImage.numberOfTapsRequired = 1;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:singleTapOnImage];
    
    [UIBarButtonItem appearance].tintColor = [UIColor whiteColor];
    [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void) setControllView{
    _navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, NAVBAR_HEIGHT)];
    [self.view addSubview:_navBar];
    
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
    _navBar.items = [NSArray arrayWithObjects: navigItem,nil];
    _navBarShow = YES;
}

-(void)showWithParentView:(ImageListViewController *) parentViewController
                           imageThbView:(UIImageView *) imageThbView
                              imageInfo:(ImageInfo *) imageInfo{
    _currentShowPage = [self.imagesInfoList indexOfObject:imageInfo];
    
    CGRect finalImageFrame;
    
    NSUInteger index = [self.imagesInfoList indexOfObject:imageInfo];
    CGRect screenFrame = parentViewController.view.bounds;
    CGRect contentFrame = CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.height);
    
    self.view.frame = screenFrame;
    self.contentView.frame = contentFrame;
    
    self.view.hidden = NO;
    self.view.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    [parentViewController addChildViewController:self];
    [parentViewController.view addSubview:self.view];
    
    
    self.animateImageDetailView = [[ImageDetailView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.animateImageDetailView];

    
    //get curent image position
    CGPoint center = [self.contentView convertPoint:imageThbView.center fromView:imageThbView.superview];
    CGSize imageSize = imageThbView.image.size;
    float scale = imageThbView.frame.size.height/imageSize.height;
    CGRect imageViewRect = CGRectMake(0, 0, imageSize.width*scale, imageSize.height*scale);
    self.animateImageDetailView.imageView.image = imageThbView.image;
    self.animateImageDetailView.imageView.frame = imageViewRect;
    self.animateImageDetailView.imageView.center = center;

    //get scale
    CGSize finalImageSize;
    finalImageSize = [self sizeThatFitsInSize:[self imageSizeToFit] initialSize:imageThbView.image.size];
    float scaleFinal = finalImageSize.width/imageViewRect.size.width;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.animateImageDetailView.imageView.center = self.animateImageDetailView.center;
                         self.animateImageDetailView.imageView.transform=CGAffineTransformMakeScale(scaleFinal, scaleFinal);
                         
                         self.view.layer.backgroundColor = [UIColor blackColor].CGColor;
                     }
                     completion:^(BOOL finished) {
                         self.scrollView = [self createImageSlideView];
                         [self.scrollView setContentOffset:CGPointMake((index)*self.contentView.frame.size.width, 0) animated:NO];
                         self.animateImageDetailView.hidden = YES;
                         
                         [self setControllView];
                     }];
    
    
}

-(UIScrollView *) createImageSlideView{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    
    [self.contentView addSubview:scrollView];
    
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    for (ImageInfo *imageInfo in self.imagesInfoList) {
        CGRect rec = self.contentView.bounds;
        ImageDetailView *idv = [[ImageDetailView alloc]initWithFrame: rec];
        [self.imageDetailViews addObject:idv];
        [self setImage:[[UIImage alloc] init] toImageDetailView:idv];
        [self cacheImage:imageInfo setToImageDetailView:idv];
        [self addRightToScrollView:scrollView view:idv];
    }
    return scrollView;
}

-(void) setImage:(UIImage *)image toImageDetailView:(ImageDetailView *)imageDetailView{
    CGRect frame;
    CGSize size = [self sizeThatFitsInSize:[self imageSizeToFit] initialSize:image.size];
    frame.size = size;
    frame.origin.x = 0;
    frame.origin.y = 0;
    [imageDetailView setImageViewFrame:frame];
    
    [imageDetailView.imageView setImage: image];

}

-(CGSize)imageSizeToFit{
    return CGSizeMake(self.contentView.bounds.size.width, self.contentView.bounds.size.height - (2*NAVBAR_HEIGHT));
}

-(void) addRightToScrollView: (UIScrollView *) scrollView view:(UIView *)view{
    
    CGRect frame = CGRectMake(scrollView.contentSize.width, 0, view.frame.size.width, view.frame.size.height);
    view.frame = frame;
    
    [scrollView addSubview:view];
    
    CGSize sizeScrollView = CGSizeMake(scrollView.contentSize.width + view.frame.size.width, scrollView.bounds.size.height);
    scrollView.contentSize = sizeScrollView;
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
    }ImageListViewController *ilvc = (ImageListViewController *)self.parentViewController;
    [ilvc.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_currentShowPage inSection:0]
                          atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    self.view.hidden = YES;
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    /*
    // Image animation
    
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
                         self.view.hidden = YES;
                         [self.view removeFromSuperview];
                         [self removeFromParentViewController];
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
            
            /***
             call reset zoom
            //ImageDetailView *idv = [self.imageDetailViews objectAtIndex:previousPage];
            //[idv zoomBack];
            ***/
            
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

-(void)imageTapDetected: (UIGestureRecognizer *)gestureRecognizer{
    if (_navBarShow) {
        CGRect finalFrame = CGRectMake(_navBar.frame.origin.x, -_navBar.frame.size.height, _navBar.frame.size.width, _navBar.frame.size.height);
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             _navBar.frame = finalFrame;
                         }
                         completion:nil];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        _navBarShow = NO;
    }
    else{
        CGRect finalFrame = CGRectMake(_navBar.frame.origin.x, 0, _navBar.frame.size.width, _navBar.frame.size.height);
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             _navBar.frame = finalFrame;
                         }
                         completion:nil];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        _navBarShow = YES;
    }
}


@end
