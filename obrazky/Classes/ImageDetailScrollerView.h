//
//  ImageDetailScrollerView.h
//  obrazky
//
//  Created by Jakub Dohnal on 27/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDetailView.h"

@interface ImageDetailScrollerView : UIScrollView

-(void) addImageDetailView:(ImageDetailView *) view;

@end
