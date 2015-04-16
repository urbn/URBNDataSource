
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

@interface URBNDataSourceAdapter ()

@property (nonatomic, strong) NSMutableDictionary *cellConfigurationBlocks;
@property (nonatomic, strong) NSMutableDictionary *viewConfigurationBlocks;

@end

@implementation URBNDataSourceAdapter

#pragma mark - init
- (instancetype)init {
    if ((self = [super init])) {
        self.rowAnimation = UITableViewRowAnimationAutomatic;
        self.cellConfigurationBlocks = [NSMutableDictionary dictionary];
        self.viewConfigurationBlocks = [NSMutableDictionary dictionary];
    }
    
    return self;
}

#pragma mark - Registration
- (void)registerCellClass:(Class)cellClass withIdentifier:(NSString *)identifier withConfigurationBlock:(URBNCellConfigureBlock)configurationBlock {
    ASSERT_TRUE(self.tableView || self.collectionView);
    
    identifier = identifier?:NSStringFromClass(cellClass);
    UINib* nib = [self nibWithName:identifier];
    if (nib) {
        [self.tableView registerNib:nib forCellReuseIdentifier:identifier];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    }
    else if (cellClass != NULL) {
        [self.tableView registerClass:cellClass forCellReuseIdentifier:identifier];
        [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
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

- (URBNSupplementaryViewConfigureBlock)viewConfigurationBlockForClass:(Class)viewClass {
    return self.viewConfigurationBlocks[NSStringFromClass(viewClass)];
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

#pragma mark - Forwarding
- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    if ([super conformsToProtocol:aProtocol]) {
        return YES;
    }
    
    if ([self.fallbackDataSource conformsToProtocol:aProtocol]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    if ([self.fallbackDataSource respondsToSelector:aSelector]) {
        return YES;
    }
    
    return NO;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.fallbackDataSource respondsToSelector:aSelector]) {
        return self.fallbackDataSource;
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

@end


/**
 *  Here we wrap up the methods that we care about from our collectionView and tableView
 */
@implementation URBNDataSourceAdapter (UITableView)

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfItemsInSection:section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    NSString *identifier = [self supplementaryIdentifierForType:URBNSupplementaryViewTypeHeader atIndexPath:indexPath];
    
    if (identifier == nil) {
        return nil;
    }
    
    URBNSupplementaryViewConfigureBlock configBlock = [self viewConfigurationBlockForIdentifier:identifier withKind:URBNSupplementaryViewKindHeader];
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    
    if (configBlock) {
        configBlock(view, URBNSupplementaryViewTypeHeader, indexPath);
    }
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    NSString *identifier = [self supplementaryIdentifierForType:URBNSupplementaryViewTypeFooter atIndexPath:indexPath];
    
    if (!identifier) {
        return nil;
    }
    
    URBNSupplementaryViewConfigureBlock configBlock = [self viewConfigurationBlockForIdentifier:identifier withKind:URBNSupplementaryViewKindFooter];
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    
    if (configBlock) {
        configBlock(view, URBNSupplementaryViewTypeFooter, indexPath);
    }
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)ip {
    id item = [self itemAtIndexPath:ip];
    NSString *identifier = [self identifierForItemAtIndexPath:ip];
    URBNCellConfigureBlock cellBlock = [self cellConfigurationBlockForIdentifier:identifier];
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:identifier forIndexPath:ip];
    
    if (cellBlock) {
        cellBlock(cell, item, ip);
    }
    
    return cell;
}

@end


@implementation URBNDataSourceAdapter (UICollectionView)

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)ip {
    id item = [self itemAtIndexPath:ip];
    NSString *identifier = [self identifierForItemAtIndexPath:ip];
    URBNCellConfigureBlock cellBlock = [self cellConfigurationBlockForIdentifier:identifier];
    
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:ip];
    
    if (cellBlock) {
        cellBlock(cell, item, ip);
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)cv viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    URBNSupplementaryViewType normalizedType = ([kind isEqualToString:UICollectionElementKindSectionFooter] ? URBNSupplementaryViewTypeFooter : URBNSupplementaryViewTypeHeader);

    NSString *identifier = [self supplementaryIdentifierForType:normalizedType atIndexPath:indexPath];
    if (identifier == nil) {
        return nil;
    }
    
    URBNSupplementaryViewConfigureBlock configBlock = [self viewConfigurationBlockForIdentifier:identifier withKind:kind];
    
    UICollectionReusableView* view = (id)[self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:identifier forIndexPath:indexPath];
    if (configBlock) {
        configBlock(view, normalizedType, indexPath);
    }
    
    return view;
}

@end
