//
//  URBNAccordionDataSourceAdapter.m
//  Pods
//
//  Created by Jason Grandelli on 3/14/15.
//
//

#import "URBNAccordionDataSourceAdapter.h"

@interface URBNAccordionDataSourceAdapter ()

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableIndexSet *expandedSections;
@property (nonatomic, strong) NSMutableDictionary *headerConfigBlocks;

@end

@implementation URBNAccordionDataSourceAdapter

- (instancetype)initWithItems:(NSArray *)items {
    return [self initWithSectionObjects:nil andItems:items];
}

- (instancetype)initWithSectionObjects:(NSArray *)sections andItems:(NSArray *)items {
    self = [super initWithItems:items];
    if (self) {
        NSAssert(sections, @"You need sections for an accordion. Stop being a jerk.");
        NSAssert(sections.count > 0, @"Nice try, an empty sections array isn't gonna cut it. GTFO.");
        self.sections = [NSMutableArray arrayWithArray:sections];
        self.items = [NSMutableArray arrayWithArray:items];

        self.expandedSections = [NSMutableIndexSet indexSet];

        self.headerConfigBlocks = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)registerSupplementaryViewClass:(Class)viewClass ofKind:(URBNSupplementaryViewType)kind withIdentifier:(NSString *)identifier withConfigurationBlock:(URBNSupplementaryViewConfigureBlock)configurationBlock {
    NSAssert(kind != URBNSupplementaryViewTypeHeader, @"RTFM! You should not be registering a header for accordion views! Use the right method. See registerAccordionHeaderViewClass:");
    if (kind == URBNSupplementaryViewTypeHeader) {
        return;
    }
    
    [super registerSupplementaryViewClass:viewClass ofKind:kind withIdentifier:identifier withConfigurationBlock:configurationBlock];
}

- (void)registerAccordionHeaderViewClass:(Class)viewClass withConfigurationBlock:(URBNAccordionHeaderViewConfigureBlock)configurationBlock {
    [self registerAccordionHeaderViewClass:viewClass withIdentifier:nil withConfigurationBlock:configurationBlock];
}

- (void)registerAccordionHeaderViewClass:(Class)viewClass withIdentifier:(NSString *)identifier withConfigurationBlock:(URBNAccordionHeaderViewConfigureBlock)configurationBlock {
    UINib *nib = nil;
    if ([[NSBundle mainBundle] pathForResource:NSStringFromClass(viewClass) ofType:@"nib"]) {
        nib = [UINib nibWithNibName:NSStringFromClass(viewClass) bundle:nil];
    }
    
    identifier = identifier?:NSStringFromClass(viewClass);

    /// Do our registrations here
    if (self.tableView) {
        /// We're registering a header / footer for tableView.
        if (nib) {
            [self.tableView registerNib:nib forHeaderFooterViewReuseIdentifier:identifier];
        }
        else {
            [self.tableView registerClass:viewClass forHeaderFooterViewReuseIdentifier:identifier];
        }
    }
    else {
        /// We're registering a supplementary view on collectionView
        if (nib) {
            [self.collectionView registerNib:nib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:identifier];
        }
        else if(viewClass) {
            [self.collectionView registerClass:viewClass forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:identifier];
        }
    }
    
    /// Now save our configurationBlock
    if (configurationBlock) {
        self.headerConfigBlocks[identifier] = configurationBlock;
    }
}

- (void)toggleSection:(NSInteger)section {
    if ([self.sectionsToKeepOpen containsIndex:section]) {
        return;
    }
    
    NSIndexSet *removedIndices = [NSIndexSet indexSet];
    if ([self.expandedSections containsIndex:section]) {
        [self.expandedSections removeIndex:section];
    }
    else {
        if (!self.allowMultipleExpandedSections) {
            removedIndices = [self.expandedSections copy];
            [self.expandedSections removeAllIndexes];
        }
        [self.expandedSections addIndex:section];
    }
    
    NSMutableIndexSet *indicesToReload = [NSMutableIndexSet indexSetWithIndex:section];
    [indicesToReload addIndexes:removedIndices];
    if (self.tableView) {
        [self.tableView reloadSections:indicesToReload withRowAnimation:self.rowAnimation];
    }
    else if (self.collectionView) {
        [self.collectionView reloadSections:indicesToReload];
    }
}

- (BOOL)sectionIsOpen:(NSInteger)section {
    return [self.sectionsToKeepOpen containsIndex:section] || [self.expandedSections containsIndex:section];
}

#pragma mark - UITableViewDataSource
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    NSString *identifier = [self supplementaryIdentifierForType:URBNSupplementaryViewTypeHeader atIndexPath:indexPath];
    identifier = identifier?:[[self.headerConfigBlocks allKeys] firstObject];
    if (identifier == nil) {
        return nil;
    }
    
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    
    URBNAccordionHeaderViewConfigureBlock configBlock = self.headerConfigBlocks[identifier];
    if (configBlock) {
        id sectionObj = self.sections.count > section ? self.sections[section] : nil;
        configBlock(view, sectionObj, indexPath.section, [self sectionIsOpen:indexPath.section]);
    }
    
    return view;
}

#pragma mark - UICollectionViewDataSource
- (UICollectionReusableView *)collectionView:(UICollectionView *)cv viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    URBNSupplementaryViewType normalizedType = ([kind isEqualToString:UICollectionElementKindSectionFooter] ? URBNSupplementaryViewTypeFooter : URBNSupplementaryViewTypeHeader);
    
    if (normalizedType == URBNSupplementaryViewTypeFooter) {
        return [super collectionView:cv viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    }
    
    NSString *identifier = [self supplementaryIdentifierForType:URBNSupplementaryViewTypeHeader atIndexPath:indexPath];
    identifier = identifier?:[[self.headerConfigBlocks allKeys] firstObject];
    if (identifier == nil) {
        return nil;
    }
    
    UICollectionReusableView* view = (id)[self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:identifier forIndexPath:indexPath];

    URBNAccordionHeaderViewConfigureBlock configBlock = self.headerConfigBlocks[identifier];
    if (configBlock) {
        id sectionObj = self.sections.count > indexPath.section ? self.sections[indexPath.section] : nil;
        configBlock(view, sectionObj, indexPath.section, [self sectionIsOpen:indexPath.section]);
    }
    
    return view;
}

#pragma mark - URBNArrayDataSourceOverrides
#pragma mark - updating items
- (void)replaceItemsInSection:(NSInteger)section withItems:(NSArray *)newItems {
    newItems = newItems?:@[];
    if ([self sectionIsOpen:section]) {
        [super replaceItemsInSection:section withItems:newItems];
    }
    else {
        [self.items replaceObjectAtIndex:section withObject:[newItems copy]];
    }
}

- (void)appendItems:(NSArray *)newItems inSection:(NSInteger)section {
    if ([self sectionIsOpen:section]) {
        [super appendItems:newItems inSection:section];
    }
    else {
        NSMutableArray *tempItems = [[self itemsForSection:section] mutableCopy];
        [tempItems addObjectsFromArray:newItems];
        [self.items replaceObjectAtIndex:section withObject:tempItems];
    }
}

- (void)insertItems:(NSArray *)newItems atIndexes:(NSIndexSet *)indexes inSection:(NSInteger)section {
    if ([self sectionIsOpen:section]) {
        [super insertItems:newItems atIndexes:indexes inSection:section];
    }
    else {
        NSMutableArray *tempItems = [[self itemsForSection:section] mutableCopy];
        [tempItems insertObjects:newItems atIndexes:indexes];
        [self.items replaceObjectAtIndex:section withObject:[NSArray arrayWithArray:tempItems]];
    }
}

- (void)replaceItemAtIndexPath:(NSIndexPath *)indexPath withItem:(id)item {
    if ([self sectionIsOpen:indexPath.section]) {
        [super replaceItemAtIndexPath:indexPath withItem:item];
    }
    else {
        NSMutableArray *tempItems = [[self itemsForSection:indexPath.section] mutableCopy];
        [tempItems replaceObjectAtIndex:indexPath.row withObject:item];
        [self.items replaceObjectAtIndex:indexPath.section withObject:[NSArray arrayWithArray:tempItems]];
    }
}

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    BOOL bothSectionsOpen = [self sectionIsOpen:indexPath.section] && [self sectionIsOpen:newIndexPath.section];
    NSAssert(bothSectionsOpen, @"At the moment both sections need to be open in order to move an item to and fro. Don't like that, raise an issue.");
    if (bothSectionsOpen) {
        [super moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
    }
}

- (void)removeItemsInRange:(NSRange)range inSection:(NSInteger)section {
    if ([self sectionIsOpen:section]) {
        [super removeItemsInRange:range inSection:section];
    }
    else {
        NSMutableArray *tempItems = [[self itemsForSection:section] mutableCopy];
        if (range.location >= tempItems.count) {
            return;
        }
        else if (range.location + range.length >= tempItems.count) {
            range = NSMakeRange(range.location, tempItems.count - range.location);
        }
        
        [tempItems removeObjectsInRange:range];
        [self.items replaceObjectAtIndex:section withObject:[NSArray arrayWithArray:tempItems]];
    }
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes inSection:(NSInteger)section {
    if ([self sectionIsOpen:section]) {
        [super removeItemsAtIndexes:indexes inSection:section];
    }
    else {
        NSMutableArray *tempItems = [[self itemsForSection:section] mutableCopy];
        [tempItems removeObjectsAtIndexes:indexes];
        [self.items replaceObjectAtIndex:section withObject:[NSArray arrayWithArray:tempItems]];
    }
}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self sectionIsOpen:indexPath.section]) {
        [super removeItemAtIndexPath:indexPath];
    }
    else {
        NSMutableArray *tempItems = [[self itemsForSection:indexPath.section] mutableCopy];
        [tempItems removeObjectAtIndex:indexPath.row];
        [self.items replaceObjectAtIndex:indexPath.section withObject:[NSArray arrayWithArray:tempItems]];
    }
}

#pragma mark - item access
- (BOOL)isSectioned {
    return YES;
}

- (NSInteger)numberOfSections {
    return self.sections.count;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    if ([self sectionIsOpen:section]) {
        return [self itemsForSection:section].count;
    }

    return 0;
}

- (NSArray *)itemsForSection:(NSInteger)section {
    NSArray *items = @[];
    if (section < self.items.count) {
        items = [self.items[section] isKindOfClass:[NSArray class]] ? self.items[section] : @[self.items[section]];
    }

    return items;
}

@end
