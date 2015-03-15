# URBNDataSource

[![CI Status](http://img.shields.io/travis/urbn/URBNDataSource.svg?style=flat)](https://travis-ci.org/urbn/URBNDataSource)
[![Version](https://img.shields.io/cocoapods/v/URBNDataSource.svg?style=flat)](http://cocoadocs.org/docsets/URBNDataSource)
[![License](https://img.shields.io/cocoapods/l/URBNDataSource.svg?style=flat)](http://cocoadocs.org/docsets/URBNDataSource)
[![Platform](https://img.shields.io/cocoapods/p/URBNDataSource.svg?style=flat)](http://cocoadocs.org/docsets/URBNDataSource)

# URBNDatasource

An abstraction layer for manipulating UITableView and UICollectionView with a single api.  

## Usage
The concept of URBNDataSource is to unify the methods of registering / configuring UITableView and UICollectionView.   Along with that we added in block-based configuration for your cells to make you're cell setup nice and neat. 

### Classes
* __URBNDataSourceAdapter:__  This is an abstract class.   This is for wrapping up all of the base logic around registering cells, and storing configuration blocks.   You cannot use this class directly.

* __URBNArrayDataSourceAdapter:__  This is a subclass of URBNDataSource that's built around an array (or array of array) of items.   This dataSource will fit for most all of the basic needs.


### Registering Cells

We have a couple of methods for registering cells.   

```
-registerCellClass: withIdentifier: withConfigurationBlock:
```
This is the main cell registration call.   You give the cell class you want to use, the identifier you want to use with that cell, and a configuration block that will get called whenever cellForItem or cellForRow gets called.   

** Note that this will automatically handle nibs if your identifier is the name of your nib.


```
-registerCellClass: withConfigurationBlock:
```
This is just a convenience method in the case that you do not have multiple cells of the same class with differing identifiers.

If you have a more complex cell layout, then you may find yourself needing to specify the cell identifier yourself.   We've recognized this case, and have a block-based way to handle this. 

```
NSArray *items = @[@"string",@10, @"STRING 2"];
URBNArrayDataSourceAdapter *adapter = [[URBNArrayDataSourceAdapter alloc] initWithItems:items]];
// Here you can pass back the cellIdentifier based off of the indexPath
[adapter setCellIdentifierBlock:^NSString *(id item, NSIndexPath *indexPath) {
 	if (indexPath.row == 0) {
 		return @"StringIdentifier";
 	} else if (indexPath.row == 1) {
 		return @"NumberIdentifier";
 	} else {
 		return @"UnknownCellIdentifier";
 	}
}];
```

### Headers and Footers
If you need more than just cells, we've got support for headers and footers as well.   

```
- registerSupplementaryViewClass:ofKind:withConfigurationBlock:
```
This can be used with UICollectionView or UITableView.   This is essentially the same thing as the cell registration except it manages headers and footers.   We also have a version with passing the identifier you want to use. 
```
- registerSupplementaryViewClass:ofKind:withIdentifier:withConfigurationBlock:
```
This follows the same guidelines as the registerCellClass method.   Which means we have the same multiple view id block handler
```
-setSupplementaryViewIdentifierBlock:
```

## Examples

All the examples can be found in our example project.   We've got examples of creating everything in IB as well as creating everything in code.  

## Requirements

URBNDataSource has been tested on iOS 7 and up. Though it may work on lower deployment targets. ARC is required.

## Installation

URBNDataSource is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "URBNDataSource"

## License

URBNDataSource is available under the MIT license. See the LICENSE file for more info.
