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

@property (nonatomic, strong, readonly) NSArray *sections;
@property (nonatomic, assign) BOOL allowMultipleExpandedSections;
@property (nonatomic, strong) NSIndexSet *sectionsToKeepOpen;

/**
 *  Create a new accordion data source specifying an array of sections and and array of items. Items can be nil, sections can not.
 */
- (instancetype)initWithSectionObjects:(NSArray *)sections andItems:(NSArray *)items NS_DESIGNATED_INITIALIZER;

/**
 *  This is a convenience method for the `-registerAccordionHeaderViewClass:withIdentifier:`. This method will use the
 *  @viewClass as the identifier
 *
 *  @param viewClass          The view class to configure.
 *  @param configurationBlock The block that configures instances of the cell class.
 */
- (void)registerAccordionHeaderViewClass:(Class)viewClass withConfigurationBlock:(URBNAccordionHeaderViewConfigureBlock)configurationBlock;

/**
 *  Provide a configuration block, called for each accordion header view with the object to display in that view.
 *  NSStringFromClass(viewClass) will be used for the identifier and the nib name if @identifier is nil
 *  This must be called after the tableview/collection view is set or it will be the callers responsibility to call
 *  "register[Class|Nib]:forSupplementaryViewOfKind:" on the tableview or collectionview.
 *
 *  @param viewClass                The view class to configure.
 *  @param identifier (optional)    The reuseIdentifier to be used for this view.  If nil the @viewClass will be used.
 *  @param configurationBlock       The block that configures instances of the view class.
 */
- (void)registerAccordionHeaderViewClass:(Class)viewClass withIdentifier:(NSString *)identifier withConfigurationBlock:(URBNAccordionHeaderViewConfigureBlock)configurationBlock;

/**
 *  Call this method to expanded/close a given section. This method will use the previously set rowAnimation for tableview 
 *  animations. This section will ignore any section in the `sectionsToKeepOpen` index set.
 *
 *  @param section      The section to toggle.
 */
- (void)toggleSection:(NSInteger)section;

/**
 *  Returns whether or not a given section is currently open/expanded.
 *  This checks both the currently toggled sections as well as the sections specified as always open.
 *  
 *  @param section      The section to check.
 *
 *  @return BOOL        YES/NO depending on the current status of the given section.
 */
- (BOOL)sectionIsOpen:(NSInteger)section;

/**
 *  Appends a section to the view.
 *
 *  @param sectionObject The section object being added
 *  @param items         The items being adding to the section
 */
- (void)appendSectionObject:(id)sectionObject items:(NSArray *)items;

@end
