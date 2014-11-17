

#import "URBNArrayDataSourceAdapter.h"
#import <CoreData/CoreData.h>

@interface URBNArrayDataSourceAdapter ()

@property (nonatomic, strong, readwrite) NSMutableArray *items;

@end

@implementation URBNArrayDataSourceAdapter

@synthesize items;

- (instancetype)initWithItems:(NSArray *)anItems {
    if ((self = [self init])) {
        self.items = (anItems ? [NSMutableArray arrayWithArray:anItems] : [NSMutableArray array]);
    }
    
    return self;
}

#pragma mark - updating items
- (void)removeAllItems {
    [self.items removeAllObjects];
    
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

- (void)replaceItems:(NSArray *)newItems {
    self.items = [NSMutableArray arrayWithArray:newItems];
    
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

- (void)appendItems:(NSArray *)newItems inSection:(NSInteger)section {
    NSInteger count = [self numberOfItemsInSection:section];
    
    if (self.isSectioned) {
        NSMutableArray *tempItems = [[self itemsForSection:section] mutableCopy];
        [tempItems addObjectsFromArray:newItems];
        [self.items replaceObjectAtIndex:section withObject:tempItems];
    }
    else {
        [self.items addObjectsFromArray:newItems];
    }
    
    if (self.tableView) {
        [self.tableView insertRowsAtIndexPaths:[[self class] indexPathArrayWithRange:NSMakeRange(count, [newItems count]) inSection:section] withRowAnimation:self.rowAnimation];
    }
    
    if (self.collectionView) {
        [self.collectionView insertItemsAtIndexPaths:[[self class] indexPathArrayWithRange:NSMakeRange(count, [newItems count]) inSection:section]];
    }
}

- (void)insertItems:(NSArray *)newItems atIndexes:(NSIndexSet *)indexes inSection:(NSInteger)section {
    NSMutableArray *tempItems = [[self itemsForSection:section] mutableCopy];
    [tempItems insertObjects:items atIndexes:indexes];
    
    if (self.isSectioned) {
        [self.items replaceObjectAtIndex:section withObject:[NSArray arrayWithArray:tempItems]];
    }
    else {
        self.items = tempItems;
    }

    if (self.tableView) {
        [self.tableView insertRowsAtIndexPaths:[[self class] indexPathArrayWithIndexSet:indexes inSection:section] withRowAnimation:self.rowAnimation];
    }
    
    if (self.collectionView) {
        [self.collectionView insertItemsAtIndexPaths:[[self class] indexPathArrayWithIndexSet:indexes inSection:section]];
    }
}

- (void)replaceItemAtIndexPath:(NSIndexPath *)indexPath withItem:(id)item {
    NSMutableArray *tempItems = [[self itemsForSection:indexPath.section] mutableCopy];
    [tempItems replaceObjectAtIndex:indexPath.row withObject:item];
    
    if (self.isSectioned) {
        [self.items replaceObjectAtIndex:indexPath.section withObject:[NSArray arrayWithArray:tempItems]];
    }
    else {
        self.items = tempItems;
    }
    
    if (self.tableView) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:self.rowAnimation];
    }
    
    if (self.collectionView) {
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
}

- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    id item = [self itemAtIndexPath:indexPath];
    
    if (self.isSectioned) {
        NSMutableArray *tempItems = [[self itemsForSection:indexPath.section] mutableCopy];
        [tempItems removeObjectAtIndex:indexPath.row];

        if (indexPath.section != newIndexPath.section) {
            NSMutableArray *newTempItems = [[self itemsForSection:newIndexPath.section] mutableCopy];
            [newTempItems insertObject:item atIndex:indexPath.row];

            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
            [indexSet addIndex:indexPath.section];
            [indexSet addIndex:newIndexPath.section];
            
            [self.items replaceObjectsAtIndexes:indexSet withObjects:@[tempItems, newTempItems]];
        }
        else {
            [tempItems insertObject:item atIndex:newIndexPath.row];
            [self.items replaceObjectAtIndex:indexPath.section withObject:tempItems];
        }
    }
    else {
        [self.items removeObject:item];
        [self.items insertObject:item atIndex:newIndexPath.row];
    }
    
    if (self.tableView) {
        [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    }
    
    if (self.collectionView) {
        [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
    }
}

- (void)removeItemsInRange:(NSRange)range inSection:(NSInteger)section {
    NSMutableArray *tempItems = [[self itemsForSection:section] mutableCopy];

    if (range.location >= tempItems.count) {
        return;
    }
    else if (range.location + range.length >= tempItems.count) {
        range = NSMakeRange(range.location, tempItems.count - range.location);
    }
    
    [tempItems removeObjectsInRange:range];
    
    if (self.isSectioned) {
        [self.items replaceObjectAtIndex:section withObject:[NSArray arrayWithArray:tempItems]];
    }
    else {
        self.items = tempItems;
    }
    
    if (self.tableView) {
        [self.tableView deleteRowsAtIndexPaths:[[self class] indexPathArrayWithRange:range inSection:section] withRowAnimation:self.rowAnimation];
    }
    
    if (self.collectionView) {
        [self.collectionView deleteItemsAtIndexPaths:[[self class] indexPathArrayWithRange:range inSection:section]];
    }
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes inSection:(NSInteger)section {
    NSMutableArray *tempItems = [[self itemsForSection:section] mutableCopy];
    [tempItems removeObjectsAtIndexes:indexes];
    
    if (self.isSectioned) {
        [self.items replaceObjectAtIndex:section withObject:[NSArray arrayWithArray:tempItems]];
    }
    else {
        self.items = tempItems;
    }
    
    if (self.tableView) {
        [self.tableView deleteRowsAtIndexPaths:[[self class] indexPathArrayWithIndexSet:indexes inSection:section] withRowAnimation:self.rowAnimation];
    }
    
    if (self.collectionView) {
        [self.collectionView deleteItemsAtIndexPaths:[[self class] indexPathArrayWithIndexSet:indexes inSection:section]];
    }
}

- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *tempItems = [[self itemsForSection:indexPath.section] mutableCopy];
    [tempItems removeObjectAtIndex:indexPath.row];
    
    if (self.isSectioned) {
        [self.items replaceObjectAtIndex:indexPath.section withObject:[NSArray arrayWithArray:tempItems]];
    }
    else {
        self.items = tempItems;
    }
    
    if (self.tableView) {
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:self.rowAnimation];
    }
    
    if (self.collectionView) {
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    }
}

#pragma mark - item access
- (BOOL)isSectioned {
    id firstItem = [[self allItems] firstObject];
    return [firstItem isKindOfClass:[NSArray class]];
}

- (NSArray *)allItems {
    return self.items;
}

- (NSArray *)itemsForSection:(NSInteger)section {
    if ([self isSectioned]) {
        if (section > [self allItems].count) {
            return nil; // Insanity check
        }
        
        return [self allItems][section];
    }
    
    return self.allItems;
}

- (NSInteger)numberOfSections {
    return [self isSectioned] ? [self allItems].count : 1;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    return [self itemsForSection:section].count;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionItems = [self itemsForSection:indexPath.section];
    
    if (sectionItems && indexPath.item < [sectionItems count]) {
        return sectionItems[indexPath.item];
    }
    
    return nil;
}

- (NSIndexPath *)indexPathForItem:(id)item {
    __block NSInteger section;
    __block NSInteger row;
    if (self.isSectioned) {
        [self.items enumerateObjectsUsingBlock:^(NSArray *sectionArray, NSUInteger idx, BOOL *stop) {
            row = [sectionArray indexOfObjectIdenticalTo:item];
            if (row != NSNotFound) {
                section = idx;
                *stop = YES;
            }
        }];
    }
    else {
        section = 0;
        row = [self.items indexOfObjectIdenticalTo:item];
    }
    
    if (row == NSNotFound) {
        return nil;
    }
    
    return [NSIndexPath indexPathForRow:row inSection:section];
}

#pragma mark - UITableViewDataSource
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    id item = [self itemAtIndexPath:sourceIndexPath];
    [self.items removeObject:item];
    [self.items insertObject:item atIndex:destinationIndexPath.row];
}

@end
