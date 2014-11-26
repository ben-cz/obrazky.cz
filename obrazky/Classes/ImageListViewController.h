//
//  ImagesTVC.h
//  obrazky
//
//  Created by Jakub Dohnal on 19/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageListResources.h"
#import "ImageTVCell.h"
#import "ImageInfo.h"
#import "ImageDetailViewController.h"
#import "ImageDetailViewControllerDelegate.h"

#define CELL_IDENTIFIER @"imageCell"

#define SEARCH_FROM 1
#define SEARCH_STEP 10

@interface ImageListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate, ImageListResourcesDelegate, ImageDetailViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property IBOutlet UISearchBar *imageSearchBar;
@property (nonatomic, strong) NSMutableArray *imagesInfoList;
@property (nonatomic, strong) UIView *viewPlaceholder;

@end
