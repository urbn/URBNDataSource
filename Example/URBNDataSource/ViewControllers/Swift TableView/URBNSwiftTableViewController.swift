//
//  URBNSwiftTableViewController.swift
//  URBNDataSource
//
//  Created by Dustin Bergman on 12/10/15.
//  Copyright © 2015 Joe. All rights reserved.
//

import UIKit
import URBNDataSource


class URBNSwiftTableViewController: UITableViewController {
    
    
    lazy var adapter: URBNArrayDataSourceAdapter = {
        var items = [String]()
        for i in 1...50 {
            items.append("Item " + String(i))
        }
        
        return URBNArrayDataSourceAdapter(items: items)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        adapter.fallbackDataSource = self
        adapter.tableView = tableView
        adapter.autoSizingEnabled = true
        adapter.registerCell { (cell: UITableViewCell, object: NSString, ip) -> () in
            cell.textLabel?.text = object as String
        }
        /// If all of your cell classes are unique, then you can just call regsiter cell with that class.
        /// The identifier will be the className
        
        /// Since this is a different subclass than the UITableViewCell we're doing above, there's no need to supply an identifier
        /// Since this Cell has a nib file, it will be instantiated from that nib as well.
        adapter.registerCell { (cell: CustomTableCellFromNib, object: NSString, ip) -> () in
            cell.textLabel?.text = object as String
            cell.detailTextLabel?.text = cell.reuseIdentifier
        }
        
        /// Since we've registered an `UITableViewCell` above, we should supply an identifier for this cell
        adapter.registerCell("My Identifier") { (cell: UITableViewCell, object: NSString, ip) -> () in
            cell.textLabel?.textColor = UIColor.red
            cell.textLabel?.text = object as String
        }
        
        /// Here we're registering a reuseableTableHeaderView for our section headers.  Pretty sweet
        adapter.registerHeaderView { (headerView: UITableViewHeaderFooterView, kind, indexPath) -> () in
            if (headerView.tag == 0) {
                headerView.tag = 100
                headerView.contentView.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
            }
            
            headerView.textLabel?.textColor = UIColor.black
            headerView.textLabel?.text = "Table HeaderView " + String(indexPath.section)
        }
        
        /// Here we're registering a reuseableTableHeaderView for our section footers.  Pretty sweet.
        /// Notice that we're not supplying an identifier here.  That's because it's not needed.
        /// Even though we're registering configuration blocks for the same class, since they're different kinds (`URBNSupplementaryViewTypeFooter` vs. `URBNSupplementaryViewTypeHeader`)
        /// we can ignore the identifier
        adapter.registerFooterView { (footerView: UITableViewHeaderFooterView, kind, indexPath) -> () in
            footerView.contentView.backgroundColor = UIColor.orange.withAlphaComponent(0.1)
            footerView.textLabel?.textColor = UIColor.black
            footerView.textLabel?.text = "Table footer " + String(indexPath.section)
        }
        
        /// Since we want more than  1 identifier, we need to supply an identifier configuration here.
        adapter.cellIdentifierBlock = { (type, indexPath) -> String in
            let cellIdentifiers = [NSStringFromClass(UITableViewCell.self), NSStringFromClass(CustomTableCellFromNib.self), "My Identifier"]

            return cellIdentifiers[(indexPath.item % cellIdentifiers.count)]
        }
        
        tableView.sectionFooterHeight = 100.0
        tableView.rowHeight = 20.0
        
        tableView.delegate = adapter
        tableView.dataSource = adapter
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100.0
    }
    
    @IBAction func toggleAutoSizing(_ sender: UIBarButtonItem) {
        let sizingStatus = adapter.autoSizingEnabled ? "Off" : "On"
        sender.title = "AutoSizing: " + sizingStatus
        adapter.autoSizingEnabled  = !adapter.autoSizingEnabled
        tableView.reloadData()
    }
    
    @IBAction func toggleSectionedData(_ sender: UIBarButtonItem) {
        if adapter.isSectioned() {
            /// We're not sectioned.  Let's make it sectioned
            let data = ["Item 1" as AnyObject, "Item 2" as AnyObject, "Item 3" as AnyObject, "Item 4" as AnyObject]
            adapter.replaceItems(data)
        }
        else {
            /// We're already sectioned.  Make this a flat list
            let data = [["Section 1 item 1", "Section 1 Item 2"],   // Section1
                ["Section 2 item 1", "Section 2 Item 2"],   // Section2
                ["Section 3 item 1", "Section 3 Item 2"],   // Section3
                ["Section 4 item 1", "Section 4 Item 2"]]   // Section4
            adapter.replaceItems(data)
        }
        
        let sectionStatus = adapter.isSectioned() ? "Off" : "On"
        sender.title = "Sections: " + sectionStatus
    }
}
