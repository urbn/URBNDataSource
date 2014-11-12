
/**
 * A generic data source object for table and collection views. Takes care of creating new cells
 * and exposes a block interface to configure cells with the object they represent.
 * Don't use this class directly except to subclass.
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, URBNSupplementaryViewType) {
    URBNSupplementaryViewTypeHeader,
    URBNSupplementaryViewTypeFooter
};


typedef NSString *(^URBNSupplementaryViewReuseIdentifierBlock) (NSString *kind, NSIndexPath *indexPath);
typedef NSString *(^URBNReuseableIdentifierBlock) (id item, NSIndexPath *indexPath);

typedef void (^URBNCellConfigureBlock) (id cell, id object, NSIndexPath* indexPath);
typedef void (^URBNSupplementaryViewConfigureBlock) (id view, URBNSupplementaryViewType kind, NSIndexPath* indexPath);


@protocol URBNDataSourceAdapterProtocol <NSObject>

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



- (URBNCellConfigureBlock)cellConfigurationBlockForIdentifier:(NSString *)identifier;
- (NSString *)identifierForItemAtIndexPath:(NSIndexPath *)indexPath;

@end



@interface URBNDataSourceAdapter : NSObject <URBNDataSourceAdapterProtocol>


#pragma mark - Outlets

/**
 * Optional: If the tableview property is assigned, the data source will perform
 * insert/reload/delete calls on it as data changes.
 */
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, assign) UITableViewRowAnimation rowAnimation;

/**
 * Optional: If the collectionview property is assigned, the data source will perform
 * insert/reload/delete calls on it as data changes.
 */
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;


/**
 *  Optional:  If the @fallbackDataSource property is assigned, any collectionView or tableView
 *  will attempt to fallback to this dataSource.
 **/
@property (nonatomic, weak) IBOutlet id fallbackDataSource;


#pragma mark - Cells

/**
 *  This is a convenience method for the `-registerCellClass:withIdentifier`.   This method will use the 
 *  @cellClass as the identifier
 *
 *  @param cellClass          The cell class o configure
 *  @param configurationBlock The block that configures instances of the cell class
 */
- (void)registerCellClass:(Class)cellClass withConfigurationBlock:(URBNCellConfigureBlock)configurationBlock;

/**
 * Provide a configuration block, called for each cell with the object to display in that cell.
 * NSStringFromClass(cellClass) will be used for the identifier and the nib name
 * This must be called after the tableview/collection view is set or it will be the callers responsibility to call
 * "register[Class|Nib]:forCellReuseIdentifier:" on the tableview or collectionview.
 *
 *  @param cellClass                The cell class o configure
 *  @param identifier (optional)    The reuseIdentifier to be used for this cell.  If nil the @cellClass will be used.
 *  @param configurationBlock       The block that configures instances of the cell class
 */
- (void)registerCellClass:(Class)cellClass withIdentifier:(NSString *)identifier withConfigurationBlock:(URBNCellConfigureBlock)configurationBlock;


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
- (void)registerSupplementaryViewClass:(Class)viewClass ofKind:(URBNSupplementaryViewType)kind withConfigurationBlock:(URBNSupplementaryViewConfigureBlock)configurationBlock;

- (void)registerSupplementaryViewClass:(Class)viewClass ofKind:(URBNSupplementaryViewType)kind withIdentifier:(NSString *)identifier withConfigurationBlock:(URBNSupplementaryViewConfigureBlock)configurationBlock;

#pragma mark - Advanced configuration

/**
 *  If your table / collectionView has more than 1 cell identifier, then you can handle that with this block. 
 *  You pass back the reuseIdentifier of the cell you expect to use at the given indexPath / item.
 */
@property (nonatomic, copy) URBNReuseableIdentifierBlock cellIdentifierBlock;
- (void)setCellIdentifierBlock:(URBNReuseableIdentifierBlock)cellIdentifierBlock;


@property (nonatomic, copy) URBNSupplementaryViewReuseIdentifierBlock supplementaryViewIdentifierBlock;
- (void)setSupplementaryViewIdentifierBlock:(URBNSupplementaryViewReuseIdentifierBlock)supplementaryViewIdentifierBlock;


#pragma mark - helpers

/**
 * Helper functions to generate arrays of NSIndexPaths.
 */
+ (NSArray *)indexPathArrayWithRange:(NSRange)range;
+ (NSArray *)indexPathArrayWithIndexSet:(NSIndexSet *)indexes;

@end



@interface URBNDataSourceAdapter (UITableView) <UITableViewDataSource, UITableViewDelegate>
@end

@interface URBNDataSourceAdapter (UICollectionView) <UICollectionViewDataSource>
@end
