//
//  SwiftConvenience.swift
//  Pods
//
//  Created by Nick DiStefano on 2/1/16.
//
//

import Foundation


extension URBNDataSourceAdapter {
    public func registerCell<CellElement: UIView, DataElement: AnyObject>(identifier: String = String(CellElement.self), configurationBlock: (CellElement, DataElement, NSIndexPath) -> ()) {
        registerCellClass(CellElement.self, withIdentifier: identifier) { (cell, data, ip) -> Void in
            guard let cell = cell as? CellElement, data = data as? DataElement else {
                assertionFailure("Incorrect Types passed to DataSource. WHAT IS HAPPENING?")
                return
            }
            configurationBlock(cell, data, ip)
        }
    }
    
    public func registerCell<CellElement: UIView, DataElement: _ObjectiveCBridgeable>(identifier: String = String(CellElement.self), configurationBlock: (CellElement, DataElement, NSIndexPath) -> ()) {
        registerCellClass(CellElement.self, withIdentifier: identifier) { (cell, data, ip) -> Void in
            guard let cell = cell as? CellElement, data = data as? DataElement else {
                assertionFailure("Incorrect Types passed to DataSource. WHAT IS HAPPENING?")
                return
            }
            configurationBlock(cell, data, ip)
        }
    }
    
    public func registerFooterView<ViewElement: UIView>(configurationBlock: (view: ViewElement, kind: URBNSupplementaryViewType, NSIndexPath) -> ()) {
        registerSupplementaryUpdatable(.Footer, configurationBlock: configurationBlock)
    }
    
    public func registerHeaderView<ViewElement: UIView>(configurationBlock: (view: ViewElement, kind: URBNSupplementaryViewType, NSIndexPath) -> ()) {
        registerSupplementaryUpdatable(.Header, configurationBlock: configurationBlock)
    }
    
    private func registerSupplementaryUpdatable<ViewElement: UIView>(kind: URBNSupplementaryViewType,configurationBlock: (view: ViewElement, kind: URBNSupplementaryViewType, NSIndexPath) -> ()) {
        registerSupplementaryViewClass(ViewElement.self, ofKind: kind) { (view, kind, ip) -> Void in
            guard let view = view as? ViewElement else {
                assertionFailure("Incorrect Types passed to DataSource. WHAT IS HAPPENING?")
                return
            }
            configurationBlock(view: view, kind: kind, ip)
        }
    }
}