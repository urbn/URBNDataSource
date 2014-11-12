//
//  URBNCodeCollectionViewController.h
//  URBNDataSource
//
//  Created by Joseph Ridenour on 11/12/14.
//  Copyright (c) 2014 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface URBNCodeCollectionViewController : UICollectionViewController

@end


/// This is a custom collectionView cell we'll be using to
/// show registration for a nib
@interface CustomCollectionCellFromNib : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UILabel *label;
@end