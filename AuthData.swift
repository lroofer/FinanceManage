//
//  AuthData.swift
//  FinanceManage
//
//  Created by Егор Колобаев on 12.09.2023.
//

import Foundation

struct AuthData: Codable {
    var passwordHash1: Int
    var passwordHash2: Int64
    var useBiometrics: Bool
    static private let mod1 = 1000000123;
    static private let base1 = 31;
    static private let base2 = 29;
    static func hasher(with password: Int) -> (Int, Int64){
        let pass = String(password)
        var b1 = 0
        var b2: Int64 = 0
        var p1 = 0
        var p2: Int64 = 0
        for i in pass {
            p1 = (p1 + Int(i.asciiValue!) * b1) % AuthData.mod1
            p2 += Int64(i.asciiValue!) * b2
            b1 = (b1 + AuthData.base1) % AuthData.mod1
            b2 *= Int64(AuthData.base2)
        }
        return (p1, p2)
    }
    init(password: Int) {
        let getHashed = AuthData.hasher(with: password)
        passwordHash1 = getHashed.0
        passwordHash2 = getHashed.1
        useBiometrics = false
    }
    func auth(with password: Int) -> Bool {
        let pass = String(password)
        var b1 = 0
        var b2: Int64 = 0
        var p1 = 0
        var p2: Int64 = 0
        for i in pass {
            p1 = (p1 + Int(i.asciiValue!) * b1) % AuthData.mod1
            p2 += Int64(i.asciiValue!) * b2
            b1 = (b1 + AuthData.base1) % AuthData.mod1
            b2 *= Int64(AuthData.base2)
        }
        return (p1, p2) == (passwordHash1, passwordHash2)
    }
}
