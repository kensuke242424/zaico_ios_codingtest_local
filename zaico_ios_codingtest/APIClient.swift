//
//  APIClient.swift
//  zaico_ios_codingtest
//
//  Created by ryo hirota on 2025/03/11.
//

import Foundation

class APIClient {
    static let shared = APIClient()
    
    private let baseURL = "https://web.zaico.co.jp"
    private let token = "MQgTpVoHzR24o9YXSmuNZRJeZVQ7MFN3" // 実際のトークンに置き換える
    
    private init() {}
    
    func fetchInventories() async throws -> [Inventory] {
        let endpoint = "/api/v1/inventories"
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    throw URLError(.badServerResponse)
                }
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("[APIClient] API Response: \(jsonString)")
            }
            
            return try JSONDecoder().decode([Inventory].self, from: data)
        } catch {
            throw error
        }
    }
    
    func fetchInventory(id: Int?) async throws -> Inventory {
        var endpoint = "/api/v1/inventories"
        
        if let id = id {
            endpoint += "/\(id)"
        }
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    throw URLError(.badServerResponse)
                }
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("[APIClient] API Response: \(jsonString)")
            }
            
            return try JSONDecoder().decode(Inventory.self, from: data)
        } catch {
            throw error
        }
    }
    
    // 在庫データの作成
    func createInventory(_ inventory: Inventory) async throws {
        let endpoint = "/api/v1/inventories"
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }
        
        let parameters: [String: Any] = [
            "title": inventory.title,
            "quantity": inventory.quantity ?? "",
            "itemImage": inventory.itemImage ?? "",
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    throw URLError(.badServerResponse)
                }
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("[APIClient] API Response: \(jsonString)")
            }
        } catch {
            throw error
        }
    }
}
