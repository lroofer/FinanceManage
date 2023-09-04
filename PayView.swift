//
//  PayView.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 02.09.2023.
//

import SwiftUI

struct PayView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var ops: UserTransactions
    let sum: Decimal
    let sumCash: Decimal
    let daysLeft: Int
    var sumLeft: Decimal {
        (sum - actualValue) / Decimal(daysLeft)
    }
    var sumCashLeft: Decimal {
        (sumCash - actualValue) / Decimal(daysLeft)
    }
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
                            Text(sumLeft.show())
                                .font(.largeTitle.bold())
                                .foregroundColor(sumLeft < 0 ? .red : .black)
                            Text("-> \(sumCashLeft.show())")
                                .font(.headline.bold())
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
                        DatePicker("Transaction time", selection: $selectedDate)
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
                        if errorMessage != nil {
                            Text(errorMessage!)
                                .foregroundColor(.red)
                                .font(.title.bold())
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
                            ops.all.append(Transaction(name: transactionName, category: cattegory, sum: actualValue, date: selectedDate))
                            ops.all.sort()
                            if let encoded = try? JSONEncoder().encode(ops) {
                                UserDefaults.standard.setValue(encoded, forKey: "transactions")
                                dismiss()
                            }
                            errorMessage = "Can't encode data"
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
        PayView(ops: UserTransactions(all: [Transaction]()), sum: 35007, sumCash: 2003, daysLeft: 30)
    }
}
