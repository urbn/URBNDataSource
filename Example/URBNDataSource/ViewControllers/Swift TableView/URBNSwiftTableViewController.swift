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
            guard let cell = cell as? CustomTableCellFromNib else { return }
            guard let object = object as? String else { return }
            
            cell.textLabel?.textColor = .redColor()
            cell.textLabel?.text = object;
        }
        
        /// Here we're registering a reuseableTableHeaderView for our section footers.  Pretty sweet.
        /// Notice that we're not supplying an identifier here.  That's because it's not needed.
        /// Even though we're registering configuration blocks for the same class, since they're different kinds (`URBNSupplementaryViewTypeFooter` vs. `URBNSupplementaryViewTypeHeader`)
        /// we can ignore the identifier
        adapter?.registerSupplementaryViewClass(UITableViewHeaderFooterView.self, ofKind: .Header) { (view, kind, indexPath) in
            guard let headerView = view as? UITableViewHeaderFooterView else { return }
            guard let indexPath = view as? NSIndexPath else { return }
            
            if (headerView.tag == 0) {
                headerView.tag = 100
                headerView.contentView.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.1)
            }
            
            headerView.textLabel?.textColor = .blackColor()
            headerView.textLabel?.text = "Table HeaderView " + String(indexPath.section)
        }
        

        /// Since we want more than  1 identifier, we need to supply an identifier configuration here.
        adapter?.cellIdentifierBlock = { (type, indexPath) -> String in
            let cellIdentifiers = [NSStringFromClass(UITableViewCell.self), NSStringFromClass(CustomTableCellFromNib.self), "My Identifier"]
            var test = cellIdentifiers[indexPath.row]
//            
//            
//            return NSStringFromClass(UITableViewCell.self)
        
            
            return cellIdentifiers[indexPath.row]
        }
        
        tableView.sectionFooterHeight = 100.0
        tableView.rowHeight = 20.0
        
        tableView.delegate = adapter
        tableView.dataSource = adapter
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100.0
    }
}
