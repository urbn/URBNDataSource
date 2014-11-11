
/**
 * A generic data source object for table and collection views. Takes care of creating new cells
 * and exposes a block interface to configure cells with the object they represent.
 * Don't use this class directly except to subclass.
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef Class (^URBNCellClassBlock) (id object, NSIndexPath* indexPath);
typedef void (^URBNCellConfigureBlock) (id cell, id object, NSIndexPath* indexPath);

typedef Class (^URBNSupplementaryViewClassBlock) (NSIndexPath* indexPath, NSString *kind);
typedef void (^URBNSupplementaryViewConfigureBlock) (id view, NSString* kind, NSIndexPath* indexPath);


@interface URBNDataSourceAdapter : NSObject <UITableViewDataSource, UICollectionViewDataSource>

#pragma mark - UITableView

/**
 * Optional: If the tableview property is assigned, the data source will perform
 * insert/reload/delete calls on it as data changes.
 */
@property (nonatomic, weak) UITableView *tableView;

/**
 * Optional animation to use when updating the table.
 * Defaults to UITableViewRowAnimationAutomatic.
 */
@property (nonatomic, assign) UITableViewRowAnimation rowAnimation;

/**
 * Optional data source fallback.
 * If this is set, it will receive data source calls that this class does not handle
 */
@property (nonatomic, weak) id <UITableViewDataSource> fallbackTableDataSource;


#pragma mark - UICollectionView

/**
 * Optional: If the collectionview property is assigned, the data source will perform
 * insert/reload/delete calls on it as data changes.
 */
@property (nonatomic, weak) UICollectionView *collectionView;

/**
 * Optional data source fallback.
 * If this is set, it will receive data source calls that this class does not handle
 */
@property (nonatomic, weak) id <UICollectionViewDataSource> fallbackCollectionDataSource;


#pragma mark - Cells

/**
 * Provide a configuration block, called for each cell with the object to display in that cell.
 * NSStringFromClass(cellClass) will be used for the identifier and the nib name
 * This must be called after the tableview/collection view is set or it will be the callers responsibility to call
 * "register[Class|Nib]:forCellReuseIdentifier:" on the tableview or collectionview.
 *
 *  @param cellClass          The cell class o configure
 *  @param configurationBlock The block that configures instances of the cell class
 */
- (void)registerCellClass:(Class)cellClass withConfigurationBlock:(URBNCellConfigureBlock)configurationBlock;

/**
 * Optional: This only needs defined if multiple cell classes are registered
 * This block will be invoked to determine which cell class to use.
 * Reuse Identifier will be @"NSStringFromClass(cellClass)"
 * Will search for a Nib of named @"NSStringFromClass(cellClass)"
 */
@property (nonatomic, copy) URBNCellClassBlock cellClassBlock;


#pragma mark - Supplimentary Views

/**
 * Supplimentary View configuration block, called for each supplementary view to display.
 * NSStringFromClass(viewClass) will be used for the kind and the nib name
 * This must be called after the collection view is set or it will be the callers responsibility to call
 * "register[Class|Nib]:forSupplementaryViewOfKind:" on the tableview ro collectionview.
 *
 *  @param viewClass          The supplementary view class to configure
 *  @param ofKind             OPTIONAL: The supplementary view kind (UICollectionElementKindSectionHeader or UICollectionElementKindSectionFooter). Defaults to class name.
 *  @param configurationBlock The block that configures instances of the class
 */
- (void)registerSupplementaryViewClass:(Class)viewClass ofKind:(NSString *)kind withConfigurationBlock:(URBNSupplementaryViewConfigureBlock)configurationBlock;

/**
 * Optional: This only needs defined if multiple view classes are registered
 * This block will be invoked to determine which supplimentary view class to use.
 * Reuse Identifier will be @"NSStringFromClass(viewClass)"
 * Will search for a Nib of named @"NSStringFromClass(viewClass)"
 */
@property (nonatomic, copy) URBNSupplementaryViewClassBlock supplementaryViewClassBlock;



#pragma mark - item access

/**
 * Returns all items. The order will be determined by the concrete subclass.
 *
 *  @return All items
 */
- (NSArray *)allItems;

/**
 * Return the number of items in the data source.
 */
- (NSUInteger)numberOfItems;

/**
 * Return the number of items in the section
 */
- (NSUInteger)numberOfItemsInSection:(NSInteger)section;

/**
 * Return the number of sections in the data source.
 */
- (NSUInteger)numberOfSections;

/**
 * Return the item at a given index path. Override in your subclass.
 *
 *  @param indexPath The index path of the item you are looking for
 *
 *  @return The item, or nil if not found
 */
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Get the index path for an item if it is contained in the array.
 *
 *  @param item The item to find
 *
 *  @return The index path, or nil if it is not contained in the datasource.
 */
- (NSIndexPath *)indexPathForItem:(id)item;

/**
 *  Get the Cell Config Block for a cell class.
 *
 *  @param A cell class
 *
 *  @return The Cell Config Block.
 */
- (URBNCellConfigureBlock)cellConfigurationBlockForClass:(Class)cellClass;

#pragma mark - helpers

/**
 * Helper functions to generate arrays of NSIndexPaths.
 */
+ (NSArray *)indexPathArrayWithRange:(NSRange)range;
+ (NSArray *)indexPathArrayWithIndexSet:(NSIndexSet *)indexes;

@end
