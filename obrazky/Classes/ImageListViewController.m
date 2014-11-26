//
//  ImagesTVC.m
//  obrazky
//
//  Created by Jakub Dohnal on 19/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import "ImageListViewController.h"

@interface ImageListViewController (){
    ImageListResources *_imageResources;
    BOOL _isSetSearchRequest;
    NSString *_searchQuery;
}

@end

@implementation ImageListViewController

@synthesize imageSearchBar;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imagesInfoList = [[NSMutableArray alloc] init];
    
    _imageResources = [[ImageListResources alloc] initWithDelegate:self];
    _isSetSearchRequest = NO;
    
    //DEBUG
    _searchQuery = @"ipad";
    [self searchImagesInfo: _searchQuery];
    self.viewPlaceholder = [self createViewPlaceholder];
}

-(UIView *)createViewPlaceholder{
    UIView *viewPlaceholder = [[UIView alloc]initWithFrame: self.tableView.frame];
    viewPlaceholder.backgroundColor = [UIColor whiteColor];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator startAnimating];
    activityIndicator.center = viewPlaceholder.center;
    
    [viewPlaceholder addSubview:activityIndicator];
    return viewPlaceholder;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"%@", tableView);
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"[self.imagesInfoList count] %d", [self.imagesInfoList count]);
    NSInteger numberOfRows;
    numberOfRows = [self.imagesInfoList count] + 1;
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"refresh row: %d", indexPath.row);
    if (indexPath.row == [self.imagesInfoList count]) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicator startAnimating];
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell addSubview:activityIndicator];
        activityIndicator.center = cell.center;
        
        if (_isSetSearchRequest) {
            [self searchNextImagesInfo];
        }
        
        return cell;
    }
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ImageViewCell" owner:self options:nil];
    ImageTVCell *cell = [nib objectAtIndex:0];
    
    // Configure the cell...
    ImageInfo *imgInfo = [self.imagesInfoList objectAtIndex:indexPath.row];
    [cell.nameLabel setText:imgInfo.name ];
    [cell.sizeLabel setText:imgInfo.sizeStr ];
    
    //Tap recognizer
    UITapGestureRecognizer *singleTapOnImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapDetected:)];
    singleTapOnImage.numberOfTapsRequired = 1;
    [cell.imageThbView setUserInteractionEnabled:YES];
    [cell.imageThbView addGestureRecognizer:singleTapOnImage];
    [cell.imageThbView setTag:indexPath.row];
    
    //Set image
    [self setImage:imgInfo forImageView:cell.imageThbView];
    [cell setNeedsDisplay];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger height;
    if (indexPath.row == [self.imagesInfoList count]) {
        height = 52;
    }
    else{
        height = 200 + 52;
    }
    return height;
}

#pragma mark image cache
//Image thb cacher
-(void) setImage:(ImageInfo *) imageInfo forImageView:(UIImageView *)imageView{
    if(imageInfo.imageThb == nil){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString: imageInfo.urlThb]];
            if (imgData) {
                UIImage *imgThbn = [UIImage imageWithData:imgData];
                if (imgThbn) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageInfo.imageThb = imgThbn;
                        [imageView setImage:imgThbn];
                        CGRect rec= imageView.frame;
                        imageView.frame = rec;
                    });
                }
            }
        });
    }
    else{
        [imageView setImage:imageInfo.imageThb];
    }
}

#pragma mark get image list
-(void) searchImagesInfo:(NSString *) searchQuery{
    _searchQuery = searchQuery;
    [_imageResources getImagesInfoListFilterName:searchQuery from:SEARCH_FROM step:SEARCH_STEP];
}

-(void) searchNextImagesInfo{
    [_imageResources getImagesInfoListFilterName:_searchQuery from:[self.imagesInfoList count] step:SEARCH_STEP];
}

#pragma mark searchButton

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    _isSetSearchRequest = NO;
    [self.tableView setContentOffset:CGPointZero animated:YES];
    [self.imagesInfoList removeAllObjects];
    [self.tableView reloadData];
    [self searchImagesInfo:[searchBar text]];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.view addSubview: self.viewPlaceholder];
    self.tableView.hidden = YES;
}

#pragma mark request call back

-(void)request:(ImageListResources *)request didFinishWithImageList:(NSArray *)imageList{
    _isSetSearchRequest = YES;
    [self.imagesInfoList addObjectsFromArray: imageList];
    
    [self.tableView reloadData];
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationFade];
    [self.viewPlaceholder removeFromSuperview];
    self.tableView.hidden = NO;
}

- (void)requestDidFailLoading:(RESTResources *)request{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Error", nil)
                          message:NSLocalizedString(@"Err network", nil)
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                          otherButtonTitles:nil];
    [alert show];
}

- (void)request:(RESTResources *)request didFinishWithError:(NSError *)error{
    NSString *errMsg = [NSString stringWithFormat:NSLocalizedString(@"Err server return: %d", nil), error.code ];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Error", nil)
                          message:errMsg
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark image tap
-(void)imageTapDetected: (UIGestureRecognizer *)gestureRecognizer {
    
    UIImageView *imageView = (UIImageView *)gestureRecognizer.view;
    ImageDetailViewController *detailViewController = [[ImageDetailViewController alloc] initWithImageInfoList:self.imagesInfoList];
    detailViewController.delegate = self;
    ImageInfo *imageInfo = [self.imagesInfoList objectAtIndex:imageView.tag];
    [detailViewController startAnimationShowWithParentView:self imageThbView:imageView imageInfo:imageInfo];
}

#pragma mark ImageDetailViewControllerDelegate
-(void)imageDetailViewControllerWillClose:(ImageDetailViewController *)imageDetailController{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self setNeedsStatusBarAppearanceUpdate];
}
@end
