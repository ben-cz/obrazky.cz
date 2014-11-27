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
    int _prevStatusBarSetting;
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
    
    _prevStatusBarSetting = [[UIApplication sharedApplication] statusBarStyle];
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
    finalImageSize = [self.animateImageDetailView getImageViewSize:imageThbView.image];
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

-(ImageDetailScrollerView *) createImageSlideView{
    ImageDetailScrollerView *scrollView = [[ImageDetailScrollerView alloc] initWithFrame:self.contentView.bounds];
    
    [self.contentView addSubview:scrollView];
    
    for (ImageInfo *imageInfo in self.imagesInfoList) {
        CGRect rec = self.contentView.bounds;
        ImageDetailView *idv = [[ImageDetailView alloc]initWithFrame: rec];
        [self.imageDetailViews addObject:idv];
        [idv setImageViewWithImageInfo:imageInfo];
        [scrollView addImageDetailView:idv ];
    }
    return scrollView;
}

#pragma mark button actions

-(void)dismissModalButtonAction:(id)sender{
    [[UIApplication sharedApplication] setStatusBarStyle:_prevStatusBarSetting];
    [self setNeedsStatusBarAppearanceUpdate];
    
    ImageListViewController *ilvc = (ImageListViewController *)self.parentViewController;
    [ilvc.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_currentShowPage inSection:0]
                          atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    
    self.view.hidden = YES;
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
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
