//
//  URBNCodeTableViewController.m
//  URBNDataSource
//
//  Created by Joseph Ridenour on 11/12/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "URBNCodeTableViewController.h"
#import <URBNDataSource/URBNArrayDataSourceAdapter.h>


@interface URBNCodeTableViewController()
@property (nonatomic, strong) URBNArrayDataSourceAdapter *adapter;
@end

@implementation URBNCodeTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *items = [NSMutableArray array];
    for(int i = 0; i < 50; i++)
    {
        [items addObject:[NSString stringWithFormat:@"Item %i", i]];
    }
    
    self.adapter = [[URBNArrayDataSourceAdapter alloc] initWithItems:items];
    self.adapter.fallbackDataSource = self;
    self.adapter.tableView = self.tableView;
    self.adapter.autoSizingEnabled = YES;
    
    /// If all of your cell classes are unique, then you can just call regsiter cell with that class.
    /// The identifier will be the className
    [self.adapter registerCellClass:[UITableViewCell class] withConfigurationBlock:^(UITableViewCell *cell, id object, NSIndexPath *indexPath) {
        cell.textLabel.text = object;
    }];
    
    /// Since this is a different subclass than the UITableViewCell we're doing above, there's no need to supply an identifier
    /// Since this Cell has a nib file, it will be instantiated from that nib as well. 
    [self.adapter registerCellClass:[CustomTableCellFromNib class] withConfigurationBlock:^(CustomTableCellFromNib *cell, id object, NSIndexPath *indexPath) {
        cell.textLabel.text = object;
        cell.detailTextLabel.text = cell.reuseIdentifier;
    }];
    
    /// Since we've registered an `UITableViewCell` above, we should supply an identifier for this cell
    [self.adapter registerCellClass:[UITableViewCell class] withIdentifier:@"My Identifier" withConfigurationBlock:^(UITableViewCell *cell, id object, NSIndexPath *indexPath) {
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.text = object;
    }];
    
    /// Here we're registering a reuseableTableHeaderView for our section headers.  Pretty sweet
    [self.adapter registerSupplementaryViewClass:[UITableViewHeaderFooterView class] ofKind:URBNSupplementaryViewTypeHeader
                          withConfigurationBlock:^(UITableViewHeaderFooterView *view, URBNSupplementaryViewType kind, NSIndexPath *indexPath) {
        
        if(view.tag == 0)
        {
            view.tag = 100;
            view.contentView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:.1f];
        }
        view.textLabel.textColor = [UIColor blackColor];
        view.textLabel.text = [NSString stringWithFormat:@"Table HeaderView %li", (long)indexPath.section];
    }];
    
    /// Here we're registering a reuseableTableHeaderView for our section footers.  Pretty sweet.
    /// Notice that we're not supplying an identifier here.  That's because it's not needed.
    /// Even though we're registering configuration blocks for the same class, since they're different kinds (`URBNSupplementaryViewTypeFooter` vs. `URBNSupplementaryViewTypeHeader`)
    /// we can ignore the identifier
    [self.adapter registerSupplementaryViewClass:[UITableViewHeaderFooterView class] ofKind:URBNSupplementaryViewTypeFooter withIdentifier:nil
                          withConfigurationBlock:^(UITableViewHeaderFooterView *view, URBNSupplementaryViewType kind, NSIndexPath *indexPath) {

        view.contentView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.1f];
        view.textLabel.text = [NSString stringWithFormat:@"Table footerView %li", (long)indexPath.section];
        view.textLabel.textColor = [UIColor blackColor];
    }];
    
    __block NSArray *cellIdentifiers = @[NSStringFromClass([UITableViewCell class]), NSStringFromClass([CustomTableCellFromNib class]), @"My Identifier"];
    /// Since we want more than  1 identifier, we need to supply an identifier configuration here.
    [self.adapter setCellIdentifierBlock:^NSString *(id item, NSIndexPath *indexPath) {
        return cellIdentifiers[(indexPath.item % cellIdentifiers.count)];
    }];
    
    self.tableView.sectionFooterHeight = 100.f;
    self.tableView.rowHeight = 20.f;

    self.tableView.delegate = self.adapter;
    self.tableView.dataSource = self.adapter;
}


/**
 *  This will toggle the data on the adapter to be sectioned
 *  or not.
 **/
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

- (IBAction)toggleAutoSizing:(UIBarButtonItem *)sender
{
    sender.title = [NSString stringWithFormat:@"AutoSizing: %@", self.adapter.autoSizingEnabled ? @"Off" : @"On"];
    self.adapter.autoSizingEnabled = !self.adapter.autoSizingEnabled;
    [self.tableView reloadData];
}

#pragma mark - Fallback Methods

/**
 *  Notice that regardless of autoSizingEnabled this method will take presedence
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 100.f;
}

@end



@implementation CustomTableCellFromNib @end