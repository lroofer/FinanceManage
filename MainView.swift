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

struct Tile: View {
    var first: String
    var second: String
    var body: some View {
        VStack {
            Text(first)
                .font(.largeTitle.bold())
            Text(second)
                .font(.headline)
        }
        .frame(width: 115, height: 115)
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct MainView: View {
    @ObservedObject var user: User
    @StateObject var ops = UserTransactions()
    @State private var today = Date.now
    @State private var showPay = false
    private var daysLeft: Int {
        let dT = today.get(.day)
        var dD = user.inflow?.get(.day) ?? 12
        let dMonth = getDaysInMonth()
        dD = min(dD, dMonth)
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
    private var total: Decimal {
        var sum: Decimal = 0
        if user.wallet == nil {
            return 143
        }
        for i in user.wallet!.accounts {
            sum += i.balance
        }
        return sum
    }
    private var totalCash: Decimal {
        var sum: Decimal = 0
        if user.wallet == nil {
            return 143
        }
        for i in user.wallet!.accounts {
            sum += i.cashback
        }
        return sum
    }
    var body: some View {
        ZStack {
            LinearGradient(colors: [.teal, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            GeometryReader { geom in
                ScrollView (showsIndicators: true) {
                    VStack (alignment: .center) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(daily.show()) rubles")
                                    .font(.largeTitle.bold())
                                Text("\(dailyTop.show()) rubles")
                                    .font(.body)
                            }
                            Spacer()
                            Button {
                                
                            } label: {
                                VStack(spacing: 10) {
                                    Image(systemName: "person")
                                    Text(user.name ?? "Yegor")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(user.wallet?.accounts ?? [Account]()) { bank in
                                    VStack(alignment: .leading) {
                                        Text(bank.bankName)
                                            .font(.title2.bold())
                                        Text("\(bank.balance.show()) ruble\(bank.balance == 1 ? "" : "s")")
                                            .font(.headline)
                                        Text("+ \(bank.cashback.show()) ruble\(bank.cashback == 1 ? "" : "s")")
                                            .font(.subheadline)
                                    }
                                    .frame(width: 120, height: 120)
                                    .background(.thickMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(.leading)
                                }
                                Button {
                                    
                                } label: {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .padding(10)
                                        .background(.thickMaterial)
                                        .foregroundColor(.secondary)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .padding(.horizontal)
                                }
                            }
                            
                        }
                        .padding(.vertical)
                        HStack (spacing: 15) {
                            Tile(first: "In \(daysLeft)", second: "day\(daysLeft == 1 ? "" : "s") is inflow")
                            Tile(first: total.show(), second: "total")
                            Tile(first: totalCash.show(), second: "cashback")
                        }
                        .padding(.bottom)
                        HStack (spacing: 15) {
                            Button {
                                
                            } label: {
                                Tile(first: "Upd", second: "Cashback")
                            }
                            Button {
                                showPay.toggle()
                            } label: {
                                Tile(first: "Pay", second: "Add item")
                            }
                            Button {
                                
                            } label: {
                                Tile(first: "Coin", second: "Transfer")
                            }
                        }
                        .padding(.bottom)
                        LazyVStack(alignment: .leading) {
                            ForEach(ops.all) { trans in
                                HStack {
                                    Image(systemName: "cart")
                                        .resizable()
                                        .frame(width: geom.size.width * 0.1, height: geom.size.width * 0.1)
                                        .padding(10)
                                        .background(.regularMaterial)
                                        .foregroundColor(.green)
                                        .clipShape(RoundedRectangle(cornerRadius: 30))
                                    VStack {
                                        Text(trans.name)
                                            .font(.title2.bold())
                                        Text(trans.category)
                                            .font(.headline)
                                    }
                                    Spacer()
                                    VStack {
                                        Text(trans.sum.show())
                                            .font(.title3.bold())
                                        Text("+ \(trans.cashback?.show() ?? "N")")
                                    }
                                }
                                .padding()
                                .background()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showPay) {
                PayView(ops: ops, sum: total, sumCash: totalCash, daysLeft: daysLeft)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(user: User(name: "Yegor", wallet: Wallet(accounts: [Account(bankName: "Tinkoff", balance: 17, cashback: 12)]), inflow: Date.now), ops: UserTransactions(all: [Transaction(name: "Пятерочка", category: "Supermarket", sum: 124, cashback: 10), Transaction(name: "Ozon", category: "Home", sum: 95), Transaction(name: "Transfer", category: "Transitions", sum: 100)]))
    }
}
