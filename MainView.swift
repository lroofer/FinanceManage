//
//  MainView.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 02.09.2023.
//

import SwiftUI

func getDaysInMonth() -> Int{
    let calendar = Calendar.current
    let dateComponents = DateComponents(year: calendar.component(.year, from: Date.now), month: calendar.component(.month, from: Date.now))
    let date = calendar.date(from: dateComponents)!
    let range = calendar.range(of: .day, in: .month, for: date)!
    let numDays = range.count
    return numDays
}

struct MainView: View {
    @ObservedObject var user: User
    @State private var today = Date.now
    private var daysLeft: Int {
        let dT = Int(today.formatted(date: .numeric, time: .omitted).split(separator: "/")[1]) ?? 1
        let dD = Int(user.inflow?.formatted(date: .numeric, time: .omitted).split(separator: "/")[1] ?? "0") ?? 12
        let dMonth = getDaysInMonth()
        return (dT <= dD ? dD - dT + 1 : dMonth - dT + 1 + dD)
    }
    private var daily: Decimal {
        var sum: Decimal = 0
        if user.wallet == nil {
            return 143
        }
        for i in user.wallet!.accounts {
            sum += i.balance
        }
        return sum / Decimal(daysLeft)
    }
    
    private var dailyTop: Decimal {
        var sum: Decimal = 0
        if user.wallet == nil {
            return 143
        }
        for i in user.wallet!.accounts {
            sum += i.balance + i.cashback
        }
        return sum / Decimal(daysLeft)
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(daily.formatted()) rubles")
                        .font(.largeTitle.bold())
                    Text("\(dailyTop.formatted()) rubles")
                        .font(.body)
                }
                Spacer()
                Button(user.name ?? "Yegor") {
                    
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(user: User(name: "Yegor", wallet: Wallet(accounts: [Account(bankName: "Tinkoff", balance: 17, cashback: 12)]), inflow: Date.now))
    }
}
