//
//  ViewController.swift
//  zaico_ios_codingtest
//
//  Created by ryo hirota on 2025/03/11.
//

import UIKit

class InventoryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private var inventories: [Inventory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupTableView()
        
        Task {
            await fetchInventories()
        }
    }
    
    private func setupNavigationBar() {
        title = "在庫一覧"
        
        let createInventoryBarButton = UIBarButtonItem(title: "新規登録", style: .done, target: self, action: #selector(createInventoryBarButtonTapped))
        self.navigationItem.rightBarButtonItem = createInventoryBarButton
    }
    
    @objc func createInventoryBarButtonTapped() {
        let inventoryCreateVC = InventoryCreateViewController(inventories: inventories)
        inventoryCreateVC.delegate = self
        navigationController?.pushViewController(inventoryCreateVC, animated: true)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.register(InventoryCell.self, forCellReuseIdentifier: "InventoryCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func fetchInventories() async {
        do {
            let data = try await APIClient.shared.fetchInventories()
            await MainActor.run {
                inventories = data
                tableView.reloadData()
            }
        } catch {
            print("Error fetching Inventories: \(error.localizedDescription)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inventories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InventoryCell", for: indexPath) as! InventoryCell
        cell.configure(leftText: String(inventories[indexPath.row].id),
                       rightText: inventories[indexPath.row].title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let inventoryDetailVC = InventoryDetailViewController(id: inventories[indexPath.row].id)
        navigationController?.pushViewController(inventoryDetailVC, animated: true)
    }
}

// 新規データ作成完了時、アイテムデータを再取得
extension InventoryListViewController: InventoryCreationDelegate {
    func didCreateNewInventory() {
        Task {
            await fetchInventories()
        }
    }
}
