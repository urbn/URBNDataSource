
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
 *
 *  @param newItems The new items
 *  @param section The section for the new items
 */
- (void)appendItems:(NSArray *)newItems inSection:(NSInteger)section;

/**
 * Insert some items at the specified indexes.
 * The count of `items` should be equal to the number of `indexes`.
 *
 *  @param newItems The new items
 *  @param indexes The indexes for the new items
 *  @param section The section for the new items
 */
- (void)insertItems:(NSArray *)newItems atIndexes:(NSIndexSet *)indexes inSection:(NSInteger)section;

/**
 *  Replace all items in the array
 *
 *  @param newItems The new items
 */
- (void)replaceItems:(NSArray *)newItems;

/*
 * Replace an item.
 *
 *  @param indexPath The indexPath of the original items
 *  @param item The new item
 */
- (void)replaceItemAtIndexPath:(NSIndexPath *)indexPath withItem:(id)item;

/**
 * Remove items in a specific range
 *
 *  @param range The range to remove
 *  @param section The section to remove from
 */
- (void)removeItemsInRange:(NSRange)range inSection:(NSInteger)section;

/**
 * Remove items at specific indexes
 *
 *  @param indexes The indexes to remove
 *  @param section The section to remove from
 */
- (void)removeItemsAtIndexes:(NSIndexSet *)indexes inSection:(NSInteger)section;

/**
 * Remove items at a specific indexPath
 *
 *  @param indexPath The indexPath to remove
 */
- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Move an item to a new indexPath.
 *
 *  @param indexPath The original indexPath
 *  @param newIndexPath The new indexPath
 */
- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

/**
 * Remove all objects in the data source.
 */
- (void)removeAllItems;

@end
