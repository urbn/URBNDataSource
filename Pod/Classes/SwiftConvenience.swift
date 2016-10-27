//
//  SwiftConvenience.swift
//  Pods
//
//  Created by Nick DiStefano on 2/1/16.
//
//

import Foundation


extension URBNDataSourceAdapter {
    public func registerCell<CellElement: UIView, DataElement: AnyObject>(_ identifier: String = "\(CellElement.self)", configurationBlock: @escaping (CellElement, DataElement, IndexPath) -> ()) {
        registerCellClass(CellElement.self, withIdentifier: identifier) { (cell, data, ip) -> Void in
            guard let cell = cell as? CellElement, let data = data as? DataElement else {
                assertionFailure("Incorrect Types passed to DataSource. WHAT IS HAPPENING?")
                return
            }
            configurationBlock(cell, data, ip as IndexPath)
        }
    }
    
    public func registerFooterView<ViewElement: UIView>(_ configurationBlock: @escaping (_ view: ViewElement, _ kind: URBNSupplementaryViewType, IndexPath) -> ()) {
        registerSupplementaryUpdatable(.footer, configurationBlock: configurationBlock)
    }
    
    public func registerHeaderView<ViewElement: UIView>(_ configurationBlock: @escaping (_ view: ViewElement, _ kind: URBNSupplementaryViewType, IndexPath) -> ()) {
        registerSupplementaryUpdatable(.header, configurationBlock: configurationBlock)
    }
    
    fileprivate func registerSupplementaryUpdatable<ViewElement: UIView>(_ kind: URBNSupplementaryViewType,configurationBlock: @escaping (_ view: ViewElement, _ kind: URBNSupplementaryViewType, IndexPath) -> ()) {
        registerSupplementaryViewClass(ViewElement.self, ofKind: kind) { (view, kind, ip) -> Void in
            guard let view = view as? ViewElement else {
                assertionFailure("Incorrect Types passed to DataSource. WHAT IS HAPPENING?")
                return
            }
            configurationBlock(view, kind, ip as IndexPath)
        }
    }
}
