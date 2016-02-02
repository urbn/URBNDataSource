//
//  SwiftConvenience.swift
//  Pods
//
//  Created by Nick DiStefano on 2/1/16.
//
//

import Foundation


extension URBNDataSourceAdapter {
    public func registerUpdatable<CELL: UIView, DATA: AnyObject>(identifier: String = "\(CELL.self)", configurationBlock: (CELL, DATA, NSIndexPath) -> ()) {
        registerCellClass(CELL.self, withIdentifier: identifier) { (cell, data, ip) -> Void in
            guard let cell = cell as? CELL, data = data as? DATA else {
                assertionFailure("Incorrect Types passed to DataSource. WHAT IS HAPPENING?")
                return
            }
            configurationBlock(cell, data, ip)
        }
    }
    
    public func registerSupplementaryUpdatable<VIEW: UITableViewHeaderFooterView>(kind: URBNSupplementaryViewType,configurationBlock: (view: VIEW, kind: URBNSupplementaryViewType, NSIndexPath) -> ()) {
        registerSupplementaryViewClass(VIEW.self, ofKind: kind) { (view, kind, ip) -> Void in
            guard let view = view as? VIEW else {
                assertionFailure("Incorrect Types passed to DataSource. WHAT IS HAPPENING?")
                return
            }
            configurationBlock(view: view, kind: kind, ip)
        }
    }
}