//
//  BNRBaseTableViewCell.h
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/24/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BNRBaseTableViewCell : UITableViewCell

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) id controller;

#define ROUTE(sender) [self routeSelector:_cmd withSender:sender];
- (void)routeSelector:(SEL)selector
           withSender:(id)sender;

- (void)dispatchAction:(SEL)action
              toOjbect:(id)target
            withSender:(id)sender;

@end
