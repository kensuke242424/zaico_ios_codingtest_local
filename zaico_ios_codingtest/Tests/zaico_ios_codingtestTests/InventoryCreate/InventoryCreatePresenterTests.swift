//
//  zaico_ios_codingtestTests.swift
//  zaico_ios_codingtestTests
//
//  Created by ryo hirota on 2025/03/11.
//

import XCTest
@testable import zaico_ios_codingtest

final class InventoryCreatePresenterTests: XCTestCase {

    /// 重複タイトルの在庫を登録しようとしたとき、重複アラートが表示されること
    func test_showDuplicateAlert_whenTitleIsDuplicate() {
        // Arrange
        let inventory = Inventory(id: 0, title: "ペン", quantity: nil, itemImage: nil)
        let mockView = MockInventoryCreateView()
        let mockDelegate = MockInventoryCreateDelegate()
        let mockAPI = MockAPIClient()

        let presenter = InventoryCreatePresenter(
            inventories: [inventory], // ← 重複リスト
            delegate: mockDelegate,
            apiClient: mockAPI
        )
        presenter.view = mockView

        // Act
        presenter.didTapDoneButton(with: inventory)

        // Assert
        XCTAssertTrue(mockView.didShowDuplicateAlert)
    }

    /// 重複していない在庫を登録したとき、APIに作成リクエストが送信され、delegateが呼ばれ、画面が閉じられること
    func test_submitInventory_successfullyCreatesInventory() async {
        // Arrange
        let inventory = Inventory(id: 0, title: "ノート", quantity: nil, itemImage: nil)
        let mockView = MockInventoryCreateView()
        let mockDelegate = MockInventoryCreateDelegate()
        let mockAPI = MockAPIClient()

        let presenter = InventoryCreatePresenter(
            inventories: [], // 重複なし
            delegate: mockDelegate,
            apiClient: mockAPI
        )
        presenter.view = mockView

        // Act
        presenter.didTapDoneButton(with: inventory)
        try? await Task.sleep(nanoseconds: 100_000_000) // タスク完了を待つ（0.1秒）

        // Assert
        XCTAssertTrue(mockDelegate.didCall)
        XCTAssertTrue(mockView.didCloseView)
    }

    /// API呼び出し時にエラーが発生したとき、エラーダイアログが表示されること
    func test_submitInventory_whenAPIThrows_errorAlertIsShown() async {
        // Arrange
        let inventory = Inventory(id: 0, title: "ノート", quantity: nil, itemImage: nil)
        let mockView = MockInventoryCreateView()
        let mockDelegate = MockInventoryCreateDelegate()
        let mockAPI = MockAPIClient()
        mockAPI.shouldThrowError = true

        let presenter = InventoryCreatePresenter(
            inventories: [],
            delegate: mockDelegate,
            apiClient: mockAPI
        )
        presenter.view = mockView

        // Act
        presenter.didTapDoneButton(with: inventory)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Assert
        XCTAssertTrue(mockView.didShowErrorAlert)
    }

    /// 重複タイトルの在庫に対し、ユーザーがアラートの「はい」を選択した場合、登録処理が実行されること
    func test_duplicateInventory_userConfirmsCreation_thenCreatesInventory() async {
        // Arrange
        let inventory = Inventory(id: 0, title: "ペン", quantity: nil, itemImage: nil)
        let mockView = MockInventoryCreateView()
        let mockDelegate = MockInventoryCreateDelegate()
        let mockAPI = MockAPIClient()

        let presenter = InventoryCreatePresenter(
            inventories: [inventory],
            delegate: mockDelegate,
            apiClient: mockAPI
        )
        presenter.view = mockView

        // Act
        presenter.didTapDoneButton(with: inventory)
        mockView.alertCompletionHandler?(true) // ユーザーが「はい」を選択したと仮定
        try? await Task.sleep(nanoseconds: 50_000_000)

        // Assert
        XCTAssertTrue(mockDelegate.didCall)
        XCTAssertTrue(mockView.didCloseView)
    }
    
    /// 重複タイトルの在庫に対し、ユーザーがアラートの「いいえ」を選択した場合、登録処理が実行されないこと
    func test_duplicateInventory_userCancelsCreation_thenDoesNotSubmit() async {
        // Arrange
        let inventory = Inventory(id: 0, title: "ペン", quantity: nil, itemImage: nil)
        let mockView = MockInventoryCreateView()
        let mockDelegate = MockInventoryCreateDelegate()
        let mockAPI = MockAPIClient()

        let presenter = InventoryCreatePresenter(
            inventories: [inventory],
            delegate: mockDelegate,
            apiClient: mockAPI
        )
        presenter.view = mockView

        // Act
        presenter.didTapDoneButton(with: inventory)

        // simulate user selecting "いいえ"
        mockView.alertCompletionHandler?(false)
        try? await Task.sleep(nanoseconds: 50_000_000)

        // Assert
        XCTAssertFalse(mockAPI.didCallCreateInventory)
        XCTAssertFalse(mockDelegate.didCall)
        XCTAssertFalse(mockView.didCloseView)
    }
}
