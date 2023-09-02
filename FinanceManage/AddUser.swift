//
//  AddUser.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 01.09.2023.
//

import SwiftUI

struct AddUser: View {
    @ObservedObject var user: User
    @Environment(\.dismiss) var dismiss
    @State private var userName = ""
    @State private var refund = Date.now
    @StateObject var wallet = Wallet(accounts: [Account(bankName: "", balance: 0, cashback: 0)])
    @FocusState private var bankNameFocused: Bool
    var body: some View {
        NavigationView {
            Form {
                TextField("First name", text: $userName)
                Section {
                    ForEach($wallet.accounts, editActions: .delete) { account in
                        VStack {
                            TextField("Bank name", text: account.bankName)
                                .font(.body.bold())
                            HStack {
                                Text("Balance:")
                                    .font(.body.bold())
                                TextField("Balance", value: account.balance, format: .currency(code: Locale.current.identifier))
                            }
                            HStack {
                                Text("Cashback:")
                                    .font(.body.bold())
                                TextField("Cashback", value: account.cashback, format: .currency(code: Locale.current.identifier))
                            }
                        }
                        .deleteDisabled(wallet.accounts.count < 2)
                    }
                    Button {
                        wallet.accounts.append(Account(bankName: "", balance: 0, cashback: 0))
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                            Text("add account")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Bank accounts")
                }
                Section {
                    DatePicker("Inflow on", selection: $refund, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                } header: {
                    Text("Next inflow on")
                }
            }
            .navigationTitle("New user")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Done") {
                        user.name = userName
                        user.wallet = wallet
                        user.inflow = refund
                        dismiss()
                    }
                    .disabled(userName.isEmpty || wallet.accounts.count < 1 || wallet.accounts[0].bankName.isEmpty)
                }
            }
        }
    }
}

struct AddUser_Previews: PreviewProvider {
    static var previews: some View {
        AddUser(user: User(), wallet: Wallet(accounts: [Account(bankName: "Tinkoff", balance: 1221, cashback: 212.31)]))
    }
}
