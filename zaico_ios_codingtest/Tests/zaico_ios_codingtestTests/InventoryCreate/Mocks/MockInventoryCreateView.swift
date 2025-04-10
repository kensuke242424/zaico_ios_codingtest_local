//
//  MockInventoryCreateView.swift
//  zaico_ios_codingtest
//
//  Created by Kensuke Nakagawa on 2025/04/10.
//
final class MockInventoryCreateView: InventoryCreateViewInterface {
    var didShowDuplicateAlert = false
    var didShowErrorAlert = false
    var didCloseView = false
    var alertCompletionHandler: ((Bool) -> Void)?

    func showDuplicateAlert(title: String?, message: String, completion: @escaping (Bool) -> Void) {
        didShowDuplicateAlert = true
        alertCompletionHandler = completion
    }

    func showErrorAlert(title: String?, message: String) {
        didShowErrorAlert = true
    }

    func closeView() {
        didCloseView = true
    }
}
