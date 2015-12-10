//
//  URBNSwiftTableViewController.swift
//  URBNDataSource
//
//  Created by Dustin Bergman on 12/10/15.
//  Copyright © 2015 Joe. All rights reserved.
//

import UIKit
//import URBNDataSource.URBNDataSourceAdapter
//import URBNArrayDataSourceAdapter

class URBNSwiftTableViewController: UITableViewController {
    
    var adapter: URBNArrayDataSourceAdapter?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var items = [String]()
        for i in 1...50 {
            items.append("Item " + String(i))
        }
        
        adapter = URBNArrayDataSourceAdapter.init(items: items)
        adapter?.fallbackDataSource = self
        adapter?.tableView = tableView
        adapter?.autoSizingEnabled = true
    }

}
