//
//  Account.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 01.09.2023.
//

import Foundation
import SwiftUI

class Account: Codable, ObservableObject, Identifiable, Hashable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        lhs.id == rhs.id && lhs.balance == rhs.balance && lhs.bankName == rhs.bankName
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(bankName)
        hasher.combine(balance)
        hasher.combine(id)
    }
    enum CodingKeys: CodingKey {
        case bankName
        case balance
        case cashback
        case id
        case accentColor
    }
    var id: UUID
    @Published var bankName: String
    @Published var balance: Decimal
    @Published var cashback: Decimal
    @Published var accentColor: ColorEncode
    
    init(bankName: String, balance: Decimal, cashback: Decimal, accentColor: ColorEncode) {
        self.bankName = bankName
        self.balance = balance
        self.cashback = cashback
        self.accentColor = accentColor
        self.id = UUID()
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.bankName, forKey: .bankName)
        try container.encode(self.balance, forKey: .balance)
        try container.encode(self.cashback, forKey: .cashback)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.accentColor, forKey: .accentColor)
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try bankName = container.decode(String.self, forKey: .bankName)
        try balance = container.decode(Decimal.self, forKey: .balance)
        try cashback = container.decode(Decimal.self, forKey: .cashback)
        try id = container.decode(UUID.self, forKey: .id)
        try accentColor = container.decode(ColorEncode.self, forKey: .accentColor)
    }
}
