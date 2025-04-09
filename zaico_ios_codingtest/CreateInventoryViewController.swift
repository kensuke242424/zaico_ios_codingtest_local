//
//  Untitled.swift
//  zaico_ios_codingtest
//
//  Created by Kensuke Nakagawa on 2025/04/09.
//

import UIKit

protocol InventoryCreationDelegate: AnyObject {
    func didCreateNewInventory()
}

class CreateInventoryViewController: UIViewController, UITextFieldDelegate {
    
    private let inventories: [Inventory]
    private let titleLabel = UILabel()
    private let textField = UITextField()
    weak var delegate: InventoryCreationDelegate?
    
    init(inventories: [Inventory], delegate: InventoryCreationDelegate? = nil) {
        self.inventories = inventories
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupTitleTextField()
    }
    
    private func setupNavigationBar() {
        title = "新規登録"
        
        let doneBarButtonItem = UIBarButtonItem(customView: makeDoneButton())
        navigationItem.rightBarButtonItem = doneBarButtonItem
    }
    
    // 完了ボタン
    private func makeDoneButton() -> UIButton {
        let doneButton = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "完了"
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
        
        let smallFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        config.attributedTitle = AttributedString("完了", attributes: AttributeContainer([.font: smallFont]))
        
        doneButton.configuration = config
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        return doneButton
    }
    
    @objc func doneButtonTapped() {
        if inventories.contains(where: { $0.title == textField.text }) {
            showAlertMessage(title: "確認", "\n物品名\n\n上記の項目で同じ在庫データが既に作成されています。このまま在庫データを作成してもよろしいですか？")
        } else {
            submitNewInventory()
        }
    }
    
    private func showAlertMessage(title: String? = nil, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OKボタン
        alert.addAction(UIAlertAction(title: "はい", style: .default, handler: { _ in
            self.submitNewInventory()
        }))
        // キャンセルボタン
        alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: { _ in
            // 処理なし
        }))
        
        present(alert, animated: true)
    }
    
    private func submitNewInventory() {
        Task {
            let result = await createInventory()
            
            if result {
                delegate?.didCreateNewInventory()
                navigationController?.popViewController(animated: true)
            } else {
                showErrorMessage("データの作成に失敗しました。再試行してください。")
            }
        }
    }
    
    private func createInventory() async -> Bool {
        
        // タイトル入力が空の場合には「-」を挿入する
        let inventoryTitle = textField.text?.isEmpty == true ? "-" : textField.text!
        
        let data = Inventory(id: 0, title: inventoryTitle, quantity: nil, itemImage: nil)
        
        do {
            try await APIClient.shared.createInventory(data)
            return true
        } catch {
            print("Error create data: \(error.localizedDescription)")
            return false
        }
    }
    
    private func setupTitleTextField() {
        titleLabel.text = "物品名"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textField.borderStyle = .roundedRect
        textField.placeholder = "物品名を入力"
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            textField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            textField.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // タップジェスチャーの追加（背景タップでキーボードを閉じる）
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // Returnキーが押されたときに呼ばれる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // 背景をタップしたときに呼ばれる
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
