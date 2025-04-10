//
//  Untitled.swift
//  zaico_ios_codingtest
//
//  Created by Kensuke Nakagawa on 2025/04/09.
//

import UIKit

class InventoryCreateViewController: UIViewController, UITextFieldDelegate {
    
    private let titleTextField = UITextField()
    
    private var presenter: InventoryCreatePresenterInterface?
    
    // 安全なラッパーでクラッシュを防ぐ
    private var safePresenter: InventoryCreatePresenterInterface {
        guard let presenter else {
            fatalError("InventoryCreatePresenter has not been injected.")
        }
        return presenter
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func inject(presenter: InventoryCreatePresenterInterface) {
        self.presenter = presenter
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
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        
        return doneButton
    }
    
    @objc func didTapDoneButton() {
        let inventory = Inventory(
            id: 0,
            title: normalizedTitle(from: titleTextField.text),
            quantity: nil,
            itemImage: nil
        )
        
        safePresenter.didTapDoneButton(with: inventory)
    }
    
    // タイトルが空なら "-" に変換して在庫データを作成・送信
    private func normalizedTitle(from input: String?) -> String {
        guard let input, !input.isEmpty else {
            return "-"
        }
        return input
    }
    
    private func setupTitleTextField() {
        let titleLabel = UILabel()
        titleLabel.text = "物品名"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleTextField.borderStyle = .roundedRect
        titleTextField.placeholder = "物品名を入力"
        titleTextField.delegate = self
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(titleTextField)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            titleTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            titleTextField.heightAnchor.constraint(equalToConstant: 60)
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
}

extension InventoryCreateViewController: InventoryCreateViewInterface {
    func showDuplicateAlert(title: String?, message: String, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "はい", style: .default, handler: { _ in
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: "いいえ", style: .cancel, handler: { _ in
            completion(false)
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func showErrorAlert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func closeView() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
