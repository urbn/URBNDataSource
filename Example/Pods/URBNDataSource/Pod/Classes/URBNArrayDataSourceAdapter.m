

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

- (void)appendItems:(NSArray *)newItems {
    NSUInteger count = [self numberOfItems];
    
    [self.items addObjectsFromArray:newItems];
    
    if (self.tableView) {
        [self.tableView insertRowsAtIndexPaths:[[self class] indexPathArrayWithRange:NSMakeRange(count, [newItems count])] withRowAnimation:self.rowAnimation];
    }
    
    if (self.collectionView) {
        [self.collectionView insertItemsAtIndexPaths:[[self class] indexPathArrayWithRange:NSMakeRange(count, [newItems count])]];
    }
}

- (void)insertItems:(NSArray *)newItems atIndexes:(NSIndexSet *)indexes {    
    [self.items insertObjects:newItems atIndexes:indexes];
    
    if (self.tableView) {
        [self.tableView insertRowsAtIndexPaths:[[self class] indexPathArrayWithIndexSet:indexes] withRowAnimation:self.rowAnimation];
    }
    
    if (self.collectionView) {
        [self.collectionView insertItemsAtIndexPaths:[[self class] indexPathArrayWithIndexSet:indexes]];
    }
}

- (void)replaceItemAtIndex:(NSUInteger)index withItem:(id)item {
    [self.items replaceObjectAtIndex:index withObject:item];

    if (self.tableView) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(NSInteger)index inSection:0]] withRowAnimation:self.rowAnimation];
    }
    
    if (self.collectionView) {
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:(NSInteger)index inSection:0]]];
    }
}

- (void)moveItemAtIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2 updateCollectionView:(BOOL)update{
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:index1 inSection:0];
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:index2 inSection:0];
    
    id item = [self itemAtIndexPath:indexPath1];
    [self.items removeObject:item];
    [self.items insertObject:item atIndex:index2];
    
    if (self.tableView) {
        [self.tableView moveRowAtIndexPath:indexPath1 toIndexPath:indexPath2];
    }
    
    if (update && self.collectionView) {
        [self.collectionView moveItemAtIndexPath:indexPath1 toIndexPath:indexPath2];
    }
}

- (void)moveItemAtIndex:(NSUInteger)index1 toIndex:(NSUInteger)index2 {
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:index1 inSection:0];
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:index2 inSection:0];
    
    id item = [self itemAtIndexPath:indexPath1];
    [self.items removeObject:item];
    [self.items insertObject:item atIndex:index2];
    
    if (self.tableView) {
        [self.tableView moveRowAtIndexPath:indexPath1 toIndexPath:indexPath2];
    }
    
    if (self.collectionView) {
        [self.collectionView moveItemAtIndexPath:indexPath1 toIndexPath:indexPath2];
    }
}

- (void)removeItemsInRange:(NSRange)range {    
    [self.items removeObjectsInRange:range];
    
    if (self.tableView) {
        [self.tableView deleteRowsAtIndexPaths:[[self class] indexPathArrayWithRange:range] withRowAnimation:self.rowAnimation];
    }
    
    if (self.collectionView) {
        [self.collectionView deleteItemsAtIndexPaths:[[self class] indexPathArrayWithRange:range]];
    }
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes {
    [self.items removeObjectsAtIndexes:indexes];

    if (self.tableView) {
        [self.tableView deleteRowsAtIndexPaths:[[self class] indexPathArrayWithIndexSet:indexes] withRowAnimation:self.rowAnimation];
    }
    
    if (self.collectionView) {
        [self.collectionView deleteItemsAtIndexPaths:[[self class] indexPathArrayWithIndexSet:indexes]];
    }
}

- (void)removeItemAtIndex:(NSUInteger)index {
    [self.items removeObjectAtIndex:index];
    
    if (self.tableView) {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(NSInteger)index inSection:0]] withRowAnimation:self.rowAnimation];
    }
    
    if (self.collectionView) {
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:(NSInteger)index inSection:0]]];
    }
}

#pragma mark - item access

- (NSUInteger)numberOfSections {
    return [self isSectioned] ? [self allItems].count : 1;
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section {
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
    NSUInteger row = [self.items indexOfObjectIdenticalTo:item];
  
    if (row == NSNotFound) {
        return nil;
    }
  
    return [NSIndexPath indexPathForRow:(NSInteger)row inSection:0];
}

#pragma mark - UITableViewDataSource
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {    
    id item = [self itemAtIndexPath:sourceIndexPath];
    [self.items removeObject:item];
    [self.items insertObject:item atIndex:destinationIndexPath.row];
}

@end
