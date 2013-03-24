//
//  BNRBaseTableViewCell.m
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/24/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import "BNRBaseTableViewCell.h"
#import <objc/message.h>

@implementation BNRBaseTableViewCell

@synthesize controller, tableView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)routeSelector:(SEL)selector withSender:(id)sender
{
    [self dispatchAction:selector toOjbect:[self controller] withSender:sender];
}

- (void)dispatchAction:(SEL)action toOjbect:(id)target withSender:(id)sender
{
    SEL cmdAtIndexPathSelector = NSSelectorFromString([NSStringFromSelector(action) stringByAppendingString:@"atIndexPath:"]);
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:self];
    
//    NSLog(@"%@\rTarget:%@\rSender:%@\rIndexPath:%@", NSStringFromSelector(cmdAtIndexPathSelector), target, sender, indexPath);
    if ([target respondsToSelector:cmdAtIndexPathSelector]) {
        
        // Use objc_msgSend to get around ARC compiler warning
        objc_msgSend(target, cmdAtIndexPathSelector, sender, indexPath);
//        [target performSelector:cmdAtIndexPathSelector
//                     withObject:sender      //        _cmd:(id)sender
//                     withObject:indexPath]; // atIndexPath:(NSIndexPath *)indexPath
    }
}

@end
