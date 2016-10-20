//
//  SwiftConvenience.swift
//  Pods
//
//  Created by Nick DiStefano on 2/1/16.
//
//

import Foundation


extension URBNDataSourceAdapter {
    public func registerCell<CellElement: UIView, DataElement: AnyObject>(identifier: String = "\(CellElement.self)", configurationBlock: @escaping (CellElement, DataElement, NSIndexPath) -> ()) {
        registerCellClass(CellElement.self, withIdentifier: identifier) { (cell, data, ip) -> Void in
            guard let cell = cell as? CellElement, let data = data as? DataElement else {
                assertionFailure("Incorrect Types passed to DataSource. WHAT IS HAPPENING?")
                return
            }
            configurationBlock(cell, data, ip as NSIndexPath)
        }
    }
    
    public func registerFooterView<ViewElement: UIView>(configurationBlock: @escaping (_ view: ViewElement, _ kind: URBNSupplementaryViewType, NSIndexPath) -> ()) {
        registerSupplementaryUpdatable(kind: .footer, configurationBlock: configurationBlock)
    }
    
    public func registerHeaderView<ViewElement: UIView>(configurationBlock: @escaping (_ view: ViewElement, _ kind: URBNSupplementaryViewType, NSIndexPath) -> ()) {
        registerSupplementaryUpdatable(kind: .header, configurationBlock: configurationBlock)
    }
    
    private func registerSupplementaryUpdatable<ViewElement: UIView>(kind: URBNSupplementaryViewType,configurationBlock: @escaping (_ view: ViewElement, _ kind: URBNSupplementaryViewType, NSIndexPath) -> ()) {
        registerSupplementaryViewClass(ViewElement.self, ofKind: kind) { (view, kind, ip) -> Void in
            guard let view = view as? ViewElement else {
                assertionFailure("Incorrect Types passed to DataSource. WHAT IS HAPPENING?")
                return
            }
            configurationBlock(view, kind, ip as NSIndexPath)
        }
    }
}
