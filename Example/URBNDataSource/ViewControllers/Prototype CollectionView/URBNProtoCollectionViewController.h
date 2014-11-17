//
//  URBNProtoCollectionViewController.h
//  URBNDataSource
//
//  Created by Joseph Ridenour on 11/17/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class URBNArrayDataSourceAdapter;

/// These ids are used for our prototype cells in MainStoryboard.storyboard
extern NSString * const kProtoCollectionViewCell1_ID;
extern NSString * const kProtoCollectionViewCell2_ID;
extern NSString * const kProtoCollectionSupplementaryView1_ID;

/**
 *  This example shows an URBNArrayDataSource created from interface builder.
 *  This viewController is defined in the MainStoryboard.storyboard.
 *  We'll be using prototypeCells using the identifiers from above.
 */

@interface URBNProtoCollectionViewController : UICollectionViewController

/**
 *  This will be the dataSource of our collectionView.  
 *  We're creating this within the MainStoryboard.storyboard, and assigning 
 *  all the dataSource connections in there.
 **/
@property (nonatomic, strong) IBOutlet URBNArrayDataSourceAdapter *adapter;

@end
