//
//  MockInventoryCreateDelegate.swift
//  zaico_ios_codingtest
//
//  Created by Kensuke Nakagawa on 2025/04/10.
//
final class MockInventoryCreateDelegate: InventoryCreateDelegate {
    var didCall = false
    func didCreateNewInventory() {
        didCall = true
    }
}
