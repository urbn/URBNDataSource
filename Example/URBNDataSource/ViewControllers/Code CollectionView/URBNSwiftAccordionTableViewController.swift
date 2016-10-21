//
//  URBNSwiftAccordionTableViewController.swift
//  URBNDataSource
//
//  Created by Dustin Bergman on 12/15/15.
//  Copyright © 2015 Joe. All rights reserved.
//

import UIKit
import URBNDataSource

typealias CellTappedBlock = () -> Void

class URBNSwiftAccordionTableViewController: UITableViewController {

    lazy var adapter: URBNAccordionDataSourceAdapter = {
        var items = [[String]]()
        var sections = [String]()
        for i in 0...5 {
            sections.append("Section " + String(i))
            items.append(["Item 0", "Item 1", "Item 2", "Item 3", "Item 4"])
        }
        
        return URBNAccordionDataSourceAdapter(sectionObjects: sections, andItems: items)
    }()

    @IBOutlet var stepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var items = [[String]]()
        var sections = [String]()
        for i in 0...5 {
            sections.append("Section " + String(i))
            items.append(["Item 0", "Item 1", "Item 2", "Item 3", "Item 4"])
        }
        
        stepper.value = Double(sections.count)

        adapter.fallbackDataSource = self
        adapter.tableView = tableView
        adapter.allowMultipleExpandedSections = true
        
        /// If all of your cell classes are unique, then you can just call regsiter cell with that class.
        /// The identifier will be the className
        adapter.registerCell { (cell: UITableViewCell, object: NSString, indexPath) in
            cell.textLabel?.text = object as String
        }
        
        adapter.registerAccordionHeaderViewClass(URBNAccordionHeader.self) { (view, object, section, expanded) in
            guard let accordionView = view as? URBNAccordionHeader,
            let itemText = object as? String else {
                return
            }

            accordionView.catLabel.text = itemText
            accordionView.expanded = expanded
            
            accordionView.tappedAction = { [unowned self] in
                self.adapter.toggleSection(section)
            }
        }
        
        adapter.sectionsToKeepOpen = IndexSet(integer: 0)
        
        tableView.delegate = self.adapter
        tableView.dataSource = self.adapter
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100.0
    }
    
    @IBAction func stepperPressed(_ sender: UIStepper) {
        let sectionCount = self.adapter.allSections().count
        if (Int(sender.value) > sectionCount) {
            adapter.appendSectionObject("Section " + String(sectionCount), items: ["Item A", "Item B", "Item C", "Item D", "Item E"])
        }
        else {
            adapter.removeLastSection()
        }
    }

    class URBNAccordionHeader : UITableViewHeaderFooterView {
        let catLabel = UILabel()
        var tappedAction:CellTappedBlock?
        let line = UIView()
        let expandedImgV = UIImageView(image: UIImage(named:"shop-category-plus"))

        var _expanded = false
        var expanded : Bool {
            get {
                return _expanded
            }
            set (willExpand) {
                if (willExpand != expanded) {
                    _expanded = willExpand
                    
                    catLabel.textColor = expanded ? UIColor.green : UIColor.blue
                    line.isHidden = expanded
                }
            }
        }
        
        override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            
            catLabel.font = UIFont.systemFont(ofSize: 14.0)
            catLabel.textColor = UIColor.blue
            catLabel.translatesAutoresizingMaskIntoConstraints = false
            catLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .vertical)
            contentView.addSubview(catLabel)
            
            let metrics = ["fifteenPadding":15]
            
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-fifteenPadding-[catLabel]", options: [], metrics:metrics, views: ["catLabel": catLabel]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[catLabel]|", options: [], metrics:metrics, views: ["catLabel": catLabel]))
            
            expandedImgV.highlightedImage = UIImage(named:"shop-category-minus")
            expandedImgV.translatesAutoresizingMaskIntoConstraints = false
            expandedImgV.contentMode = .scaleAspectFit
            contentView.addSubview(expandedImgV)
            
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:[expandedImgV]-fifteenPadding-|", options: [], metrics:metrics, views: ["expandedImgV": expandedImgV]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[expandedImgV]|", options: [], metrics:metrics, views: ["expandedImgV": expandedImgV]))
        
            let tap = UITapGestureRecognizer(target: self, action: #selector(URBNAccordionHeader.tapped(_:)))
            tap.numberOfTapsRequired = 1
            tap.numberOfTouchesRequired = 1
            addGestureRecognizer(tap)
            
            line.backgroundColor = UIColor.lightGray
            line.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(line)
            
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[line]|", options: [], metrics:metrics, views: ["line": line]))
            NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:[line(==0.5)]|", options: [], metrics:metrics, views: ["line": line]))
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func tapped(_ tap:UITapGestureRecognizer) {
            if (tap.state == .ended) {
                tappedAction?()
            }
        }
    }
}
