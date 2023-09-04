//
//  Account.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 01.09.2023.
//

import Foundation

class Account: Codable, ObservableObject, Identifiable, Hashable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(bankName)
        hasher.combine(balance)
    }
    enum CodingKeys: CodingKey {
        case bankName
        case balance
        case cashback
    }
    var id = UUID()
    @Published var bankName: String
    @Published var balance: Decimal
    @Published var cashback: Decimal
    init(bankName: String, balance: Decimal, cashback: Decimal) {
        self.bankName = bankName
        self.balance = balance
        self.cashback = cashback
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.bankName, forKey: .bankName)
        try container.encode(self.balance, forKey: .balance)
        try container.encode(self.cashback, forKey: .cashback)
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try bankName = container.decode(String.self, forKey: .bankName)
        try balance = container.decode(Decimal.self, forKey: .balance)
        try cashback = container.decode(Decimal.self, forKey: .cashback)
    }
}
