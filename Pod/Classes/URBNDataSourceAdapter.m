
#import "URBNDataSourceAdapter.h"


//// These used to be defined in URBNKit.  For backwards sake we'll add them here in a safe way.
#ifdef DEBUG

#ifndef NOT_NIL_ASSERT
#define NOT_NIL_ASSERT(x)                  NSAssert4((x != nil), @"\n\n    ****  Unexpected Nil Assertion  ****\n    ****  " # x @" is nil.\nin file:%s at line %i in Method %@ with object:\n %@", __FILE__, __LINE__, NSStringFromSelector(_cmd), self)
#endif

#ifndef ASSERT_TRUE
#define ASSERT_TRUE(test)                  NSAssert4(test, @"\n\n    ****  Unexpected Assertion  **** \nAssertion in file:%s at line %i in Method %@ with object:\n %@", __FILE__, __LINE__, NSStringFromSelector(_cmd), self)
#endif

#else

#ifndef NOT_NIL_ASSERT
#define NOT_NIL_ASSERT(x) NSLog(@"\n\n    ****  Unexpected Nil Assertion  ****\n    ****  " # x @" is nil.\nin file:%s at line %i in Method %@ with object:\n %@", __FILE__, __LINE__, NSStringFromSelector(_cmd), self)
#endif

#ifndef ASSERT_TRUE
#define ASSERT_TRUE(test) NSLog(@"\n\n    ****  Unexpected Assertion  **** \nAssertion in file:%s at line %i in Method %@ with object:\n %@", __FILE__, __LINE__, NSStringFromSelector(_cmd), self)
#endif

#ifndef NS_BLOCK_ASSERTIONS
#define NS_BLOCK_ASSERTIONS
#endif

#endif /* ifdef DEBUG */

NSString *const URBNSupplementaryViewKindHeader = @"URBNSupplementaryViewKindHeader";
NSString *const URBNSupplementaryViewKindFooter = @"URBNSupplementaryViewKindFooter";

/**
 *  These are our internal objects to wrap up the collectionView dataSource delegate stuff.
 */
@interface URBNDataSourceInternalResponder : NSObject
@property (nonatomic, weak) URBNDataSourceAdapter *ds;
@end

/**
 *  These are our internal responders.   Used to keep code segregated.
 */
@interface URBNDSITableDataSource: URBNDataSourceInternalResponder <UITableViewDataSource, UITableViewDelegate> @end
@interface URBNDSICollectionDataSource: URBNDataSourceInternalResponder <UICollectionViewDataSource> @end

@interface URBNDSITableDelegate: URBNDataSourceInternalResponder <UITableViewDelegate> @end
@interface URBNDSICollectionDelegate: URBNDataSourceInternalResponder <UICollectionViewDelegateFlowLayout> @end

@interface URBNDataSourceAdapter ()

@property (nonatomic, strong) URBNDSICollectionDelegate *internalCollectionDelegate;
@property (nonatomic, strong) URBNDSITableDelegate *internalTableDelegate;

@property (nonatomic, strong) NSMutableDictionary *cellConfigurationBlocks;
@property (nonatomic, strong) NSMutableDictionary *viewConfigurationBlocks;

@property (nonatomic, strong) NSMutableArray *dataSources;
@property (nonatomic, strong) NSMutableDictionary *prototypeCells;
@property (nonatomic, strong) NSMutableDictionary *prototypeHeaders;

@end

@implementation URBNDataSourceAdapter

#pragma mark - init
- (instancetype)init {
    self = [super init];
    if (self) {
        self.rowAnimation = UITableViewRowAnimationAutomatic;
        self.cellConfigurationBlocks = [NSMutableDictionary dictionary];
        self.viewConfigurationBlocks = [NSMutableDictionary dictionary];
        self.dataSources = [NSMutableArray array];
        self.prototypeCells = [NSMutableDictionary dictionary];
        self.prototypeHeaders = [NSMutableDictionary dictionary];
        
        // Wire up our collection/table dataSources.
        URBNDSICollectionDataSource *cd = [URBNDSICollectionDataSource new];
        URBNDSITableDataSource *td = [URBNDSITableDataSource new];
        cd.ds =
        td.ds = self;
        [self.dataSources addObject:cd];
        [self.dataSources addObject:td];
        
        // Let's go ahead and create our internal delegate stuff here.
        // We won't wire them up until told to do so.
        self.internalTableDelegate = [URBNDSITableDelegate new];
        self.internalCollectionDelegate = [URBNDSICollectionDelegate new];
        self.internalTableDelegate.ds =
        self.internalCollectionDelegate.ds = self;
    }
    return self;
}

#pragma mark - Setters
- (void)setFallbackDataSource:(id)fallbackDataSource {
    if (_fallbackDataSource == fallbackDataSource) {
        return;
    }
    if (!fallbackDataSource) {
        [self.dataSources removeObject:_fallbackDataSource];
    }
    _fallbackDataSource = fallbackDataSource;
    
    if (fallbackDataSource) {
        [self.dataSources addObject:fallbackDataSource];
    }
    
    // Flush the caches
    self.collectionView.dataSource = nil;
    self.collectionView.dataSource = self;
    self.tableView.dataSource = nil;
    self.tableView.dataSource = self;
}

- (void)setAutoSizingEnabled:(BOOL)autoSizingEnabled {
    if (autoSizingEnabled == _autoSizingEnabled) {
        return;
    }
    
    _autoSizingEnabled = autoSizingEnabled;
    
    if (autoSizingEnabled) {
        // We're going to add our tableViewDelegate object into our list of dataSources.
        [self.dataSources addObject:self.internalCollectionDelegate];
        [self.dataSources addObject:self.internalTableDelegate];
    }
    else {
        // We're going to remove our delegate objects from our list of dataSources.
        [self.dataSources removeObject:self.internalCollectionDelegate];
        [self.dataSources removeObject:self.internalTableDelegate];
    }
}

#pragma mark - Forwarding
- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    if ([super conformsToProtocol:aProtocol]) {
        return YES;
    }
    
    for (id obj in self.dataSources) {
        if ([obj conformsToProtocol:aProtocol]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    for (id obj in self.dataSources) {
        if ([obj respondsToSelector:aSelector]) {
            return YES;
        }
    }
    
    return NO;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    for (id obj in self.dataSources) {
        if ([obj respondsToSelector:aSelector]) {
            return obj;
        }
    }
    return nil;
}

#pragma mark - Heights
- (void)cacheAndSaveCellWithNib:(UINib *)nib withIdentifier:(NSString *)identifier {
    if (self.prototypeCells[identifier]) {
        return;
    }
    
    self.prototypeCells[identifier] = [[nib instantiateWithOwner:nil options:nil] firstObject];
}

- (void)cacheAndSaveCellOfClass:(Class)aClass withIdentifier:(NSString *)identifier {
    if (self.prototypeCells[identifier]) {
        return;
    }
    
    if (self.tableView) {
        self.prototypeCells[identifier] = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    }
    else {
        self.prototypeCells[identifier] = [[aClass alloc] initWithFrame:CGRectZero];
    }
}

- (CGSize)sizeForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self identifierForItemAtIndexPath:indexPath];
    id cell = self.prototypeCells[identifier];
    if (!cell) {
        if (self.tableView) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        }
        else {
            // This is a cell that came from a storyboard or something.   The reason we can't cache this here is because
            // this will call an infinite loop within itemSize.   We may want to throw some kind of log warning or something to tell the user this
        }
        /**
         *  If we still don't have a cell.   Then we're just going to return rowHeight
         */
        if (!cell) {
            if (self.tableView) {
                CGFloat height = [self.tableView rowHeight] ?: [self.tableView estimatedRowHeight];
                return  CGSizeMake(0, height);
            }
            else {
                UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
                if ([flowLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
                    CGSize size = CGSizeEqualToSize([flowLayout itemSize], CGSizeZero) ? [flowLayout estimatedItemSize] : [flowLayout itemSize];
                    if (!CGSizeEqualToSize(size, CGSizeZero)) {
                        return size;
                    }
                }

                // If collectionView doesn't have anything we want, then just return this
                return [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath].frame.size;
            }
        }
        
        // Now that we've got a cell, let's cache it.
        self.prototypeCells[identifier] = cell;
    }
    
    URBNCellConfigureBlock configBlock = [self cellConfigurationBlockForIdentifier:identifier];
    configBlock(cell, [self itemAtIndexPath:indexPath], indexPath);
    return [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
}

- (CGSize)sizeForSupplementaryViewOfType:(URBNSupplementaryViewType)type atIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self supplementaryIdentifierForType:type atIndexPath:indexPath];
    NSString *suppKind = [[self class] normalizedKindForSupplementaryType:type withView:self.collectionView?:self.tableView];
    id view = self.prototypeHeaders[identifier];
    if (!view) {
        if (self.tableView) {
            view = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
        }
        else {
            // This is a cell that came from a storyboard or something.   The reason we can't cache this here is because
            // this will call an infinite loop within itemSize.   We may want to throw some kind of log warning or something to tell the user this
        }
        
        if (!view) {
            if (self.tableView) {
                CGFloat height = (type == URBNSupplementaryViewTypeFooter ? [self.tableView sectionFooterHeight] : [self.tableView sectionHeaderHeight]) ?:
                    (type == URBNSupplementaryViewTypeFooter ? [self.tableView estimatedSectionFooterHeight] : [self.tableView estimatedSectionHeaderHeight]);
                return CGSizeMake(0, height);
            }
            else {
                UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
                if ([flowLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
                    CGSize size = type == URBNSupplementaryViewTypeFooter ? [flowLayout footerReferenceSize] : [flowLayout headerReferenceSize];
                    if (!CGSizeEqualToSize(size, CGSizeZero)) {
                        return size;
                    }
                }
                
                // If collectionView doesn't have anything we want, then just return this
                return [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:suppKind atIndexPath:indexPath].frame.size;
            }
        }
    }
    
    URBNSupplementaryViewConfigureBlock configBlock = [self viewConfigurationBlockForIdentifier:identifier withKind:suppKind];
    configBlock(view, type, indexPath);
    return [view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
}

#pragma mark - Registration
- (void)registerCellClass:(Class)cellClass withIdentifier:(NSString *)identifier withConfigurationBlock:(URBNCellConfigureBlock)configurationBlock {
    ASSERT_TRUE(self.tableView || self.collectionView);
    
    identifier = identifier?:NSStringFromClass(cellClass);
    UINib* nib = [self nibWithName:identifier];
    if (nib) {
        [self.tableView registerNib:nib forCellReuseIdentifier:identifier];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
        [self cacheAndSaveCellWithNib:nib withIdentifier:identifier];
    }
    else if (cellClass != NULL) {
        [self.tableView registerClass:cellClass forCellReuseIdentifier:identifier];
        [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
        [self cacheAndSaveCellOfClass:cellClass withIdentifier:identifier];
    }
    
    self.cellConfigurationBlocks[identifier] = configurationBlock;
}

- (void)registerCellClass:(Class)cellClass withConfigurationBlock:(URBNCellConfigureBlock)configurationBlock {
    [self registerCellClass:cellClass withIdentifier:nil withConfigurationBlock:configurationBlock];
}

- (void)registerSupplementaryViewClass:(Class)viewClass ofKind:(URBNSupplementaryViewType)kind withIdentifier:(NSString *)identifier withConfigurationBlock:(URBNSupplementaryViewConfigureBlock)configurationBlock {
    ASSERT_TRUE(self.collectionView || self.tableView);
    
    NSString *kindString = [[self class] normalizedKindForSupplementaryType:kind withView:(self.collectionView?:self.tableView)];
    UINib *nib = [self nibWithName:NSStringFromClass(viewClass)];
    
    /// Do our registrations here
    if (self.tableView) {
        identifier = identifier ? : kindString;
        /// We're registering a header / footer for tableView.
        if (nib) {
            [self.tableView registerNib:nib forHeaderFooterViewReuseIdentifier:identifier];
        }
        else {
            [self.tableView registerClass:viewClass forHeaderFooterViewReuseIdentifier:identifier];
        }
    }
    else {
        identifier = identifier?:NSStringFromClass(viewClass);
        /// We're registering a supplementary view on collectionView
        if (nib) {
            [self.collectionView registerNib:nib forSupplementaryViewOfKind:kindString withReuseIdentifier:identifier];
        }
        else if(viewClass) {
            [self.collectionView registerClass:viewClass forSupplementaryViewOfKind:kindString withReuseIdentifier:identifier];
        }
    }
    
    /// Now save our configurationBlock
    if (configurationBlock) {
        NSMutableDictionary *configsForKind = [self.viewConfigurationBlocks[kindString] mutableCopy] ?: [NSMutableDictionary dictionary];
        configsForKind[identifier] = configurationBlock;
        self.viewConfigurationBlocks[kindString] = configsForKind;
    }
}

- (void)registerSupplementaryViewClass:(Class)viewClass ofKind:(URBNSupplementaryViewType)kind withConfigurationBlock:(URBNSupplementaryViewConfigureBlock)configurationBlock {
    [self registerSupplementaryViewClass:viewClass ofKind:kind withIdentifier:nil withConfigurationBlock:configurationBlock];
}

- (URBNCellConfigureBlock)cellConfigurationBlockForIdentifier:(NSString *)identifier {
    return self.cellConfigurationBlocks[identifier];
}

- (URBNSupplementaryViewConfigureBlock)viewConfigurationBlockForIdentifier:(NSString *)identifier withKind:(NSString *)kind {
    NSDictionary *kindBlocks = self.viewConfigurationBlocks[kind];
    if (kindBlocks) {
        return kindBlocks[identifier];
    }
    
    return nil;
}

- (NSString *)supplementaryIdentifierForType:(URBNSupplementaryViewType)type atIndexPath:(NSIndexPath *)indexPath {
    NSString *kind = [[self class] normalizedKindForSupplementaryType:type withView:(self.collectionView?:self.tableView)];
    NSString *identifier = nil;
    if (self.supplementaryViewIdentifierBlock) {
        identifier = self.supplementaryViewIdentifierBlock(kind, indexPath);
    }
    else {
        identifier = [[self.viewConfigurationBlocks[kind] allKeys] firstObject];
    }
    
    return identifier;
}

- (NSString *)identifierForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = nil;
    
    if (self.cellIdentifierBlock) {
        identifier = self.cellIdentifierBlock([self itemAtIndexPath:indexPath], indexPath);
    }
    else {
        identifier = [[self.cellConfigurationBlocks allKeys] firstObject];
    }
    
    return identifier;
}

#pragma mark - Protocol adherance
- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Did you forget to override %@?",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSInteger)numberOfSections {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Did you forget to override %@?",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Did you forget to override %@?",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    
}

- (NSIndexPath *)indexPathForItem:(id)item {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Did you forget to override %@?",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark - Convenience
+ (NSString *)normalizedKindForSupplementaryType:(URBNSupplementaryViewType)type withView:(UIView *)collectionOrTableView {
    if (!collectionOrTableView || [collectionOrTableView isKindOfClass:[UITableView class]]) {
        /// We're either nil or a tableView
        return type == URBNSupplementaryViewTypeHeader ? URBNSupplementaryViewKindHeader : URBNSupplementaryViewKindFooter;
    }
    
    /// We're a collectionView.
    return type == URBNSupplementaryViewTypeFooter ? UICollectionElementKindSectionFooter : UICollectionElementKindSectionHeader;
}

+ (NSArray *)indexPathArrayWithRange:(NSRange)range inSection:(NSInteger)section {
    NSMutableArray *ret = [NSMutableArray array];
    for( NSInteger i = range.location; i < NSMaxRange(range); i++) {
        [ret addObject:[NSIndexPath indexPathForRow:(NSInteger)i inSection:section]];
    }
    
    return ret;
}

+ (NSArray *)indexPathArrayWithIndexSet:(NSIndexSet *)indexes inSection:(NSInteger)section {
    NSMutableArray *ret = [NSMutableArray array];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        [ret addObject:[NSIndexPath indexPathForRow:(NSInteger)index inSection:section]];
    }];
    
    return ret;
}

/*
 * The only way to know if a nib truly exists (in the main bundle)
 * nibWithName… returns a (broken) nib even if no file exists
 * Instead we cheat, and ignore the possibility of a nib in a subfolder
 */
- (UINib*)nibWithName:(NSString*)name {
    UINib *nib = nil;
    
    if (name && [[NSBundle mainBundle] pathForResource:name ofType:@"nib"]) {
        nib = [UINib nibWithNibName:name bundle:nil];
    }
    
    return nib;
}

@end


// This is only an object to give all of our DSI objects the same properties
@implementation URBNDataSourceInternalResponder @end
/**
 *  Here we wrap up the methods that we care about from our collectionView and tableView
 */
@implementation URBNDSITableDataSource

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.ds numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.ds numberOfItemsInSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    NSString *identifier = [self.ds supplementaryIdentifierForType:URBNSupplementaryViewTypeHeader atIndexPath:indexPath];
    
    if (identifier == nil) {
        return nil;
    }
    
    URBNSupplementaryViewConfigureBlock configBlock = [self.ds viewConfigurationBlockForIdentifier:identifier withKind:URBNSupplementaryViewKindHeader];
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    
    if (configBlock) {
        configBlock(view, URBNSupplementaryViewTypeHeader, indexPath);
    }
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    NSString *identifier = [self.ds supplementaryIdentifierForType:URBNSupplementaryViewTypeFooter atIndexPath:indexPath];
    
    if (!identifier) {
        return nil;
    }
    
    URBNSupplementaryViewConfigureBlock configBlock = [self.ds viewConfigurationBlockForIdentifier:identifier withKind:URBNSupplementaryViewKindFooter];
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    
    if (configBlock) {
        configBlock(view, URBNSupplementaryViewTypeFooter, indexPath);
    }
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip {
    id item = [self.ds itemAtIndexPath:ip];
    NSString *identifier = [self.ds identifierForItemAtIndexPath:ip];
    URBNCellConfigureBlock cellBlock = [self.ds cellConfigurationBlockForIdentifier:identifier];
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:identifier forIndexPath:ip];
    
    if (cellBlock) {
        cellBlock(cell, item, ip);
    }
    
    return cell;
}

@end

@implementation URBNDSITableDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.ds sizeForRowAtIndexPath:indexPath].height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self.ds sizeForSupplementaryViewOfType:URBNSupplementaryViewTypeHeader atIndexPath:[NSIndexPath indexPathForRow:-1 inSection:section]].height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return [self.ds sizeForSupplementaryViewOfType:URBNSupplementaryViewTypeFooter atIndexPath:[NSIndexPath indexPathForRow:-1 inSection:section]].height;
}

@end


@implementation URBNDSICollectionDataSource

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.ds numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.ds numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)ip {
    id item = [self.ds itemAtIndexPath:ip];
    NSString *identifier = [self.ds identifierForItemAtIndexPath:ip];
    URBNCellConfigureBlock cellBlock = [self.ds cellConfigurationBlockForIdentifier:identifier];
    
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:ip];
    
    if (cellBlock) {
        cellBlock(cell, item, ip);
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)cv viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    URBNSupplementaryViewType normalizedType = ([kind isEqualToString:UICollectionElementKindSectionFooter] ? URBNSupplementaryViewTypeFooter : URBNSupplementaryViewTypeHeader);
    
    NSString *identifier = [self.ds supplementaryIdentifierForType:normalizedType atIndexPath:indexPath];
    if (identifier == nil) {
        return nil;
    }
    
    URBNSupplementaryViewConfigureBlock configBlock = [self.ds viewConfigurationBlockForIdentifier:identifier withKind:kind];
    
    UICollectionReusableView* view = (id)[self.ds.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:identifier forIndexPath:indexPath];
    if (configBlock) {
        configBlock(view, normalizedType, indexPath);
    }
    
    return view;
}

@end

@implementation URBNDSICollectionDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = [self.ds sizeForRowAtIndexPath:indexPath];
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGSize size = [self.ds sizeForSupplementaryViewOfType:URBNSupplementaryViewTypeFooter atIndexPath:[NSIndexPath indexPathForItem:-1 inSection:section]];
    
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize size = [self.ds sizeForSupplementaryViewOfType:URBNSupplementaryViewTypeHeader atIndexPath:[NSIndexPath indexPathForItem:-1 inSection:section]];
    return size;
}

@end
