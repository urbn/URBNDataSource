//
//  URBNViewController.m
//  URBNDataSource
//
//  Created by Joe on 11/10/2014.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "URBNTableViewController.h"

@interface UIViewController (URBNDataSource)

/// Convenience method for setting up a dataSource based on a viewController
- (void)setupArrayDataSourceAdapter;
@end

@implementation URBNCollectionViewController


@end

@implementation URBNTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.adapter) {
        [self setupArrayDataSourceAdapter];
        UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)];
        self.navigationItem.rightBarButtonItem = addItem;
    }
}


#pragma mark - Actions

- (void)addItem
{
    /// Example of appending items to the dataSource
    /// This will automagically update the tableView
    [self.adapter appendItems:@[@(self.adapter.allItems.count).stringValue]];
}


#pragma mark - Adapter

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if([cell isKindOfClass:[CustomTableViewCell class]]) {
        /// The datasource also supports the same syntax for collectionView
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(200, 300);
        URBNCollectionViewController *vc = [[URBNCollectionViewController alloc] initWithCollectionViewLayout:layout];
        [vc setupArrayDataSourceAdapter];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        URBNTableViewController *vc = [[URBNTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [vc setupArrayDataSourceAdapter];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end


#pragma mark - DataSource setup

@implementation UIViewController(URBNDataSource)


- (void)setupArrayDataSourceAdapter
{
    BOOL isTableVC = [self isKindOfClass:[URBNTableViewController class]];
    BOOL isCollectionVC = [self isKindOfClass:[URBNCollectionViewController class]];
    
    if(!isTableVC && !isCollectionVC) return;
    
    URBNArrayDataSourceAdapter *ds = [[URBNArrayDataSourceAdapter alloc] initWithItems:@[@"1",@"2",@"3",@"4",@"5"]];
    [self setValue:ds forKey:@"adapter"];
    
    Class normalCellClass = isTableVC ? [UITableViewCell class] : [UICollectionViewCell class];
    Class customCellClass = isTableVC ? [CustomTableViewCell class] : [CustomCollectionViewCell class];
    
    /// If your datasource wants multiple cell types, then you MUST override this to pass back the proper cellClass based on the
    /// indexPath.
    [ds setCellClassBlock:^(id item, NSIndexPath *indexPath) {
        if((indexPath.row % 2) == 1) {
            return normalCellClass;
        } else {
            return customCellClass;
        }
    }];
    
    if(isTableVC) {
        // Setup for tableView
        URBNTableViewController *tvc = (URBNTableViewController *)self;
        /// You must set your tableView before registering cells
        ds.tableView = tvc.tableView;
        
        [ds registerCellClass:normalCellClass withConfigurationBlock:^(UITableViewCell *cell, id object, NSIndexPath *indexPath) {
            cell.textLabel.text = [NSString stringWithFormat:@"UITableViewCell %@ (%li, %li)", object, (long)indexPath.section, (long)indexPath.row];
        }];
        
        [ds registerCellClass:customCellClass withConfigurationBlock:^(CustomTableViewCell *cell, id object, NSIndexPath *indexPath) {
            cell.textLabel.textColor = cell.detailTextLabel.textColor = [UIColor orangeColor];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
            cell.textLabel.text = [NSString stringWithFormat:@"CustomCell (%li, %li)", (long)indexPath.section, (long)indexPath.row];
            cell.detailTextLabel.text = object;
        }];
        
        tvc.tableView.dataSource = ds;
    } else {
        // Setup for collectionView
        URBNCollectionViewController *cvc = (URBNCollectionViewController *)self;
        ds.collectionView = cvc.collectionView;
        
        [ds registerCellClass:normalCellClass withConfigurationBlock:^(UICollectionViewCell *cell, id object, NSIndexPath *indexPath) {
            cell.backgroundColor = [UIColor yellowColor];
        }];
        
        [ds registerCellClass:customCellClass withConfigurationBlock:^(CustomCollectionViewCell *cell, id object, NSIndexPath *indexPath) {
            cell.backgroundColor = [UIColor greenColor];
        }];
        
        cvc.collectionView.dataSource = ds;
    }
}


@end


#pragma mark - Custom Cell Holders

@implementation CustomTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}
@end
@implementation CustomCollectionViewCell @end