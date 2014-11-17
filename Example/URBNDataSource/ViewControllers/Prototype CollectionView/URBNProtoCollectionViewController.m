//
//  URBNProtoCollectionViewController.m
//  URBNDataSource
//
//  Created by Joseph Ridenour on 11/17/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "URBNProtoCollectionViewController.h"
#import <URBNDataSource/URBNArrayDataSourceAdapter.h>

NSString * const kProtoCollectionViewCell1_ID           = @"kProtoCollectionViewCell1_ID";
NSString * const kProtoCollectionViewCell2_ID           = @"kProtoCollectionViewCell2_ID";
NSString * const kProtoCollectionSupplementaryView1_ID  = @"kProtoCollectionSupplementaryView1_ID";

@implementation URBNProtoCollectionViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES];
}

/**
 *  At this point we've already wired up all of our IB connections.
 *  All that's left to do is add our configuration blocks and our data.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    /// Since we're using prototype cells from the storyboard.  All we want to do is supply the identifier of our
    /// prototype cell.
    [self.adapter registerCellClass:nil withIdentifier:kProtoCollectionViewCell1_ID withConfigurationBlock:^(UICollectionViewCell *cell, id object, NSIndexPath *indexPath) {
        
        /// This label is setup in the storyboard.
        UILabel *l = (UILabel *)[cell viewWithTag:100];

        l.text = object;
    }];
    
    [self.adapter registerCellClass:nil withIdentifier:kProtoCollectionViewCell2_ID withConfigurationBlock:^(UICollectionViewCell *cell, id object, NSIndexPath *indexPath) {
        
        /// This label is setup in the storyboard.
        UILabel *l = (UILabel *)[cell viewWithTag:100];
        
        l.text = object;
    }];
    
    [self.adapter registerSupplementaryViewClass:nil ofKind:URBNSupplementaryViewTypeHeader withIdentifier:kProtoCollectionSupplementaryView1_ID withConfigurationBlock:^(UICollectionReusableView *view, URBNSupplementaryViewType kind, NSIndexPath *indexPath) {
        
        /// This label is created in the storyboard
        UILabel *l = (UILabel *)[view viewWithTag:100];
        
        l.text = [NSString stringWithFormat:@"Section Header %li", (long)indexPath.section];
    }];
    
    /// Since we have multiple identifiers we want to toggle between, we need to set this block and
    /// pass back the identifier we want to use
    __block NSArray *availableIds = @[kProtoCollectionViewCell1_ID, kProtoCollectionViewCell2_ID];
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


#pragma mark - CollectionView Fallback
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger numCols = 3;
    if(collectionView.bounds.size.width > 450) {
        numCols = 4;
    }
    
    CGFloat availableWidth = collectionView.bounds.size.width;
    availableWidth -= collectionView.contentInset.left;
    availableWidth -= collectionView.contentInset.right;
    availableWidth -= (collectionViewLayout.minimumInteritemSpacing * numCols);
    CGFloat size = availableWidth / numCols;
    return CGSizeMake(size, size);
}


@end
