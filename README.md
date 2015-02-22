[![CI Status](http://img.shields.io/travis/urbn/URBNDataSource.svg?style=flat)](https://travis-ci.org/urbn/URBNDataSource)
[![Version](https://img.shields.io/cocoapods/v/URBNDataSource.svg?style=flat)](http://cocoadocs.org/docsets/URBNDataSource)
[![License](https://img.shields.io/cocoapods/l/URBNDataSource.svg?style=flat)](http://cocoadocs.org/docsets/URBNDataSource)
[![Platform](https://img.shields.io/cocoapods/p/URBNDataSource.svg?style=flat)](http://cocoadocs.org/docsets/URBNDataSource)

# URBNDataSource
URBNDataSource is a generic table/collection data source, useful when your data is an array of objects.  If this datasource's `tableView` or `collectionView` property is set to your tableview or collection view, the data source will perform insert/reload/delete calls when the data changes.  URBNDataSource can be used in `tableViews` or `collectionViews` defined in Nibs, Storyboards or programmatically.

## Usage
The URBNDataSource may be individually imported on an as needed basis. Add to your class in following fashion: ```#import <URBNDataSource/URBNArrayDataSourceAdapter.h>```

* __(NSArray *)allItems:__ This method used to return all items currently in the item array.

* __(void)appendItems:(NSArray *)newItems inSection:(NSInteger)section:__ Use this to add some more items to the end of the item array.

* __(void)insertItems:(NSArray *)newItems atIndexes:(NSIndexSet *)indexes inSection:(NSInteger)section:__ Use this to insert some items at specified indexes.

* __(void)replaceItems:(NSArray *)newItems:__ Use this to replace all items in the array.

* __(void)replaceItemAtIndexPath:(NSIndexPath *)indexPath withItem:(id)item:__ Use this to replace an item at a specific indexpath 

* __(void)removeItemsInRange:(NSRange)range inSection:(NSInteger)section:__ Use this to remove items in a specific range

* __(void)removeItemsAtIndexes:(NSIndexSet *)indexes inSection:(NSInteger)section:__ Use this to remove items at specific indexes

* __(void)removeItemAtIndexPath:(NSIndexPath *)indexPath:__ Use this to remove an item at a specific indexPath

* __(void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath:__ Use this to move an item to a new indexPath

* __(void)removeAllItems:__ Remove all objects in the item array.

* __(NSArray *)indexPathArrayWithRange:(NSRange)range inSection:(NSInteger)section:__ Returns an array of index paths with item set to values in the range param and section set to section param.

* __(NSArray *)indexPathArrayWithIndexSet:(NSIndexSet *)indexes inSection:(NSInteger)section:__ Returns an array of index paths with item set to the indexes in the indexes param and section set to section param.

##Sample Project
The sample project demonstrates how to use URBNDataSource with `tableViews` or `collectionViews` in Nibs, Storyboards and programmatically.

## Requirements
URBNDataSource has been tested on iOS 7 and up. Though it may work on lower deployment targets. ARC is required.

## Installation
URBNDataSource is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "URBNDataSource"

## License

URBNDataSource is available under the MIT license. See the LICENSE file for more info.

