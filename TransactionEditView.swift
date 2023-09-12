//
//  TransactionEditView.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 05.09.2023.
//

import SwiftUI

struct TransactionEditView: View {
    @ObservedObject private var user: User
    @State var account: Account? = nil
    var ops: UserTransactions
    let sumTotal: Decimal
    let daysLeft: Int
    @Environment(\.dismiss) var dismiss
    private var id: UUID
    @State private var name: String
    @State private var category: String
    private var sum: Decimal {
        Decimal(writtenSum) / 100
    }
    private var reconsider: Decimal {
        (sumTotal - sum) / Decimal(daysLeft)
    }
    @State private var writtenSum: Int
    @State private var date: Date = .now
    @State private var alertShow = false
    @State private var alertMessage = ""
    @State private var paddingValue: CGFloat = 0
    private let opId: String
    private var accountSum: Decimal {
        (account?.balance ?? 0) - sum + initialValue
    }
    let initialValue: Decimal
    init(user: User, opId: String, ops: UserTransactions, sumTotal: Decimal, daysLeft: Int, id: UUID, name: String, category: String, writtenSum: Decimal, date: Date) {
        self.user = user
        self.ops = ops
        self.sumTotal = sumTotal
        self.daysLeft = daysLeft
        self.id = id
        self.opId = opId
        for i in user.wallet.accounts {
            if i.id.uuidString == opId {
                _account = State(initialValue: i)
            }
        }
        _name = State(initialValue: name)
        _category = State(initialValue: category)
        _writtenSum = State(initialValue: Int(truncating: writtenSum * 100 as NSDecimalNumber))
        self.initialValue = writtenSum
        self.date = date
    }
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        TextField("Transaction", text: $name)
                            .font(.title.bold())
                        Picker("Category", selection: $category) {
                            ForEach(Transaction.categories, id: \.self) { item in
                                HStack {
                                    Text(item)
                                    Image(systemName: "cart")
                                }
                            }
                        }
                    }
                    .disabled(account == nil)
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    }
                    .padding(8)
                    HStack {
                        TextFieldPro(value: $writtenSum)
                        Image(systemName: "rublesign")
                            .font(.title.bold())
                    }
                    .disabled(account == nil)
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    }
                    .padding(8)
                    DatePicker("Purchase time", selection: $date)
                        .disabled(account == nil)
                        .fontWeight(.bold)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        }
                        .padding(8)
                    HStack {
                        Text("Estimate: \(reconsider.show())")
                            .font(.headline)
                            .foregroundColor(reconsider < 0 ? .red : .primary)
                        Spacer()
                        if account != nil {
                            Text("\(account!.bankName) \(accountSum.show())")
                                .fontWeight(.bold)
                                .padding(8)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(accountSum > 0 ? account!.accentColor.get().opacity(0.5) : Color.red, lineWidth: 2)
                                }
                                .onTapGesture {
                                    alertMessage = "Can't change payment account yet"
                                    alertShow = true
                                }
                        } else {
                            Text("Archived account")
                                .fontWeight(.bold)
                                .padding(8)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.4), lineWidth: 2)
                                }
                                .onTapGesture {
                                    alertMessage = "Account was changed or deleted"
                                    alertShow = true
                                }
                        }
                    }
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    }
                    .alert(isPresented: $alertShow) {
                        Alert(title: Text(alertMessage))
                    }
                    .padding(8)
                    VStack {
                        Button("Delete", role: .destructive) {
                            for i in 0..<ops.all.count {
                                if ops.all[i].id == id {
                                    ops.all.remove(at: i)
                                    break
                                }
                            }
                            ops.all.sort()
                            if account != nil {
                                for i in 0..<user.wallet.accounts.count {
                                    if user.wallet.accounts[i].id == account!.id {
                                        user.wallet.accounts[i].balance += initialValue
                                    }
                                }
                                if let encoded = try? JSONEncoder().encode(user) {
                                    UserDefaults.standard.set(encoded, forKey: "user")
                                }
                            }
                            if let encoded = try? JSONEncoder().encode(ops.all) {
                                UserDefaults.standard.set(encoded, forKey: "transactions")
                                dismiss()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(paddingValue)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red.opacity(CGFloat((10 - paddingValue) / 10)), lineWidth: 2)
                        }
                        .onAppear {
                            withAnimation(Animation.easeIn(duration: 2).repeatForever(autoreverses: false)) {
                                paddingValue = 10
                            }
                        }
                    }
                    .frame(width: 200, height: 50)
                    
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button("Apply") {
                            if accountSum < 0 {
                                alertMessage = "Not enough money on the account"
                                alertShow = true
                                return
                            }
                            if sum == 0 {
                                alertMessage = "Purchase can't be free! Delete it"
                                alertShow = true
                                return
                            }
                            if account != nil {
                                for i in 0..<user.wallet.accounts.count {
                                    if user.wallet.accounts[i].id == account!.id {
                                        user.wallet.accounts[i].balance = accountSum
                                    }
                                }
                                if let encoded = try? JSONEncoder().encode(user) {
                                    UserDefaults.standard.set(encoded, forKey: "user")
                                }
                            }
                            for i in 0..<ops.all.count {
                                if ops.all[i].id == id {
                                    ops.all[i].name = name
                                    ops.all[i].category = category
                                    ops.all[i].sum = sum
                                    ops.all[i].date = date
                                }
                            }
                            ops.all.sort()
                            if let encoded = try? JSONEncoder().encode(ops.all) {
                                UserDefaults.standard.set(encoded, forKey: "transactions")
                                dismiss()
                            }
                        }
                        .disabled(account == nil)
                    }
            }
            }
        }
    }
}

struct TransactionEditView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionEditView(user: User(), opId: "test3", ops: UserTransactions(), sumTotal: 13005, daysLeft: 30, id: UUID(), name: "Ozon", category: "Shop", writtenSum: 351, date: .now)
    }
}
