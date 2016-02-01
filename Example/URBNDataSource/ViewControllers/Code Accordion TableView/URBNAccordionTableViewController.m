//
//  URBNAccordionTableViewController.m
//  URBNDataSource
//
//  Created by Jason Grandelli on 3/14/15.
//  Copyright (c) 2015 Joe. All rights reserved.
//

#import "URBNAccordionTableViewController.h"
@import URBNDataSource;

@interface URBNAccordionHeader : UITableViewHeaderFooterView

@property (nonatomic, strong) UILabel *catLabel;
@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, copy) void (^tappedBlock)();
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIImageView *expandedImgV;
- (void)setExpanded:(BOOL)expanded;

@end

@implementation URBNAccordionHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.catLabel = [UILabel new];
        self.catLabel.font = [UIFont systemFontOfSize:14.0];
        self.catLabel.textColor = [UIColor blueColor];
        self.catLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.catLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
        [self.contentView addSubview:self.catLabel];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_catLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_catLabel)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_catLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_catLabel)]];
        
        self.expandedImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-category-plus"]];
        self.expandedImgV.highlightedImage = [UIImage imageNamed:@"shop-category-minus"];
        self.expandedImgV.translatesAutoresizingMaskIntoConstraints = NO;
        self.expandedImgV.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.expandedImgV];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_expandedImgV]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_expandedImgV)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_expandedImgV]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_expandedImgV)]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tap];
        
        self.line = [UIView new];
        self.line.backgroundColor = [UIColor lightGrayColor];
        self.line.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.line];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_line]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_line)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_line(==0.5)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_line)]];
    }
    
    return self;
}

- (void)tapped:(UITapGestureRecognizer *)tap {
    if (UIGestureRecognizerStateEnded == tap.state && self.tappedBlock) {
        self.tappedBlock();
    }
}

- (void)setExpanded:(BOOL)expanded {
    if (expanded == _expanded) {
        return;
    }

    _expanded = expanded;
    self.catLabel.textColor = expanded ? [UIColor greenColor] : [UIColor blueColor];
    self.line.hidden = expanded;
}

@end

@interface URBNAccordionTableViewController ()

@property (nonatomic, strong) URBNAccordionDataSourceAdapter *adapter;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;

@end

@implementation URBNAccordionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *items = [NSMutableArray array];
    NSMutableArray *sections = [NSMutableArray array];
    for (int i = 0; i < 5; i++) {
        [sections addObject:[NSString stringWithFormat:@"Section %i", i]];
        [items addObject:@[@"Item 0", @"Item 1", @"Item 2", @"Item 3", @"Item 4"]];
    }
    self.stepper.value = (double)sections.count;

    self.adapter = [[URBNAccordionDataSourceAdapter alloc] initWithSectionObjects:sections andItems:items];
    self.adapter.fallbackDataSource = self;
    self.adapter.tableView = self.tableView;
    self.adapter.allowMultipleExpandedSections = YES;
    
    /// If all of your cell classes are unique, then you can just call regsiter cell with that class.
    /// The identifier will be the className
    [self.adapter registerCellClass:[UITableViewCell class] withConfigurationBlock:^(UITableViewCell *cell, id object, NSIndexPath *indexPath) {
        cell.textLabel.text = object;
    }];
    
    /// Here we're registering a reuseableTableHeaderView for our section headers.  Pretty sweet
    __weak typeof(self) weakSelf = self;
    [self.adapter registerAccordionHeaderViewClass:[URBNAccordionHeader class] withConfigurationBlock:^(URBNAccordionHeader *view, id object, NSInteger section, BOOL expanded) {
        view.catLabel.text = object;
        [view setExpanded:expanded];
        view.tappedBlock = ^() {
            [weakSelf.adapter toggleSection:section];
        };
    }];

    self.adapter.sectionsToKeepOpen = [NSIndexSet indexSetWithIndex:0];
    
    self.tableView.delegate = self.adapter;
    self.tableView.dataSource = self.adapter;
}

- (IBAction)stepperPressed:(UIStepper *)stepper {
    NSUInteger sectionCount = [self.adapter allSections].count;
    if (stepper.value > sectionCount) {
        [self.adapter appendSectionObject:[NSString stringWithFormat:@"Section %lu", (unsigned long)sectionCount] items:@[@"Item A", @"Item B", @"Item C", @"Item D", @"Item E"]];
    }
    else {
        [self.adapter removeLastSection];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

@end
