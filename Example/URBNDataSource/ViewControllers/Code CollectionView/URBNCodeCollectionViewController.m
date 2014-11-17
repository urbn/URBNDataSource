//
//  URBNCodeCollectionViewController.m
//  URBNDataSource
//
//  Created by Joseph Ridenour on 11/12/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import "URBNCodeCollectionViewController.h"
#import <URBNDataSource/URBNArrayDataSourceAdapter.h>

@interface URBNCodeCollectionViewController ()
@property (nonatomic, strong) URBNArrayDataSourceAdapter *adapter;
@end

@implementation URBNCodeCollectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    layout.headerReferenceSize = CGSizeMake(300.f, 50.f);
    layout.footerReferenceSize = CGSizeMake(300.f, 50.f);
    
    self.adapter = [[URBNArrayDataSourceAdapter alloc] initWithItems:@[@"Item 1",@"Item 2",@"Item 3",@"Item 4"]];
    self.adapter.fallbackDataSource = self;
    self.adapter.collectionView = self.collectionView;
    
    /// If all of your cell classes are unique, then you can just call regsiter cell with that class.
    /// The identifier will be the className
    [self.adapter registerCellClass:[UICollectionViewCell class] withConfigurationBlock:^(UICollectionViewCell *cell, id object, NSIndexPath *indexPath) {
        
        cell.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:.8f];
        UILabel *label = (UILabel *)[cell viewWithTag:100];
        
        if(!label)
        {
            label = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
            label.tag = 100;
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:30];
            label.textColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label];
        }
        
        label.text = object;
    }];
    
    /// Since this is a different subclass than the UITableViewCell we're doing above, there's no need to supply an identifier
    /// Since this Cell has a nib file, it will be instantiated from that nib as well.
    [self.adapter registerCellClass:[CustomCollectionCellFromNib class] withConfigurationBlock:^(CustomCollectionCellFromNib *cell, id object, NSIndexPath *indexPath) {
        cell.label.text = [NSString stringWithFormat:@"Custom Cell %@", object];
    }];
    
    /// Since we've registered an `UICollectionViewCell` above, we should supply an identifier for this cell
    [self.adapter registerCellClass:[UICollectionViewCell class] withIdentifier:@"My Identifier" withConfigurationBlock:^(UICollectionViewCell *cell, id object, NSIndexPath *indexPath) {
        
        cell.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.8f];
        UILabel *label = (UILabel *)[cell viewWithTag:100];
        
        if(!label)
        {
            label = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
            label.tag = 100;
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:30];
            label.textColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label];
        }
        
        label.text = object;
    }];
    
    /// Here we're registering a reuseableView for our section headers.  Pretty sweet
    [self.adapter registerSupplementaryViewClass:[UICollectionReusableView class] ofKind:URBNSupplementaryViewTypeHeader withConfigurationBlock:^(UICollectionReusableView *view, URBNSupplementaryViewType kind, NSIndexPath *indexPath) {
        
        view.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:.8f];
        view.layer.borderWidth = 1.f;
        UILabel *label = (UILabel *)[view viewWithTag:100];
        
        if(!label)
        {
            label = [[UILabel alloc] initWithFrame:view.bounds];
            label.tag = 100;
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:30];
            label.textColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
        }
        
        label.text = [NSString stringWithFormat:@"Header for section %li", (long)indexPath.section];
    }];
    
    /// Here we're registering a reuseableTableHeaderView for our section footers.  Pretty sweet.
    /// Notice that we're not supplying an identifier here.  That's because it's not needed.
    /// Even though we're registering configuration blocks for the same class, since they're different kinds (`URBNSupplementaryViewTypeFooter` vs. `URBNSupplementaryViewTypeHeader`)
    /// we can ignore the identifier
    [self.adapter registerSupplementaryViewClass:[UICollectionReusableView class] ofKind:URBNSupplementaryViewTypeFooter withConfigurationBlock:^(UICollectionReusableView *view, URBNSupplementaryViewType kind, NSIndexPath *indexPath) {
        
        view.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:.8f];
        view.layer.borderWidth = 1.f;
        UILabel *label = (UILabel *)[view viewWithTag:100];
        
        if(!label)
        {
            label = [[UILabel alloc] initWithFrame:view.bounds];
            label.tag = 100;
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:30];
            label.textColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
        }
        
        label.text = [NSString stringWithFormat:@"Footer for section %li", (long)indexPath.section];
    }];
    
    __block NSArray *cellIdentifiers = @[NSStringFromClass([UICollectionViewCell class]), NSStringFromClass([CustomCollectionCellFromNib class]), @"My Identifier"];
    /// Since we want more than  1 identifier, we need to supply an identifier configuration here.
    [self.adapter setCellIdentifierBlock:^NSString *(id item, NSIndexPath *indexPath) {
        return cellIdentifiers[(indexPath.item % cellIdentifiers.count)];
    }];
    
    self.collectionView.dataSource = self.adapter;
}


#pragma mark - Actions

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


@end


@implementation CustomCollectionCellFromNib @end