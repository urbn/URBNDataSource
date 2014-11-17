//
//  URBNProtoTableVC.h
//  URBNDataSource
//
//  Created by Joseph Ridenour on 11/17/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>


@class URBNArrayDataSourceAdapter;

/// These ids are used for our prototype cells in MainStoryboard.storyboard
extern NSString * const kProtoTableViewCell1_ID;
extern NSString * const kProtoTableViewCell2_ID;

/**
 *  This example shows an URBNArrayDataSource created from interface builder.
 *  This viewController is defined in the MainStoryboard.storyboard.
 *  We'll be using prototypeCells using the identifiers from above.
 */
@interface URBNProtoTableViewController : UITableViewController

/**
 *  We'll be creating our dataSourceAdapter from interface builder.
 */
@property (nonatomic, strong) IBOutlet URBNArrayDataSourceAdapter *adapter;

@end
