//
//  MockAPIClient.swift
//  zaico_ios_codingtest
//
//  Created by Kensuke Nakagawa on 2025/04/10.
//

import Foundation

final class MockAPIClient: APIClientProtocol {
    var shouldThrowError = false
    var didCallCreateInventory = false

    func fetchInventories() async throws -> [Inventory] {
        fatalError("Not used")
    }

    func fetchInventory(id: Int?) async throws -> Inventory {
        fatalError("Not used")
    }

    func createInventory(_ inventory: Inventory) async throws {
        didCallCreateInventory = true
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 1)
        }
    }
}
