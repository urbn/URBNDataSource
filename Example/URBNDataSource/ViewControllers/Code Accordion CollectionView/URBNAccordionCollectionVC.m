//
//  URBNAccordionCollectionVC.m
//  URBNDataSource
//
//  Created by Jason Grandelli on 3/15/15.
//  Copyright (c) 2015 Joe. All rights reserved.
//

#import "URBNAccordionCollectionVC.h"
#import <UDS/URBNAccordionDataSourceAdapter.h>

@interface URBNAccordionCVHeader : UICollectionReusableView

@property (nonatomic, strong) UILabel *catLabel;
@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, copy) void (^tappedBlock)();
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIImageView *expandedImgV;
- (void)setExpanded:(BOOL)expanded;

@end

@implementation URBNAccordionCVHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.catLabel = [UILabel new];
        self.catLabel.font = [UIFont systemFontOfSize:14.0];
        self.catLabel.textColor = [UIColor blueColor];
        self.catLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.catLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
        [self addSubview:self.catLabel];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_catLabel]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_catLabel)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_catLabel]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_catLabel)]];
        
        self.expandedImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shop-category-plus"]];
        self.expandedImgV.highlightedImage = [UIImage imageNamed:@"shop-category-minus"];
        self.expandedImgV.translatesAutoresizingMaskIntoConstraints = NO;
        self.expandedImgV.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.expandedImgV];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_expandedImgV]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_expandedImgV)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_expandedImgV]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_expandedImgV)]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tap];
        
        self.line = [UIView new];
        self.line.backgroundColor = [UIColor lightGrayColor];
        self.line.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.line];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_line]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_line)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_line(==0.5)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_line)]];
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

@interface URBNAccordionCollectionVC ()
@property (nonatomic, strong) URBNAccordionDataSourceAdapter *adapter;
@property (weak, nonatomic) IBOutlet UIStepper *stepper;
@end

@implementation URBNAccordionCollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    layout.headerReferenceSize = CGSizeMake(300.f, 40.f);
    
    NSMutableArray *items = [NSMutableArray array];
    NSMutableArray *sections = [NSMutableArray array];
    for (int i = 0; i < 4; i++) {
        [sections addObject:[NSString stringWithFormat:@"Section %i", i]];
        [items addObject:@[@"Item 0", @"Item 1", @"Item 2", @"Item 3", @"Item 4"]];
    }
    self.stepper.value = (double)sections.count;
    
    self.adapter = [[URBNAccordionDataSourceAdapter alloc] initWithSectionObjects:sections andItems:items];
    self.adapter.fallbackDataSource = self;
    self.adapter.collectionView = self.collectionView;
    self.adapter.sectionsToKeepOpen = [NSIndexSet indexSetWithIndex:0];
    self.adapter.allowMultipleExpandedSections = YES;

    /// If all of your cell classes are unique, then you can just call regsiter cell with that class.
    /// The identifier will be the className
    [self.adapter registerCellClass:[UICollectionViewCell class] withConfigurationBlock:^(UICollectionViewCell *cell, id object, NSIndexPath *indexPath) {
        cell.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:.8f];
        UILabel *label = (UILabel *)[cell viewWithTag:100];
        
        if(!label)
        {
            label = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
            label.tag = 100;
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:30];
            label.textColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:label];
        }
        
        label.text = object;
    }];
    
    /// Here we're registering a reuseableView for our section headers.  Pretty sweet
    __weak typeof(self) weakSelf = self;
    [self.adapter registerAccordionHeaderViewClass:[URBNAccordionCVHeader class] withConfigurationBlock:^(URBNAccordionCVHeader *view, id object, NSInteger section, BOOL expanded) {
        view.catLabel.text = object;
        [view setExpanded:expanded];
        view.tappedBlock = ^() {
            [weakSelf.adapter toggleSection:section];
        };
    }];
    
    self.collectionView.dataSource = self.adapter;
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

@end
