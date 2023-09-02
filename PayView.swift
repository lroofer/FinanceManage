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
        sum / Decimal(daysLeft)
    }
    var sumCashLeft: Decimal {
        sumCash / Decimal(daysLeft)
    }
    @State private var selectedDate = Date.now
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    if selectedDate.getDay() == Date.now.getDay() && selectedDate.getMonth() == Date.now.getMonth() && selectedDate.getYear() == Date.now.getYear() {
                        VStack(alignment: .leading) {
                            Text(selectedDate.getDay())
                                .font(.title.bold())
                            Text(selectedDate.getMonth())
                        }
                    } else {
                        VStack(alignment: .leading) {
                            Text("-")
                                .font(.title.bold())
                            Text("-")
                        }
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text(sumLeft.formatted(.currency(code: Locale.current.identifier)))
                            .font(.largeTitle.bold())
                        Text("-> \(sumCashLeft.formatted(.currency(code: Locale.current.identifier)))")
                            .font(.headline.bold())
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("Pay")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PayView_Previews: PreviewProvider {
    static var previews: some View {
        PayView(ops: UserTransactions(all: [Transaction]()), sum: 1007, sumCash: 2003, daysLeft: 10)
    }
}
