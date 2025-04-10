//
//  APIClientProtocol.swift
//  zaico_ios_codingtest
//
//  Created by Kensuke Nakagawa on 2025/04/10.
//
import Foundation

protocol APIClientProtocol {
    func fetchInventories() async throws -> [Inventory]
    func fetchInventory(id: Int?) async throws -> Inventory
    func createInventory(_ inventory: Inventory) async throws
}
