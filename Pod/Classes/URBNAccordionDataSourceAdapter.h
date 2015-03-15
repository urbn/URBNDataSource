//
//  URBNAccordionDataSourceAdapter.h
//  Pods
//
//  Created by Jason Grandelli on 3/14/15.
//
//

#import "URBNArrayDataSourceAdapter.h"

typedef void (^URBNAccordionHeaderViewConfigureBlock) (id view, id object, NSInteger section, BOOL expanded);

@interface URBNAccordionDataSourceAdapter : URBNArrayDataSourceAdapter

@property (nonatomic, assign) BOOL allowMultipleExpandedSections;

- (instancetype)initWithSections:(NSArray *)sections andItems:(NSArray *)items NS_DESIGNATED_INITIALIZER;

- (void)registerAccordionHeaderViewClass:(Class)viewClass withIdentifier:(NSString *)identifier withConfigurationBlock:(URBNAccordionHeaderViewConfigureBlock)configurationBlock;
- (void)registerAccordionHeaderViewClass:(Class)viewClass withConfigurationBlock:(URBNAccordionHeaderViewConfigureBlock)configurationBlock;

- (void)toggleSection:(NSInteger)section;

@end
