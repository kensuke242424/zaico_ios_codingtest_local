//
//  InventoryCreatePresenter.swift
//  zaico_ios_codingtest
//
//  Created by Kensuke Nakagawa on 2025/04/10.
//
import Foundation

final class InventoryCreatePresenter: InventoryCreatePresenterInterface {
    
    weak var view: InventoryCreateViewInterface?
    private let inventories: [Inventory]
    private let apiClient: APIClientProtocol
    private let delegate: InventoryCreateDelegate
    
    private var safeView: InventoryCreateViewInterface {
        guard let view else {
            fatalError("View has not been injected into Presenter")
        }
        return view
    }
    
    init(
        inventories: [Inventory],
        delegate: InventoryCreateDelegate,
        apiClient: APIClientProtocol = APIClient.shared
    ) {
        self.inventories = inventories
        self.delegate = delegate
        self.apiClient = apiClient
    }
    
    func didTapDoneButton(with inventory: Inventory) {
        if isDuplicate(inventory) {
            safeView.showDuplicateAlert(
                title: "確認",
                message: "\n物品名\n\n上記の項目で同じ在庫データが既に作成されています。このまま在庫データを作成してもよろしいですか？",
                completion: { [weak self] confirmed in
                    guard confirmed else { return }
                    self?.submit(inventory: inventory)
                }
            )
        } else {
            submit(inventory: inventory)
        }
    }
    
    private func isDuplicate(_ inventory: Inventory) -> Bool {
        return inventories.contains { $0.title == inventory.title }
    }
    
    private func submit(inventory: Inventory) {
        Task {
            do {
                try await apiClient.createInventory(inventory)
                delegate.didCreateNewInventory()
                safeView.closeView()
            } catch {
                safeView.showErrorAlert(title: nil, message: "データの作成に失敗しました。再試行してください。")
            }
        }
    }
}
