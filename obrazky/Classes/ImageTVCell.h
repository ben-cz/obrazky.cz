//
//  ImageCell.h
//  obrazky
//
//  Created by Jakub Dohnal on 21/11/14.
//  Copyright (c) 2014 dohnal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageTVCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *imageThbView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

@end
