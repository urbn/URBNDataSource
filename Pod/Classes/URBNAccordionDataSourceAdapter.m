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
        self.sections = [NSMutableArray arrayWithArray:sections];
        self.items = [NSMutableArray arrayWithArray:items];

        self.expandedSections = [NSMutableIndexSet indexSet];

        self.headerConfigBlocks = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)registerSupplementaryViewClass:(Class)viewClass ofKind:(URBNSupplementaryViewType)kind withIdentifier:(NSString *)identifier withConfigurationBlock:(URBNSupplementaryViewConfigureBlock)configurationBlock {
    NSAssert(kind == URBNSupplementaryViewTypeHeader, @"RTFM! You should not be registering a header for accordion views! Use the right method. See registerAccordionHeaderViewClass:");
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
        configBlock(view, sectionObj, section, [self.expandedSections containsIndex:section]);
    }
    
    return view;
}

- (void)toggleSection:(NSInteger)section {
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
    [self.tableView reloadSections:indicesToReload withRowAnimation:self.rowAnimation];
}

#pragma mark - item access
- (NSInteger)numberOfSections {
    return self.sections.count;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    if ([self.expandedSections containsIndex:section] || [self.sectionsToKeepOpen containsIndex:section]) {
        return [self itemsForSection:section].count;
    }

    return 0;
}

@end
