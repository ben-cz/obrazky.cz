//
//  ImageListViewController.h
//  obrazky
//
//  Created by Jakub Dohnal on 26/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

@class ImageDetailViewController;

@protocol ImageDetailViewControllerDelegate <NSObject>

@optional
-(void) imageDetailViewControllerWillClose:(ImageDetailViewController *) imageDetailController;

@end
