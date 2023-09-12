//
//  UserInfoView.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 09.09.2023.
//

import SwiftUI

struct UserInfoView: View {
    @ObservedObject var user: User
    
    @State private var userName = "User"
    @State private var inflow: Date = .now
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                TextField("Name", text: $userName)
                    .titleStyle()
                    .font(.largeTitle.bold())
                    .padding()
                DatePicker("Inflow date", selection: $inflow)
                    .datePickerStyle(.graphical)
                    .titleStyle()
                    .padding()
                Button("Update") {
                    user.name = userName
                    user.inflow = inflow
                    if let encoded = try? JSONEncoder().encode(user) {
                        UserDefaults.standard.set(encoded, forKey: "user")
                    }
                }
                .disabled(userName.isEmpty)
            }
            .onAppear {
                userName = user.name ?? "User"
                inflow = user.inflow
            }
            .navigationTitle("User data")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct UserInfoView_Previews: PreviewProvider {
    static var previews: some View {
        UserInfoView(user: User(name: "Yegor", wallet: Wallet(accounts: [Account]()), inflow: Date.now, auth: AuthData(password: 1234)))
    }
}
