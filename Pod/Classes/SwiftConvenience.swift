//
//  SwiftConvenience.swift
//  Pods
//
//  Created by Nick DiStefano on 2/1/16.
//
//

import Foundation


extension URBNDataSourceAdapter {
    public func registerUpdatable<CELL: UIView, DATA: AnyObject>(configurationBlock: (CELL, DATA, NSIndexPath) -> ()) {
        registerCellClass(CELL.self) { (cell, data, ip) -> Void in
            guard let cell = cell as? CELL, data = data as? DATA else {
                assertionFailure("Incorrect Types passed to DataSource. WHAT IS HAPPENING?")
                return
            }
            configurationBlock(cell, data, ip)
        }
    }
}