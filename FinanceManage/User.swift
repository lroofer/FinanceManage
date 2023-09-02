//
//  User.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 31.08.2023.
//

import Foundation

class User: Codable, ObservableObject {
    enum CodingKeys: CodingKey {
        case name
        case wallet
        case inflow
    }
    
    @Published var name: String?
    @Published var wallet: Wallet?
    @Published var inflow: Date?
    init(name: String, wallet: Wallet, inflow: Date?) {
        self.name = name
        self.wallet = wallet
        self.inflow = inflow
    }
    init() {
        if let savedUser = UserDefaults.standard.data(forKey: "user") {
            if let decoded = try? JSONDecoder().decode(User.self, from: savedUser) {
                self.name = decoded.name
                self.wallet = decoded.wallet
                self.inflow = decoded.inflow
                return
            }
        }
        self.name = nil
        self.inflow = nil
        self.wallet = nil
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        wallet = try container.decode(Wallet.self, forKey: .wallet)
        inflow = try container.decode(Date.self, forKey: .inflow)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(wallet, forKey: .wallet)
        try container.encode(inflow, forKey: .inflow)
    }
}
