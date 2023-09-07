//
//  PayView.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 02.09.2023.
//

import SwiftUI

struct PayView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var user: User
    @ObservedObject var ops: UserTransactions
    let sum: Decimal
    let sumCash: Decimal
    let daysLeft: Int
    var sumLeft: Decimal {
        (sum / Decimal(daysLeft)) - actualValue
    }
    var sumCashLeft: Decimal {
        ((sumCash + sum) / Decimal(daysLeft)) - actualValue
    }
    var reconsider: Decimal {
        (sum - actualValue) / Decimal(daysLeft)
    }
    @State var accountId: UUID
    @State private var selectedDate = Date.now
    @State private var valueSum = 0
    @State private var transactionName = "State shop"
    @State private var cattegory = Transaction.categories[0]
    @State private var errorMessage: String? = nil
    private var actualValue: Decimal {
        Decimal(valueSum) / 100
    }
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        VStack {
                            if selectedDate.get(.day, .month, .year) == Date.now.get(.day, .month, .year) {
                                Text("\(selectedDate.get(.day))")
                                    .font(.title.bold())
                                Text(selectedDate.get(.month).convertToMonth())
                            } else {
                                Image(systemName: "clock.badge.questionmark")
                                    .resizable()
                                    .frame(width: 45, height: 40)
                                
                            }
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            if selectedDate.get(.day, .month, .year) == Date.now.get(.day, .month, .year) {
                                Text(sumLeft.show())
                                    .font(.largeTitle.bold())
                                    .foregroundColor(sumLeft < 0 ? .red : .primary)
                                Text("-> \(sumCashLeft.show())")
                                    .font(.headline.bold())
                            } else {
                                Text(reconsider.show())
                                    .font(.largeTitle.bold())
                                    .foregroundColor(reconsider < 0 ? .red : .primary)
                                Text("new estimate for today")
                                    .font(.headline.bold())
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    VStack {
                        HStack {
                            TextFieldPro(value: $valueSum)
                            Image(systemName: "rublesign")
                        }
                        .padding(20)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        }
                        .frame(height: 100)
                        .font(.largeTitle.bold())
                        DatePicker("Purchase time", selection: $selectedDate)
                            .fontWeight(.bold)
                            .padding(10)
                            .overlay {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                            }
                        HStack {
                            TextField("Name", text: $transactionName)
                            Picker("Category", selection: $cattegory) {
                                ForEach(Transaction.categories, id:\.self) { item in
                                    HStack {
                                        Image(systemName: "cart")
                                        Rectangle()
                                            .frame(width:50, height: 0)
                                        Text(item)
                                    }
                                }
                            }
                        }
                        .fontWeight(.bold)
                        .padding(10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        }
                        HStack {
                            Text("Account")
                            Spacer()
                            Picker("Account", selection: $accountId) {
                                ForEach(user.wallet!.accounts) { item in
                                    Text("\(item.bankName) \(item.balance.show())")
                                }
                            }
                            .fontWeight(.bold)
                            .padding(5)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                            }
                        }
                        .fontWeight(.bold)
                        .padding(10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        }
                        if errorMessage != nil {
                            Text(errorMessage!)
                                .foregroundColor(.red)
                                .font(.title.bold())
                        }
                        if sumLeft < 0 && reconsider > 0 && selectedDate.get(.day, .month, .year) == Date.now.get(.day, .month, .year)  {
                            Text("New goal: \(reconsider.show())")
                                .foregroundColor(.red)
                                .font(.title.bold())
                        } else if sumLeft < 0 && reconsider <= 0 {
                            Text("Out of money")
                                .foregroundColor(.red)
                                .font(.title.bold())
                                .padding(10)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.red.opacity(0.6), lineWidth: 2)
                                }
                        }
                    }
                    .padding(10)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button("Pay") {
                            errorMessage = nil
                            if (reconsider < 0) {
                                return
                            }
                            if actualValue == 0 {
                                errorMessage = "Can't be zero"
                                return
                            }
                            var accountBalance: Decimal = 0
                            for item in user.wallet!.accounts {
                                if item.id == accountId {
                                    accountBalance = item.balance
                                    break
                                }
                            }
                            if accountBalance < actualValue {
                                errorMessage = "Not enough money on the balance of selected account"
                                return
                            }
                            for item in user.wallet!.accounts {
                                if item.id == accountId {
                                    item.balance -= actualValue
                                    break
                                }
                            }
                            if let encoded = try? JSONEncoder().encode(user) {
                                UserDefaults.standard.setValue(encoded, forKey: "user")
                            } else {
                                fatalError("Cannot encode user")
                            }
                            ops.all.append(Transaction(name: transactionName, category: cattegory, sum: actualValue, date: selectedDate, transactionID: accountId.uuidString))
                            ops.all.sort()
                            if let encoded = try? JSONEncoder().encode(ops.all) {
                                UserDefaults.standard.setValue(encoded, forKey: "transactions")
                                dismiss()
                            } else {
                                errorMessage = "Can't encode data"
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .navigationTitle("Add new payment")
            .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct PayView_Previews: PreviewProvider {
    static var previews: some View {
        PayView(user: User(name: "Yegor", wallet: Wallet(accounts: [Account(bankName: "Tinkoff", balance: 13232, cashback: 123, accentColor: .init(stored: .yellow)), Account(bankName: "Alfa", balance: 141000, cashback: 1221, accentColor: .init(stored: .yellow))]), inflow: Date.now), ops: UserTransactions(all: [Transaction]()), sum: 35007, sumCash: 2003, daysLeft: 30, accountId: Account(bankName: "Tinkoff", balance: 13232, cashback: 123, accentColor: .init(stored: .blue)).id)
    }
}
