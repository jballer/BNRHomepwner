//
//  HomepwnerItemCell.h
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/23/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNRBaseTableViewCell.h"

@interface HomepwnerItemCell : BNRBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

- (IBAction)showImage:(id)sender;

@end
