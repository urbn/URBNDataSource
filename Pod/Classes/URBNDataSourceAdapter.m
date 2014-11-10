
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



@interface URBNDataSourceAdapter ()

@property (nonatomic, retain) NSMutableDictionary* cellConfigurationBlocks;
@property (nonatomic, retain) NSMutableDictionary* viewConfigurationBlocks;

@end

@implementation URBNDataSourceAdapter

#pragma mark - Forwarding

- (BOOL)conformsToProtocol:(Protocol *)aProtocol{
    
    if([super conformsToProtocol:aProtocol])
        return YES;
    if([self.fallbackTableDataSource conformsToProtocol:aProtocol])
        return YES;
    if([self.fallbackCollectionDataSource conformsToProtocol:aProtocol])
        return YES;
    
    return NO;
}

- (BOOL)respondsToSelector:(SEL)aSelector{
    
    if([super respondsToSelector:aSelector])
        return YES;
    if([self.fallbackTableDataSource respondsToSelector:aSelector])
        return YES;
    if([self.fallbackCollectionDataSource respondsToSelector:aSelector])
        return YES;
    
    return NO;
}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    
    if([self.fallbackTableDataSource respondsToSelector:aSelector])
        return self.fallbackTableDataSource;
    if([self.fallbackCollectionDataSource respondsToSelector:aSelector])
        return self.fallbackCollectionDataSource;
    
    return [super forwardingTargetForSelector:aSelector];
}

#pragma mark - init

- (instancetype)init {
    if( ( self = [super init] ) ) {
        self.rowAnimation = UITableViewRowAnimationAutomatic;
        self.cellConfigurationBlocks = [NSMutableDictionary dictionary];
        self.viewConfigurationBlocks = [NSMutableDictionary dictionary];
        
    }
    
    return self;
}

#pragma mark - Registration


- (void)registerCellClass:(Class)cellClass withConfigurationBlock:(URBNCellConfigureBlock)configurationBlock{
    
    ASSERT_TRUE(self.tableView || self.collectionView);
    
    NSString* identifier = NSStringFromClass(cellClass);
    
    UINib* nib = [self nibWithName:identifier];
    
    if(nib){
        
        [self.tableView registerNib:nib forCellReuseIdentifier:identifier];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
        
    }else{
        
        [self.tableView registerClass:cellClass forCellReuseIdentifier:identifier];
        [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
    }
    
    self.cellConfigurationBlocks[identifier] = configurationBlock;
    
}

- (void)registerSupplementaryViewClass:(Class)viewClass ofKind:(NSString *)kind withConfigurationBlock:(URBNSupplementaryViewConfigureBlock)configurationBlock {
    NOT_NIL_ASSERT(self.collectionView);
    
    NSString* identifier = NSStringFromClass(viewClass);
    
    UINib* nib = [self nibWithName:identifier];
    
    if ( !kind ) {
        kind = identifier;
    }
    
    if(nib){
        [self.collectionView registerNib:nib forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
    }
    else{
        [self.collectionView registerClass:viewClass forSupplementaryViewOfKind:kind withReuseIdentifier:identifier];
    }
    
    if ( configurationBlock ) {
        self.viewConfigurationBlocks[identifier] = configurationBlock;
    }
}



- (URBNCellConfigureBlock)cellConfigurationBlockForClass:(Class)cellClass{
    
    return self.cellConfigurationBlocks[NSStringFromClass(cellClass)];
}

- (URBNSupplementaryViewConfigureBlock)viewConfigurationBlockForClass:(Class)viewClass{
    
    return self.viewConfigurationBlocks[NSStringFromClass(viewClass)];
}

/*
 * The only way to know if a nib truly exists (in the main bundle)
 * nibWithName… returns a (broken) nib even if no file exists
 * Instead we cheat, and ignore the possibility of a nib in a subfolder
 */
- (UINib*)nibWithName:(NSString*)name{

    UINib* nib;

    if ([[NSBundle mainBundle] pathForResource:name ofType:@"nib"]) {
        
        nib = [UINib nibWithNibName:name bundle:nil];
        
    }else{
        
        nib = nil;
        
    }
    
    return nib;
    
}

#pragma mark - item access

- (NSArray *)allItems{
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Did you forget to override %@?",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    
}

- (NSUInteger) numberOfItems{
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Did you forget to override %@?",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    
}

- (NSUInteger)numberOfItemsInSection:(NSInteger)section{
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Did you forget to override %@?",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    
}

- (NSUInteger)numberOfSections{
    
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

- (NSIndexPath *) indexPathForItem:(id)item{
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Did you forget to override %@?",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return [self numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tv
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id item = [self itemAtIndexPath:indexPath];
    
    Class cellClass;
    
    if(self.cellClassBlock){
        
        cellClass = self.cellClassBlock(item, indexPath);
        
    }else{
        
        cellClass = NSClassFromString([self.cellConfigurationBlocks allKeys][0]);
    }
    
    
    URBNCellConfigureBlock cellBlock = [self cellConfigurationBlockForClass:cellClass];
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:NSStringFromClass(cellClass) forIndexPath:indexPath];
    
    cellBlock(cell, item, indexPath);
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tv canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if( [self.fallbackTableDataSource respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)] )
        return [self.fallbackTableDataSource tableView:tv
                                 canMoveRowAtIndexPath:indexPath];
    
    return NO;
}

- (BOOL)tableView:(UITableView *)tv canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if( [self.fallbackTableDataSource respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)] )
        return [self.fallbackTableDataSource tableView:tv
                                 canEditRowAtIndexPath:indexPath];
    
    return NO;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if( [self.fallbackTableDataSource respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)] )
        [self.fallbackTableDataSource tableView:tv
                             commitEditingStyle:editingStyle
                              forRowAtIndexPath:indexPath];
    
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return [self numberOfSections];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    id item = [self itemAtIndexPath:indexPath];
    
    Class cellClass;
    
    if(self.cellClassBlock){
        
        cellClass = self.cellClassBlock(item, indexPath);
        
    }else{
        
        cellClass = NSClassFromString([self.cellConfigurationBlocks allKeys][0]);
    }
    
    URBNCellConfigureBlock cellBlock = [self cellConfigurationBlockForClass:cellClass];
    
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:NSStringFromClass(cellClass) forIndexPath:indexPath];
    
    cellBlock(cell, item, indexPath);
    
    return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)cv
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    Class supplementaryClass;
    
    if(self.supplementaryViewClassBlock){
        
        supplementaryClass = self.supplementaryViewClassBlock(indexPath, kind);
        
    }else{
        
        supplementaryClass = NSClassFromString([self.viewConfigurationBlocks allKeys][0]);
    }
    
    URBNSupplementaryViewConfigureBlock supplementaryViewConfigureBlock = [self viewConfigurationBlockForClass:supplementaryClass];
    
    UICollectionReusableView* view = (id)[self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass(supplementaryClass) forIndexPath:indexPath];
    
    if ( supplementaryViewConfigureBlock )  {
        supplementaryViewConfigureBlock(view, kind, indexPath);
    }
    
    return view;
}


#pragma mark - indexpath helpers

+ (NSArray *)indexPathArrayWithRange:(NSRange)range {
    NSMutableArray *ret = [NSMutableArray array];
    
    for( NSUInteger i = range.location; i < NSMaxRange(range); i++ )
        [ret addObject:[NSIndexPath indexPathForRow:(NSInteger)i inSection:0]];
    
    return ret;
}

+ (NSArray *)indexPathArrayWithIndexSet:(NSIndexSet *)indexes {
    NSMutableArray *ret = [NSMutableArray array];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        [ret addObject:[NSIndexPath indexPathForRow:(NSInteger)index inSection:0]];
    }];
    
    return ret;
}

@end
