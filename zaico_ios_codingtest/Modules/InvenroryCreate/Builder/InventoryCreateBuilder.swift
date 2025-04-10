//
//  Untitled.swift
//  zaico_ios_codingtest
//
//  Created by Kensuke Nakagawa on 2025/04/10.
//

import UIKit

enum InventoryCreateBuilder {
    static func build(
        inventories: [Inventory],
        delegate: InventoryCreateDelegate,
        apiClient: APIClientProtocol = APIClient.shared
    ) -> UIViewController {
        let viewController = InventoryCreateViewController()
        let presenter = InventoryCreatePresenter(
            inventories: inventories,
            delegate: delegate,
            apiClient: apiClient
        )
        presenter.view = viewController
        viewController.inject(presenter: presenter)
        return viewController
    }
}
