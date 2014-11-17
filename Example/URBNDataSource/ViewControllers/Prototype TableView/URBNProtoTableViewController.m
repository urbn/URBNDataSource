//
//  URBNProtoTableVC.m
//  URBNDataSource
//
//  Created by Joseph Ridenour on 11/17/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "URBNProtoTableViewController.h"
#import <URBNDataSource/URBNArrayDataSourceAdapter.h>


NSString * const kProtoTableViewCell1_ID                = @"kProtoTableViewCell1_ID";
NSString * const kProtoTableViewCell2_ID                = @"kProtoTableViewCell2_ID";


@implementation URBNProtoTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /**
     *  At this point we've already wired up all of our IB connections.
     *  All that's left to do is add our configuration blocks and our data.
    */
    
    /// Since we're using prototype cells from the storyboard.  All we want to do is supply the identifier of our
    /// prototype cell.
    [self.adapter registerCellClass:nil withIdentifier:kProtoTableViewCell1_ID withConfigurationBlock:^(UITableViewCell *cell, id object, NSIndexPath *indexPath) {
        
        cell.textLabel.text = object;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"ProtoCell-1: '%@'", kProtoTableViewCell1_ID];
    }];
    
    [self.adapter registerCellClass:nil withIdentifier:kProtoTableViewCell2_ID withConfigurationBlock:^(UITableViewCell *cell, id object, NSIndexPath *indexPath) {
        
        cell.textLabel.text = object;
        cell.detailTextLabel.text = kProtoTableViewCell2_ID;
    }];
    
    URBNSupplementaryViewConfigureBlock config = ^(UITableViewHeaderFooterView *view, URBNSupplementaryViewType kind, NSIndexPath *ip) {
        
        NSString *type = kind == URBNSupplementaryViewTypeFooter ? @"Footer View" : @"Header View";
        view.contentView.backgroundColor = kind == URBNSupplementaryViewTypeFooter ? [UIColor greenColor] : [UIColor redColor];
        view.textLabel.text = [NSString stringWithFormat:@"%@ %li", type, (long)ip.section];
    };
    
    /// Storyboards do not currently support tableHeaderFooterViews.  So you'll have to pass in the class for now.
    [self.adapter registerSupplementaryViewClass:[UITableViewHeaderFooterView class] ofKind:URBNSupplementaryViewTypeHeader withConfigurationBlock:config];
    [self.adapter registerSupplementaryViewClass:[UITableViewHeaderFooterView class] ofKind:URBNSupplementaryViewTypeFooter withConfigurationBlock:config];

    
    /// Since we have multiple identifiers we want to toggle between, we need to set this block and
    /// pass back the identifier we want to use
    __block NSArray *availableIds = @[kProtoTableViewCell1_ID, kProtoTableViewCell2_ID];
    [self.adapter setCellIdentifierBlock:^NSString *(id item, NSIndexPath *indexPath) {
        return availableIds[(indexPath.row % availableIds.count)];
    }];
    
    
    /// Now populate our array of data.
    NSMutableArray *data = [NSMutableArray array];
    for (int i = 0; i < 4; i++) {
        [data addObject:[NSString stringWithFormat:@"Item %i", i]];
    }
    [self.adapter replaceItems:data];
}


#pragma mark - Actions
/**
 *  This will toggle the data on the adapter to be sectioned
 *  or not.
 */
- (IBAction)toggleSectionedData:(UIBarButtonItem *)sender
{
    NSArray *data = nil;
    if([self.adapter isSectioned])
    {
        /// We're not sectioned.  Let's make it sectioned
        data = @[@"Item 1", @"Item 2", @"Item 3", @"Item 4"];
    }
    else
    {
        /// We're already sectioned.  Make this a flat list
        data =
        @[
          @[@"Section 1 item 1", @"Section 1 Item 2"],   // Section1
          @[@"Section 2 item 1", @"Section 2 Item 2"],   // Section2
          @[@"Section 3 item 1", @"Section 3 Item 2"],   // Section3
          @[@"Section 4 item 1", @"Section 4 Item 2"]   // Section4
          ];
    }
    
    sender.title = [NSString stringWithFormat:@"Sections: %@", [self.adapter isSectioned] ? @"Off" : @"On"];
    /// Calling this method will automagically reload the table for us.
    [self.adapter replaceItems:data];
}

/**
 *  Here we're adding one item to the end of our items.
 *  The dataSource will take care of calling the proper tableView animation here.
 */
- (IBAction)insertItemAtFirstIndex {
    self.adapter.rowAnimation = UITableViewRowAnimationMiddle;
    
    NSTimeInterval t = [[NSDate date] timeIntervalSince1970];
    NSString *itemToInsert = [NSString stringWithFormat:@"Item %02f", t];
    [self.adapter insertItems:@[itemToInsert] atIndexes:[NSIndexSet indexSetWithIndex:0] inSection:0];
}

/**
 *  Here we're adding one item to the end of our items.
 *  The dataSource will take care of calling the proper tableView animation here.
 */
- (IBAction)addItem {
    self.adapter.rowAnimation = UITableViewRowAnimationRight;
    
    NSTimeInterval t = [[NSDate date] timeIntervalSince1970];
    NSString *itemToAppend = [NSString stringWithFormat:@"Item %02f", t];
    [self.adapter appendItems:@[itemToAppend] inSection:0];
}

/**
 *  Here we're going to move our first item in the allItems.  
 *  If we're sectioned we're going to move the item to the next section.
 *  Otherwise we'll just move 1 row
 *
 */
- (IBAction)moveItem {
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
    
    if([self.adapter isSectioned]) {
        nextIndexPath = [NSIndexPath indexPathForItem:0 inSection:1];
    }
    [self.adapter moveItemAtIndexPath:firstIndexPath toIndexPath:nextIndexPath];
}

/**
 *  We're going to replace the first item in our list with a new item.
 */
- (IBAction)replaceItems {
    NSTimeInterval t = [[NSDate date] timeIntervalSince1970];
    NSString *newItem = [NSString stringWithFormat:@"New Item %.02f", t];
    
    [self.adapter replaceItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] withItem:newItem];
}

#pragma mark - Fallback TableView
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        /// This is how we would remove 1 item from our adapter.
        self.adapter.rowAnimation = UITableViewRowAnimationAutomatic;
        [self.adapter removeItemAtIndexPath:indexPath];
    }
}

@end
