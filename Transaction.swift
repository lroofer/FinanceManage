//
//  Transaction.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 02.09.2023.
//

import Foundation

class UserTransactions: Codable, ObservableObject {
    enum CodingKeys: CodingKey {
        case all
    }
    @Published var all: [Transaction]
    init(all: [Transaction]) {
        self.all = all
    }
    init() {
        if let userData = UserDefaults.standard.data(forKey: "transactions") {
            if let decoded = try? JSONDecoder().decode([Transaction].self, from: userData) {
                all = decoded
                return
            }
        }
        all = [Transaction]()
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        all = try container.decode([Transaction].self, forKey: .all)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(all, forKey: .all)
    }
}

struct Transaction: Codable, Identifiable {
    static let categories = ["Shop", "Transition", "Home", "Commute", "Entertain"]
    var id = UUID()
    var name: String
    var category: String
    var sum: Decimal
    var cashback: Decimal?
}
