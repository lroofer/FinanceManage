//
//  InflowView.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 09.09.2023.
//

import SwiftUI

struct Case: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(8)
            .overlay {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
            }
    }
}

extension View {
    func titleStyle() -> some View {
        modifier(Case())
    }
}

struct InflowView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var user: User
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                ForEach($user.wallet.accounts) { account in
                    VStack {
                        TextField("Bank name", text: account.bankName)
                            .titleStyle()
                            .font(.title.bold())
                            .padding(.vertical, 5)
                        HStack {
                            Text("Balance:")
                                .font(.body.bold())
                            TextField("Balance", value: account.balance, format: .currency(code: Locale.current.identifier))
                        }
                        .titleStyle()
                        .padding(.vertical, 5)
                        HStack {
                            Text("Cashback:")
                                .font(.body.bold())
                            TextField("Cashback", value: account.cashback, format: .currency(code: Locale.current.identifier))
                        }
                        .titleStyle()
                        .padding(.vertical, 5)
                        HStack {
                            Picker("Accent color", selection: account.accentColor.stored) {
                                ForEach(ColorEncode.DynamicColor.headerCases, id: \.self) { color in
                                    HStack {
                                        Text(color.name)
                                        Spacer()
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(ColorEncode.init(stored: color).get().opacity(0.7))
                                            .frame(width: 20, height: 20)
                                    }
                                    .frame(width: 80)
                                }
                            }
                            .font(.body.bold())
                            .pickerStyle(.navigationLink)
                        }
                        .titleStyle()
                        .padding(.vertical, 5)
                        
                    }
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(account.accentColor.wrappedValue.get().opacity(0.9), lineWidth: 2)
                    }
                    .padding(8)
                }
            }
            .toolbar {
                Button("Done") {
                    if let encoded = try? JSONEncoder().encode(user) {
                        UserDefaults.standard.set(encoded, forKey: "user")
                        dismiss()
                    }
                }
            }
            .navigationTitle("Inflow in")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct InflowView_Previews: PreviewProvider {
    static var previews: some View {
        InflowView(user: User(name: "Yegor", wallet: Wallet(accounts: [Account(bankName: "Tinkoff", balance: 125000, cashback: 100, accentColor: .init(stored: .yellow)), Account(bankName: "Alfa", balance: 25000, cashback: 125, accentColor: .init(stored: .red))]), inflow: Date.now, auth: AuthData(password: 1234)))
    }
}
