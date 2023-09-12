//
//  ContentView.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 31.08.2023.
//

import SwiftUI
import Combine
import LocalAuthentication

struct ContentView: View {
    @StateObject private var user = User() {
        didSet {
            if let encoded = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(encoded, forKey: "user")
            }
        }
    }
    @State private var userName = ""
    @State private var addUser = false
    @State private var password = ""
    @State private var isUnlocked = false
    
    @StateObject private var wallet = Wallet()
    
    func auth() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "We need to lock your data"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if success {
                    isUnlocked = true
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.teal, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                VStack(alignment: .leading) {
                    GeometryReader { geom in
                        VStack (alignment: .leading) {
                            if (user.name != nil) {
                                VStack (alignment: .center) {
                                    VStack(spacing: 20) {
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .frame(width: geom.size.width * 0.1, height: geom.size.width * 0.1)
                                        Text(user.name ?? "N/A")
                                            .font(.headline)
                                    }
                                    .frame(width: geom.size.width * 0.3, height: geom.size.width * 0.3)
                                    .background()
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .onAppear {
                                        if let encoded = try? JSONEncoder().encode(user) {
                                            UserDefaults.standard.set(encoded, forKey: "user")
                                        }
                                        if user.auth.useBiometrics {
                                            auth()
                                        }
                                    }
                                    VStack {
                                        SecureField("Enter password", text: $password)
                                            .keyboardType(.decimalPad)
                                            .onReceive(Just(password)) { newValue in
                                                let filtered = newValue.filter { "0123456789".contains($0) }
                                                if filtered != newValue {
                                                    self.password = filtered
                                                }
                                            }
                                        Button("Sign in") {
                                            if user.auth.auth(with: Int(password)!) {
                                                isUnlocked = true
                                            }
                                        }
                                        .disabled(password.count < 4 || password.count > 6)
                                    }
                                    .padding()
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.secondary.opacity(0.5), lineWidth: 2)
                                    }
                                    .padding()
                                }
                            } else {
                                VStack(spacing: 20) {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .frame(width: geom.size.width * 0.1, height: geom.size.width * 0.1)
                                }
                                .frame(width: geom.size.width * 0.3, height: geom.size.width * 0.3)
                                .background()
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .onTapGesture {
                                    addUser.toggle()
                                }
                            }
                        }
                        .frame(width: geom.size.width * 0.9, height: geom.size.height * 0.75)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding([.horizontal, .top])
                    }
                }
                .sheet(isPresented: $addUser) {
                    AddUser(user: user)
                }
            }
            .navigationTitle("Finance Control")
            .navigationDestination(isPresented: $isUnlocked) {
                MainView(user: user)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
