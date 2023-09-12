//
//  AddAccount.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 07.09.2023.
//

import SwiftUI

struct AddAccount: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var user: User
    
    @State private var bankName = ""
    @State private var balanceInput = 0
    @State private var cashbackInput = 0
    @State private var accentColor = ColorEncode.init(stored: .blue)
    
    private var actualBalanceInput: Decimal {
        Decimal(balanceInput) / 100
    }
    private var actualCashbackInput: Decimal {
        Decimal(cashbackInput) / 100
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                TextField("Sberbank", text: $bankName)
                    .font(.title.bold())
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(accentColor.get().opacity(0.5), lineWidth: 2)
                    }
                    .padding(8)
                HStack{
                    Text("Balance: ")
                        .font(.title2.bold())
                    TextFieldPro(value: $balanceInput)
                }
                    .padding(6)
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    }
                    .padding(8)
                HStack{
                    Text("Cashback: ")
                        .font(.title3.bold())
                    TextFieldPro(value: $cashbackInput)
                }
                    .padding(6)
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    }
                    .padding(8)
                Picker("Accent color", selection: $accentColor.stored) {
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
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                }
                .padding(8)
            
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Done") {
                        user.wallet.accounts.append(Account(bankName: bankName, balance: actualBalanceInput, cashback: actualCashbackInput, accentColor: accentColor))
                        if let encoded = try? JSONEncoder().encode(user) {
                            UserDefaults.standard.set(encoded, forKey: "user")
                        }
                        dismiss()
                    }
                    .disabled(bankName.isEmpty)
                }
            }
            .navigationTitle("New account")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AddAccount_Previews: PreviewProvider {
    static var previews: some View {
        AddAccount(user: User(name: "Yegor", wallet: Wallet(accounts: [Account(bankName: "Tinkoff", balance: 132500, cashback: 201, accentColor: .init(stored: .green))]), inflow: Date.now, auth: AuthData(password: 1234)))
    }
}
