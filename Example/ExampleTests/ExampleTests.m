//
//  URBNDataSourceTests.m
//  URBNDataSourceTests
//
//  Created by Joe on 11/10/2014.
//  Copyright (c) 2014 Joe. All rights reserved.
//

@import XCTest;
@import URBNDataSource;

@interface BaseTests : XCTestCase @end
@implementation BaseTests

- (void)testAsserts {
    URBNArrayDataSourceAdapter *ds = [[URBNArrayDataSourceAdapter alloc] init];
    
    // The following items should throw asserts
    XCTAssertThrows([ds registerCellClass:[UITableViewCell class] withConfigurationBlock:nil]);
    XCTAssertThrows([ds registerCellClass:[UITableViewCell class] withIdentifier:@"Id" withConfigurationBlock:nil]);
}

// https://github.com/urbn/URBNDataSource/issues/4
- (void)testGithubIssue4Collection {
    
    URBNArrayDataSourceAdapter *ds = [[URBNArrayDataSourceAdapter alloc] initWithItems:nil];
    XCTAssertNotNil(ds.allItems);
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    UICollectionView *cv = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 320) collectionViewLayout:layout];
    ds.collectionView = cv;
    [ds registerCellClass:[UICollectionViewCell class] withConfigurationBlock:^(id cell, id object, NSIndexPath *indexPath) {
        
    }];
    cv.dataSource = ds;
    
    NSArray *itemsBeingAdded = @[@0,@1,@2,@3];
    XCTAssertNoThrow([ds appendItems:itemsBeingAdded inSection:0]);
}

- (void)testGithubIssue4Table {
    URBNArrayDataSourceAdapter *ds = [[URBNArrayDataSourceAdapter alloc] initWithItems:nil];
    XCTAssertNotNil(ds.allItems);
    
    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 320) style:UITableViewStyleGrouped];
    ds.tableView = tv;
    [ds registerCellClass:[UITableViewCell class] withConfigurationBlock:^(id cell, id object, NSIndexPath *indexPath) {
        
    }];
    tv.dataSource = ds;
    
    NSArray *itemsBeingAdded = @[@0,@1,@2,@3];
    XCTAssertNoThrow([ds appendItems:itemsBeingAdded inSection:0]);
}

- (void)testAccordionNilOrEmptySectionsArrayAssert {
    XCTAssertThrows([[URBNAccordionDataSourceAdapter alloc] initWithSectionObjects:nil andItems:nil]);
    XCTAssertThrows([[URBNAccordionDataSourceAdapter alloc] initWithItems:nil]);
    XCTAssertThrows([[URBNAccordionDataSourceAdapter alloc] initWithSectionObjects:@[] andItems:nil]);
}

@end