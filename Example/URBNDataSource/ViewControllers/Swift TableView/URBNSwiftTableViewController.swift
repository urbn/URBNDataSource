//
//  URBNSwiftTableViewController.swift
//  URBNDataSource
//
//  Created by Dustin Bergman on 12/10/15.
//  Copyright © 2015 Joe. All rights reserved.
//

import UIKit

class URBNSwiftTableViewController: UITableViewController {
    
    var adapter: URBNArrayDataSourceAdapter?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var items = [String]()
        for i in 1...50 {
            items.append("Item " + String(i))
        }
        
        adapter = URBNArrayDataSourceAdapter(items: items)
        adapter?.fallbackDataSource = self
        adapter?.tableView = tableView
        adapter?.autoSizingEnabled = true
        
        /// If all of your cell classes are unique, then you can just call regsiter cell with that class.
        /// The identifier will be the className
        adapter?.registerCellClass(UITableViewCell.self) { (cell, object, indexPath) in
            guard let cell = cell as? UITableViewCell else { return }
            guard let object = object as? String else { return }
            
            cell.textLabel?.text = object
        }
        
        /// Since this is a different subclass than the UITableViewCell we're doing above, there's no need to supply an identifier
        /// Since this Cell has a nib file, it will be instantiated from that nib as well.
        adapter?.registerCellClass(CustomTableCellFromNib.self) { (cell, object, indexPath) in
            guard let cell = cell as? CustomTableCellFromNib else { return }
            guard let object = object as? String else { return }
            
            cell.textLabel?.text = object
            cell.detailTextLabel?.text = cell.reuseIdentifier
        }
        
        /// Since we've registered an `UITableViewCell` above, we should supply an identifier for this cell
        adapter?.registerCellClass(UITableViewCell.self, withIdentifier: "My Identifier") { (cell, object, indexPath) in
            guard let cell = cell as? UITableViewCell else { return }
            guard let object = object as? String else { return }
            
            cell.textLabel?.textColor = .redColor()
            cell.textLabel?.text = object;
        }
        
        /// Here we're registering a reuseableTableHeaderView for our section headers.  Pretty sweet
        adapter?.registerSupplementaryViewClass(UITableViewHeaderFooterView.self, ofKind: .Header) { (view, kind, indexPath) in
            guard let headerView = view as? UITableViewHeaderFooterView else { return }

            if (headerView.tag == 0) {
                headerView.tag = 100
                headerView.contentView.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
            }
            
            headerView.textLabel?.textColor = .blackColor()
            headerView.textLabel?.text = "Table HeaderView " + String(indexPath.section)
        }
        
        /// Here we're registering a reuseableTableHeaderView for our section footers.  Pretty sweet.
        /// Notice that we're not supplying an identifier here.  That's because it's not needed.
        /// Even though we're registering configuration blocks for the same class, since they're different kinds (`URBNSupplementaryViewTypeFooter` vs. `URBNSupplementaryViewTypeHeader`)
        /// we can ignore the identifier
        adapter?.registerSupplementaryViewClass(UITableViewHeaderFooterView.self, ofKind: .Footer) { (view, kind, indexPath) in
            guard let footerView = view as? UITableViewHeaderFooterView else { return }
            
            footerView.contentView.backgroundColor = UIColor.orangeColor().colorWithAlphaComponent(0.1)
            footerView.textLabel?.textColor = .blackColor()
            footerView.textLabel?.text = "Table footer " + String(indexPath.section)
        }
        
        /// Since we want more than  1 identifier, we need to supply an identifier configuration here.
        adapter?.cellIdentifierBlock = { (type, indexPath) -> String in
            let cellIdentifiers = [NSStringFromClass(UITableViewCell.self), NSStringFromClass(CustomTableCellFromNib.self), "My Identifier"]

            return cellIdentifiers[(indexPath.item % cellIdentifiers.count)];
        }
        
        tableView.sectionFooterHeight = 100.0
        tableView.rowHeight = 20.0
        
        tableView.delegate = adapter
        tableView.dataSource = adapter
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100.0
    }
    
    @IBAction func toggleAutoSizing(sender: UIBarButtonItem) {
        if let dsAdapter = adapter {
                    
            let sizingStatus = dsAdapter.autoSizingEnabled ? "Off" : "On"
            sender.title = "AutoSizing: " + sizingStatus
            dsAdapter.autoSizingEnabled  = !dsAdapter.autoSizingEnabled
            tableView.reloadData()
        }
    }
    
    @IBAction func toggleSectionedData(sender: UIBarButtonItem) {
        var data = [AnyObject]()
 
        if let dsAdapter = adapter {
            if dsAdapter.isSectioned() {
                /// We're not sectioned.  Let's make it sectioned
                data = ["Item 1", "Item 2", "Item 3", "Item 4"];
            }
            else {
                /// We're already sectioned.  Make this a flat list
                data = [["Section 1 item 1", "Section 1 Item 2"],   // Section1
                    ["Section 2 item 1", "Section 2 Item 2"],   // Section2
                    ["Section 3 item 1", "Section 3 Item 2"],   // Section3
                    ["Section 4 item 1", "Section 4 Item 2"]]   // Section4
            }
            
            let sectionStatus = dsAdapter.isSectioned() ? "Off" : "On"
            sender.title = "Sections: " + sectionStatus
            
            dsAdapter.replaceItems(data)
        }
    }
}
