
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
 * Return the number of items in the section
 */
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

/**
 * Return the number of sections in the data source.
 */
- (NSInteger)numberOfSections;

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

@end


IB_DESIGNABLE @interface URBNDataSourceAdapter : NSObject <URBNDataSourceAdapterProtocol>

#pragma mark - Outlets
/**
 *  This determines whether you want us to implement the sizing delegate methods
 *  as well.
 */
@property (nonatomic, assign) IBInspectable BOOL autoSizingEnabled;

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
 * NSStringFromClass(cellClass) will be used for the identifier and the nib name if @identifier is nil
 * This must be called after the tableview/collection view is set or it will be the callers responsibility to call
 * "register[Class|Nib]:forCellReuseIdentifier:" on the tableview or collectionview.
 *
 *  @param cellClass                The cell class o configure
 *  @param identifier (optional)    The reuseIdentifier to be used for this cell.  If nil the @cellClass will be used.
 *  @param nibName (optional)       The nibName to be used for this cell.  If nil the @cellClass will be used.
 *  @param configurationBlock       The block that configures instances of the cell class
 */
- (void)registerCellClass:(Class)cellClass withIdentifier:(NSString *)identifier withConfigurationBlock:(URBNCellConfigureBlock)configurationBlock;
- (void)registerCellClass:(Class)cellClass withNibName:(NSString *)nibName withConfigurationBlock:(URBNCellConfigureBlock)configurationBlock;
- (void)registerCellClass:(Class)cellClass withIdentifier:(NSString *)identifier withNibName:(NSString *)nibName withConfigurationBlock:(URBNCellConfigureBlock)configurationBlock;

- (URBNCellConfigureBlock)cellConfigurationBlockForIdentifier:(NSString *)identifier;

- (NSString *)identifierForItemAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Supplimentary Views
/**
 *  This is a convenience method for the `-registerSupplementaryViewClass:ofKind:withIdentifier:`.   This method will use the
 *  @viewClass as the identifier
 *
 *  @param viewClass            The supplementary view class to configure
 *  @param ofKind               The supplementary view kind (UICollectionElementKindSectionHeader or UICollectionElementKindSectionFooter).
 *  @param configurationBlock   The block that configures instances of the class
 */
- (void)registerSupplementaryViewClass:(Class)viewClass ofKind:(URBNSupplementaryViewType)kind withConfigurationBlock:(URBNSupplementaryViewConfigureBlock)configurationBlock;

/**
 * Provide a configuration block, called for each supplementary view to display.
 * NSStringFromClass(cellClass) will be used for the identifier and the nib name
 * This must be called after the tableview/collection view is set or it will be the callers responsibility to call
 * "register[Class|Nib]:forSupplementaryViewOfKind:" on the tableview ro collectionview.
 *
 *  @param viewClass                The supplementary view class to configure
 *  @param ofKind                   The supplementary view kind (UICollectionElementKindSectionHeader or UICollectionElementKindSectionFooter).
 *  @param identifier (optional)    The reuseIdentifier to be used for this cell.  If nil the @cellClass will be used.
 *  @param nibName (optional)       The nibName to be used for this cell.  If nil the @cellClass will be used.
 *  @param configurationBlock       The block that configures instances of the class
 */
- (void)registerSupplementaryViewClass:(Class)viewClass ofKind:(URBNSupplementaryViewType)kind withIdentifier:(NSString *)identifier withNibName:(NSString*)nibName withConfigurationBlock:(URBNSupplementaryViewConfigureBlock)configurationBlock;
- (void)registerSupplementaryViewClass:(Class)viewClass ofKind:(URBNSupplementaryViewType)kind withNibName:(NSString *)nibName withConfigurationBlock:(URBNSupplementaryViewConfigureBlock)configurationBlock;
- (void)registerSupplementaryViewClass:(Class)viewClass ofKind:(URBNSupplementaryViewType)kind withIdentifier:(NSString *)identifier withConfigurationBlock:(URBNSupplementaryViewConfigureBlock)configurationBlock;

- (URBNSupplementaryViewConfigureBlock)viewConfigurationBlockForIdentifier:(NSString *)identifier withKind:(NSString *)kind;

- (NSString *)supplementaryIdentifierForType:(URBNSupplementaryViewType)type atIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Advanced configuration

/**
 *  Method to calculate the height for a given indexPath based on
 *  prototypeCell logic.   If the dataSource cannot get a prototypeCell for any
 *  reason, it will default to the tableView/collectionView default size or estimatedSize
 *  methods.
 *
 *  @param indexPath The indexpath of the row we want to calculate size on.
 *
 *  @return The calculated size for the given row.
 */
- (CGSize)sizeForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Method to calculate the size of a supplementary view at a given indexPath.
 *  The logic for this sizing is the same as the row sizing methods.
 *
 *  @param type     The supplementary view type to calculate for.
 *  @param indexPath    The indexPath of the supplementaryView to calculate for
 *
 *  @return The calculated size for the supplementaryView
 */
- (CGSize)sizeForSupplementaryViewOfType:(URBNSupplementaryViewType)type atIndexPath:(NSIndexPath *)indexPath;

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
+ (NSArray *)indexPathArrayWithRange:(NSRange)range inSection:(NSInteger)section;
+ (NSArray *)indexPathArrayWithIndexSet:(NSIndexSet *)indexes inSection:(NSInteger)section;

@end


@interface URBNDataSourceAdapter (UITableView) <UITableViewDataSource, UITableViewDelegate>
@end

@interface URBNDataSourceAdapter (UICollectionView) <UICollectionViewDataSource, UICollectionViewDelegate>
@end
