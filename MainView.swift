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
        .frame(width: 180, height: 115)
        .background(.thickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct MainView: View {
    @ObservedObject var user: User
    
    @StateObject var ops = UserTransactions()
    @StateObject var wallet = Wallet(accounts: [Account(bankName: "", balance: 0, cashback: 0, accentColor: .init(stored: .red))])

    @State private var today = Date.now
    @State private var showPay = false
    @State private var selectedTrans = Transaction(name: "", category: "", sum: 12, date: Date.now, transactionID: "test")
    @State private var showTrans = false
    @State private var showAddAccount = false
    @State private var shareShow = false
    
    private var daysLeft: Int {
        let dT = today.get(.day)
        var dD = user.inflow.get(.day)
        let dMonth = getDaysInMonth()
        dD = min(dD, dMonth)
        return (dT <= dD ? dD - dT + 1 : dMonth - dT + 1 + dD)
    }
    private var daily: Decimal {
        var sum: Decimal = 0
        for i in user.wallet.accounts {
            sum += i.balance
        }
        return sum / Decimal(daysLeft)
    }
    
    private var dailyTop: Decimal {
        var sum: Decimal = 0
        for i in user.wallet.accounts {
            sum += i.balance + i.cashback
        }
        return sum / Decimal(daysLeft)
    }
    private var total: Decimal {
        var sum: Decimal = 0
        for i in user.wallet.accounts {
            sum += i.balance
        }
        return sum
    }
    private var totalCash: Decimal {
        var sum: Decimal = 0
        for i in user.wallet.accounts {
            sum += i.cashback
        }
        return sum
    }
    private func getAccounts() -> [(String, Decimal)] {
        var ans = [(String, Decimal)]()
        for i in user.wallet.accounts {
            ans.append((i.bankName, i.balance))
        }
        return ans
    }
    private func handle(for data: Transaction) {
        selectedTrans = data
        showTrans.toggle()
    }
    var body: some View {
        let _ = self.selectedTrans
        ZStack {
            LinearGradient(colors: [.teal, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            GeometryReader { geom in
                ScrollView (showsIndicators: true) {
                    VStack (alignment: .center) {
                        HStack {
                            VStack(alignment: .leading) {
                                HStack(spacing: 5) {
                                    Text("\(daily.show())")
                                    Image(systemName: "rublesign")
                                        .font(.title.bold())
                                }
                                .font(.largeTitle.bold())
                                HStack(spacing: 2) {
                                    Text("\(dailyTop.show())")
                                    Image(systemName: "rublesign")
                                        .font(.caption)
                                }
                                .font(.body)
                            }
                            Spacer()
                            NavigationLink(destination: UserInfoView(user: user)) {
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
                        .padding(.horizontal, 8)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach($user.wallet.accounts) { account in
                                    VStack(alignment: .leading) {
                                        Text(account.bankName.wrappedValue)
                                            .font(.title2.bold())
                                        HStack (spacing: 3) {
                                            Text("\(account.balance.wrappedValue.show())")
                                                .font(.headline)
                                            Image(systemName: "rublesign")
                                                .font(.subheadline)
                                        }
                                        HStack (spacing: 1) {
                                            Text("+ \(account.cashback.wrappedValue.show())")
                                                .font(.subheadline)
                                            Image(systemName: "rublesign")
                                                .font(.caption)
                                        }
                                    }
                                    .frame(width: 180, height: 120)
                                    .background(account.accentColor.wrappedValue.get().opacity(0.7))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding(.leading, 8)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.primary.opacity(0.7), lineWidth: 2)
                                            .padding(.leading, 8)
                                    }
                                }
                                Button {
                                    showAddAccount.toggle()
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
                        .sheet(isPresented: $showAddAccount) {
                            AddAccount(user: user)
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack (spacing: 15) {
                                Tile(first: "In \(daysLeft)", second: "day\(daysLeft == 1 ? "" : "s") is inflow")
                                    .padding(.leading, 8)
                                Tile(first: total.show(), second: "total")
                                Tile(first: totalCash.show(), second: "cashback")
                                    .padding(.trailing, 8)
                            }
                        }
                        .padding(.bottom)
                        HStack (spacing: 15) {
                            Button {
                                shareShow.toggle()
                            } label: {
                                Tile(first: "Inflow", second: "in")
                            }
                            Button {
                                showPay.toggle()
                            } label: {
                                Tile(first: "Pay", second: "Add item")
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
                                    VStack(alignment: .leading) {
                                        Text(trans.name)
                                            .font(.title2.bold())
                                        Text(trans.category)
                                            .font(.headline)
                                        if (trans.date.get(.day, .month, .year) == Date.now.get(.day, .month, .year)) {
                                            Text(trans.date.formatted(date: .omitted, time: .shortened))
                                        } else {
                                            Text(trans.date.formatted(date: .abbreviated, time: .omitted))
                                        }
                                    }
                                    Spacer()
                                    VStack {
                                        Text(trans.sum.show())
                                            .font(.title3.bold())
                                    }
                                }
                                .padding()
                                .background()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.horizontal, 8)
                                .onTapGesture {
                                    handle(for: trans)
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showPay) {
                PayView(user: user, ops: ops, sum: total, sumCash: totalCash, daysLeft: daysLeft, accountId: user.wallet.accounts[0].id)
            }
            .sheet(isPresented: $showTrans) {
                TransactionEditView(user: user, opId: selectedTrans.transactionID ,ops: ops, sumTotal: total, daysLeft: daysLeft, id: selectedTrans.id, name: selectedTrans.name, category: selectedTrans.category, writtenSum: selectedTrans.sum, date: selectedTrans.date)
            }
            .sheet(isPresented: $shareShow) {
                InflowView(user: user)
            }
            .navigationBarBackButtonHidden()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(user: User(name: "Yegor", wallet: Wallet(accounts: [Account(bankName: "Tinkoff", balance: 36000, cashback: 1741, accentColor: .init(stored: .green))]), inflow: Date.now, auth: AuthData(password: 1234)), ops: UserTransactions(all: [Transaction(name: "Пятерочка", category: "Supermarket", sum: 2124, date: Date.now, transactionID: "test1"), Transaction(name: "Ozon", category: "Home", sum: 95, date: Date.now, transactionID: "test2"), Transaction(name: "Transfer", category: "Transitions", sum: 1000, date: Date.now, transactionID: "test4")]))
    }
}
