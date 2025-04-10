//
//  InventoryCreateContract.swift.swift
//  zaico_ios_codingtest
//
//  Created by Kensuke Nakagawa on 2025/04/10.
//
import Foundation

protocol InventoryCreateViewInterface: AnyObject {
    func showDuplicateAlert(title: String?, message: String, completion: @escaping (Bool) -> Void)
    func showErrorAlert(title: String?, message: String)
    func closeView()
}

protocol InventoryCreatePresenterInterface: AnyObject {
    func didTapDoneButton(with inventory: Inventory)
}

protocol InventoryCreateDelegate: AnyObject {
    func didCreateNewInventory()
}
