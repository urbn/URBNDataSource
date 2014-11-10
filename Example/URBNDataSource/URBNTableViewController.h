//
//  URBNViewController.h
//  URBNDataSource
//
//  Created by Joe on 11/10/2014.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <URBNDataSource/URBNArrayDataSourceAdapter.h>

@interface URBNTableViewController : UITableViewController
@property (nonatomic, strong) URBNArrayDataSourceAdapter *adapter;
@end




@interface URBNCollectionViewController : UICollectionViewController
@property (nonatomic, strong) URBNArrayDataSourceAdapter *adapter;
@end


/// Holder classes
@interface  CustomCollectionViewCell : UICollectionViewCell @end
@interface  CustomTableViewCell : UITableViewCell @end