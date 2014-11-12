
/**
 * Generic table/collection data source, useful when your data is an array of objects.
 * If this datasource's `tableView` or `collectionView` property is set to your
 * tableview or collection view, the data source will
 * perform insert/reload/delete calls when the data changes.
 */

#import "URBNDataSourceAdapter.h"

@interface URBNArrayDataSourceAdapter : URBNDataSourceAdapter

/**
 * Create a new array data source by specifying an array of items. Items can be nil.
 */
- (instancetype)initWithItems:(NSArray *)items;


/**
 * Using the methods below to manipulate the items
 * will cause the table view or collection view to update automatically
 */

- (BOOL)isSectioned;

- (NSArray *)allItems;

/**
 * Add some more items to the end of the items array.
 */
- (void)appendItems:(NSArray *)newItems;

/**
 * Insert some items at the specified indexes.
 * The count of `items` should be equal to the number of `indexes`.
 */
- (void)insertItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes;

/**
 *  Replace all items in the array
 *
 *  @param newItems The new items
 */
- (void)replaceItems:(NSArray *)newItems;

/*
 * Replace an item.
 *
 *  @param index The index of the original items
 *  @param item  The new item
 */
- (void)replaceItemAtIndex:(NSUInteger)index withItem:(id)item;

/**
 * Remove items in a specific range
 *
 *  @param range The range to remove
 */
- (void)removeItemsInRange:(NSRange)range;

/**
 * Remove items at specific indexes
 *
 *  @param indexes The indexes to remove
 */
- (void)removeItemsAtIndexes:(NSIndexSet *)indexes;

/**
 * Remove items at a specific index
 *
 *  @param index The index to remove
 */
- (void)removeItemAtIndex:(NSUInteger)index;

/**
 * Move an item to a new index. Note: if index1 is before index2, then index2 will be 
 *
 *  @param index1 The original index
 *  @param index2 The new index
 */
- (void)moveItemAtIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2;

/**
 * Remove all objects in the data source.
 */
- (void)removeAllItems;

@end
