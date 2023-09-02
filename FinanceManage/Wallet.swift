//
//  Wallet.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 31.08.2023.
//

import Foundation

class Wallet: Codable, ObservableObject {
    enum CodingKeys: CodingKey {
        case accounts
    }
    
    @Published var accounts: [Account]
    init() {
        accounts = [Account]()
    }
    init(accounts: [Account]) {
        self.accounts = accounts
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accounts = try container.decode([Account].self, forKey: .accounts)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accounts, forKey: .accounts)
    }
}
