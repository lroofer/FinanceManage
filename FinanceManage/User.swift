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
        case auth
    }
    @Published var name: String?
    @Published var wallet: Wallet
    @Published var inflow: Date
    @Published var auth: AuthData
    init(name: String?, wallet: Wallet, inflow: Date, auth: AuthData) {
        self.name = name
        self.wallet = wallet
        self.inflow = inflow
        self.auth = auth
    }
    init() {
        if let savedUser = UserDefaults.standard.data(forKey: "user") {
            if let decoded = try? JSONDecoder().decode(User.self, from: savedUser) {
                self.name = decoded.name
                self.wallet = decoded.wallet
                self.inflow = decoded.inflow
                self.auth = decoded.auth
                return
            }
        }
        self.name = nil
        self.inflow = Date.now
        self.wallet = Wallet()
        self.auth = AuthData(password: 1234)
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        wallet = try container.decode(Wallet.self, forKey: .wallet)
        inflow = try container.decode(Date.self, forKey: .inflow)
        auth = try container.decode(AuthData.self, forKey: .auth)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(wallet, forKey: .wallet)
        try container.encode(inflow, forKey: .inflow)
        try container.encode(auth, forKey: .auth)
    }
}
