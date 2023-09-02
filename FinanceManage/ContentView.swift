//
//  ContentView.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 31.08.2023.
//

import SwiftUI

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
    @StateObject private var wallet = Wallet()
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [.teal, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                VStack(alignment: .leading) {
                    GeometryReader { geom in
                        VStack (alignment: .leading) {
                            if (user.name != nil) {
                                NavigationLink(destination: MainView(user: user).navigationBarBackButtonHidden()) {
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
                                    }
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
